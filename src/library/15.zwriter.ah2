#include 01.zinit.ah2
#include 07.ztemplate.ah2
#include 06.zcolor.ah2

class zz_TextWriter {
    _indents := []
    __New(writeLine, defaultIndentString := "    ", indents := 0) {
        if indents is Array {
            this._indents := indents
        } else {
            this._indents := zz_array_repeat(defaultIndentString, indents)
        }
        this._writeLine := zz_normFuncToMethod(writeLine)
        this._defaultIndentString := defaultIndentString
    }

    Indent(str := unset) {
        if IsSet(str) {
            this._indents.Push(str)
        } else {
            this._indents.Push(this._defaultIndentString)
        }
        return this
    }

    Unindent() {
        if this._indents.Length <= 0 {
            throw zBadStateError("Cannot unindent because this TextWriter has indent level 0.")
        }
        this._indents.Pop()
        return this
    }

    WriteLine(text := "") {
        lines := StrSplit(text, "`n")
        for line in lines {
            buildLine := zz_str_join(this._indents) StrReplace(line, "~~+ ", this._defaultIndentString)
            this._writeLine(buildLine)
        }
        return this
    }
}
