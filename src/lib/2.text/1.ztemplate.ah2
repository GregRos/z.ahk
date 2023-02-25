
; Like `Format`, but creates a template object that can be used to generate lots of different messages.
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

            this.Name := name == "" ? 1 : name
            this.Path := StrSplit(path, ".")
            this.Format := format
            this.FormatTK := "{1:" this.Format "}"
        }

        Call(value) {
            result := zz_obj.evalPath(value, this.Path)
            return Format(this.FormatTK, result)
        }
    }
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


    _evaluate(allArgs) {
        if not allArgs is Array {
            throw zBadInputError("Internal error - allArgs must be an array.")
        }
        text := ""
        for tk in this._tokens {
            if not tk is zTemplate.Token {
                ; A non-object string means verbatim text
                text .= tk
            } else if tk.Name <= allArgs.Length {
                ; Numbered tokens index the allArgs array.
                text .= tk(allArgs[tk.Name])
            } else {
                ; Referring to a token with an invalid number
                throw zBadInputError(Format("No value assigned to input number {1}.", tk.Name))
            }

        }
        decoded := zTemplate._decodeBraces(text)

        return decoded
    }

    Call(args*) {
        return this._evaluate(args)
    }

}

zTemplateMultiLineFormat(multiLineStringOrArray, template) {
    tmplt := zTemplate(template)
    wasString := False
    if multiLineStringOrArray is String {
        wasString := True
        multiLineStringOrArray := StrSplit(multiLineStringOrArray, "`n")
    }
    for i, line in multiLineStringOrArray {
        multiLineStringOrArray[i] := tmplt(line)
    }
    if wasString {
        return zz_str.join(multiLineStringOrArray, "`n")
    }
    return multiLineStringOrArray

}