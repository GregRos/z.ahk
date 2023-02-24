

zWriterSink(nameOrObject) {
    return zz_sink.GetSink(nameOrObject)
}

zWriter(sink, defaultIndent := "  ", indents := 0) {
    return zz_TextWriter(sink, defaultIndent, indents)
}

class zz_TextWriter {
    _indents := []
    _prefix := ""
    _line := ""
    __New(sink, defaultIndent := "  ", indents := 0) {
        indents := IsObject(indents) ? indents : zz_arr.repeat(defaultIndent, indents)
        this._sink := zz_sink.GetSink(sink)
        this._defaultIndent := defaultIndent
        this._indents := indents
        this._prefix := zz_str.join(this._indents)
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

    _newLine() {
        this._line := ""
    }


    Put(text := "", args*) {

        if IsObject(text) {
            text := text.ToString()
        }
        if args.Length {
            text := zTemplate(text)(args*)
        }
        if not this._line {
            this._line := zz_str.join(this._indents)
        }
        joined := this._line text
        this._line := ""
        if not joined {
            return this
        }
        lines := StrSplit(joined, "`n")
        if lines.Length = 1 {
            this._line := joined
            return this
        }

        loop lines.Length - 1 {
            curLine := lines[A_Index]
            if A_Index > 1 {
                curLine := zz_str.join(this._indents) curLine
            }

            this._sink.PutLn(curLine)
        }
        lastLine := lines[-1]
        if lastLine {
            this._line .= zz_str.join(this._indents) lastLine
        } else {
            this._line := ""
        }
        return this
    }

    Flush() {
        if this._line {
            this._sink.Put(this._line)
        }
        this._line := ""
    }

    PutLn(text := "", args*) {
        if args.Length {
            text := zTemplate(text)(args*)
        }
        indentForLine := zz_str.join(this._indents, "")
        if not this._line {
            this._line := indentForLine
        }
        line := this._line text
        line := StrReplace(line, "`n", "`n" indentForLine)
        this._sink.PutLn(line)
        this._line := ""
        return this
    }
}
class zz_sink {
    class Sink {
        PutLn(text) {
            return this.Put(text "`n")
        }

        Call(text) {
            return this.PutLn(text)
        }

        Put(text) {
            throw zNotImplementedError("The 'Put' method must be implemented.")
        }
    }

    class DebugSink extends zz_sink.Sink {
        Put(text) {
            OutputDebug(text)
            return this
        }

        PutLn(text) {
            OutputDebug(text)
            return this
        }

    }

    class StdSink extends zz_sink.Sink {
        __New(type) {
            if type = "stderr" {
                this._out := "**"
            } else if type = "stdout" {
                this._out := "*"
            } else {
                throw zBadInputError("Invalid std sink type '" type "'. Expected 'stdout' or 'stderr'.")
            }
        }

        PutLn(text) {
            return this.Put(text "`n")
        }

        Put(text) {
            FileAppend(text, this._out, "`n UTF-8")
            return this
        }
    }

    class MemorySink extends zz_sink.Sink {
        __New(ref) {
            this._ref := ref
        }

        Put(text) {
            %this._ref% .= text
            return this
        }
    }

    static GetSink(nameOrObject) {
        switch nameOrObject {
            case "stdout", "stderr":
                return zz_sink.StdSink(nameOrObject)
            case "debug":
                return zz_sink.DebugSink()
        }
        if nameOrObject is VarRef {
            return zz_sink.MemorySink(nameOrObject)
        }
        if not IsObject(nameOrObject) {
            throw zBadInputError("Parameter 'sink' must be a sink or the name of a sink.")
        }
        return nameOrObject
    }

}