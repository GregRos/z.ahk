class zError extends Error {

}

class zInvalidCallError extends zError {

}

class zBadInputError extends zError {

}

class zNotImplementedError extends zError {

}

zz_none := {}

class zz_throw {
    static badParam(name, needed, value) {
        return zBadInputError(Format("Parameter {1} is invalid. Expected {2}.", needed, value))
    }

    static checkEnumeratorArity(real, expected) {
        if real != expected {
            throw zInvalidCallError(Format("Requested {1} variable enumerator, but this supports only {2} variables.", real, expected))
        }
    }
}


class zBadStateError extends zError {

}

class zInvalidError extends zError {
    __New(reason) {
        super.__New(Format("Illegal internal call: {1}", reason))
    }
}

zz_normFuncToMethod(f) {
    return (self, args*) => f(args*)
}

class zz_arr {
    static mergeSort(arr, work, comparer) {
        ; Merge sort because it's a stable sort
        merge(begin, middle, end) {
            Loop end - begin {
                ix := A_Index + begin
                if i < middle and (ix >= end or comparer(arr[start], arr[middle]) <= 0) {
                    work[ix] := arr[start]
                    start++
                } else {
                    work[ix] := arr[end]
                    end++
                }
            }
        }

        splitMerge(begin, end) {
            if (end - begin = 0) {
                ; One-item run
                return
            }
            middle := Integer((end + begin) / 2)
            splitMerge(start, middle)
            splitMerge(middle, end)
            merge(start, middle, end)
        }

        splitMerge(1, arr.Length)
    }
    static slice(arr, start := 1, count := -1) {
        newArr := []
        start := zz_normIndex(start, arr.Length)
        count := count = -1 ? arr.Length - start + 1 : count
        loop count {
            newArr.Push(arr[start + A_Index - 1])
        }
        return newArr
    }
    static hasUnsetItems(arr) {
        lastIndex := 0
        for index, item in arr {
            if index != lastIndex + 1 {
                return True
            }
            lastIndex := index
        }
        return False
    }

    static repeat(value, count) {
        arr := []
        loop count {
            arr.Push(value)
        }
        return arr
    }

    static has(arr, item, caseMode := False) {
        for x in arr {
            if item == x {
                return True
            } else if not caseMode and item = x {
                return True
            }
        }
        return False
    }

    static hasAny(arr, options*) {
        return zz_arr.has(options, arr, False)
    }
}

class zz_str {
    static trimEach(arr) {
        newArr := []
        for x in arr {
            x := Trim(x)
            if not x {
                continue
            }
            newArr.Push(x)
        }
        return newArr
    }

    static split(haystack, needle, matchAction := False, startingPos := 1, omitEmpty := False) {
        results := []
        oldMatchEnd := startingPos
        matches := zz_str.matchAll(haystack, needle, startingPos)
        for match in matches {
            matchStart := match.Pos
            slice := SubStr(haystack, oldMatchEnd, matchStart - oldMatchEnd)
            if slice {
                results.Push(slice)
            }
            if zz_func.isCallable(matchAction) {
                result := matchAction(match)
            } else if IsObject(matchAction) {
                throw zz_throw.badParam("matchAction", "a value or a callable object", matchAction)
            } else if matchAction {
                result := match[matchAction]
            }
            if IsSet(result) {
                if not omitEmpty or result != "" {
                    results.Push(result)
                }
            }
            oldMatchEnd := matchStart + match.Len
        }
        results.Push(SubStr(haystack, oldMatchEnd))

        return results
    }

    static matchAll(haystack, needle, startingPos := 1) {
        pos := startingPos
        matches := []
        while (pos := RegExMatch(haystack, needle, &match, pos)) {
            matches.Push(match)
            pos += Max(1, match.Len)
        }
        return matches
    }

    static join(arr, delim := "") {
        result := ""
        for i, x in arr {
            if i != 1 {
                result .= delim
            }
            result .= x
        }
        return result
    }

}

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
    static normalize(f, wantedParams) {
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
}

class zz_obj {
    static evalPath(obj, pathSegments) {
        cur := obj
        for segment in pathSegments {
            cur := cur.%segment%
        }
        return cur
    }

    static toMap(obj) {
        if not obj {
            return {}
        }
        if obj is Map {
            return obj
        }
        objMap := Map()
        objMap.CaseSense := False
        for key in ObjOwnProps(obj) {
            objMap[key] := obj.%key%
        }
        return objMap
    }

    static defaults(target, sources*) {
        if not target {
            target := {}
        } else if not IsObject(target) {
            throw zz_throw.badParam("target", "an object", target)
        }
        for source in sources {
            for k in ObjOwnProps(source) {
                v := source.%k%
                if not HasProp(target, k) {
                    target[k] := v
                }
            }
        }
        return target
    }

    static equal(a, b, caseMode := False) {
        if not (IsObject(a) and IsObject(b)) {
            return caseMode ? a == b : a = b
        }
        protoA := a.Base
        protoB := b.Base
        if protoA != protoB {
            return False
        }
        if protoA = Array.Prototype {
            if a.Length != b.Length {
                return False
            }
            loop arr1.Length {
                if not zz_obj.equal(arr1[A_Index], arr2[A_Index]) {
                    return False
                }
            }
            return True
        }
        if ObjOwnPropCount(a) != ObjOwnPropCount(b) {
            return False
        }
        for key, value in ObjOwnProps(a) {
            if not zz_obj.equal(a[key], b[key], caseMode) {
                return False
            }
        }
        return True
    }

}

class zz_sys {
    static getCurrentPid() {
        DetectHiddenWindows True
        pid := WinGetPID("ahk_id " A_ScriptHwnd)
        DetectHiddenWindows False
        return pid
    }
}

class zz_map {
    static keys(mp) {
        arr := []
        for key, val in mp {
            arr.Push(key)
        }
        return arr
    }
}

class zz_Disposable {
    IsClosed := False
    IsOk {
        get => !this.IsClosed
    }

    ; Override this
    _close() {

    }

    Close() {
        this._close()
        this.IsClosed := True
    }
}


zz_normIndex(index, len) {
    if index <= 0 {
        return len + index + 1
    }
    return index
}


zz_options_parse(optionsString) {
    optionsMap := Map()
    optionsMap.CaseSense := False
    optionsMap.Default := 0
    split := StrSplit(optionsString, " ")
    for option in split {
        firstChar := SubStr(option, 1, 1)
        if firstChar = "+" {
            properName := SubStr(option, 2)
            optionsMap[properName] := 1
        } else if firstChar = "-" {
            properName := SubStr(option, 2)
            optionsMap[properName] := -1
        } else {
            optionsMap[option] := 1
        }
    }
    return optionsMap
}


class zz_GenericEnumerable {
    __New(paramCount, makeEnumerator) {
        this._paramCount := paramCount
        this._makeEnumerator := makeEnumerator
    }

    __Enum(count) {

        return this.zz_makeEnumerable.Call()
    }
}