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

zora("single-char parser fn", t => {
  let p = Parser.pchar(70)
  let one_bad = list{80}
  let one_good = list{70}
  let mult_bad = list{80, 0}
  let mult_good = list{70, 0, 1}

  t->resultError(Parser.run(p, one_bad), "rejects unexpected")
  t->resultOk(Parser.run(p, one_good), (t, expected) => t->equal(expected, (70, list{}), "success single item"))

  t->resultOk(Parser.run(p, mult_good), (t, expected) => t->equal(expected, (70, list{0, 1}), "success mult item"))
  t->resultError(Parser.run(p, mult_bad), "rejected unexpected")
  done()
})
