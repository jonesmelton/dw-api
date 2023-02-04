import WST from "./vendor/wst"
import * as StateMachine from "pastafarian"

function errorHandler(error, prev, next /* ...params */) {
  if (error.name === 'IllegalTransitionException') {
    console.log(error.message, "prev: ", prev, "next: ", next);
      console.log(Date.now())
    // prev is fsm.current
    // next is the transition attempted, eg. fsm.go(next, ...)
    // params are any other parameters to fsm.go, eg. fsm.go(next, param1, param2 ...)
  } else {
      console.log(`err: ${error} while trans from ${prev} to ${next}`)
    // error is whatever was thrown in the transition callback that caused the error
    // prev, next and other arguments will be undefined
  }
}

export class TP {
    cursor = 0;
    accum: number[] = [];
    chunk: number[] = [];
    fsm: StateMachine;
    constructor() {
        const fsm = new StateMachine({
            initial: "IDLE",
            states: {
                IDLE: ["START"],
                START: ["TEXT", "DATA"],
                TEXT: ["DATA", "START", "IDLE"],
                DATA: ["START", "IDLE"]
            },
            error: errorHandler
        })

        fsm.on("START", (_prev) => {
            if (this.chunk[this.cursor] === WST.TelnetNegotiation.IAC) {
                this.cursor++
                return this.fsm.go("DATA")
            } else {
                return this.fsm.go("TEXT")
            }
        })

        fsm.on("DATA", (_prev) => {
            for (; this.cursor < this.chunk.length; this.cursor++) {
                if (this.chunk[this.cursor] === WST.TelnetNegotiation.IAC) {
                    this.cursor++
                    this.fsm.go("START")
                    break
                } else {
                    this.accum.push(this.chunk[this.cursor])
                }
            }
            return this.fsm.go("IDLE")
        })

        fsm.on("after:DATA", (_prev) => {
            console.log("DATA result: ", this.accum)
            this.accum = []
        })

        fsm.on("TEXT", (_prev) => {
            for (; this.cursor < this.chunk.length; this.cursor++) {
                if (this.chunk[this.cursor] === WST.TelnetNegotiation.IAC) {
                    this.cursor++
                    this.fsm.go("DATA")
                    break
                } else {
                    this.accum.push(this.chunk[this.cursor])
                }
            }
            this.fsm.go("IDLE")
        })

        fsm.on("after:TEXT", (_prev) => {
            console.log("TEXT result: ", this.accum)
            this.accum = []
        })

        fsm.on("*", (prev, next) => {
            console.log(`transition ${prev} -> ${next}\ncur: ${this.cursor} acc: ${this.accum}\nts: ${Date.now()}`)
        })

        this.fsm = fsm
    }
    parse(chars: number[]): void {
        this.cursor = 0
        this.chunk = chars
        this.fsm.go("START")
    }
}
