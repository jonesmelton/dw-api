  let parse = (char, stream) => {
    switch stream {
      | list{} => Result.Error("end of stream")
      | list{only} => Result.Ok((only, list{}))
      | list{head, ...tail} => Result.Ok((head, tail))
    }
  }

  let run = (char, arr) => {
    let res = parse(List.fromArray(arr))
    res
  }
