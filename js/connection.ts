"use strict";

import WST from "./vendor/wst"
import {parse} from "./Telnet.bs"

// text: "(2Aj", gmcp: "!#"
const test = [40, 50, 255, 250, 201, 33, 35, 255, 240, 65, 106, 80, 80, 255, 250, 201, 41, 88, 95, 112, 255, 240, 32, 38]
//             (   2  beg gmcp        !   #  end gmcp   A    j   P   P    beg gmcp      )   X   _    p  end gmcp  spc  &

const res = parse(test)

console.log("result: ", res)
// const parser = new TP(ln => {
//   console.log("line handler: ", ln)
//   postMessage(ln)
// }, {debug: false})


// const host = "ws://discworld.atuin.net:4243"
// const mud = new WST(host)

// const reader = new TextDecoder()

// mud.onopen = () => {
//   console.log("connected")

//   self.onmessage = (ev: MessageEvent)=> {
//     mud.send(ev.data + "\n")
//   }
// }

// mud.onwill = option => {
//   if (option === WST.TelnetOption.GMCP) {
//     mud.do(WST.TelnetOption.GMCP);
//     mud.sendGMCP("Core.Hello", { client: "ws-telnet-client/lore", version: "1.0.0" });
//     mud.sendGMCP("core.supports.set", [ "char.login", "char.info", "char.vitals", "char.login", "room.info", "room.map", "room.writtenmap"])
//   }
// }

// mud.onreceive = (ev) => {
//   parser.parse(ev)
// }

// mud.onmessage = (ev) => {
//   //postMessage(ev)
// };

// // Telnet event received.
// mud.ontelnet = (ev) => {
//     //console.log(`[=TELNET EVENT=]\nCommand: ${ev.command}\nOption: ${ev.option}\nData?: ${ev.data}`);
// };
