"use strict";
import { t } from '@arrow-js/core';
import Colors from 'ansicolor'

import type { Mudline } from "./telnet_parser"

const mud_display = document.querySelector("#main-window > pre")
const mud_container = document.querySelector("#main-window")

function receive(message: Mudline) {
  switch (message.kind) {
      case "line":
        // to clean any missed oob chars, esp whatever runs on password prompt
        const colored = Colors.parse(message.payload)
        var insert = t`${colored.spans.map(
                        span => t`<span style='${span.css}'>${span.text}</span>`
                    )}`
        break
      case "gmcp_data":
        console.log("gmcp: ", message.payload)
        var insert = t`<span> GMCP: ${message.payload} </span>`
        break
      default:
        console.error("unknown type")
    }
    insert(mud_display)
    mud_container.scrollTop = mud_container.scrollHeight
  }

if (window.Worker) {
  const mudc = new Worker(new URL('./connection.ts', import.meta.url), {type: "module"})
  window.mudc = mudc // so hyperscript can get it...

  mudc.onmessage = event => {
    receive(event.data)
  }

} else {
  console.error("browser doesn't support web workers")
}
