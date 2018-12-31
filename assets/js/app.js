// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";
import { Socket } from "phoenix";
import demo_loader from "./demo_loader";

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

let socket = new Socket("/socket", { params: { token: window.userToken } });
socket.connect();
let channel = socket.channel("test:test", {});
channel
  .join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp);
  })
  .receive("error", resp => {
    console.log("Unable to join", resp);
  });

$(function() {
  $('[data-toggle="tooltip"]').tooltip();
});

$("#testupload").on("click", () => {
  $("#fileupload").trigger("click");
});

$("#fileupload").on("change", () => {
  let startTime = Date.now();
  let file = $("#fileupload").prop("files")[0];
  demo_loader(file, results => {
    console.log((Date.now() - startTime) / 1000 / 60);
    channel.push("test:info", {
      info: results
    });
  });
});
