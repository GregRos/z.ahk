class zz_ExpectContinuation extends zExpect {
    __New(continuation) {
        this._continuation := continuation
    }

    onSuccessfulAssertion(assertion) {
        this._continuation.Call(True, assertion)
    }

    onFailedAssertion(assertion) {
        this._continuation.Call(False, assertion)
    }

}
class zExpect {

    _notMode := False
    __New(REAL) {
        this.REAL := REAL
        this._inspect := zz_Inspect(this.REAL)
    }

    onFailedAssertion(assertion) {
        throw zAssertionFailedError(assertion)
    }

    onPassedAssertion(assertion) {

    }

    fail(assertionText) {
        this._type(False, assertionText)
    }

    _getNotMode() {
        old := this._notMode
        this._notMode := False
        return old
    }

    _createRelative(relation, other) => zz_assert.RelativeAssertion(this._getNotMode(), this.REAL, relation, other)
    _createUnary(type) => zz_assert.UnaryAssertion(this._getNotMode(), this.REAL, type)

    _test(pass, assertion) {
        if pass == assertion.IsInverted {
            this.onFailedAssertion(assertion)
        } else {
            this.onPassedAssertion(assertion)
        }
    }

    _relation(pass, relation, other) {
        this._test(pass, this._createRelative(relation, other))
        return this
    }

    not {
        get {
            this._notMode := true
            return this
        }
    }


    _type(pass, type) {
        this._test(pass, this._createUnary(type))
        return this
    }

    _startPropertyAssertion(property) {
        outer := this
        myNot := this._getNotMode()
        finish_assertion(pass, assertion) {
            if assertion.kind == "property" {
                throw zBadInputError("You can't nest property assertions.")
            }
            outer._test(pass, zz_assert.PropertyAssertion(myNot, property, outer.REAL, assertion))
        }
        return zz_ExpectContinuation(finish_assertion)
    }

    every {
        get {
            return this._startPropertyAssertion("every element")
        }
    }

    some {
        get {
            return this._startPropertyAssertion("some element")
        }
    }

    length {
        get {
            return this._startPropertyAssertion("length")
        }
    }

    atPosition(index) {
        return this._startPropertyAssertion("element at index " index)
    }


    toBe(other) {
        return this._relation(this.REAL == other, "be", String(other))
    }

    toBeObj() {
        return this._relation(IsObject(this.REAL), "")
    }

    toEqual(other) {
        return this._relation(zz_obj.equal(this.REAL, other), "equal", other)
    }

    toBeKvp(key, value) {
        other := zz_Kvp(key, value)
        return this._relation(zz_obj.equal(this.REAL, other), "equal", other)
    }

    toNotEqual(other) {
        return this.not.toEqual(other)
    }

    toBeAtLeast(other) {
        return this._relation(this.REAL >= other, "be at least", other)
    }

    toBeMoreThan(other) {
        return this._relation(this.REAL > other, "be more than", other)
    }

    toBeMap() {
        return this._type(this.REAL is Map, "be a Map")
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
        return this._type(this.REAL is ctor, "be instanceof", zz_Inspect(ctor).shortString)
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
        return this._relation(this._inspect.contains(value), "contain", value)
    }

    toHaveLength(len) {
        return this._relation(this._inspect.Length, "have length", len)
    }

    toBeOneOf(options*) {
        return this._relation(zArrHas(options, this.REAL), "")
    }

    toBeArray(predicate?) {
        this._type(this.REAL is Array, "be an array")
        if IsSet(predicate) {
            for item in this.REAL {
                this._type(predicate(item), "match predicate")
            }
        }
        return this
    }

    toBeArrayLike() {
        this._type(this._inspect.isArrayLike, "be array-like")
        return this
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

    toBeCallable(wMinParams := unset, wMaxParams := unset) {
        wMaxParams := wMaxParams ?? wMinParams ?? unset
        inspected := this._inspect
        this._type(inspected.isCallable(), "be a function")
        if IsSet(wMaxParams) {
            this._type(inspected.maxParams <= wMaxParams, Format("accept at most {1} params", wMaxParams))
        }
        if IsSet(wMinParams) and not inspected.isVariadic {
            this._type(inspected.minParams >= wMinParams, Format("accept at least {1} params", wMinParams))
        }

    }

    toBeBool() {
        return this._type(this.REAL == True or this.REAL == False, "be boolean")
    }

    toBeEnum(options*) {
        trailer := zz_str.join(options, ", ")
        anyMatching := False
        for option in options {
            anyMatching |= zz_Inspect(this.REAL).isEnum(option)
        }
        return this._type(anyMatching, "be enumerable with: " trailer)
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

zz_expectArrayItem(real, name, n) {
    return zExpectArg(real, Format("{1}[{2}]", name, n))
}

class zExpectArg extends zExpect {
    __New(REAL, name) {
        super.__New(REAL)
        this.Name := name
    }

    onFailedAssertion(assertion) {
        static relTemplate := zTemplate("Argument {1.Name} was expected {2}to {3.Operator} {3.Value}, but was {3.Real}.")
        static typeTemplate := zTemplate("Argument {1.Name} was expected {2}to be {3.Operator}, but was {3.Real}")
        prefix := assertion.IsInverted ? "not " : ""
        if assertion is zz_assert.RelativeAssertion {
            throw zBadInputError(relTemplate(
                this,
                prefix,
                assertion))
        } else if assertion is zz_assert.UnaryAssertion {
            throw zBadInputError(typeTemplate(
                this,
                prefix,
                assertion))
        }
    }
}