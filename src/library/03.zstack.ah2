class zz_StackTrace extends Array {
    __New(trace) {
        for frame in zz_StackTrace.Parse(trace) {
            this.Push(frame)
        }
    }

    static Parse(error, skip := 0) {
        stack := error.Stack
        frames := StrSplit(stack, "`r`n")
        frameRegexp := "^(.*) \((\d+)\) : (?:\[(.*)\] (.*))?"
        trace := []
        for frame in frames {
            if A_Index <= skip {
                continue
            }
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

        return trace
    }

}

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

class zz_CallFrame {
    static _tmFrame := zTemplate("{Function} @ {File}:{Line} | {Quote}")
     __New(file, ln, function := unset, quote := unset) {
        frame := this
        frame.File := file
        frame.Line := ln
        frame.Function := function ?? ''
        frame.Quote := quote ?? ''
        return frame
    }

    ToString() {
        x := zz_CallFrame._tmFrame.Render(this)
        return x
    }

    isScript {
        get => True
    }
}



zz_stack_capture(skip := 0) {
    err := Error()
    stack := zz_StackTrace.Parse(err, skip + 1)
    return stack
}
