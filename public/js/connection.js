"use strict";

const host = "ws://discworld.atuin.net:4243"
const conn = new WebSocket(host)
conn.binaryType = "arraybuffer"

// escapes & commands
const IAC = 255;
const DO = 253;
const WILL = 251;
const SB = 250;
const SE = 240;

// telopts
const NAWS = 31
const TTYPE = 24 // https://mudhalla.net/tintin/protocols/mtts/
const MXP = 91 // http://www.zuggsoft.com/zmud/mxp.htm
const MSSP = 70
const ZMP = 93 // http://discworld.starturtle.net/external/protocols/zmp.html
const NEW_ENV = 39 // rfc 1572
const GMCP = 201;

// const DONT = 254;
// const WONT = 252;


// const GA = 249;
// const EOR = 239;

const writer = new TextEncoder()

function send(bytes) {
  const buf = new Uint8Array(bytes).buffer
  conn.send(buf)
}

function send_text(text) {
  const buf = writer.encode(text + "\n").buffer
  conn.send(buf)
}

function do_gmcp() {
  send([IAC, DO, GMCP])
}

function sb_gmcp() {
  const client = writer.encode(`core.hello { "client" : "TinTin++", "version" : "2.01.2" }`).buffer
  const req = writer.encode(`core.supports.set [ "char.login", "char.info", "char.vitals", "char.login", "room.info", "room.map", "room.writtenmap" ]`).buffer

  conn.send([IAC, SB, GMCP, ...client, IAC, SE])
  conn.send([IAC, SB, GMCP, ...req, IAC, SE])
}

function sb_env() {
  send([IAC, SB, NEW_ENV, 1, IAC, SE])
}

function will_env() {
  send([IAC, WILL, NEW_ENV])
}

function will_ttype() {
  send([IAC, WILL, TTYPE])
}

function sb_ttype() {
  const client_name = writer.encode("WEBSOCKETS")
  const term = writer.encode("XTERM")
  send([IAC, SB, TTYPE, 0, ...client_name, IAC, SE])
  send([IAC, SB, TTYPE, 0, ...term, IAC, SE])
  send([IAC, SB, TTYPE, 0, 299, IAC, SE])
}

function parse_mud(uintarray) {
  const [esc, com, opt, ...rest] = uintarray
  // console.log(com, opt, rest, Date.now())

  if (esc !== IAC) // pass through to be shown to user
    {return uintarray}

  if (com === DO) {
    switch (opt) {
      case NAWS:
        break
      case TTYPE:
        will_ttype()
        break
      case MXP:
        break
      case MSSP:
        break
      case ZMP:
        break
      case NEW_ENV:
        will_env()
        break
      default:
        break
    }
  }

  if (com === WILL && opt === GMCP) {
    do_gmcp()
  }

  if (com === SB) {
    switch (opt) {
      case TTYPE:
        sb_ttype()
        break
      case NEW_ENV:
        sb_env()
        break
      case GMCP:
        sb_gmcp()
      default:
        console.log("default SB")
    }
  }
}

const reader = new TextDecoder()

conn.onopen = event => {
  console.log("connect")
    onmessage = (event) => {
      send_text(event.data)
  }
}

conn.onmessage = event => {
  // decode() can take the event.data directly,
  // but since we already need the raw numbers,
  // might as well pass it this way.
  const view = new Uint8Array(event.data)
  const text = reader.decode(parse_mud(view))
  if (text !== "") {
    postMessage(text)
  }
}

conn.onclose = event => {
  console.log("close")
  console.log(event)
}

conn.onerror = event => {
  console.log("error")
  console.log(event)
}
