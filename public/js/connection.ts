"use strict";

import WST from "./vendor/wst"
import {TP} from "./telnet_parser"

const parser = new TP(ln => {
  console.log("line handler: ", ln)
  postMessage(ln)
})
// parser.parse([100, 45, 255, 250, 201, 72, 73, 255, 240])
// console.log(parser)

const host = "ws://discworld.atuin.net:4243"
const mud = new WST(host)

const reader = new TextDecoder()

mud.onopen = () => {
  console.log("connected")

  self.onmessage = (ev: MessageEvent)=> {
    mud.send(ev.data + "\n")
  }
}

mud.onwill = option => {
  if (option === WST.TelnetOption.GMCP) {
    mud.do(WST.TelnetOption.GMCP);
    mud.sendGMCP("Core.Hello", { client: "ws-telnet-client/lore", version: "1.0.0" });
    mud.sendGMCP("core.supports.set", [ "char.login", "char.info", "char.vitals", "char.login", "room.info", "room.map", "room.writtenmap"])
  }
}

mud.onreceive = (ev) => {
  parser.parse(ev)
}

mud.onmessage = (ev) => {
  //postMessage(ev)
};

// Telnet event received.
mud.ontelnet = (ev) => {
    //console.log(`[=TELNET EVENT=]\nCommand: ${ev.command}\nOption: ${ev.option}\nData?: ${ev.data}`);
};
