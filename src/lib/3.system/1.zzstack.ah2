class zAhkSourceFile {
    Path := ""
    __New(path) {
        this.Path := path
    }

    Lines {
        get {
            if HasProp(this, "_lines") {
                return this._lines
            }
            this.DefineProp("_lines", {
                Value: StrSplit(FileRead(this.Path, "`n UTF-8"), "`n")
            })
            return this._lines
        }
    }
}

class zz_stack {
    class Frame {
        File := ""
        Line := ""
        Function := ""
        Quote := ""
        __New(file, line, function?, quote?) {
            this.File := zAhkSourceFile(file)
            this.Line := line
            this.Function := IsSet(function) ? zz_stack.FunctionInfo(function) : ""
            this.Quote := quote
        }

        Format(tmplt) {
            return tmplt(this)
        }

        ToString() {
            static tmFrame := zTemplate("➜ {.Function} ({.File.Path}:{.Line})")
            x := tmFrame(this)
            return x
        }

        static Parse(error, skip := 0) {
            if error.stack is Array {
                return error.stack
            }
            stack := error.Stack
            frames := StrSplit(stack, "`r`n")
            frameRegexp := "^(.*) \((\d+)\) : (?:\[(.*)\] (.*))?"
            trace := []
            for frame in frames {
                if not frame {
                    continue
                }
                if InStr(frame, "Auto-execute") {
                    continue
                }
                output := ""
                if not RegExMatch(frame, frameRegexp, &output) {
                    break
                }

                file := output.1
                line := output.2
                trace.Push(zz_stack.Frame(file, line, output.3, output.4))
            }
            head := trace[1]
            if head.File.Path != error.File or head.Line != error.Line {
                trace.Push(zz_stack.Frame(error.File, error.Line))
            }
            trace := zz_arr.slice(trace, skip + 1)
            trace := zz_arr.filter(trace, frame => !zz_str.hasAny(frame.Function.ToString(), "zTest", "zz_Test", "Func.Call"))
            return trace
        }
    }


    class FunctionInfo {
        Class := ""
        Name := ""
        IsInstance := False
        __New(functionPart) {
            static matchMethod := "^([^.]*)(\.Prototype)?\.([^.]*)$"
            if RegExMatch(functionPart, matchMethod, &result) {
                this.Class := result[1]
                this.Name := result[3]
                this.IsInstance := !!result[2]
            } else {
                this.Name := functionPart
            }
        }

        IsMethod {
            get => !!this.Class
        }

        ToString() {
            return this.IsMethod ? Format("{1}.{2}", this.Class, This.Name) : this.Name
        }


    }

    class SourceFile {

    }

    static capture(skip := 1) {
        err := Error()
        stack := zz_stack.Frame.Parse(err, skip)
        return stack
    }

}