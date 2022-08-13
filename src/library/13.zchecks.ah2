#Include 01.zinit.ah2
zzutils_checkObjectLike(name, value) {
    if not value is Object {
        throw errInvalidParameter(parameterName, "an object", value)
    }
}

zzutils_checkArray(name, value) {
    if not value is Array {
        throw errInvalidParameter(name, "an array", value)
    }
}

zzutils_checkIter(name, value) {
    if not (value is Array or HasMethod(value, "__Enum")) {
        throw errInvalidParameter(name, "an array or enumerable object", value)
    }
}

zzutils_checkFunc(name, value, minParams?) {
    if not (IsObject(value) or HasMethod(value, "Call")) {
        throw errInvalidParameter(name, "a function", value)
    }
    if IsSet(minParams) {
        call := value.Call
        if not call.IsVariadic and call.MaxParams < minParams {
            throw errInvalidParameter(name, Format("a function taking at least {1} parameters", minParams), "bad")
        }
    }
}

zzutils_checkInt(name, value) {
    if not IsInteger(value) {
        throw errInvalidParameter(name, "an integer", value) 
    }
}

zzutils_checkStr(name, value) {
    if value is Object {
        throw errInvalidParameter(name, "a number or string", value)
    }
}

zzutils_checkBool(name, value) {
    if value != False and value != True {
        throw errInvalidParameter(name, "a boolean (0 or 1)", value)
    }
}

zzutils_checkInstanceOf(name, cls, value) {
    if not value is cls {
        throw errInvalidParameter(name, "an instance of " Type(cls), value)
    }
}

