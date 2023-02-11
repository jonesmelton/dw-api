open Zora

zora("should run a test asynchronously", t => {
  let input = [1, 2, 5]
  let result = Telnet.parse(input)
  t->notEqual(input, result, "should not be the same")
  done()
})

zora("should run a second test at the same time", t => {
  let answer = 3.14
  t->equal(answer, 3.14, "Should be a tasty dessert")
  done()
})
