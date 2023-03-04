

zColorParse(input) {
    reduceUntilOpener(stack) {
        pos := 0
        loop stack.Length {
            cur := stack[-A_Index]
            if cur is zz_color.Run or not IsObject(cur) {
                pos := A_Index
            } else if cur is zz_color.OpenRunToken {
                ; We found the open run token
                ; Trim all the tokens we've scanned
                slice := zz_arr.slice(stack, -A_Index + 1)
                stack.Length -= A_Index
                return cur.Wrap(slice)
            }
        }
        ; We reached the end of the stack, but no run opener
        throw zSyntaxError("Unexpected [!]", input, StrLen(input))
    }
    stack := []
    ; apply the lexers to get tokens
    tokens := zz_color.lex(input)
    ; Go over the tokens
    for t in tokens {
        if t != zz_none {
            ; If it's not an end token, push to stack (shift)
            stack.Push(t)
        } else {
            ; If it is an end token [!], reduce
            run := reduceUntilOpener(stack)
            stack.Push(run)
        }
    }
    finalRunKids := []
    for item in stack {
        if item is zz_color.Run or not IsObject(item) {
            finalRunKids.Push(item)
        } else if item !== "" is zz_color.OpenRunToken {
            ; An unclosed run means missing [!]
            throw zSyntaxError(
                Format("not terminated"),
                input,
                item.Pos
            )
        }
    }
    return zz_color.Run(finalRunKids, [])
}

zColor(textOrObject) {
    if not IsSet(textOrObject) {
        return zz_color.makeDefault()
    } else if not IsObject(textOrObject) {
        return zz_color.default.Call(textOrObject)
    } else if IsObject(textOrObject) {
        return zz_color.default.Aliases(textOrObject)
    }
}


zColorStrip(text) {
    return zz_color.strip(text)
}


class zz_color {

    static tokenRegexp := "\[!([^\]]+)]|(\[!])"
    static stripRegexp := "\[!.*?\]"
    static strip(input) {
        result := RegExReplace(input, this.stripRegexp, "")
        return result
    }
    static lex(input) {
        return zz_str.split(input, zz_color.tokenRegexp, m => m.1 != "" ? zz_color.OpenRunToken(m.Pos, m.1) : zz_none, , True)
    }
    static unexpectedError(expected, got) {
        return zBadInputError(Format("Expected {0}", expected), )
    }

    static verbatim(text) {
        return StrReplace(text, "[!", "[\!")
    }

    static unescape(text) {
        return StrReplace(text, "[\!", "[!")
    }

    static makeDefault() {
        renderer := zz_color.Renderer({
            ; MODIFIERS
            reset: zz_color.Ansi16(0, 0),
            bold: zz_color.Ansi16(1, 22),
            dim: zz_color.Ansi16(2, 22),
            italic: zz_color.Ansi16(3, 23),
            underline: zz_color.Ansi16(4, 24),
            overline: zz_color.Ansi16(53, 55),
            inverse: zz_color.Ansi16(7, 27),
            hidden: zz_color.Ansi16(8, 28),
            strikethrough: zz_color.Ansi16(9, 29),
            ; FG COLOR
            black: zz_color.Ansi16(30, 39),
            red: zz_color.Ansi16(31, 39),
            green: zz_color.Ansi16(32, 39),
            yellow: zz_color.Ansi16(33, 39),
            blue: zz_color.Ansi16(34, 39),
            magenta: zz_color.Ansi16(35, 39),
            cyan: zz_color.Ansi16(36, 39),
            white: zz_color.Ansi16(37, 39),
            blackBright: zz_color.Ansi16(90, 39),
            redBright: zz_color.Ansi16(91, 39),
            greenBright: zz_color.Ansi16(92, 39),
            yellowBright: zz_color.Ansi16(93, 39),
            blueBright: zz_color.Ansi16(94, 39),
            magentaBright: zz_color.Ansi16(95, 39),
            cyanBright: zz_color.Ansi16(96, 39),
            whiteBright: zz_color.Ansi16(97, 39),
            ; BG COLOR
            bgBlack: zz_color.Ansi16(40, 49),
            bgRed: zz_color.Ansi16(41, 49),
            bgGreen: zz_color.Ansi16(42, 49),
            bgYellow: zz_color.Ansi16(43, 49),
            bgBlue: zz_color.Ansi16(44, 49),
            bgMagenta: zz_color.Ansi16(45, 49),
            bgCyan: zz_color.Ansi16(46, 49),
            bgWhite: zz_color.Ansi16(47, 49),
            bgBlackBright: zz_color.Ansi16(100, 49),
            bgRedBright: zz_color.Ansi16(101, 49),
            bgGreenBright: zz_color.Ansi16(102, 49),
            bgYellowBright: zz_color.Ansi16(103, 49),
            bgBlueBright: zz_color.Ansi16(104, 49),
            bgMagentaBright: zz_color.Ansi16(105, 49),
            bgCyanBright: zz_color.Ansi16(106, 49),
            bgWhiteBright: zz_color.Ansi16(107, 49),
            ; Aliases
            uline: "underline",
            oline: "overline",
            strike: "strikethrough",
            o: "overline",
            u: "underline",
            s: "strikethrough",
            b: "bold",
            i: "italic",
            d: "dim",
            h: "hidden",
            v: "inverse",
            r: "reset",
            grey: "blackBright",
            gray: "blackBright",
            bgGray: "bgBlackBright",
            bgGrey: "bgBlackBright"
        })

        ; Here we alias redBright to brightRed
        ; And bgRedBright to bgBrightRed and so on
        for key in renderer.Keys {
            aliasKey := RegExReplace(key, "^bg([A-Z][a-z]*)Bright", "bgBright$1", &count)
            if count > 0 {
                renderer._setAlias(aliasKey, key)
                continue
            }
            aliasKey := RegExReplace(key, "^([a-z]*)Bright", "bright$T1", &count)
            if count > 0 {
                renderer._setAlias(aliasKey, key)
                continue
            }
        }

        return renderer
    }

    static default := zz_color.makeDefault()

    class Run {
        __New(kids, directives) {
            newKids := []
            this.Kids := kids
            this.Directives := directives
        }
    }
    class OpenRunToken {
        __New(pos, directives) {
            this.Pos := pos
            this.Directives := zz_str.trimEach(StrSplit(directives, " "))
        }

        ToString() {
            return Format("[!{1}]", zz_str.join(this.Directives, " "))
        }

        Wrap(kids) {
            return zz_color.Run(kids, this.Directives)
        }
    }


    class Ansi16 {

        __New(open, close) {
            this.Open := zz_ansiEscape(open "m")
            this.Close := zz_ansiEscape(close "m")
        }

        Call(text) {
            text := StrReplace(text, this.Close, this.Open)
            return this.Open text this.Close
        }
    }

    class Combined {
        __New(kids) {
            merged := []
            for kid in kids {
                if kid is zz_color.Combined {
                    for subKid in kid {
                        merged.Push(subKid)
                    }
                } else {
                    merged.Push(kid)
                }
            }
            this._kids := merged
        }

        __Enum(vars) {
            return this._kids.__Enum(vars)
        }

        Call(text) {
            for kid in this._kids {
                text := kid(text)
            }
            return text
        }
    }

    class Renderer {
        __New(formatters) {
            this._formatters := zz_obj.toMap(formatters)

            ; Process aliases:
            for key, value in this._formatters {
                if not IsObject(value) {
                    this._formatters[key] := this._formatters[value]
                }
            }
        }

        __Item[key] {
            get {
                return this._formatters[key]
            }
        }

        _resolveDirectives(directives) {
            formatters := []
            for kw in directives {
                kw := Trim(kw)
                if kw == "" {
                    continue
                }
                if not this.Has(kw) {
                    throw zBadInputError(Format("Unknown formatting option '{1}'.", kw))
                }
                formatter := this[kw]
                formatters.Push(formatter)
            }
            if formatters.Length = 1 {
                return formatters[1]
            }
            if formatters.Length = 0 {
                return x => x
            }
            return zz_color.Combined(formatters)
        }

        Call(text) {
            
            if not InStr(text, "[!]") {
                return text
            }
            run := zColorParse(text)
            result := this._renderRun(run)
            return zz_color.unescape(result)
        }

        _renderRun(run) {
            text := ""
            for kid in run.kids {
                curText := kid
                if kid is zz_color.Run {
                    ; Recursively render children
                    curText := this._renderRun(kid)
                }
                text .= curText
            }
            formatter := this._resolveDirectives(run.Directives)
            ; Split based on lines, as ANSI directives don't persist between lines
            lines := StrSplit(text, "`n")
            ; Apply all the formatters from the directives to each line of the run.
            lines := zz_arr.map(lines, formatter)
            ; Join the lines back up
            text := zJoin(lines, "`n")
            return text
        }

        Keys {
            get => zz_Inspect(this._formatters).keys
        }

        __Enum(x) {
            return this._formatters.__Enum(x)
        }

        _setAlias(alias, target) {
            resolved := this._resolveDirectives(StrSplit(target, " "))
            this._formatters[alias] := resolved
        }

        _setAliases(aliases) {
            for alias, target in ObjOwnProps(aliases) {
                this._setAlias(alias, target)
            }
            return this
        }

        Clone() {
            return zz_color.Renderer(this._formatters.Clone())
        }

        Aliases(aliases) {
            clone := this.Clone()._setAliases(aliases)
            return clone
        }

        Has(key) {
            return this._formatters.Has(key)
        }
    }


}
