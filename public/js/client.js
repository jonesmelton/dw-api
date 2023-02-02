"use strict";
import { t } from 'https://cdn.skypack.dev/@arrow-js/core';
import Colors from '/js/vendor/ansicolor.js'

if (window.Worker) {
  const mudc = new Worker("/js/connection.js")
  window.mudc = mudc

  const mud_display = document.querySelector("#main-window")


  mudc.onmessage = event => {
    const colored = new Colors(event.data)
    const spans = t`
                <pre>
                    ${colored.parsed.spans.map(
                        span => t`<span style='${span.css}'>${span.text}</span>`
                    )}
                </pre>`

    spans(mud_display)
  }

} else {
  console.error("browser doesn't support web workers")
}
