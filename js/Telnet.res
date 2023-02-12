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

let make_token = uint8 =>
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

let token_to_string = token =>
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

let parse = (ch, stream) => {
  switch stream {
  | list{} => Result.Error("end of stream")
  | list{only} => Result.Ok((only, list{}))
  | list{head, ...tail} => Result.Ok((head, tail))
  }
}

let run = (char, arr) => {
  if Array.length(arr) == 0 {
    Result.Error("empty array")
  } else {
    parse(char, List.fromArray(arr))
  }
}
