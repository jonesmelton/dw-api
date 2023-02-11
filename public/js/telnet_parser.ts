import WST from "./vendor/wst"

type State = "text" | "gmcp"

type DataType = "line" | "gmcp_data"

export type Mudline = {
    kind: DataType;
    payload: string;
}

function e(current: State, attempted: State): Error {
    return new Error(`attempted illegal transition from ${current} to ${attempted}`)
}

export class TP {
    private cursor = 0;
    private acc_text: string = "";
    private acc_gmcp: string = "";
    private chunk: number[] = [];
    private state: State = "text";
    public message_handler: (mudline: Mudline) => void = (mudline) => {};
    private debug: boolean = false;
    private acc_dbg: string = "";
    private dbg_rec: boolean = false;

    constructor(emitter, options?: Record<string, any>) {
        this.message_handler = emitter

        if (options?.debug) {
            this.debug = true
        }
    }

    private current(): number {
        return this.chunk[this.cursor]
    }

    parse(chars: Uint8Array): void {
        console.log("debug? ", this.debug)

        this.cursor = 0
        this.chunk = Array.from(chars)
        this.acc_text = ""
        this.acc_gmcp = ""

        if (this.debug) {
            for (; this.cursor < this.chunk.length; this.cursor++) {
                if (this.current() === 255) {this.dbg_rec = true}
                if (this.dbg_rec) {
                    const esc = WST.TelnetNegotiation[this.current()] || WST.TelnetOption[this.current()]
                    if (esc) {
                        this.acc_dbg += esc
                        this.acc_dbg += " "
                        this.acc_dbg += String.fromCharCode(this.current())
                    }

                }

            }
            this.cursor = 0
            console.log(this.acc_dbg)
        }

        for (; this.cursor < this.chunk.length; this.cursor++) {
            // begin gmcp
            if (this.current() === WST.TelnetNegotiation.IAC &&
                this.chunk?.[this.cursor + 1] === WST.TelnetNegotiation.SB &&
                this.chunk?.[this.cursor + 2] === WST.TelnetOption.GMCP) {

                this.cursor += 3
                this.state = "gmcp"
            }

            // end gmcp
            if (this.state === "gmcp" &&
                this.current() === WST.TelnetNegotiation.IAC &&
                this.chunk?.[this.cursor + 1] === WST.TelnetNegotiation.SE) {


                this.cursor = this.cursor + 2
                this.emit_gmcp(this.acc_gmcp)
                this.state = "text"
            }

            if (this.cursor < this.chunk.length) {
                this.gather()
            }

        }

        this.emit_text()
    }

    private gather(): void {

        if (this.state === "text") {
            const char = String.fromCharCode(this.current())
            this.acc_text += char
        }

        if (this.state === "gmcp") {
            const char = String.fromCharCode(this.current())
            this.acc_gmcp += char
        }
    }

    private emit_gmcp(gmcp: string): Mudline {
        const line = {
            kind: <const> "gmcp_data",
            payload: gmcp
        }
        this.message_handler(line)
        return line
    }

    private emit_text(): Mudline {
        const line = {
            kind: <const> "line",
            payload: this.acc_text
        }
        this.message_handler(line)
        return line
    }
}
