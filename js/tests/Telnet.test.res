open Zora
module Telnet = Telnet.Parser

zora("base cases", t => {
  let eof = Telnet.run(1, [])
  t->resultError(eof, "error result")

  let single = Telnet.run(1, [0])
  t->resultOk(single, (t, expected) =>
    t->equal(expected, (0, None), "single element"))

  let more = Telnet.run(1, [2, 3, 4])
  t->resultOk(more, (t, expected) =>
    t->equal(expected, (2, Some(list{3, 4})), "multiple elements"))
  done()
})
