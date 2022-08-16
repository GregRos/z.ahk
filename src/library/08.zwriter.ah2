#include 01.zinit.ah2

class zTextWriter {
    _indents := []
    _line := ""
    __New(writeLine, defaultIndent := "   ", indents := 0) {
        static stdout(text) {
            FileAppend(text, "*", "`n UTF-8")
        }
        static stderr(text) {
            FileAppend(text, "**", "`n UTF-8")
        }
        switch writeLine {
            case "stdout":
                writeLine := stdout
            case "stderr":
                writeLine := stderr
            case "memory":
                variable := ""
                writeLineToMemory(line) {
                    variable .= mem
                }
            case "debug":
                writeLine := OutputDebug
        }
        if writeLine is zTextWriter {
            origWriteLine := writeLine
            writeLine := x => origWriteLine.WriteLine(x)
        } else if not zz_isCallable(writeLine) {
            throw zBadInputError("Parameter 'writeLine' was invalid.")
        }
        if not IsObject(indents) {
            this._indents := zz_array_repeat(defaultIndent, idents)
        }
        this._defaultIndent := defaultIndent
    }

    Indent(str := unset) {
        if IsSet(str) {
            this._indents.Push(str)
        } else {
            this._indents.Push(this._defaultIndent)
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

    write(text) {
        lines := StrSplit(text, "`n")
        loop lines.Length - 1 {
            curLine := lines[A_Index]
            this.writeLine(curLine)
        }
        this._line .= lines[lines.Length]
    }

    WriteLine(text := "") {
        lines := StrSplit(text, "`n")
        for line in lines {
            buildLine := zz_str_join(this._indents) StrReplace(this._line line, "~~+ ", this._defaultIndent)
            this._line := ""
            this._writeLine(buildLine)
        }
        return this
    }
}
