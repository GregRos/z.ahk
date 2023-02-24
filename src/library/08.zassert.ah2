#include 01.zinit.ah2
#include 07.ztemplate.ah2

class zAssertFail {
    Name := "???"
    Values := {}
    Text := "???"
    __New(name, text, values) {
        this.Name := name
        this.Values := values
        this.Text := text
    }
}

class zAssertFailureInfo {
    __New(assertion, data) {
        this.assertion := assertion
        this.data := data
    }
}

class zTypeAssertion {
    __New(real, relation, type) {
        this.Real := real
        this.Relation := relation
        this.Type := type
    }

    Description {
        get {
            static template := zTemplate("{.Relation} {.Type}")
            return template(this)
        }
    }

    TextTitle {
        get {
            static template := zTemplate("[!real]🟥 Real[!] [!kw]{.Relation}[!] [!type]{.Type}[!]")
            return template(this)
        }
    }

    TextBody {
        get {
            static template := zTemplate("[!real]🟥 real: {.Real} [!]")
            return template(this)
        }
    }
}

class zComparisonAssertion {
    __New(real, relation, target) {
        this.Real := real
        this.Relation := relation
        this.Target := target
    }
}

class zAssert {
    static _quote(str) {
        Format("'{1}'", str)
    }
    _notMode := False
    __New() {

    }

    onFailedAssertion(err) {
        throw zNotImplementedError("You must implement 'onFailedAssertion'.")
    }

    onSuccessfulAssertion(assert) {

    }

    _kwTypeAssertion(real, kw, type) {
        static template := zTemplate("[!real]Real[!] [!kw]{.kw}[!] [!type]{.Type}[!]")
        return {
            title: template({
                kw: kw,
                type: type
            }),
            full: ""
        }
    }

    _relationAssertion(real, relation, expected) {
        out := ""
        writer := zWriter(&out)
        title := zTemplate("[!real]🟥 real[!] [!operator]{.relation}[!] [!expected]🟢 expected[!]")({
            relation: relation
        })
        writer.Put("[!real]🟥 real: ")
        writer.PutLn(zPrint(real) "[!]")
        writer.Put("[!expected]🟢 expected: ")
        writer.Put(zPrint(expected) "[!]")
        writer.Flush()
        return {
            title: title,
            full: out
        }
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
            this._fail(failText, data)
        } else if success and notMode {
            this._fail(passText, data)
        } else {
            this.onSuccessfulAssertion(passText)
        }
    }

    fail(message) {
        this._fail({
            title: message,
            full: ""
        }, {})
    }

    _fail(assertion, data) {
        failure := zAssertFailureInfo(assertion, data)
        this.onFailedAssertion(failure)
    }

    isArray(real) {
        pass := this._kwTypeAssertion(real, "is", "Array")
        fail := this._kwTypeAssertion(real, "is not", "Array")
        this._result(real is Array, pass, fail, {})
    }

    isInt(real) {
        pass := this._kwTypeAssertion(real, "is an", "Integer")
        fail := this._kwTypeAssertion(real, "isn't an", "Integer")
        this._result(IsInteger(real), pass, fail, {})
    }

    isTrue(real) {
        pass := this._kwTypeAssertion(real, "is", "True")
        fail := this._kwTypeAssertion(real, "isn't", "True")
        this._result(real == True, pass, fail, {})
    }

    isFalse(real) {
        pass := this._kwTypeAssertion(real, "is", "False")
        fail := this._kwTypeAssertion(real, "isn't", "False")
        this._result(real == False, pass, fail, {})
    }

    isTruthy(real) {
        pass := this._relationAssertion(real, "is", "Truthy")
        fail := this._relationAssertion(real, "isn't", "Truthy")
        this._result(real == True, pass, fail, {})
    }

    throws(function) {
        ex := ""
        try {
            function()
        } catch as e {
            ex := e
        }
        this._result(!!ex, "function threw", "function didn't throw", {})
    }

    isFalsy(real) {
        pass := this._relationAssertion(real, "is", "Falsy")
        fail := this._relationAssertion(real, "isn't", "Falsy")
        this._result(real == True, pass, fail, {})
    }


    isEqual(real, expected) {
        pass := this._relationAssertion(real, "is equal to", expected)
        fail := this._relationAssertion(real, "isn't equal to", expected)
        this._result(zz_obj.equal(real, expected, False), pass, fail, {})
    }

    atLeast(real, lowerBound) {
        pass := this._relationAssertion(real, "is at least", lowerBound)
        fail := this._relationAssertion(real, "isn't at least", lowerBound)
        this._result(real >= lowerBound, pass, fail, {
            real: real
        })
    }

    atMost(real, upperBound) {
        pass := this._relationAssertion(real, "is at most", upperBound)
        fail := this._relationAssertion(real, "isn't at most", upperBound)
        this._result(real <= upperBound, pass, fail, {})
    }

    strHas(real, needle, caseMode := False) {
        pass := this._relationAssertion(real, "has substring", zAssert._quote(needle))
        fail := this._relationAssertion(real, "doesn't have substring", zAssert._quote(needle))
        this._result(InStr(real, needle, caseMode), pass, fail, {})
    }

    arrayHas(real, element, caseMode := False) {
        pass := this._relationAssertion(real, "has array element", zAssert._quote(element))
        fail := this._relationAssertion(real, "doesn't have array element", zAssert._quote(element))
        this._result(zz_arr.has(real, element, caseMode).Length, pass, fail, {})
    }

}