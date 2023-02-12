// module type Parser = {
//   let parse: (int, array<int>) => result<string, (int, option<list<int>>)>
// }

module Parser = {
  let parse = (char, stream) => {
    switch stream {
      | list{} => Result.Error("end of stream")
      | list{only} => Result.Ok((only, None))
      | list{head, ...tail} => Result.Ok((head, Some(tail)))
    }
  }

  let run = (char, arr) => {
    if Array.length(arr) == 0 {
      Result.Error("end of stream")
    } else {
      parse(char, List.fromArray(arr))
    }
  }
}
