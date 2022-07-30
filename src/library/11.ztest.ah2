#include 10.zassert.ah2
#include 02.zmaybe.ah2

class zz_TestResult {
    __New(suite, test, result) {
        this.suite := suite
        this.test := test
        this.result := result
    }
}

class zz_Test {
    __New(title, definition) {
        this.title := title
        this.definition := definition
    }

    Run() {
        try {
            this.definition()
        } catch Error as err {
            return err
        }
    }
}

zz_testSuites := []

class zz_TestSuite {
    __New(title, tests := []) {
        this.title := title
        this._tests := tests
    }

    Add(test) {
        this._tests.Push(test)
    }

    Run() {
        results := []
        for test in this._tests {
            result := test.Run()
            results.Push(zz_TestResult(this.title, test.title, result))
        }
        return results
    }
}

class zInvalidTestError extends Error {
    
}

class zz_AssertionFailedError extends Error {
    __New(failure) {
        super.__New(Format("Assertion[{1}] failed - {2}", failure.assertion, failure.message))
        this.info := failure
    }
}

class zTestSuite extends zAssert {
    static suites := []
    __New() {
        base.__New(ObjBindMethod(this, "raise"))
    }

    raise(failure) {
        throw zz_AssertionFailedError(failure)
    }

    Name {
        get {
            return Type(this)
        }
    }
    static makeSuiteFromClass(suiteClass) {
        tests := []
        inst := suiteClass()
        for key in ObjOwnProps(suiteClass.Prototype) {
            value := suiteClass.Prototype[key]
            if HasProp(value, "Call") {
                bound := ObjBindMethod(inst, key)
                tests.Push(zz_Test(title, bound))
            }
        }
        return zz_TestSuite(Type(inst), tests)
    }

    static __New() {
        if (this != zTestSuite) {
            this.suites.Push(this.makeSuiteFromClass(this))
        }
    }
}

