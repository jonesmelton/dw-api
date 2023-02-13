module Token = {
  type opt =
    | IAC
    | SB
    | SE
    | GMCP

  type ws =
    | LF
    | CR
    | Tab

  type token =
    | Alphanum(string)
    | Telopt(opt)
    | Control(ws)
    | Ignore(int)

  type t = token

  let make = uint8 =>
    switch uint8 {
    | 9 => Control(LF)
    | 10 => Control(CR)
    | 13 => Control(Tab)
    | 255 => Telopt(IAC)
    | 250 => Telopt(SB)
    | 240 => Telopt(SE)
    | 201 => Telopt(GMCP)
    | i if i < 32 => Ignore(i)
    | i if i > 126 => Ignore(i)
    | c => Alphanum(Js.String.fromCharCode(c))
    }

  let to_string = token => {
    switch token {
    | Alphanum(c) => c
    | Ignore(i) => Int.toString(i)
    | Control(c) =>
      switch c {
      | LF => "LF"
      | CR => "CR"
      | Tab => "TAB"
      }
    | Telopt(o) =>
      switch o {
      | IAC => "IAC"
      | SB => "SB"
      | SE => "SE"
      | GMCP => "GMCP"
      }
    }
  }
}

module Parser = {
  type state = {
    remaining: list<int>,
    location: int,
  }

  let pchar = (target, stream) => {
    switch stream {
    | list{} => Error("end of stream")
    | list{only} => only === target ? Ok((only, list{})) : Error("unexpected char")
    | list{ch, ...remaining} =>
      if ch === target {
        Ok((ch, remaining))
      } else {
        let lost = Int.toString(target)
        let found = Int.toString(ch)
        Error(`unexpected char -- expected: ${lost}, got ${found}`)
      }
    }
  }
}
