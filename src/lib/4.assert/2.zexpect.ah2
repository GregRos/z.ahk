class zExpectBase {
    _notMode := False
    __New(REAL) {
        this.REAL := REAL
    }

    onFailedAssertion(assertion) {

        throw zNotImplementedError("You must implement onFailedAssertion.")
    }

    onPassedAssertion(assertion) {
        
    }

    _getNotMode() {
        old := this._notMode
        this._notMode := False
        return old
    }

    _relation(pass, relation, other) {
        assertion := zz_assert.RelationAssertion(this._getNotMode(), this.REAL, relation, other)
        if pass == assertion.IsInverted {
            this.onFailedAssertion(assertion)
        } else {
            this.onPassedAssertion(assertion)
        }
        return this
    }

    _type(pass, type) {
        assertion := zz_assert.TypeAssertion(this._getNotMode(), this.REAL, type)
        if pass == assertion.IsInverted {
            this.onFailedAssertion(assertion)
        } else {
            this.onPassedAssertion(assertion)
        }
    }

    not {
        get {
            this._notMode := True
            return this
        }
    }

    toEqual(other) {
        return this._relation(zz_obj.equal(this.REAL, other), "equal", other)
    }

    toNotEqual(other) {
        return this.not.toEqual(other)
    }

    toBeAtLeast(other) {
        return this._relation(this.REAL >= other, "be at least", other)
    }

    toBeAtMost(other) {
        return this._relation(this.REAL <= other, "be at most", other)
    }

    toBeTrue() {
        return this._type(this.REAL == True, "True")
    }

    toBeFalse() {
        return this._type(this.REAL == False, "False")
    }

    toBeInstanceOf(ctor) {
        return this._type(this.REAL is ctor, "be an instance of", zz_obj.toShortStr(ctor))
    }

    toBeIntLike() {
        return this._type(IsInteger(this.REAL), "int-like")
    }

    toBeNumLike() {
        return this._type(IsNumber(this.REAL), "be number-like")
    }

    toBeStringLike() {
        return this._type( not IsObject(this.REAL), "string-like")
    }

    toContain(value) {
        return this._relation(zz_gen.contains(this.REAL, value), "contain", value)
    }

    toBeArray() {
        return this._type(this.REAL is Array, "an array")
    }

    toThrow() {
        ex := ""
        try {
            this.REAL()
        } catch Error as e {
            ex := e
        }
        this._type(!!ex, "throwing")
    }

    toBeFunc() {
        return this._type(this.REAL is Func or this.REAL.HasMethod("Call") or this.REAL.HasProp("Call"), "a function")
    }

    toBeBool() {
        return this._type(this.REAL == True or this.REAL == False, "boolean")
    }

    toBeEnum() {
        return this._type(this.REAL.HasMethod("__Enum") or this.REAL.HasProp("__Enum"), "enumerable")
    }
}

class zExpectArg extends zExpectBase {
    __New(REAL, name) {
        super.__New(REAL)
        this.Name := name
    }

    onFailedAssertion(assertion) {
        if assertion is zz_assert.RelationAssertion {
            throw zBadInputError("Argument '{.Name}' was expected{.Prefix}to {.Relation} {.Value}, but was {.Real}.", {
                Name: this.Name,
                Prefix: assertion.Inverted ? " not " : "",
                Relation: assertion.Relation,
                Value: assertion.Value,
                Real: assertion.Real
            })
        }
    }
}