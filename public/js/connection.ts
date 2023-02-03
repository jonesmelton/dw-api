"use strict";

import WST from "./vendor/wst"
const host = "ws://discworld.atuin.net:4243"
const mud = new WST(host)

const reader = new TextDecoder()

mud.onopen = () => {
  console.log("connected")
}

mud.onwill = option => {
  if (option === WST.TelnetOption.GMCP) {
      mud.do(WST.TelnetOption.GMCP);
      mud.sendGMCP("Core.Hello", { client: "ws-telnet-client", version: "1.0.0" });
  }
}

// Regular string data received.
mud.onreceive = (ev) => {
  postMessage({type: "line", value: reader.decode(ev)})
};

// Telnet event received.
mud.ontelnet = (ev) => {
    console.log(`[=TELNET EVENT=]\nCommand: ${ev.command}\nOption: ${ev.option}\nData?: ${ev.data}`);
};
