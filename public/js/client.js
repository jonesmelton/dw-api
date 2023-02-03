"use strict";
import { t } from 'https://cdn.skypack.dev/@arrow-js/core';
import Colors from '/js/vendor/ansicolor.js'

if (window.Worker) {
  const mudc = new Worker("/js/connection.js")
  window.mudc = mudc

  const mud_display = document.querySelector("#main-window > pre")
  const mud_container = document.querySelector("#main-window")
  mudc.onmessage = event => {

    switch (event.data.type) {
      case "line":
        const colored = new Colors(event.data.value)
        var insert = t`
                    ${colored.parsed.spans.map(
                        span => t`<span style='${span.css}'>${span.text}</span>`
                    )}`
        break
      case "goahead":
        var insert = t`<span> GA </span>`
        break
      default:
        console.error("unknown type")
    }


    insert(mud_display)
    mud_container.scrollTop = mud_container.scrollHeight
  }

} else {
  console.error("browser doesn't support web workers")
}
