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
  type the_move =
    | Eat(string)
    | Skip(int)
    | Nothing

  type state = {
    remaining: list<int>,
    location: int,
  }

  let check_one = (ch, remaining) => {
    let peek = (list{hd, ...tl}) => Token.make(hd)
    let action = switch Token.make(ch) {
    | Alphanum(c) => Eat(c)
    | Control(_) => Skip(1)
    | Ignore(_) => Skip(1)
    | Telopt(IAC) => Skip(2)
    | Telopt(_) => Skip(1)
    }
  }

  let parse = stream => {
    switch stream {
    | list{} => Error("end of stream")
    | list{only} => Ok((only, list{}))
    | list{head, ...tail} => Ok((head, tail))
    }
  }

  let run = arr => {
    if Array.length(arr) == 0 {
      Result.Error("empty array")
    } else {
      parse(List.fromArray(arr))
    }
  }
}
