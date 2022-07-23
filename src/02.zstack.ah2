; Represents an entry in a stack trace.
class z__gutils_StackFrame {

     __New(file, line) {
        frame := this
        frame.File := file
        frame.Line := line
        return frame
    }

    ToString() {
        x := Format("{1}:{2}", this.File, this.Line)
        return x
    }
}

z__gutils_parse(stack) {
    RegExMatch(stack, ".*")
    frames := StrSplit(stack, "`r`n")
    frameRegexp := "^(.*) \((\d+)\) :.*$"
    trace := []
    for frame in frames {
        if not frame {
            continue
        }
        if InStr(frame, "Auto-execute") {
            continue
        }
        output := ""
        RegExMatch(frame, frameRegexp, &output)
        file := output.1
        line := output.2
        trace.Push(z__gutils_StackFrame(file, line))
    }
    return trace
}