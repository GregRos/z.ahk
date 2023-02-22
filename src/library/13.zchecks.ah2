#Include 01.zinit.ah2

class zz_checks {
    static isObjectLike(name, value) {
        if not value is Object {
            throw zz_throw.badParam(parameterName, "an object", value)
        }
    }

    static isArray(name, value) {
        if not value is Array {
            throw zz_throw.badParam(name, "an array", value)
        }
    }

    static isIter(name, value) {
        if not (value is Array or HasMethod(value, "__Enum")) {
            throw zz_throw.badParam(name, "an array or enumerable object", value)
        }
    }

    static isFunc(name, value, minParams?) {
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

    static isInt(name, value) {
        if not IsInteger(value) {
            throw zz_throw.badParam(name, "an integer", value)
        }
    }

    static isNumber(name, value) {
        if not IsNumber(value) {
            throw zz_throw.badParam(name, "a number", value)
        }
    }

    static isString(name, value) {
        if value is Object {
            throw zz_throw.badParam(name, "a number or string", value)
        }
    }

    static isBool(name, value) {
        if value != False and value != True {
            throw zz_throw.badParam(name, "a boolean (0 or 1)", value)
        }
    }

    static isNotEqual(name, value, illegal) {
        if value == illegal {
            throw zz_throw.badParam(name, "not " illegal, value)
        }
    }

    static isLte(name, value, threshold) {
        this.isNumber(name, value)
        if !(value <= threshold) {
            throw zz_throw.badParam(name, "a number less than or equal to " threshold, value)
        }
    }
    
    static isGt(name, value, threshold) {
        this.isNumber(name, value)
        if value <= threshold {
            throw zz_throw.badParam(name, "a number greater than " threshold, value)
        }
    }

    static isLt(name, value, threshold) {
        this.isNumber(name, value)
        if value >= threshold {
            throw zz_throw.badParam(name, "a number smaller than " threshold, value)
        }
    }


    static isInstanceOf(name, cls, value) {
        if not value is cls {
            throw zz_throw.badParam(name, "an instance of " Type(cls), value)
        }
    }
}
