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
  let incorrect_single =
  t->resultError(p(list{80}), "rejects unexpected")
  t->resultOk(p(list{70}), (t, expected) => t->equal(expected, (70, list{}), "success single item"))

  t->resultOk(p(list{70, 0, 1}), (t, expected) => t->equal(expected, (70, list{0, 1}), "success mult item"))
  t->resultError(p(list{80, 0}), "rejected unexpected")
  done()
})
