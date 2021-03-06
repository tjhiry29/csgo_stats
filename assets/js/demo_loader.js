import {
  setBasicEventInfo,
  setGrenadeDetonationInfo,
  setGrenadeThrowInfo,
  setKillInfo,
  createTeams,
  createMatchStats,
  createPlayers,
  processKills,
  getPlayersById,
  killStats,
  aggreggateStats,
  updateDamageInformation
} from "./demo_processing";

const GRENADE_WEAPONS = [
  "weapon_hegrenade",
  "weapon_molotov",
  "weapon_incgrenade",
  "weapon_flashbang",
  "weapon_smokegrenade"
];

// This Version number should be changed for updates to the demo loader.
// For extremely breaking changes which completely changes data formats or data results,
// such that mixing data between versions doesn't make sense, bump major version.
// For small fixes, bump the patch version number.

const VERSION = "0.1.0";

const onFileUploaded = (file, onEnd) => {
  let reader = new FileReader();

  reader.onloadend = evt => {
    if (evt.target.readyState === FileReader.DONE) {
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
    playerInfo = [],
    lastTime = 0;

  const updateGrenadeThrowInformation = (idx, e) => {
    if (idx != -1) {
      let grenadeThrow = grenadeThrows[idx];
      grenadeThrow = setGrenadeDetonationInfo(grenadeThrow, e);
      if (e.dmg_dealt) {
        grenadeThrow.total_damage_dealt += e.dmg_dealt;
      }
      grenadeThrows[idx] = grenadeThrow;
    }
  };

  demoFile.on("start", () => {
    console.log("Demo header:", demoFile.header);
    console.log("Tick rate:", demoFile.tickRate);
    tickRate = demoFile.tickRate;
    mapName = demoFile.header.mapName;
    playbackTicks = demoFile.playbackTicks;
  });

  demoFile.stringTables.on("update", e => {
    if (e.table.name === "userinfo" && e.userData != null) {
      console.log("\nPlayer info updated:");
      console.log(e.entryIndex, e.userData);
      e.userData.xuid = e.userData.xuid.toString();
      playerInfo.push(e.userData);
    }
  });

  demoFile.gameEvents.on("round_announce_match_start", () => {
    roundNum++;
    let players = demoFile.entities.players;
    players = players
      .filter(
        player =>
          !player.userInfo.guid.includes("BOT") && !player.name.includes("Obs")
      )
      .map(player => {
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
    lastTime = demoFile.currentTime;
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
      e = setBasicEventInfo(e, demoFile, mapName, roundNum, lastTime);
      e = setGrenadeThrowInfo(e, user);
      grenadeThrows.push(e);
    }
  });

  demoFile.gameEvents.on("player_hurt", e => {
    e = setBasicEventInfo(e, demoFile, mapName, roundNum, lastTime);
    if (e.weapon === "hegrenade") {
      let idx = grenadeThrows.findIndex(
        gt =>
          gt.weapon === "weapon_hegrenade" &&
          gt.round === roundNum &&
          gt.userid === e.attacker &&
          gt.detonated
      );
      updateGrenadeThrowInformation(idx, e);
    }
    if (e.weapon === "inferno") {
      let idx = grenadeThrows.findIndex(
        gt =>
          (gt.weapon === "weapon_molotov" ||
            gt.weapon === "weapon_incgrenade") &&
          gt.round === roundNum &&
          gt.userid === e.attacker &&
          !gt.expired
      );
      updateGrenadeThrowInformation(idx, e);
    }
    playerRoundRecords = updateDamageInformation(playerRoundRecords, e);

    playerDamaged.push(e);
  });

  demoFile.gameEvents.on("flashbang_detonate", e => {
    e = setBasicEventInfo(e, demoFile, mapName, roundNum, lastTime);
    grenadeDetonations.push(e);
    let idx = grenadeThrows.findIndex(
      gt =>
        gt.weapon === "weapon_flashbang" &&
        gt.round === roundNum &&
        gt.userid === e.userid
    );
    updateGrenadeThrowInformation(idx, e);
  });

  demoFile.gameEvents.on("smokegrenade_detonate", e => {
    e = setBasicEventInfo(e, demoFile, mapName, roundNum, lastTime);
    grenadeDetonations.push(e);
    let idx = grenadeThrows.findIndex(
      gt =>
        gt.weapon === "weapon_smokegrenade" &&
        gt.round === roundNum &&
        !gt.detonated
    );
    updateGrenadeThrowInformation(idx, e);
  });

  demoFile.gameEvents.on("inferno_startburn", e => {
    e = setBasicEventInfo(e, demoFile, mapName, roundNum, lastTime);
    grenadeDetonations.push(e);
    let idx = grenadeThrows.findIndex(
      gt =>
        (gt.weapon === "weapon_molotov" || gt.weapon === "weapon_incgrenade") &&
        gt.round === roundNum &&
        !gt.detonated
    );
    updateGrenadeThrowInformation(idx, e);
  });

  demoFile.gameEvents.on("inferno_expire", e => {
    e = setBasicEventInfo(e, demoFile, mapName, roundNum, lastTime);
    grenadeDetonations.push(e);
    let idx = grenadeThrows.findIndex(
      gt =>
        (gt.weapon === "weapon_molotov" || gt.weapon === "weapon_incgrenade") &&
        gt.round === roundNum
    );
    if (idx != -1) {
      let grenadeThrow = grenadeThrows[idx];
      grenadeThrow.expired = true;
      grenadeThrows[idx] = grenadeThrow;
    }
  });

  demoFile.gameEvents.on("hegrenade_detonate", e => {
    e = setBasicEventInfo(e, demoFile, mapName, roundNum, lastTime);
    grenadeDetonations.push(e);
    let idx = grenadeThrows.findIndex(
      gt =>
        gt.weapon === "weapon_hegrenade" &&
        gt.round === roundNum &&
        gt.userid === e.userid
    );
    updateGrenadeThrowInformation(idx, e);
  });

  demoFile.gameEvents.on("player_blind", e => {
    let idx = grenadeThrows.findIndex(
      gt =>
        gt.weapon === "weapon_flashbang" &&
        gt.userid === e.attacker &&
        gt.round === roundNum
    );
    if (idx != -1) {
      let grenadeThrow = grenadeThrows[idx];
      grenadeThrow.total_blind_duration += e.blind_duration;
      grenadeThrows[idx] = grenadeThrow;
    }
  });

  demoFile.gameEvents.on("player_death", e => {
    e = setBasicEventInfo(e, demoFile, mapName, roundNum, lastTime);
    e = setKillInfo(e, demoFile);
    const playerRecordIdx = playerRoundRecords[roundNum - 1].findIndex(
      p => p.userid === e.userid
    );
    const attackerIdx = playerRoundRecords[roundNum - 1].findIndex(
      p => p.userid === e.attacker
    );
    const assisterIdx = playerRoundRecords[roundNum - 1].findIndex(
      p => p.userid === e.assister
    );
    if (playerRoundRecords[roundNum - 1][assisterIdx]) {
      playerRoundRecords[roundNum - 1][assisterIdx].assists++;
    }
    playerRoundRecords[roundNum - 1][attackerIdx].kills++;
    playerRoundRecords[roundNum - 1][playerRecordIdx].dead = true;

    if (roundNum != 0) {
      kills.push(e);
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
    // console.log(teams);
    // console.log(tickRate);
    // console.log(mapName);
    // console.log(playerRoundRecords);
    // console.log(kills);
    // console.log(grenadeThrows);
    // console.log(grenadeDetonations);
    // console.log(playerDamaged);
    // console.log(roundWins);
    // console.log(matchStats);
    // console.log(playersById);
    onEnd({
      tick_rate: tickRate,
      map_name: mapName,
      player_round_records: playerRoundRecords,
      kills,
      grenade_throws: grenadeThrows,
      // round_wins: roundWins,
      player_info: playerInfo,
      teams,
      demo_name: file.name,
      players: playersById,
      version: VERSION
    });
  });

  demoFile.parse(buffer);
};

export default onFileUploaded;
