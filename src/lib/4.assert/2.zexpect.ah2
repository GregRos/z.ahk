
class zExpect {
    _notMode := False
    __New(REAL) {
        this.REAL := REAL
    }

    onFailedAssertion(assertion) {
        throw zAssertionFailedError(assertion)
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

    toBe(other) {
        return this._relation(this.REAL == other, "be", other)
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
        return this._type(this.REAL == True, "be True")
    }

    toBeFalse() {
        return this._type(this.REAL == False, "be False")
    }

    toBeInstanceOf(ctor) {
        return this._type(this.REAL is ctor, "be instanceof", zz_obj.toShortStr(ctor))
    }

    toBeIntLike() {
        return this._type(IsInteger(this.REAL), "be int-like")
    }

    toBeNumLike() {
        return this._type(IsNumber(this.REAL), "be number-like")
    }

    toBeStringLike() {
        return this._type( not IsObject(this.REAL), "be string-like")
    }

    toContain(value) {
        return this._relation(zz_gen.contains(this.REAL, value), "contain", value)
    }

    toBeArray() {
        return this._type(this.REAL is Array, "be an array")
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

    toBeCallable() {
        return this._type(zz_func.isCallable(this.REAL), "be a function")
    }

    toBeBool() {
        return this._type(this.REAL == True or this.REAL == False, "be boolean")
    }

    toBeEnum() {
        return this._type(this.REAL.HasMethod("__Enum") or this.REAL.HasProp("__Enum"), "be enumerable")
    }

    toHaveMethods(names*) {
        for name in names {
            this._type(this.REAL.HasMethod(name), "have method " name)
        }
        return this
    }

    toHaveProps(names*) {
        for name in names {
            this._type(this.REAL.HasProp(name), "have prop " name)
        }
        return this
    }

    toHaveNames(names*) {
        for name in names {
            this._type(this.REAL.HasProp(name) or this.REAL.HasMethod(name), "to have name " name)
        }
        return this
    }
}

class zAssertionFailedError extends Error {
    __New(assertion) {
        super.__New(assertion.ToString(), assertion.REAL)
        this.Assertion := assertion
        this.Trace := zTrace(this).Filter(frm => not frm.Function.Match("Object.Call|zAssertionFailed|Func.Call|zz_Test|zExpect"))
    }
}

class zExpectArg extends zExpect {
    __New(REAL, name) {
        super.__New(REAL)
        this.Name := name
    }

    onFailedAssertion(assertion) {
        static relTemplate := zTemplate("Argument '{1.Name}' was expected {2}to {3.Relation} {3.Value}, but was {3.Real}.")
        static typeTemplate := zTemplate("Argument '{1.Name}' was expected {2}to be {3.Type}, but was {3.Real}")
        prefix := assertion.IsInverted ? "not " : ""
        if assertion is zz_assert.RelationAssertion {
            throw zBadInputError(relTemplate(
                this,
                prefix,
                assertion))
        } else if assertion is zz_assert.TypeAssertion {
            throw zBadInputError(typeTemplate(
                this,
                prefix,
                assertion))
        }
    }
}