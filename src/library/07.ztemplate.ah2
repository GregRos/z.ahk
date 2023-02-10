#include 01.zinit.ah2

class zTemplate {
    static replaceOpen := "[~[["
    static replaceClose := "]~]]"
    static _encodeBraces(input) {
        return StrReplace(StrReplace(input, "{{}", zTemplate.replaceOpen), "{}}", zTemplate.replaceClose)
    }

    static _decodeBraces(input) {
        return StrReplace(StrReplace(input, zTemplate.replaceOpen, "{"), zTemplate.replaceClose, "}")
    }
    class Token {
        __New(name, path := "", format := "") {
            this.Name := name
            this.Path := StrSplit(path, ".")
            this.Format := format
            this.FormatTK := "{1:" this.Format "}"
        }

        Call(value) {
            result := zz_evaluatePath(value, this.Path)
            return Format(this.FormatTK, result)
        }
    }
    _post := []
    __New(template) {
        template := zTemplate._encodeBraces(template)
        tokens := StrSplit(template, ["{", "}"])
        loop tokens.Length {
            if Mod(A_Index, 2) = 0 {
                tk := Trim(tokens[A_Index])
                splitFormat := StrSplit(tk, ":", , 2)
                splitPath := StrSplit(splitFormat[1], ".", , 2)
                stt := zTemplate.Token(splitPath[1], splitPath.Length > 1 ? splitPath[2] : unset, splitFormat.Length > 1 ? splitFormat[2] : unset)
                tokens[A_Index] := stt
            } else {
                tokens[A_Index] := zTemplate._decodeBraces(tokens[A_Index])
            }

        }
        this._tokens := tokens
    }

    Map(post) {
        this._post.Push(post)
    }

    _evaluate(allArgs) {
        text := ""
        for tk in this._tokens {
            if tk is zTemplate.Token {
                if not allArgs.Has(tk.Name) {
                    throw zBadInputError(Format("No value assigned for template input '{1}'.", tk.Name))
                }
                text .= tk(allArgs[tk.Name])
            } else {
                text .= tk
            }
        }
        decoded := zTemplate._decodeBraces(text)
        for step in this._post {
            decoded := step(decoded)
        }
        return decoded
    }

    Call(argsKeyed := {}, argsIndexed*) {
        if not IsObject(argsKeyed) {
            argsIndexed.InsertAt(1, argsKeyed)
            argsKeyed := {}
        }
        allArgs := Map()
        allArgs.CaseSense := False
        for key, value in ObjOwnProps(argsKeyed) {
            allArgs[key] := value
        }
        for ix, value in argsIndexed {
            allArgs[String(ix)] := value
        }
        return this._evaluate(allArgs)
    }
}
