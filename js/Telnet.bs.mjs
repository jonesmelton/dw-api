// Generated by ReScript, PLEASE EDIT WITH CARE


function make(uint8) {
  if (uint8 >= 240) {
    if (uint8 === 250) {
      return {
              TAG: /* Telopt */1,
              _0: /* SB */1
            };
    }
    if (uint8 === 255) {
      return {
              TAG: /* Telopt */1,
              _0: /* IAC */0
            };
    }
    if (uint8 < 241) {
      return {
              TAG: /* Telopt */1,
              _0: /* SE */2
            };
    }
    
  } else if (uint8 >= 14) {
    if (uint8 === 201) {
      return {
              TAG: /* Telopt */1,
              _0: /* GMCP */3
            };
    }
    
  } else if (uint8 >= 9) {
    switch (uint8) {
      case 9 :
          return {
                  TAG: /* Control */2,
                  _0: /* LF */0
                };
      case 10 :
          return {
                  TAG: /* Control */2,
                  _0: /* CR */1
                };
      case 11 :
      case 12 :
          break;
      case 13 :
          return {
                  TAG: /* Control */2,
                  _0: /* Tab */2
                };
      
    }
  }
  if (uint8 < 32 || uint8 > 126) {
    return {
            TAG: /* Ignore */3,
            _0: uint8
          };
  } else {
    return {
            TAG: /* Alphanum */0,
            _0: String.fromCharCode(uint8)
          };
  }
}

function to_string(token) {
  switch (token.TAG | 0) {
    case /* Alphanum */0 :
        return token._0;
    case /* Telopt */1 :
        switch (token._0) {
          case /* IAC */0 :
              return "IAC";
          case /* SB */1 :
              return "SB";
          case /* SE */2 :
              return "SE";
          case /* GMCP */3 :
              return "GMCP";
          
        }
    case /* Control */2 :
        switch (token._0) {
          case /* LF */0 :
              return "LF";
          case /* CR */1 :
              return "CR";
          case /* Tab */2 :
              return "TAB";
          
        }
    case /* Ignore */3 :
        return String(token._0);
    
  }
}

var Token = {
  make: make,
  to_string: to_string
};

function pchar(target, chars) {
  if (!chars) {
    return {
            TAG: /* Error */1,
            _0: "end of stream"
          };
  }
  var remaining = chars.tl;
  var only = chars.hd;
  if (remaining) {
    if (only === target) {
      return {
              TAG: /* Ok */0,
              _0: [
                only,
                remaining
              ]
            };
    } else {
      return {
              TAG: /* Error */1,
              _0: "unexpected char -- expected: target, got: ch"
            };
    }
  } else if (only === target) {
    return {
            TAG: /* Ok */0,
            _0: [
              only,
              /* [] */0
            ]
          };
  } else {
    return {
            TAG: /* Error */1,
            _0: "unexpected char"
          };
  }
}

var Parser = {
  pchar: pchar
};

export {
  Token ,
  Parser ,
}
/* No side effect */
