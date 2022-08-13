#include 01.zinit.ah2
#include 07.ztemplate.ah2
class zAssertFailureInfo {
    __New(assertion, data) {
        this.assertion := assertion
        this.data := data
    }
}

zz_assert_quote(str) {
    return Format("'{1}'", str)
}

class zAssert {
    _notMode := False
    __New(onFailCallback) {
        this._onFailCallback := onFailCallback
    }

    _kwTypeAssertion(kw,type) {
        static template := zTemplate("[!real]$real[!] [!kw]{kw}[!] [!type]{type}[!]")
        return template({
            kw: kw,
            type: type
        })
    }

    _relationAssertion(relation, other) {
        static template := zTemplate("[!real]$real[!] [!operator]{relation}[!] [!value]{other}[!]")
        return template({
            relation: relation,
            other: other
        })
    }

    not {
        get {
            this._notMode := not this._notMode
            return this
        }
    }

    _result(success, passText, failText, data) {
        notMode := this._notMode
        this._notMode := False
        if not success and not notMode {
            this._fail(passText, data)
        } else if success and notMode {
            this._fail(failText, data)
        }
    }

    _fail(assertion, data) {
        failure := zAssertFailureInfo(assertion, data)
        this._onFailCallback.Call(failure)
    }

    isArray(real) {
        static pass := this._kwTypeAssertion("is", "Array")
        static fail := this._kwTypeAssertion("is not", "Array")
        this._result(real is Array, pass, fail, {
            real: real
        })
    }

    isInt(real) {
        static pass := this._kwTypeAssertion("is an", "Integer")
        static fail := this._kwTypeAssertion("isn't an", "Integer")
        this._result(IsInteger(real), pass, fail, {
            real: real
        })
    }

    isTrue(real) {
        static pass := this._kwTypeAssertion("is", "True")
        static fail := this._kwTypeAssertion("isn't", "True")
        this._result(real == True, pass, fail, {
            real: real
        })
    }

    isFalse(real) {
        static pass := this._kwTypeAssertion("is", "False")
        static fail := this._kwTypeAssertion("isn't", "False")
        this._result(real == False, pass, fail, {
            real: real
        })
    }

    isTruthy(real) {
        static pass := this._relationAssertion("is", "Truthy")
        static fail := this._relationAssertion("isn't", "Truthy")
            this._result(real == True, pass, fail, {
            real: real
        })
    }

    isFalsy(real) {
        static pass := this._relationAssertion("is", "Falsy")
        static fail := this._relationAssertion("isn't", "Falsy")
        this._result(real == True, pass, fail, {
            real: real
        })
    }

    isEqual(real, expected) {
        static pass := this._relationAssertion("is equal to", "$expected")
        static fail := this._relationAssertion("isn't equal to", "$expected")
        this._result(zz_equal(real, expected, False), pass, fail, {
            real: real,
            expected: expected
        })
    }

    atLeast(real, lowerBound) {
        pass := this._relationAssertion("is at least", lowerBound)
        fail := this._relationAssertion("isn't at least", lowerBound)
        this._result(real >= lowerBound, pass, fail, {
            real: real
        })
    }

    atMost(real, upperBound) {
        pass := this._relationAssertion("is at most", lowerBound)
        fail := this._relationAssertion("isn't at most", lowerBound)
        this._result(real <= upperBound, pass, fail, {
            real: real
        })
    }

    strHas(real, needle, caseMode := False) {
        pass := this._relationAssertion("has substring", zz_assert_quote(needle))
        fail := this._relationAssertion("doesn't have substring", zz_assert_quote(needle))
        this._result(InStr(real, needle, caseMode), pass, fail, {
            real: real,
            caseMode: caseMode
        })
    }

    arrayHas(real, element, caseMode := False) {
        static pass := this._relationAssertion("has array element", "$element")
        static fail := this._relationAssertion("doesn't have array element", "$element")
        this._result(zz_array_has(real, element, caseMode).Length, pass, fail, {
            real: real,
            element: item,
            caseMode: caseMode
        })
    }

}