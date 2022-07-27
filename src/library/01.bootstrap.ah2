class zUtilsError extends Error {

}

class zBadInputError extends zUtilsError {
    __New(parameterName, needed, value) {
        super.__New(Format("Parameter {1} is invalid. Expected {2}, got: {3}", parameterName, needed, value))
    }
}

class zInvalidError extends zUtilsError {
    __New(reason) {
        super.__New(Format("Illegal internal call: {1}", reason))
    }
}

zzutils_normFunc(f, wantedParams) {
    if not f is Func {
        f := f.Call
    }
    if f.MaxParams = wantedParams or f.IsVariadic {
        return f
    }
    combo := wantedParams * 10 + f.MaxParams
    switch combo {
        case 10:
            return x => f()
        case 21:
            return (a, b) => f(a)
        case 20:
            return (a, b) => f()
        case 32:
            return (a, b, c) => f(a, b)
        case 31:
            return (a, b, c) => f(a)
        case 30:
            return a => f()
        default:
            throw zInvalidError("Parameter combo not supported")
    }
}