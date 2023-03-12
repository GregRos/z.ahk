#include 1.zerrors.ah2

class zz_CallableInfo {
    __New(target) {
        this.Target := target
    }

    Name {
        get {
            f := this.Target
            if f is Func {
                return f.Name
            }
            return ""
        }
    }
    
    MaxParams {
        get {
            target := this.Target
            if not zIsCallable(target) {
                throw zz_BadInputError("Value is not callable.")
            }
            if target is Func {
                return target.MaxParams
            }
            return target.Call.MaxParams - 1
        }
    }
    MinParams {
        get {
            target := this.Target
            if not zIsCallable(target) {
                throw zz_BadInputError("Value is not callable.")
            }
            if target is Func {
                return target.MinParams
            }
            return target.Call.MinParams - 1
        }
    }

    IsVariadic {
        get {
            target := this.Target
            if target is Func {
                return target.IsVariadic
            }
            return target.Call.IsVariadic
        }
    }
}

/**
 * Checks if a value is callable and, if so, returns a CallableInfo object.
 * @param target The value to test.
 * @param paramCount If present, also checks if the value is callable with this number of params.
 * @see https://www.autohotkey.com/docs/v2/misc/Functor.htm
 * @example
 * ; Check if a lambda is callable:
 * zIsCallable(() => {}) ; {True}
 * ; Check if a string is callable:
 * zIsCallable("abc") ; False
 * ; Check if a built-in is callable with 2 params:
 * zIsCallable(StrSplit, 2) ; True
 * ; Check if a zTemplate is callable:
 * zIsCallable(zTemplate("abc")) ; True
 */
zIsCallable(target, paramCount?) {
    return HasMethod(target, , paramCount?)
}

/**
 * Get a callable value's info. Returns `""` if not callable.
 * @param target The value to test.
 * @example
 * ; Get the info of a lambda:
 * zGetCallableInfo(() => {}) ; {Name: "", MaxParams: 0, MinParams: 0, IsVariadic: False}
 * ; Get the info of a built-in:
 * zGetCallableInfo(StrSplit) ; {Name: "StrSplit", MaxParams: 1, MinParams: 4, IsVariadic: False}
 * ; Get the info of a zTemplate:
 * zGetCallableInfo(zTemplate("abc")) ; {Name: "", MaxParams: 1, MinParams: 1, IsVariadic: True}
 * ; Get the info of a string:
 * zGetCallableInfo("abc") ; ""
 */
zGetCallableInfo(target) {
    if not zIsCallable(target) {
        return ""
    }
    return zz_CallableInfo(target)
}

/**
 * Checks if something is enumerable. BUGGED AS OF v2.0.2.
 * @param target The value to test.
 * @param arity Optionally, also checks the value is enumerable with this many params.
 */
zIsEnumerable(target, arity?) {
    if zIsCallable(target, arity?) {
        return True
    }
    if not IsSet(arity) {
        return target is Array or target is Map or HasMethod(target, "__Enum")
    }
    try {
        iterator := target.__Enum(arity)
        return zIsCallable(iterator, arity)
    } catch Any as e {
        return False
    }
}

/**
 * Checks if something is a built-in callable. Built-in callables are `Func`, `Closure`, and `BoundFunc`.
 * @param target The value to test.
 * @example
 * ; Check if a lambda is a built-in callable:
 * zIsBuiltInCallable(() => {}) ; True
 * ; Check if a zTemplate is a built-in callable:
 * zIsBuiltInCallable(zTemplate("abc")) ; False
 * ; Check if a string is a built-in callable:
 * zIsBuiltInCallable("abc") ; False
 * 
 */
zIsBuiltInCallable(target) {
    return target is Func or target is Closure or target is BoundFunc
}

/**
 * Gets an object's property descriptor, potentially searching up the prototype chain. Returns `""` if not found.
 * @param target The object to check.
 * @param name The name of the property.
 * @example
 * ; Get the property descriptor of a property:
 * zGetPropDesc({a: 1}, "a") ; {Value: 1}
 * ; Get the property descriptor for a method in a prototype:
 * zGetPropDesc([1], "Length") ; ...
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
 * @example
 * ; Check if an array is indexable:
 * zIsIndexed([1, 2, 3]) ; True
 * ; Check if a string is indexable:
 * zIsIndexed("abc") ; False
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
 * @example
 * ; Check if an array is array-like:
 * zIsArrayLike([1, 2, 3]) ; True
 * ; Check if a string is array-like:
 * zIsArrayLike("abc") ; False
 * ; Check if a map is array-like:
 * zIsArrayLike({a: 1, b: 2}) ; False
 */
zIsArrayLike(target) {
    return HasProp(target, "Length") and HasMethod(target, "__Enum") and zIsIndexed(target, 1)
}

/**
 * Checks if something is a collection. Collections are `Array` and `Map`.
 * @param target The value to test.
 * @example
 * ; Check if an array is a collection:
 * zIsCollection([1, 2, 3]) ; True
 * ; Check if a string is a collection:
 * zIsCollection("abc") ; False
 * ; Check if a map is a collection:
 * zIsCollection(Map("a", 1)) ; True
 * 
 */
zIsCollection(target) {
    return target is Array or target is Map
}