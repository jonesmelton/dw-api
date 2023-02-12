open Zora

module Token = Telnet.Token
module Parser = Telnet.Parser

zora("telopt tokenizer", t => {
  let iac = Token.make(255)
  t->equal(iac, Token.Telopt(IAC),
          "converts int to Telopt")

  t->equal(Token.to_string(iac),
          "IAC", "converts Telopt to string")
  done()
})

zora("line feed tokenizer", t => {
  let lf = Token.make(9)
  t->equal(lf, Token.Control(LF),
          "converts int to Control")

  t->equal(Token.to_string(lf),
          "LF", "converts Control to string")
  done()
})

zora("ignorable tokenizer", t => {
  let one99 = Token.make(199)
  t->equal(one99, Token.Ignore(199),
          "converts non-alphanum to Ignore")

  t->equal(Token.to_string(one99),
           "199", "converts non-alphanum to number")
  done()
})

zora("actual letter tokenizer", t => {
  let cap_F = Token.make(70)
  t->equal(cap_F, Token.Alphanum("F"),
          "converts letter to Alphanum")

  t->equal(Token.to_string(cap_F),
           "F", "converts Alphanum to string")
  done()
})

zora("base cases", t => {
  let eof = Parser.run(1, [])
  t->resultError(eof, "error result")

  let single = Parser.run(1, [0])
  t->resultOk(single, (t, expected) => t->equal(expected, (0, list{}), "single element"))

  let more = Parser.run(1, [2, 3, 4])
  t->resultOk(more, (t, expected) => t->equal(expected, (2, list{3, 4}), "multiple elements"))
  done()
})
