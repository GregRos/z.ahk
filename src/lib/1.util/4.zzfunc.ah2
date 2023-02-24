class zz_func {

    static id := x => x


    static wrapVariadic(fVariadic, paramCount, skipThis := False) {
        switch paramCount {
            case 0:
                return () => fVariadic.Call()
            case 1:
                return a => fVariadic.Call(a)
            case 2:
                return (a, b) => fVariadic.Call(a, b)
            case 3:
                return (a, b, c) => fVariadic.Call(a, b, c)
            case 4:
                return (a, b, c, d) => fVariadic.Call(a, b, c, d)
            case 5:
                return (a, b, c, d, e) => fVariadic.Call(a, b, c, d, e)
            default:
                throw zInvalidCallError(Format("Doesn't support {1} parameters.", paramCount))
        }
    }

    static refArgsToArrayReturn(f, count) {
        arr := []
        next() {
            arr.Length := 0
            switch count {
                case 0:
                    if not f() {
                        return False
                    }
                        return arr
                    case 1:
                        if f(&r1) {
                            arr.Push(r1)
                        }
                        case 2:
                            if f(&r1, &r2) {
                                arr.Push(r1, r2)
                            }
                            case 3:
                                if f(&r1, &r2, &r3) {
                                    arr.Push(r1, r2, r3)
                                }
                                case 4:
                                    if f(&r1, &r2, &r3, &r4) {
                                        arr.Push(r1, r2, r3, r4)
                                    }
                                    case 5:
                                        if f(&r1, &r2, &r3, &r4, &r5) {
                                            arr.Push(r1, r2, r3, r4, r5)
                                        }
                                        default:
                                            throw zNotImplementedError("Iter(args*) for more than 5 arguments")
            }
            if arr.Length = 0 {
                return False
            }
            return arr
        }
        return next
    }
    static isCallable(input) {
        return HasMethod(input, "Call")
    }
    static getMinParams(f) {
        if f is Func {
            return f.MinParams
        }
        return f.Call.MinParams - 1
    }
    static getMaxParams(f) {
        if f is Func {
            return f.MaxParams
        }
        return f.Call.MaxParams - 1
    }
    static getIsVariadic(f) {
        if f is Func {
            return f.IsVariadic
        }
        return f.Call.IsVariadic
    }
    static wrapIteratee(f) {
        if this.getMaxParams(f) = 2 or this.getIsVariadic(f) {
            return f
        }
        if this.getMaxParams(f) = 1 {
            return (i, x) => f(x)
        }

        throw zBadInputError("Expected function to take 1 or 2 parameters", f.MaxParams)
    }

    static wrapAccumulator(f) {
        if this.getMaxParams(f) = 3 or this.getIsVariadic(f) {
            return f
        }
        switch this.getMaxParams(f) {
            case 2:
                return (acc, cur, index) => f(acc, cur)
            case 1:
                return (acc, cur, index) => f(acc)
            case 0:
                return (acc, cur, index) => f()
        }
        return f
    }

    static normalize2(f) {
        if not f is Func {
            maxParams := f.Call.MaxParams - 1
            isVariadic := f.Call.IsVariadic
            f := f.Call.Bind(f)
        }
    }

    static normalize(f, wantedParams) {

        if maxParams = wantedParams or isVariadic {
            return f
        }
        combo := wantedParams * 10 + maxParams
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
}