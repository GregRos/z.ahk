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
                throw zNotImplementedError(Format("Not implemented for {1} parameters.", paramCount))
        }
    }


    static wrapJoinIteratee(dimension, f) {
        f := zz_func.getIsVariadic(f)
        maxParams := zz_func.getMaxParams(f)
        ; Variadic functions don't need to be wrapped
        if f {
            return f
        } else if maxParams == dimension + 1 {
            ; This means it's a complete join iteratee, no need to change anything.
            return f
        } else if maxParams > dimension + 1 {
            ; This means it requires more parameters than is allowed.
            throw zInvalidCallError(f, Format("Function takes {1} params, but expected up to {2}.", f.MaxParams, dimension + 1))
        } else {
            ; The full signature of a join iteratee is (key, item1, ..., itemN) => joinResult
            ; However, you can pass in a function taking fewer parameters so the later inputs are ignored.

            invokeJoinIteratee(args*) {
                ; Next we trim the number of args to be the maximum allowed.
                args.Length := maxParams
                return f.Call(args*)
            }
            return invokeIteratee
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