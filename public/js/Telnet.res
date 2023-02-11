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

type oob =
  | Gmcp(array<int>)
  | None

type parse = {
  text: string,
  data: array<oob>
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
  let _ = Js.log4(chars, start, end, acc)
  switch (current, next, nextnext) {
    | (None, _, _) => acc
    | (IAC, SB, GMCP) =>
      let beginGMCP = start + 3
      let nextSE = Array.getIndexBy(
        chars, ele => teloptFromInt(ele) == SE)
        ->Option.getWithDefault(end - 1)
      let gmcp = Js.Array.slice(~start=beginGMCP, ~end_=nextSE - 1, chars)
      let rest = Array.sliceToEnd(chars, nextSE)
      let _ = Js.Array.push(Gmcp(gmcp), acc.data)
      run(rest, 0, Array.length(rest) - 1, acc)
    | (c, _, _) => run(chars, start + 1, Array.length(chars) - 1, {...acc, text: acc.text ++ stringFromTelopt(c)})
  }
}

let parse = (chars) => {
  run(chars, 0, Array.length(chars) - 1, {text: "", data: []})
}
