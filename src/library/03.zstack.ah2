
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

class zz_StackFrame {

     __New(file, ln, function := unset, quote := unset) {
        frame := this
        frame.File := file
        frame.Line := ln
        frame.Function := function ?? ''
        frame.Quote := quote ?? ''
        return frame
    }

    ToString() {
        x := Format("{1}:{2}", this.File, this.Line)
        return x
    }

    isScript {
        get => True
    }
}

zz_stack_parse(error) {
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
        trace.Push(zz_StackFrame(file, line, output.3, output.4))
    }
    head := trace[1]
    if head.File != error.File or head.Line != error.Line {
        trace.Push(zz_StackFrame(error.File, error.Line))
    }

    return trace
}

zz_stack_capture() {
    err := Error()
    return zz_parse_error(err)
}