#include 01.zinit.ah2
class zz_writer {
    class Sink {
        PutLn(text) {
            this.Put(text "`n")
        }

        Call(text) {
            this.PutLn(text)
        }

        Put(text) {
            throw zNotImplementedError("The 'Put' method must be implemented.")
        }
    }
    
    class DebugSink extends zz_writer.Sink {
        Put(text) {
            OutputDebug(text)
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

        Put(text) {
            FileAppend(text, this._out, "`n UTF-8")
        }
    }

    class MemorySink extends zz_writer.Sink {
        __New(ref) {
            this._ref := ref
        }

        Put(text) {
            %this._ref% .= text
        }
    }
}

class zTextWriter {
    _indents := []
    _line := ""
    __New(sink, defaultIndent := "  ", indents := 0) {
        indents := IsObject(indents) ? indents : zz_array_repeat(defaultIndent, indents)
        switch sink {
            case "stdout", "stderr":
                sink := zz_writer.StdSink(sink)
            case "debug":
                sink := zz_writer.DebugSink()
        }
        if sink is VarRef {
            sink := zz_writer.MemorySink(sink)
        }
        if not IsObject(sink) {
            throw new zBadInputError("Parameter 'sink' must be a sink or the name of a sink.")
        }
        this._sink := sink
        this._defaultIndent := defaultIndent
        this._indents := indents
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

    Put(text) {
        lines := StrSplit(text, "`n")
        loop lines.Length - 1 {
            curLine := lines[A_Index]
            buildLine := this._line curLine
            this._sink.PutLn(buildLine)
            this._line := zz_str_join(this._indents)
        }
        this._line .= lines[lines.Length]
        return this
    }

    Flush() {
        this._sink.Put(this._line)
        this._line := zz_str_join(this._indents)
    }

    PutLn(text := "") {
        this.Put(text "`n")
    }
}