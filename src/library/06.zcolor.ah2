#include 01.zinit.ah2
class zz_Run {
    __New(kids, directives) {
        newKids := []
        this.Kids := kids
        this.Directives := directives
    }
}

class zz_OpenRunToken {
    __New(pos, directives) {
        this.Pos := pos
        this.Directives := zz_strArray_clean(StrSplit(directives, " "))
    }

    ToString() {
        return Format("[!{1}]", zz_str_join(this.Directives, " "))
    }

    Wrap(kids) {
        return zz_Run(kids, this.Directives)
    }
}

zz_color_parse(input) {
    static lex(input) {
        return zz_regex_split(input, "\[!([^\]]+)]|(\[!])", m => m.1 ? zz_OpenRunToken(m.Pos, m.1) : zz_emptyPlaceholder, , True)
    }
    static reduceUntilOpener(stack) {
        pos := 0
        loop stack.Length {
            cur := stack[-A_Index]
            if cur is zz_Run or not IsObject(cur) {
                pos := A_Index
            } else if cur is zz_OpenRunToken {
                ; We found the open run token
                ; Trim all the tokens we've scanned
                slice := zz_array_slice(stack, -A_Index + 1)
                stack.Length -= A_Index
                return cur.Wrap(slice)
            }
        }
        ; We reached the end of the stack, but no run opener
        throw zBadInputError("Found run terminator [!] at but no matching run opener [!...].")
    }
    stack := []
    ; apply the lexers to get tokens
    tokens := lex(input)
    ; Go over the tokens
    for t in tokens {
        if t != zz_emptyPlaceholder {
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
        if item is zz_Run or not IsObject(item) {
            finalRunKids.Push(item)
        } else if item is zz_OpenRunToken {
            throw zBadInputError(Format("Expected [!] run terminator for run token '{1}' at position {2}.", item.ToString(), item.Pos))
        }
    }
    return zz_Run(finalRunKids, [])
}

zz_color_ansi16Escape(code) {
    esc := Chr(0x001b)
    return esc "[" code "m"
}

class zz_Ansi16 {
    __New(open, close) {
        this.Open := zz_color_ansi16Escape(open)
        this.Close := zz_color_ansi16Escape(close)
    }

    Call(text) {
        text := StrReplace(text, this.Close, this.Open)
        return this.Open text this.Close
    }
}

class zz_CombinedFormatter {
    __New(kids) {
        merged := []
        for kid in kids {
            if kid is zz_CombinedFormatter {
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

class zz_ColorRenderer {
    __New(formatters) {
        this._formatters := formatters
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
            if not kw {
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
            return zz_identity
        }
        return zz_CombinedFormatter(formatters)
    }

    Call(text) {
        if not InStr(text, "[!]") {
            return text
        }
        run := zz_color_parse(text)
        return this._renderRun(run)
    }

    _renderRun(run) {
        text := ""
        for kid in run.kids {
            curText := kid
            if kid is zz_Run {
                ; Recursively render children
                curText := this._renderRun(kid)
            }
            text .= curText
        }
        formatter := this._resolveDirectives(run.Directives)
        ; Apply all the formatters from the directives to the run.
        text := formatter(text)
        return text
    }

    Keys {
        get => zz_map_getKeys(this._formatters)
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
        return zz_ColorRenderer(this._formatters.Clone())
    }

    Aliases(aliases) {
        clone := this.Clone()._setAliases(aliases)
        return clone
    }

    Has(key) {
        return this._formatters.Has(key)
    }
}

zz_color_getDefaultRenderer() {
    core := {
        ; MODIFIERS
        reset: zz_Ansi16(0, 0),
        bold: zz_Ansi16(1, 22),
        dim: zz_Ansi16(2, 22),
        italic: zz_Ansi16(3, 23),
        underline: zz_Ansi16(4, 24),
        overline: zz_Ansi16(53, 55),
        inverse: zz_Ansi16(7, 27),
        hidden: zz_Ansi16(8, 28),
        strikethrough: zz_Ansi16(9, 29),

        ; FG COLOR
        black: zz_Ansi16(30, 39),
        red: zz_Ansi16(31, 39),
        green: zz_Ansi16(32, 39),
        yellow: zz_Ansi16(33, 39),
        blue: zz_Ansi16(34, 39),
        magenta: zz_Ansi16(35, 39),
        cyan: zz_Ansi16(36, 39),
        white: zz_Ansi16(37, 39),
        blackBright: zz_Ansi16(90, 39),
        redBright: zz_Ansi16(91, 39),
        greenBright: zz_Ansi16(92, 39),
        yellowBright: zz_Ansi16(93, 39),
        blueBright: zz_Ansi16(94, 39),
        magentaBright: zz_Ansi16(95, 39),
        cyanBright: zz_Ansi16(96, 39),
        whiteBright: zz_Ansi16(97, 39),

        ; BG COLOR
        bgBlack: zz_Ansi16(40, 49),
        bgRed: zz_Ansi16(41, 49),
        bgGreen: zz_Ansi16(42, 49),
        bgYellow: zz_Ansi16(43, 49),
        bgBlue: zz_Ansi16(44, 49),
        bgMagenta: zz_Ansi16(45, 49),
        bgCyan: zz_Ansi16(46, 49),
        bgWhite: zz_Ansi16(47, 49),

        bgBlackBright: zz_Ansi16(100, 49),
        bgRedBright: zz_Ansi16(101, 49),
        bgGreenBright: zz_Ansi16(102, 49),
        bgYellowBright: zz_Ansi16(103, 49),
        bgBlueBright: zz_Ansi16(104, 49),
        bgMagentaBright: zz_Ansi16(105, 49),
        bgCyanBright: zz_Ansi16(106, 49),
        bgWhiteBright: zz_Ansi16(107, 49),
    }
    formatters := Map()
    formatters.CaseSense := False
    for formatKey, formatter in ObjOwnProps(core) {
        formatters[formatKey] := formatter
    }
    renderer := zz_ColorRenderer(formatters)
    aliases := {
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
        r: "reset"
    }

    ; Here we alias redBright to brightRed
    ; And bgRedBright to bgBrightRed and so on
    for key in renderer.Keys {
        aliasKey := RegExReplace(key, "^bg([A-Z][a-z]*)Bright", "bgBright$1", &count)
        if count > 0 {
            aliases.%aliasKey% := key
            continue
        }
        aliasKey := RegExReplace(key, "^([a-z]*)Bright", "bright$T1", &count)
        if count > 0 {
            aliases.%aliasKey% := key
            continue
        }
    }
    return renderer.Aliases(aliases)
}

zColor := zz_color_getDefaultRenderer()
