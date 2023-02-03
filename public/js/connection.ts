"use strict";

import WST from "./vendor/wst"
const host = "ws://discworld.atuin.net:4243"
const mud = new WST(host)

const reader = new TextDecoder()

mud.onopen = () => {
  console.log("connected")

  self.onmessage = (ev: MessageEvent)=> {
    mud.send(ev.data + "\n")
  }
}

mud.ongmcp = (ns, data) => {
  console.log("gmcp: ", ns, "data:\n ", data)
}

mud.onwill = option => {
  if (option === WST.TelnetOption.GMCP) {
    mud.do(WST.TelnetOption.GMCP);
    mud.sendGMCP("Core.Hello", { client: "ws-telnet-client/lore", version: "1.0.0" });
    mud.sendGMCP("core.supports.set", [ "char.login", "char.info", "char.vitals", "char.login", "room.info", "room.map", "room.writtenmap"])
  }
}

mud.ongoahead = () => {
  postMessage({type: "oob", value: "goahead"})
}

// Regular string data received.
mud.onreceive = (ev) => {
  postMessage({type: "line", value: reader.decode(ev)})
};

// Telnet event received.
mud.ontelnet = (ev) => {
    console.log(`[=TELNET EVENT=]\nCommand: ${ev.command}\nOption: ${ev.option}\nData?: ${ev.data}`);
};
