type telopt =
  | IAC
  | SB
  | SE
  | GMCP
  | None
  | OTHER(int)

let teloptFromInt = (opt) => {
  switch opt {
    | 255 => IAC
    | 250 => SB
    | 240 => SE
    | 201 => GMCP
    | 0 => None
    | o => OTHER(o)
  }
}

let stringFromTelopt = (opt) => {
  switch opt {
    | IAC => " IAC "
    | SB => " SB "
    | SE => " SE "
    | GMCP => " GMCP "
    | None => ""
    | OTHER(code) => Js.String2.fromCharCode(code)
  }
}

let teloptToString = (code) => {
  code
    ->teloptFromInt
    ->stringFromTelopt
}

let rec run = (chars, start, end, acc) => {
  let current = Array.get(chars, start)
    ->Option.map(teloptFromInt)
    ->Option.getWithDefault(None)
  let next = Array.get(chars, start + 1)
    ->Option.map(teloptFromInt)
    ->Option.getWithDefault(None)
  let nextnext = Array.get(chars, start + 2)
    ->Option.map(teloptFromInt)
    ->Option.getWithDefault(None)

  // now accumulate gmcp data separate
  switch (current, next, nextnext) {
    | (None, _, _) => acc
    | (IAC, SB, GMCP) => run(chars, start + 3, end, acc)
    | (c, _, _) => run(chars, start + 1, end, acc ++ stringFromTelopt(c))
  }
}

let parse = (chars) => {
  run(chars, 0, Array.length(chars), "")
}
