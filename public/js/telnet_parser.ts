import WST from "./vendor/wst"
import * as StateMachine from "pastafarian"

export class TP {
    cursor = 0;
    accum: number[];
    chunk: number[];
    fsm: StateMachine;
    constructor(chunk: number[]) {
        this.accum = []
        this.chunk = chunk
        const fsm = new StateMachine({
            initial: "idle",
            states: {
                "idle": "ready",
                "ready": ["text", "COMMAND"],
                "text": ["COMMAND", "idle"],
                "COMMAND": ["GMCP"]
            },
            error: (err, prev, next) => {
                console.error(`err: ${err} while trans from ${prev} to ${next}`)
            }
        })

        fsm.on("GMCP", (prev) => {
            if (this.chunk[this.cursor] === WST.TelnetNegotiation.IAC &&
                this.chunk[this.cursor + 1] === WST.TelnetNegotiation.SE) {
                this.cursor + 2
                this.fsm.go("ready")
            } else {
                for (let i = this.cursor; i < this.chunk.length; i++) {
                    this.cursor++
                    this.accum.push(this.chunk[i])
                }
                this.cursor++
                this.fsm.go("ready")
            }
        })

        fsm.on("ready", (_prev: string) => {
            if (this.chunk[this.cursor] === WST.TelnetNegotiation.IAC) {
                this.cursor++
                this.fsm.go("COMMAND")
            } else {
                this.fsm.go("text")
            }
        })

        fsm.on("COMMAND", (prev) => {
            const {GMCP} = WST.TelnetOption
            if (this.chunk[this.cursor] === WST.TelnetNegotiation.SB) {
                this.cursor++
                switch (this.chunk[this.cursor]) {
                    case GMCP:
                    this.cursor++
                    this.fsm.go("GMCP")
                    break
                }
            }
        })

        fsm.on("text", (_prev: string) => {
                for (let i = this.cursor; i < chunk.length; i++) {
                    if (this.chunk[i] === WST.TelnetNegotiation.IAC) {
                        this.cursor++
                        this.fsm.go("COMMAND")
                        return
                    } else {
                        this.accum.push(this.chunk[i])
                    }
                }
            this.fsm.go("idle")
        })

        fsm.on("before:idle", (prev) => {
            console.log("result: ", this.accum)
        })

        fsm.on("idle", (prev) => {
            this.accum = []
            this.chunk = []
            this.cursor = 0
        })

        fsm.on("*", (prev, next) => {
            console.log(`transition ${prev} -> ${next}\ncur: ${this.cursor} acc: ${this.accum}\nts: ${Date.now()}`)
        })

        this.fsm = fsm
    }
    parse(): void {
        this.fsm.go("ready")
    }
}
