open Zora

zora("should run a test asynchronously", t => {
  let input = [1, 2, 5]
  let act = Telnet.run(1, input)
  t->resultOk(Result.Ok((1, list{2, 5})), (t, msg) => t->equal(msg, (1, list{2, 5}), "result ok"))
  done()
})
