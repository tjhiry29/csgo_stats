import { groupBy, convertToArray } from "./util";

export const setBasicEventInfo = (event, demoFile, mapName, roundNum) => {
  return Object.assign({}, event, {
    map_name: mapName,
    tick: demoFile.currentTick,
    time_elapsed: demoFile.current_time,
    round: roundNum
  });
};

export const setGrenadeDetonationInfo = (grenadeThrow, e) => {
  return Object.assign({}, grenadeThrow, {
    location: [e.x, e.y, e.z],
    detonated: true
  });
};

export const setGrenadeThrowInfo = (grenadeThrow, user) => {
  return Object.assign({}, grenadeThrow, {
    origin: convertToArray(user.position),
    facing: convertToArray(user.eyeAngles),
    damage_dealt: 0,
    blind_duration: 0,
    detonated: false,
    expired: false
  });
};

export const setKillInfo = (e, demoFile) => {
  const victim = demoFile.entities.getByUserId(e.userid);
  const victimName = victim ? victim.name : "unnamed";
  const victimPosition = victim
    ? convertToArray(victim.position)
    : { x: null, y: null, z: null };
  const attacker = demoFile.entities.getByUserId(e.attacker);
  const attackerName = attacker ? attacker.name : "unnamed";
  const attackerPosition = attacker
    ? convertToArray(attacker.position)
    : { x: null, y: null, z: null };
  const assister = demoFile.entities.getByUserId(e.assister);
  const assisterName = assister ? assister.name : "unnamed";
  const assisterPosition = assister
    ? convertToArray(assister.position)
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

export const createTeams = teams => {
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

export const createMatchStats = players => {
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

export const createPlayers = (players, mapName, teams) => {
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

export const findTradeKills = (kills, kill, tickRate) => {
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

export const processKills = (kills, tickRate) => {
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

export const getPlayersById = players => {
  return players.reduce(function(acc, obj) {
    var key = obj["userid"];
    if (!acc[key]) {
      acc[key] = [];
    }
    acc[key] = obj;
    return acc;
  }, {});
};

export const killStats = (kills, playersById, playerRoundRecords) => {
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

export const aggreggateStats = (playersById, playerRoundRecords) => {
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
