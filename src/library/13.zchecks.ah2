#Include 01.zinit.ah2
zzutils_checkObjectLike(name, value) {
    if not value is Object {
        throw zz_throw.badParam(parameterName, "an object", value)
    }
}

zzutils_checkArray(name, value) {
    if not value is Array {
        throw zz_throw.badParam(name, "an array", value)
    }
}

zzutils_checkIter(name, value) {
    if not (value is Array or HasMethod(value, "__Enum")) {
        throw zz_throw.badParam(name, "an array or enumerable object", value)
    }
}

zzutils_checkFunc(name, value, minParams?) {
    if not (IsObject(value) or HasMethod(value, "Call")) {
        throw zz_throw.badParam(name, "a function", value)
    }
    if IsSet(minParams) {
        call := value.Call
        if not call.IsVariadic and call.MaxParams < minParams {
            throw zz_throw.badParam(name, Format("a function taking at least {1} parameters", minParams), "bad")
        }
    }
}

zzutils_checkInt(name, value) {
    if not IsInteger(value) {
        throw zz_throw.badParam(name, "an integer", value) 
    }
}

zzutils_checkStr(name, value) {
    if value is Object {
        throw zz_throw.badParam(name, "a number or string", value)
    }
}

zzutils_checkBool(name, value) {
    if value != False and value != True {
        throw zz_throw.badParam(name, "a boolean (0 or 1)", value)
    }
}

zzutils_checkInstanceOf(name, cls, value) {
    if not value is cls {
        throw zz_throw.badParam(name, "an instance of " Type(cls), value)
    }
}

