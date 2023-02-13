// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Zora from "@dusty-phillips/rescript-zora/src/Zora.bs.mjs";
import * as Zora$1 from "zora";
import * as Telnet$DwApi from "../Telnet.bs.mjs";

Zora$1.test("telopt tokenizer", (function (t) {
        var iac = Telnet$DwApi.Token.make(255);
        t.equal(iac, {
              TAG: /* Telopt */1,
              _0: /* IAC */0
            }, "converts int to Telopt");
        t.equal(Telnet$DwApi.Token.to_string(iac), "IAC", "converts Telopt to string");
        return Zora.done(undefined);
      }));

Zora$1.test("line feed tokenizer", (function (t) {
        var lf = Telnet$DwApi.Token.make(9);
        t.equal(lf, {
              TAG: /* Control */2,
              _0: /* LF */0
            }, "converts int to Control");
        t.equal(Telnet$DwApi.Token.to_string(lf), "LF", "converts Control to string");
        return Zora.done(undefined);
      }));

Zora$1.test("ignorable tokenizer", (function (t) {
        var one99 = Telnet$DwApi.Token.make(199);
        t.equal(one99, {
              TAG: /* Ignore */3,
              _0: 199
            }, "converts non-alphanum to Ignore");
        t.equal(Telnet$DwApi.Token.to_string(one99), "199", "converts non-alphanum to number");
        return Zora.done(undefined);
      }));

Zora$1.test("actual letter tokenizer", (function (t) {
        var cap_F = Telnet$DwApi.Token.make(70);
        t.equal(cap_F, {
              TAG: /* Alphanum */0,
              _0: "F"
            }, "converts letter to Alphanum");
        t.equal(Telnet$DwApi.Token.to_string(cap_F), "F", "converts Alphanum to string");
        return Zora.done(undefined);
      }));

Zora$1.test("base cases", (function (t) {
        var eof = Telnet$DwApi.Parser.run([]);
        Zora.resultError(t, eof, "error result");
        var single = Telnet$DwApi.Parser.run([0]);
        Zora.resultOk(t, single, (function (t, expected) {
                t.equal(expected, [
                      0,
                      /* [] */0
                    ], "single element");
              }));
        var more = Telnet$DwApi.Parser.run([
              2,
              3,
              4
            ]);
        Zora.resultOk(t, more, (function (t, expected) {
                t.equal(expected, [
                      2,
                      {
                        hd: 3,
                        tl: {
                          hd: 4,
                          tl: /* [] */0
                        }
                      }
                    ], "multiple elements");
              }));
        return Zora.done(undefined);
      }));

var Token;

var Parser;

export {
  Token ,
  Parser ,
}
/*  Not a pure module */
