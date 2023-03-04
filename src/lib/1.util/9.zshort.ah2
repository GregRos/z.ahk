#include 1.zerrors.ah2
/**
 * Checks if a value is callable.
 * @param target The value to test.
 * @param paramCount If present, also checks if the value is callable with this number of params.
 * @see https://www.autohotkey.com/docs/v2/misc/Functor.htm
 */
zIsCallable(target, paramCount?) {
    return HasMethod(target, , paramCount?)
}

/**
 * Gets the maximum number of declared params a callable accepts.
 * @param target The value to test.
 * @throws {zBadInputError} If the value is not callable.
 * @remarks Doesn't check for variadic parameters.
 */
zFuncMaxParams(target) {
    if not zIsCallable(target) {
        throw zBadInputError("Value is not callable.")
    }
    if target is Func {
        return target.MaxParams
    }
    return target.Call.MaxParams - 1
}

/**
 * Gets the minimum number of params needed by a callable.
 * @param target The value to test.
 * @throws {zBadInputError} If the value is not callable.
 * 
 */
zFuncMinParams(target) {
    if not zIsCallable(target) {
        throw zBadInputError("Value is not callable.")
    }
    if target is Func {
        return target.MinParams
    }
    return target.Call.MinParams - 1
}


/**
 * Checks if a callable is variadic, i.e. has a "rest"-type argument.
 * @param target The value to test.
 * @throws {zBadInputError} If the value is not callable.
 * 
 */
zFuncIsVariadic(target) {
    if target is Func {
        return target.IsVariadic
    }
    return target.Call.IsVariadic
}

/**
 * Checks if something is enumerable. Will always return true due to bug.
 * @param target The value to test.
 * @param arity Optionally, also checks the value is enumerable with this many params.
 */
zIsEnumerable(target, arity?) {
    if zIsCallable(target, arity?) {
        return True
    }
    if not IsSet(arity) {
        return True
    }
    try {
        iterator := target.__Enum(arity)
        return zIsCallable(iterator, arity)
    } catch Any as e {
        return False
    }
}

/**
 * Gets an object's property descriptor, potentially searching up the prototype chain. Returns `""` if not found.
 * @param target The object to check.
 * @param name The name of the property.
 */
zGetPropDesc(target, name) {
    if not target.HasProp(name) {
        return ""
    }
    while target {
        if target.HasOwnProp(name) {
            return target.GetOwnPropDesc(name)
        }
        target := ObjGetBase(target)
    }
    return ""
}

/**
 * Checks if something has an indexer `__Item` property.
 * @param target The value to test.
 * @param arity Optionally, also checks the value is indexable with this many params.
 */
zIsIndexed(target, arity?) {
    if target is Array or target is Map {
        return True
    }
    if not HasProp(target, "__Item") {
        return False
    }
    if not IsSet(arity) {
        return True
    }
    desc := zGetPropDesc(target, "__Item")
    return zIsCallable(target.Get, arity + 1)
}

/**
 * Checks if something is array-like. Array-like means:
 * * `Length` property.
 * * `__Enum` method.
 * * Indexable with 1 param.
 * @param target The value to test.
 */
zIsArrayLike(target) {
    return HasProp(target, "Length") and HasMethod(target, "__Enum") and zIsIndexed(target, 1)
}