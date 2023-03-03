class zz_trace {

    class Function {
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

        Match(regex) {
            return RegExMatch(this.ToString(), regex)
        }

        ToString() {
            return this.IsMethod ? Format("{1}.{2}", this.Class, This.Name) : this.Name
        }
    }

    class Frame {
        File := ""
        Line := ""
        Function := ""
        Quote := ""
        __New(file, line, function?, quote?) {
            this.File := zz_trace.SourceFile(file)
            this.Line := line
            this.Function := IsSet(function) ? zz_trace.Function(function) : ""
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


    }

    class SourceFile {
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

        Match(regex) {
            return RegExMatch(this.Path, regex)
        }

    }

    class Trace {
        __New(frames) {
            this._frames := frames
        }

        __Enum(count?) {
            return this._frames.__Enum(count?)
        }

        __Item[pos] {
            get {
                return this._frames[pos]
            }
        }

        Length {
            get {
                return this._frames.Length
            }
        }

        Skip(count) {
            return zz_trace.Trace(zz_arr.take(this._frames, count + 1))
        }

        Take(count) {
            return zz_trace.Trace(zz_arr.take(this._frames, count))
        }

        Filter(predicate) {
            return zz_trace.Trace(zz_arr.filter(this._frames, predicate))
        }

        FindIndex(predicate) {
            return zz_arr.find(this._frames, predicate).Key
        }

        FindLastIndex(predicate) {
            return zz_arr.findLast(this._frames, predicate).Key
        }

    }
}

zTrace(err := Error()) {
    if err.HasProp("zTrace") {
        return err.zTrace
    }
    stack := err.Stack
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
        trace.Push(zz_trace.Frame(file, line, output.3, output.4))
    }
    head := trace[1]
    if head.File.Path != err.File or head.Line != err.Line {
        trace.Push(zz_trace.Frame(err.File, err.Line))
    }

    return zz_trace.Trace(trace)
}