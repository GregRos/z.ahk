

class zCheck {
    __New(Value, Name) {
        this.Value := Value
        this.Name := Name
    }

    static toErrorString(v) {
        if IsObject(v) {
            if v.HasMethod("ToString") or v.HasProp("ToString") {
                return v.ToString()
            }
            return Type(v)
        } else {
            return String(v)
        }
    }

    _raise(templateText, extras*) {
        value := zCheck.toErrorString(this.Value)
        for i, extra in extras {
            extras[i] := zCheck.toErrorString(extra)
        }
        throw zBadInputError(Format(templateText, this.Name, value, extras*), this.Value)
    }

    greater(than) {
        if this.Value <= then {
            this._raise("Argument '{1}' must be greater than {3}, but got {2}.", than)
        }
        return this
    }

    smaller(than) {
        if this.Value >= than {
            this._raise("Argument '{1}' must be smaller than {3}, but got {2}.", than)
        }
        return this
    }

    isntGreater(than) {
        if not (this.Value <= than) {
            this._raise("Argument '{1}' mustn't be greater than {3}, but got {2}.", than)
        }
    }

    instanceOf(ctor) {
        if not (this.Value is ctor) {
            this._raise("Argument '{1}' must be {3}, but got {2}.", ctor.Name)
        }
        return this
    }

    isInt() {
        if not IsInteger(this.Value) {
            this._raise("Argument '{1}' must be an integer, but got {2}.")
        }
        return this
    }

    number() {
        if not IsNumber(this.Value) {
            this._raise("Argument '{1}' must be a number, but not {2}.")
        }
        return this
    }

    isNotEqual(what, description?) {
        if this.Value == what {
            this._raise("Argument '{1}' must not be {3}, but got {2}.", IsSet(description) ? description : what)
        }
        return this
    }

    isObject() {
        if not IsObject(this.Value) {
            this._raise("Argument '{1}' must be an object, but got {2}.")
        }
        return this
    }

    isFunc() {
        if not (IsObject(this.Value) and HasMethod(this.value, "Call")) {
            this._raise("Argument '{1}' wasn't a function or callable. It was {2}.")
        }
    }

    isString() {
        if  IsObject(this.Value) {
            this._raise("Argument '{1}' must be a string, but got an object.")
        }
    }

    isArray() {
        if not this.Value is Array {
            this._raise("Argument '{1}' must be an array, but got {2}.")
        }
    }

    isBool() {
        if this.Value !== 0 and this.Value !== 1 {
            this._raise("Argument '{1}' must be True or False, but was {2}.")
        }
    }

    isEnumerable() {
        this.isObject()
        if not (IsObject(this.Value) and this.Value.hasMethod("__Enum")) {
            this._raise("Argument '{1}' doesn't define __Enum(...).")
        }
        return this
    }

}