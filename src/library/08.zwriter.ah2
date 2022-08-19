#include 01.zinit.ah2

class zz_Sinks {
     class Debug extends zTextSink {
            __New() {

            }
         WriteLine(text) {
             OutputDebug(text)
         }
     }

     class StdOut extends zTextSink {
    __New() {

    }
         WriteLine(text) {
             FileAppend(text, "*", "`n UTF-8")
         }
     }

     class StdErr extends zTextSink {
            __New() {

            }
         WriteLine(text) {
             FileAppend(text, "**", "`n UTF-8")
         }
     }

     class Memory extends zTextSink {
            __New() {

            }
        _buffer := ""
         WriteLine(text) {
            this._buffer .= text "`n"
         }

         Buffer {
             get =>this._buffer
         }
     }
}

class zTextSink {
    __New(args*) {
        throw zInvalidCallError("This class is abstract.")
    }

    WriteLine(text) {
        throw zNotImplementedError("You must override this method.")
    }
}

class zz_TextWriter {
    _indents := []
    _line := ""
    __New(sink, defaultIndent, indents) {
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

    Write(text) {
        lines := StrSplit(text, "`n")
        loop lines.Length - 1 {
            curLine := lines[A_Index]
            this._sink.WriteLine(curLine)
        }
        this._line .= lines[lines.Length]
        return this
    }
 
    WriteLine(text := "") {
        lines := text = "" ? [""] : StrSplit(text, "`n")
        loop lines.Length {
            line := lines[A_Index]
            buildLine := this._line line
            this._sink.WriteLine(buildLine)
            this._line := zz_str_join(this._indents)
        }
        return this
    }
}

zTextWriter(sink, defaultIndent := "  ", indents := 0) {
    static stdout := zz_Sinks.StdOut()
    static stderr := zz_Sinks.StdErr()
    static debug := zz_Sinks.Debug()
    if not IsObject(indents) {
        indents := zz_array_repeat(defaultIndent, indents)
    }
    switch sink {
        case "stdout":
            sink := stdout
        case "stderr":
            sink := stderr
        case "debug":
            sink := debug
    }
    if not sink is zTextSink {
        throw zBadInputError("Parameter 'sink' must be a valid sink name or a sink object.")
    }
    return zz_TextWriter(sink, defaultIndent, indents)
}

zTextWriter_String(withTextWriter, defaultIndent := "  ", indents := 0) {
    sink := zz_Sinks.Memory()
    writer := zTextWriter(sink, defaultIndent, indents)
    withTextWriter(writer)
    return sink.Buffer
}