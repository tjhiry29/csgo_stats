import { groupBy } from "./util";

const GRENADE_WEAPONS = [
  "weapon_hegrenade",
  "weapon_molotov",
  "weapon_incgrenade",
  "weapon_flashbang",
  "weapon_smokegrenade"
];

const setBasicEventInfo = (event, demoFile) => {
  event.tick = demoFile.currentTick;
  event.current_time = demoFile.current_time;
  event.round = demoFile.gameRules.roundsPlayed + 1;
  return event;
};

const setGrenadeDetonationInfo = (grenadeThrow, e) => {
  grenadeThrow.location = { x: e.x, y: e.y, z: e.z };
  grenadeThrow.detonated = true;
  return grenadeThrow;
};

const findTradeKills = (kills, kill, tickRate) => {
  return kills.map(k => {
    if (
      k.userid == kill.attacker &&
      k.tick >= kill.tick &&
      k.tick <= kill.tick + 5 * tickRate
    ) {
      k.trade_kill = true;
    }
    return k;
  });
};

const processKills = (kills, tickRate) => {
  let killsByRound = groupBy(kills, "round");
  let finalKills = [];
  Object.keys(killsByRound).forEach(key => {
    let kills = killsByRound[key];
    let sortedKills = kills.sort((k1, k2) => k1.tick - k2.tick);
    sortedKills[0].first_kill = true;
    let resultKills = sortedKills;
    sortedKills.forEach(kill => {
      resultKills = findTradeKills(resultKills, kill, tickRate);
    });
    finalKills.push(resultKills);
  });
  return finalKills.flat();
};

const onFileUploaded = (file, onEnd) => {
  let reader = new FileReader();

  reader.onloadend = evt => {
    if (evt.target.readyState == FileReader.DONE) {
      let buffer = reader.result;
      outputDemoInfo(buffer, onEnd);
    } else {
      // TODO: error state
    }
  };

  reader.readAsArrayBuffer(file);
};

const outputDemoInfo = (buffer, onEnd) => {
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
      playerInfo.push(e);
    }
  });

  demoFile.gameEvents.on("round_announce_match_start", () => {
    roundNum++;
  });

  demoFile.gameEvents.on("round_end", e => {
    roundWins.push(e);
  });

  demoFile.gameEvents.on("round_officially_ended", e => {
    let teams = demoFile.teams;

    let terrorists = teams[demofile.TEAM_TERRORISTS];
    let cts = teams[demofile.TEAM_CTS];
    let players = demoFile.entities.players;
    players = players.map(player => {
      return {
        round: roundNum,
        name: player.name,
        userid: player.userId,
        kills: player.kills,
        deaths: player.deaths
      };
    });
    playerRoundRecords.push(players);
    roundNum++;

    console.log(
      "\tTerrorists: %s score %d\n\tCTs: %s score %d",
      terrorists.clanName,
      terrorists.score,
      cts.clanName,
      cts.score
    );
  });

  demoFile.gameEvents.on("weapon_fire", e => {
    if (GRENADE_WEAPONS.includes(e.weapon) && roundNum != 0) {
      const user = demoFile.entities.getByUserId(e.userid);
      e = setBasicEventInfo(e, demoFile);
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
      e = setBasicEventInfo(e, demoFile);
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
      e = setBasicEventInfo(e, demoFile);
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
    playerDamaged.push(e);
  });

  demoFile.gameEvents.on("flashbang_detonate", e => {
    e = setBasicEventInfo(e, demoFile);
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
    e = setBasicEventInfo(e, demoFile);
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
    e = setBasicEventInfo(e, demoFile);
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
    e = setBasicEventInfo(e, demoFile);
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
    e = setBasicEventInfo(e, demoFile);
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
    let victim = demoFile.entities.getByUserId(e.userid);
    let victimName = victim ? victim.name : "unnamed";
    let attacker = demoFile.entities.getByUserId(e.attacker);
    let attackerName = attacker ? attacker.name : "unnamed";

    e = setBasicEventInfo(e, demoFile);
    e.attacker_name = attackerName;
    e.victim_name = victimName;
    e.first_kill = false;
    e.trade_kill = false;
    if (roundNum != 0) {
      kills.push(e);
    }
  });

  demoFile.on("end", () => {
    let matchStats = [];
    demoFile.entities.players.forEach(player => {
      const playerStats = player.matchStats.map((stat, idx) => {
        return Object.assign({}, stat, {
          name: player.name,
          userId: player.userId,
          round: idx + 1
        });
      });
      matchStats.push(playerStats);
    });
    kills = processKills(kills, tickRate);
    console.log(tickRate);
    console.log(playbackTicks);
    console.log(mapName);
    console.log(playerRoundRecords);
    console.log(kills);
    console.log(grenadeThrows);
    console.log(grenadeDetonations);
    console.log(playerDamaged);
    console.log(roundWins);
    console.log(matchStats);
    onEnd({
      tick_rate: tickRate,
      playback_ticks: playbackTicks,
      map_name: mapName,
      player_round_records: matchStats,
      kills,
      grenade_throws: grenadeThrows,
      round_wins: roundWins,
      player_info: playerInfo,
      teams: demoFile.teams
    });
  });

  demoFile.parse(buffer);
};

export default onFileUploaded;
