// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
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
    let endTime = Date.now();
    console.log((endTime - startTime) / 1000 / 60);
    channel.push("test:info", {
      info: results
    });
  });
});
