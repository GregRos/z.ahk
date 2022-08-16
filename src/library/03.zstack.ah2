

class zz_AutoExecFrame {
    __New() {

    }

    ToString() {
        return "Auto-execute"
    }

    isScript {
        get => False
    }
}

class zz_FuncInfo {
    class Method {
        __New(cls, name, isInstance) {
            this.Class := cls
            this.Name := name
            this.IsInstance := isInstance
        }

        isMethod {
            get => True
        }

        Display {
            get => Format("{1}.{2}", this.Class, this.Name)
        }

        ToString() {
            return this.Display
        }
    }
    class Function {
        __New(name) {
            this.Name := name
        }

        isMethod {
            get => False
        }

        Display {
            get => this.Name
        }

        ToString() {
            return this.Display
        }
    }

    static Call(line) {
        static matchMethod := "^([^.]*)(\.Prototype)?\.([^.]*)$"
        if RegExMatch(line, matchMethod, &result) {
            return zz_FuncInfo.Method(result[1], result[3], !!result[2])
        } else {
            return zz_FuncInfo.Function(line)
        }
    }
}


class zz_CallFrame {
     __New(file, ln, function := unset, quote := unset) {
        frame := this
        frame.File := file
        frame.Line := ln
        frame.Function := IsSet(function) ? zz_FuncInfo(function) : ''
        frame.Quote := quote ?? ''
    }

    ToString() {
        static tmFrame := zTemplate("{Function.Display} @ {File}:{Line} | {Quote}")
        x := tmFrame.Render(this)
        return x
    }

    isScript {
        get => True
    }
}

zz_stack_parseTrace(error, skip := 0) {
    stack := error.Stack
    frames := StrSplit(stack, "`r`n")
    frameRegexp := "^(.*) \((\d+)\) : (?:\[(.*)\] (.*))?"
    trace := []
    for frame in frames {
        if not frame {
            continue
        }
        if InStr(frame, "Auto-execute") {
            trace.Push(zz_AutoExecFrame())
            continue
        }
        output := ""
        RegExMatch(frame, frameRegexp, &output)
        file := output.1
        line := output.2
        trace.Push(zz_CallFrame(file, line, output.3, output.4))
    }
    head := trace[1]
    if head.isScript and (head.File != error.File or head.Line != error.Line) {
        trace.Push(zz_CallFrame(error.File, error.Line))
    }
    trace := zz_array_slice(trace, skip + 1)
    return trace
}


zz_stack_capture(skip := 0) {
    err := Error()
    stack := zz_stack_parseTrace(err, skip + 1)
    return stack
}
