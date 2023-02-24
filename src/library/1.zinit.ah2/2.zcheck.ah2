class zCheck {
    __New(Value, argName) {
        this.Value := Value
        this.ArgName := argName
    }

    _raise(templateText, extras*) {
        throw zBadInputError(Format(templateText, name, value, extras*), value)
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

    instanceOf(ctor) {
        if not (this.Value is ctor) {
            this._raise("Argument '{1}' must be {3}, but got {2}.", ctor.Name)
        }
        return this
    }

    integer() {
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

    notEqual(what, description) {
        if this.Value == what {
            this._raise("Argument '{1}' must not be {3}, but got {2}.", description)
        }
        return this
    }

    isObject() {
        if IsObject(this.Value) {
            this._raise("Argument '{1}' must be an object, but got {2}.")
        }
        return this
    }

    isEnumerable() {
        this.isObject()
        if not this.Value.hasMethod("__Enum") {
            this._raise("Argument '{1}' doesn't define __Enum(...).")
        }
        return this
    }

    isFunction(minParams := unset, maxParams := unset) {
        this.isObject()
        if not (IsObject(value) or HasMethod(value, "Call")) {
            this._raise("Argument '{1}' isn't a function and doesn't define Call(...)")
        }

    }
}