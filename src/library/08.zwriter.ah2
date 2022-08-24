#include 01.zinit.ah2
class zz_writer {
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

    class DebugSink extends zz_writer.Sink {
        Put(text) {
            OutputDebug(text)
            return this
        }

        PutLn(text) {
            OutputDebug(text)
            return this
        }
        
    }

    class StdSink extends zz_writer.Sink {
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
            return this.Put(text)
        }

        Put(text) {
            FileAppend(text, this._out, "`n UTF-8")
            return this
        }
    }

    class MemorySink extends zz_writer.Sink {
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
                return zz_writer.StdSink(nameOrObject)
            case "debug":
                return zz_writer.DebugSink()
        }
        if nameOrObject is VarRef {
            return zz_writer.MemorySink(nameOrObject)
        }
        if not IsObject(nameOrObject) {
            throw zBadInputError("Parameter 'sink' must be a sink or the name of a sink.")
        }
        return nameOrObject
    }
}

class zTextWriter {
    _indents := []
    _prefix := ""
    _line := zz_none
    __New(sink, defaultIndent := "  ", indents := 0) {
        indents := IsObject(indents) ? indents : zz_array_repeat(defaultIndent, indents)
        this._sink := zz_writer.GetSink(sink)
        this._defaultIndent := defaultIndent
        this._indents := indents
        this._prefix := zz_str_join(this._indents)
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
        lines := StrSplit(text, "`n")
        if not lines.Length {
            return this
        }
        loop lines.Length - 1 {
            curLine := lines[A_Index]
            buildLine := this._line curLine
            this._sink.PutLn(buildLine)
            this._newLine()
        }
        this._line .= lines[lines.Length]
        return this
    }

    Flush() {
        this._sink.Put(this._line)
        this._newLine()
    }

    PutLn(text := "") {
        this.Put(text)
        this._sink.PutLn(this._line)
        this._newLine()
        return this
    }
}