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

    constructor(emitter) {
        this.message_handler = emitter
    }

    private current(): number {
        return this.chunk[this.cursor]
    }

    parse(chars: Uint8Array): void {
        this.cursor = 0
        this.chunk = Array.from(chars)
        this.acc_text = ""
        this.acc_gmcp = ""

        for (; this.cursor < this.chunk.length; this.cursor++) {
            // begin gmcp
            if (this.current() === WST.TelnetNegotiation.IAC &&
                this.chunk?.[this.cursor + 1] === WST.TelnetNegotiation.SB &&
                this.chunk?.[this.cursor + 2] === WST.TelnetOption.GMCP) {

                this.record_all = true

                this.cursor += 3
                this.state = "gmcp"
            }

            // end gmcp
            if (this.state === "gmcp" &&
                this.current() === WST.TelnetNegotiation.IAC &&
                this.chunk?.[this.cursor + 1] === WST.TelnetNegotiation.SE) {
                console.log("emit gmcp")
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
