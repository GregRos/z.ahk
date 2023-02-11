#include 01.zinit.ah2

class zTextWriter {
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

    class DebugSink extends zTextWriter.Sink {
        Put(text) {
            OutputDebug(text)
            return this
        }

        PutLn(text) {
            OutputDebug(text)
            return this
        }

    }

    class StdSink extends zTextWriter.Sink {
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

    class MemorySink extends zTextWriter.Sink {
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
                return zTextWriter.StdSink(nameOrObject)
            case "debug":
                return zTextWriter.DebugSink()
        }
        if nameOrObject is VarRef {
            return zTextWriter.MemorySink(nameOrObject)
        }
        if not IsObject(nameOrObject) {
            throw zBadInputError("Parameter 'sink' must be a sink or the name of a sink.")
        }
        return nameOrObject
    }
    _indents := []
    _prefix := ""
    _line := ""
    __New(sink, defaultIndent := "  ", indents := 0) {
        indents := IsObject(indents) ? indents : zz_arr.repeat(defaultIndent, indents)
        this._sink := zTextWriter.GetSink(sink)
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

    Put(text) {
        joined := this._line text
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
            curLine := zz_str.join(this._indents) curLine
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

    PutLn(text := "") {
        this.Put(text "`n")
        this._line := ""
        return this
    }
}