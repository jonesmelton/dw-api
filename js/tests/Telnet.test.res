open Zora

module Tn = Telnet

zora("telopt tokenizer", t => {
  let iac = Tn.make_token(255)
  t->equal(iac, Tn.Telopt(IAC),
          "converts int to Telopt")

  t->equal(Tn.token_to_string(iac),
          "IAC", "converts Telopt to string")
  done()
})

zora("line feed tokenizer", t => {
  let lf = Tn.make_token(9)
  t->equal(lf, Tn.Control(LF),
          "converts int to Control")

  t->equal(Tn.token_to_string(lf),
          "LF", "converts Control to string")
  done()
})

zora("ignorable tokenizer", t => {
  let one99 = Tn.make_token(199)
  t->equal(one99, Tn.Ignore(199),
          "converts non-alphanum to Ignore")

  t->equal(Tn.token_to_string(one99),
           "199", "converts non-alphanum to number")
  done()
})

zora("actual letter tokenizer", t => {
  let cap_F = Tn.make_token(70)
  t->equal(cap_F, Tn.Alphanum("F"),
          "converts letter to Alphanum")

  t->equal(Tn.token_to_string(cap_F),
           "F", "converts Alphanum to string")
  done()
})

zora("base cases", t => {
  let eof = Telnet.run(1, [])
  t->resultError(eof, "error result")

  let single = Telnet.run(1, [0])
  t->resultOk(single, (t, expected) => t->equal(expected, (0, list{}), "single element"))

  let more = Telnet.run(1, [2, 3, 4])
  t->resultOk(more, (t, expected) => t->equal(expected, (2, list{3, 4}), "multiple elements"))
  done()
})
