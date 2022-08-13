class zUtilsError extends Error {

}

class zInvalidCallError extends zUtilsError {
    
}

class zBadInputError extends zUtilsError {

}

class zNotImplementedError extends zUtilsError {

}

zz_emptyPlaceholder := {}

errInvalidParameter(name, needed, value) {
    return zBadInputError(Format("Parameter {1} is invalid. Expected {2}.", parameterName, needed))
}

errInvalidParamCount(name, expected, received) {
    return zInvalidCallError(Format("Invalid call to {1}. Expected {2} parameters, received {3}.", name, expected, received))
}

errInvalidCall(name, expected, received) {
    throw zInvalidCallError()
}

errAbstract(name) {
    return zNotImplementedError(Format("The property or method {1} needs to be overriden.", name))
}

checkEnumeratorArity(real, expected) {
    if real != expected {
        throw zInvalidCallError(Format("Requested {1} variable enumerator, but this supports only {2} variables.", real, expected))
    }
}





class zBadStateError extends zUtilsError {

}

class zInvalidError extends zUtilsError {
    __New(reason) {
        super.__New(Format("Illegal internal call: {1}", reason))
    }
}

zz_identity(x) {
    return x
}

zz_normFuncToMethod(f) {
    return (self, args*) => f(args*)
}

zz_strArray_clean(arr) {
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

zz_normFunc(f, wantedParams) {
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

zz_str_getAt(str, pos) {
    return SubStr(str, pos, 1)
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

zz_evaluatePath(obj, pathSegments) {
    cur := obj
    for segment in pathSegments {
        cur := cur.%segment%
    }
    return cur
}

zz_lowerCaseMapKeys(inMap) {
    newMap := Map()
    for k, v in inMap {
        newMap[k] := v
    }
    return newMap
}

zz_objToMap(obj) {
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

zz_getCurrentPid() {
    DetectHiddenWindows True
    pid := WinGetPID("ahk_id " A_ScriptHwnd)
    DetectHiddenWindows False
    return pid
}


zz_equal(a, b, caseMode := False) {
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
            if not zz_equal(arr1[A_Index], arr2[A_Index]) {
                return False
            }
        }
        return True
    }
    if ObjOwnPropCount(a) != ObjOwnPropCount(b) {
        return False
    }
    for key, value in ObjOwnProps(a) {
        if not zz_equal(a[key], b[key], caseMode) {
            return False
        }
    }
    return True
}

zz_repeatStr(str, count, delim := "") {
    result := ""
    loop count {
        if A_Index != 1 {
            result .= delim
        }
        result .= str
    }
    return result
}

zz_assign(target, sources*) {
    if not target {
        target := {}
    }
    else if IsObject(target) {
        throw errInvalidParameter("target", "an object", target)
    }
    for source in sources {
        for k, v in source {
            target[k] := v
        }
    }
    return target
}

zz_isCallable(input) {
    return HasMethod(input, "Call")
}

zz_defaults(target, sources*) {
    if not target {
        target := {}
    } else if not IsObject(target) {
        throw errInvalidParameter("target", "an object", target)
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

zz_regex_matchAll(haystack, needle, startingPos := 1) {
    pos := startingPos
    matches := []
    while (pos := RegExMatch(haystack, needle, &match, pos)) {
        matches.Push(match)
        pos += Max(1, match.Len)
    }
    return matches
}

zz_normIndex(index, len) {
    if index <= 0 {
        return len + index + 1
    }
}

zz_str_slice(self, start := 1, end := 0) {
    start := zz_normIndex(start, self.Length)
    end := zz_normIndex(end, self.Length)
    newArr := []
    Loop end - start + 1 {
        newArr.Push(self[A_Index + start - 1])
    }
    return newArr
}

zz_ownKvps(obj) {
    results := []
    for key in ObjOwnProps(obj) {
        value := obj.%key%
        results.Push([key, value])
    }
    return results
}

zz_array_slice(arr, start := 1, count := -1) {
    newArr := []
    start := zz_normIndex(start, arr.Length)
    count := count = -1 ? arr.Length - start + 1 : count
    loop count {
        newArr.Push(arr[start + A_Index - 1])
    }
    return newArr
}

zz_regex_split(haystack, needle, matchAction := False, startingPos := 1, omitEmpty := False) {
    results := []
    oldMatchEnd := startingPos
    matches := zz_regex_matchAll(haystack, needle, startingPos)
    for match in matches {
        matchStart := match.Pos
        slice := SubStr(haystack, oldMatchEnd, matchStart - oldMatchEnd)
        if slice {
            results.Push(slice)
        }
        if zz_isCallable(matchAction) {
            result := matchAction(match)
        } else if IsObject(matchAction) {
            throw errInvalidParameter("matchAction", "a value or a callable object", matchAction)
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

zz_array_repeat(value, count) {
    arr := []
    loop count {
        arr.Push(value)
    }
    return arr
}

zz_array_map(arr, projection) {
    newArr := []
    for x in arr {
        newArr.Push(projection(x))
    }
    return newArr
}

zz_array_findLast(arr, predicate) {
    loop arr.Length {
        i := arr.Length - A_Index + 1
        cur := arr[i]
        if predicate(cur) {
            return {
                item: cur,
                index: i
            }
        }
    }
    return ""
}

zz_array_has(arr, item, caseMode := False) {
    for x in arr {
        if item == x {
            return True
        } else if not caseMode and item = x {
            return True
        }
    }
    return False
}

zz_array_filter(arr, predicate) {
    newArr := []
    for x in arr {
        if predicate(x) {
            newArr.Push(x)
        }
    }
    return newArr
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


zz_map_getKeys(mp) {
    arr := []
    for key, val in mp {
        arr.Push(key)
    }
    return arr
}

zz_func_wrapVariadic(fVariadic, paramCount, skipThis := False) {
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

zz_refArgs_to_arrayReturn(f, count) {
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

class zz_GenericEnumerable {
    __New(paramCount, makeEnumerator) {
        this._paramCount := paramCount
        this._makeEnumerator := makeEnumerator
    }

    __Enum(count) {

        return this.zz_makeEnumerable.Call()
    }
}
