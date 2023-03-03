class zError extends Error {

}

class zInvalidCallError extends zError {
    __New(func, message) {
        super.__New(Format("Function {1} was invoked illegaly. {2}", zz_Inspect(func).funcName, message), func)
    }
}

class zSyntaxError extends zBadInputError {
    __New(message, what, position) {
        text := what
        rows := StrSplit(text, "`n")
        rowPos := 0
        loop {
            rowPos += 1
            curRow := rows[rowPos]
            position -= StrLen(curRow) + 1
            if position <= 0 {
                break
            }
        }
        errorMarker := zz_str.repeat(" ", StrLen(curRow) + position) "🢁 " message
        rows.InsertAt(rowPos + 1, errorMarker)
        text := zz_str.join(rows, "`n")
        super.__New(text, "")
    }
}

class zBadInputError extends zError {
    __New(message, what?, extra?) {
        super.__New(message, what?, extra?)
    }
}

class zNotImplementedError extends zError {

}
class zBadStateError extends zError {

}

class zInvalidError extends zError {
    __New(reason) {
        super.__New(Format("Illegal internal call: {1}", reason))
    }
}



zz_none := {}