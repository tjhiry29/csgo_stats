import { groupBy } from "./util";

const GRENADE_WEAPONS = [
  "weapon_hegrenade",
  "weapon_molotov",
  "weapon_incgrenade",
  "weapon_flashbang",
  "weapon_smokegrenade"
];

const setBasicEventInfo = (event, demoFile, mapName, roundNum) => {
  return Object.assign({}, event, {
    map_name: mapName,
    tick: demoFile.currentTick,
    time_elapsed: demoFile.current_time,
    round: roundNum
  });
};

const setGrenadeDetonationInfo = (grenadeThrow, e) => {
  return Object.assign({}, grenadeThrow, {
    location: { x: e.x, y: e.y, z: e.z },
    detonated: true
  });
};

const setKillInfo = (e, demoFile) => {
  const victim = demoFile.entities.getByUserId(e.userid);
  const victimName = victim ? victim.name : "unnamed";
  const victimPosition = victim
    ? victim.position
    : { x: null, y: null, z: null };
  const attacker = demoFile.entities.getByUserId(e.attacker);
  const attackerName = attacker ? attacker.name : "unnamed";
  const attackerPosition = attacker
    ? attacker.position
    : { x: null, y: null, z: null };
  const assister = demoFile.entities.getByUserId(e.assister);
  const assisterName = assister ? assister.name : "unnamed";
  const assisterPosition = assister
    ? assister.position
    : { x: null, y: null, z: null };
  return Object.assign({}, e, {
    attacker_userid: e.attacker,
    attacker_name: attackerName,
    attacker_position: attackerPosition,
    victim_userid: e.userid,
    victim_name: victimName,
    victim_position: victimPosition,
    assister_userid: e.assister,
    assister_name: assisterName,
    assister_position: assisterPosition,
    first_of_round: false,
    trade: false
  });
};

const createTeams = teams => {
  return teams.map(team => {
    return {
      score: team.score,
      rounds_won: team.score,
      teamnum: team.teamNumber,
      team_name: team.teamName,
      team_number: team.teamNumber,
      players: team.members.map(player => {
        return {
          name: player.name,
          userid: player.userId
        };
      })
    };
  });
};

const createMatchStats = players => {
  let matchStats = {};
  players.forEach(player => {
    const playerStats = player.matchStats.map((stat, idx) => {
      return Object.assign({}, stat, {
        name: player.name,
        userid: player.userId,
        round: idx + 1,
        dead: stat.deaths >= 1,
        total_damage_dealt: stat.damage,
        teamnum: player.teamNumber,
        traded: false
      });
    });
    matchStats[player.userId] = playerStats;
  });
  return matchStats;
};

const createPlayers = (players, mapName, teams) => {
  return players.map(player => {
    return {
      name: player.name,
      userid: player.userId,
      map_name: mapName,
      kill_count: player.kills,
      death_count: player.deaths,
      assist_count: player.assists,
      headshot_count: 0,
      headshot_percentage: 0.0,
      kill_death_ratio: player.kills / player.deaths,
      adr: 0.0,
      trade_kills: 0,
      deaths_traded: 0,
      first_deaths: 0,
      first_kills: 0,
      kast: 0,
      rounds_played: teams[2].score + teams[3].score,
      won:
        teams[player.teamNumber].score >
        teams[player.teamNumber == 2 ? 2 : 3].score,
      tie: teams[2].score == teams[3].score,
      teamnum: player.teamNumber,
      xuid: player.userInfo.xuid.toString(),
      guid: player.userInfo.guid,
      friends_id: player.userInfo.friendsId
    };
  });
};

const findTradeKills = (kills, kill, tickRate) => {
  return kills.map(k => {
    if (
      k.userid == kill.attacker &&
      k.tick >= kill.tick &&
      k.tick <= kill.tick + 5 * tickRate
    ) {
      k.trade = true;
      k.killTraded = kill;
    }
    return k;
  });
};

const processKills = (kills, tickRate) => {
  const killsByRound = groupBy(kills, "round");
  let finalKills = [];
  Object.keys(killsByRound).forEach(key => {
    let kills = killsByRound[key];
    let sortedKills = kills.sort((k1, k2) => k1.tick - k2.tick);
    sortedKills[0].first_of_round = true;
    let resultKills = sortedKills;
    sortedKills.forEach(kill => {
      resultKills = findTradeKills(resultKills, kill, tickRate);
    });
    finalKills.push(resultKills);
  });
  return finalKills.flat();
};

const getPlayersById = players => {
  return players.reduce(function(acc, obj) {
    var key = obj["userid"];
    if (!acc[key]) {
      acc[key] = [];
    }
    acc[key] = obj;
    return acc;
  }, {});
};

const killStats = (kills, playersById, playerRoundRecords) => {
  kills.forEach(kill => {
    const attacker = playersById[kill.attacker_userid];
    const victim = playersById[kill.victim_userid];

    if (kill.headshot) {
      attacker.headshot_count++;
    }
    if (kill.first_of_round) {
      attacker.first_kills++;
      victim.first_deaths++;
    }
    if (kill.trade) {
      attacker.trade_kills++;
      if (kill.killTraded) {
        const tradedPlayer = playersById[kill.killTraded.victim_userid];
        tradedPlayer.deaths_traded++;
        let idx = playerRoundRecords[kill.round - 1].findIndex(
          p => p.userid == tradedPlayer.userid
        );
        playerRoundRecords[kill.round - 1][idx].traded = true;
        playersById[tradedPlayer.userid] = tradedPlayer;
      }
    }
    playersById[kill.attacker_userid] = attacker;
    playersById[kill.victim_userid] = victim;
  });
  return [playersById, playerRoundRecords];
};

const aggreggateStats = (playersById, playerRoundRecords) => {
  let playerRoundRecordsById = {};
  playerRoundRecords.forEach(roundRecords => {
    roundRecords.forEach(record => {
      if (!playerRoundRecordsById[record.userid]) {
        playerRoundRecordsById[record.userid] = [];
      }
      playerRoundRecordsById[record.userid].push(record);
    });
  });
  Object.keys(playersById).forEach(id => {
    const player = playersById[id];
    const stats = playerRoundRecordsById[id];
    const total_damage_dealt = stats.reduce((acc, stat) => {
      return acc + stat.total_damage_dealt;
    }, 0);
    const adr = total_damage_dealt / stats.length;
    const kast_score = stats.reduce((acc, stat) => {
      if (!stat.dead || stat.kills >= 1 || stat.assists >= 1 || stat.traded) {
        acc++;
      }
      return acc;
    }, 0);
    player.headshot_percentage = player.headshot_count / player.kill_count;
    player.kast = kast_score / stats.length;
    player.adr = adr;
    playersById[player.userid] = player;
  });
  return playersById;
};

const onFileUploaded = (file, onEnd) => {
  let reader = new FileReader();

  reader.onloadend = evt => {
    if (evt.target.readyState == FileReader.DONE) {
      let buffer = reader.result;
      outputDemoInfo(buffer, onEnd, file);
    } else {
      // TODO: error state
    }
  };

  reader.readAsArrayBuffer(file);
};

const outputDemoInfo = (buffer, onEnd, file) => {
  let demoFile = new demofile.DemoFile();
  let mapName, tickRate, playbackTicks;
  let roundNum = 0;
  let playerRoundRecords = [],
    kills = [],
    grenadeThrows = [],
    grenadeDetonations = [],
    playerDamaged = [],
    roundWins = [],
    playerInfo = [];

  demoFile.on("start", () => {
    tickRate = demoFile.tickRate;
    mapName = demoFile.header.mapName;
    playbackTicks = demoFile.playbackTicks;
  });

  demoFile.stringTables.on("update", e => {
    if (e.table.name === "userinfo" && e.userData != null) {
      console.log("\nPlayer info updated:");
      console.log(e.entryIndex, e.userData);
      playerInfo.push(e.userData);
    }
  });

  demoFile.gameEvents.on("round_announce_match_start", () => {
    roundNum++;
    let players = demoFile.entities.players;
    players = players.map(player => {
      return {
        round: roundNum,
        name: player.name,
        userid: player.userId,
        health: 100,
        dead: false,
        traded: false,
        total_damage_dealt: 0.0,
        teamnum: player.teamNumber,
        kills: 0,
        assists: 0
      };
    });
    playerRoundRecords.push(players);
  });

  demoFile.gameEvents.on("round_end", e => {
    roundWins.push(e);
  });

  demoFile.gameEvents.on("round_start", e => {
    let players = demoFile.entities.players;
    players = players.map(player => {
      return {
        round: roundNum,
        name: player.name,
        userid: player.userId,
        health: 100,
        dead: false,
        traded: false,
        total_damage_dealt: 0.0,
        teamnum: player.teamNumber,
        kills: 0,
        assists: 0
      };
    });
    playerRoundRecords.push(players);
  });

  demoFile.gameEvents.on("round_officially_ended", e => {
    let teams = demoFile.teams;

    let terrorists = teams[demofile.TEAM_TERRORISTS];
    let cts = teams[demofile.TEAM_CTS];
    console.log(
      "\tTerrorists: %s score %d\n\tCTs: %s score %d",
      terrorists.clanName,
      terrorists.score,
      cts.clanName,
      cts.score
    );
    roundNum++;
  });

  demoFile.gameEvents.on("weapon_fire", e => {
    if (GRENADE_WEAPONS.includes(e.weapon) && roundNum != 0) {
      const user = demoFile.entities.getByUserId(e.userid);
      e = setBasicEventInfo(e, demoFile, mapName, roundNum);
      e.origin = user.position;
      e.facing = user.eyeAngles;
      e.damage_dealt = 0;
      e.blind_duration = 0;
      e.detonated = false;
      e.expired = false;
      grenadeThrows.push(e);
    }
  });

  demoFile.gameEvents.on("player_hurt", e => {
    if (e.weapon == "hegrenade") {
      e = setBasicEventInfo(e, demoFile, mapName, roundNum);
      let idx = grenadeThrows.findIndex(
        gt =>
          gt.weapon == "weapon_hegrenade" &&
          gt.round == roundNum &&
          gt.userid == e.attacker &&
          gt.detonated
      );
      if (idx != -1) {
        let grenadeThrow = grenadeThrows[idx];
        grenadeThrow.damage_dealt += e.dmg_health;
        grenadeThrows[idx] = grenadeThrow;
      }
    }
    if (e.weapon == "inferno") {
      e = setBasicEventInfo(e, demoFile, mapName, roundNum);
      let idx = grenadeThrows.findIndex(
        gt =>
          (gt.weapon == "weapon_molotov" || gt.weapon == "weapon_incgrenade") &&
          gt.round == roundNum &&
          gt.userid == e.attacker &&
          !gt.expired
      );
      if (idx != -1) {
        let grenadeThrow = grenadeThrows[idx];
        grenadeThrow.damage_dealt += e.dmg_health;
        grenadeThrows[idx] = grenadeThrow;
      }
    }
    const victimIdx = playerRoundRecords[roundNum - 1].findIndex(
      p => p.userid == e.userid
    );
    const victim = playerRoundRecords[roundNum - 1][victimIdx];
    const attackerIdx = playerRoundRecords[roundNum - 1].findIndex(
      p => p.userid == e.attacker
    );
    const attacker = playerRoundRecords[roundNum - 1][attackerIdx];
    let dmg_dealt = e.dmg_health;
    const health = victim ? victim.health : 0;
    let new_health = health - e.dmg_health;
    if (new_health < 0) {
      new_health = 0;
      dmg_dealt = health;
    }
    if (victim) {
      victim.health = new_health;
      playerRoundRecords[roundNum - 1][victimIdx] = victim;
    }
    if (attacker) {
      attacker.total_damage_dealt += parseInt(dmg_dealt);
      playerRoundRecords[roundNum - 1][attackerIdx] = attacker;
    }

    playerDamaged.push(e);
  });

  demoFile.gameEvents.on("flashbang_detonate", e => {
    e = setBasicEventInfo(e, demoFile, mapName, roundNum);
    grenadeDetonations.push(e);
    let idx = grenadeThrows.findIndex(
      gt =>
        gt.weapon == "weapon_flashbang" &&
        gt.round == roundNum &&
        gt.userid == e.userid
    );
    if (idx != -1) {
      let grenadeThrow = grenadeThrows[idx];
      grenadeThrow = setGrenadeDetonationInfo(grenadeThrow, e);
      grenadeThrows[idx] = grenadeThrow;
    }
  });

  demoFile.gameEvents.on("smokegrenade_detonate", e => {
    e = setBasicEventInfo(e, demoFile, mapName, roundNum);
    grenadeDetonations.push(e);
    let idx = grenadeThrows.findIndex(
      gt =>
        gt.weapon == "weapon_smokegrenade" &&
        gt.round == roundNum &&
        !gt.detonated
    );
    if (idx != -1) {
      let grenadeThrow = grenadeThrows[idx];
      grenadeThrow = setGrenadeDetonationInfo(grenadeThrow, e);
      grenadeThrows[idx] = grenadeThrow;
    }
  });

  demoFile.gameEvents.on("inferno_startburn", e => {
    e = setBasicEventInfo(e, demoFile, mapName, roundNum);
    grenadeDetonations.push(e);
    let idx = grenadeThrows.findIndex(
      gt =>
        (gt.weapon == "weapon_molotov" || gt.weapon == "weapon_incgrenade") &&
        gt.round == roundNum &&
        !gt.detonated
    );
    if (idx != -1) {
      let grenadeThrow = grenadeThrows[idx];
      grenadeThrow = setGrenadeDetonationInfo(grenadeThrow, e);
      grenadeThrows[idx] = grenadeThrow;
    }
  });

  demoFile.gameEvents.on("inferno_expire", e => {
    e = setBasicEventInfo(e, demoFile, mapName, roundNum);
    grenadeDetonations.push(e);
    let idx = grenadeThrows.findIndex(
      gt =>
        (gt.weapon == "weapon_molotov" || gt.weapon == "weapon_incgrenade") &&
        gt.round == roundNum
    );
    if (idx != -1) {
      let grenadeThrow = grenadeThrows[idx];
      grenadeThrow.expired = true;
      grenadeThrows[idx] = grenadeThrow;
    }
  });

  demoFile.gameEvents.on("hegrenade_detonate", e => {
    e = setBasicEventInfo(e, demoFile, mapName, roundNum);
    grenadeDetonations.push(e);
    let idx = grenadeThrows.findIndex(
      gt =>
        gt.weapon == "weapon_hegrenade" &&
        gt.round == roundNum &&
        gt.userid == e.userid
    );
    if (idx != -1) {
      let grenadeThrow = grenadeThrows[idx];
      grenadeThrow = setGrenadeDetonationInfo(grenadeThrow, e);
      grenadeThrows[idx] = grenadeThrow;
    }
  });

  demoFile.gameEvents.on("player_blind", e => {
    let idx = grenadeThrows.findIndex(
      gt =>
        gt.weapon == "weapon_flashbang" &&
        gt.userid == e.attacker &&
        gt.round == roundNum
    );
    if (idx != -1) {
      let grenadeThrow = grenadeThrows[idx];
      grenadeThrow.blind_duration += e.blind_duration;
      grenadeThrows[idx] = grenadeThrow;
    }
  });

  demoFile.gameEvents.on("player_death", e => {
    e = setBasicEventInfo(e, demoFile, mapName, roundNum);
    e = setKillInfo(e, demoFile);
    const playerRecordIdx = playerRoundRecords[roundNum - 1].findIndex(
      p => p.userid == e.userid
    );
    const attackerIdx = playerRoundRecords[roundNum - 1].findIndex(
      p => p.userid == e.attacker
    );
    const assisterIdx = playerRoundRecords[roundNum - 1].findIndex(
      p => p.userid == e.assister
    );
    if (playerRoundRecords[roundNum - 1][assisterIdx]) {
      playerRoundRecords[roundNum - 1][assisterIdx].assists++;
    }
    playerRoundRecords[roundNum - 1][attackerIdx].kills++;
    playerRoundRecords[roundNum - 1][playerRecordIdx].dead = true;

    if (roundNum != 0) {
      kills.push(e);
    }
    if (e.round == 30) {
      console.log(e);
    }
  });

  demoFile.on("end", () => {
    const teams = createTeams(demoFile.teams);
    let matchStats = createMatchStats(demoFile.entities.players);
    kills = processKills(kills, tickRate);
    const players = createPlayers(demoFile.entities.players, mapName, teams);
    let playersById = getPlayersById(players);
    let results = killStats(kills, playersById, playerRoundRecords);
    playersById = results[0];
    playerRoundRecords = results[1];
    playersById = aggreggateStats(playersById, playerRoundRecords);
    console.log(teams);
    console.log(tickRate);
    console.log(mapName);
    console.log(playerRoundRecords);
    console.log(kills);
    console.log(grenadeThrows);
    console.log(grenadeDetonations);
    console.log(playerDamaged);
    console.log(roundWins);
    console.log(matchStats);
    console.log(playersById);
    onEnd({
      tick_rate: tickRate,
      map_name: mapName,
      player_round_records: matchStats,
      kills,
      grenade_throws: grenadeThrows,
      round_wins: roundWins,
      player_info: playerInfo,
      teams,
      demo_name: file.name,
      players: playersById
    });
  });

  demoFile.parse(buffer);
};

export default onFileUploaded;
