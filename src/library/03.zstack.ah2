; Represents an entry in a stack trace.
#include 03.zstack.ah2
class zzutils_StackFrame {

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

zzutils__parseStack(stack) {
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
        trace.Push(zzutils_StackFrame(file, line))
    }
    return trace
}