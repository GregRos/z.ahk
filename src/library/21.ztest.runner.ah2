#include 01.zinit.ah2
#include 08.zassert.ah2
#include 03.zstack.ah2
class zInvalidTestError extends Error {

}

class zz_TestAssertionFailed {
    ; The assertion that failed.
    Assertion := ""

    ; Data included with the assertion.
    Data := ""

    ; Call stack when the assertion failed.
    Stack := ""
    __New(assertion, data) {
        this.Assertion := assertion
        this.Data := data

        frames := zz_stack.capture(1)
        ; This will find the last frame in the class zAssert. All assertions are defined on it,
        ; so the frame above that is the one with user code.
        lastFrameworkFrameIndex := zz_arr.findLastIndex(frames, frm => frm.Function.Class == "zAssert")
        
        this.Stack := zz_arr.slice(frames, lastFrameworkFrameIndex + 1)
    }

    Bottom {
        get => this.Stack[1]
    }

}

class zz_TestResult {
    __New(suite, test, result) {
        this.suite := suite
        this.Test := test
        this.result := result
        if this.isError {
            this.Result.Stack := zz_stack.Frame.parse(this.Result)
        }
        
    }

    isOk {
        get => this.result = True
    }

    isFail {
        get => this.result is zz_TestAssertionFailed
    }

    isError {
        get => this.result is Error
    }
}

class zz_Test {
    __New(name, definition) {
        this.Name := name
        this.definition := definition
    }

    zzRun() {
        try {
            this.definition.Call()
            return True
        } catch Any as err {
            return err
        }
    }
}

class zz_TestSuite {
    __New(name, tests) {
        this.Name := name
        this._tests := tests
    }

    zzRun(reporter) {
        results := []
        for test in this._tests {
            reporter.running(test.Name)
            result := zz_TestResult(this.Name, test.Name, test.zzRun())
            results.Push(result)
            reporter.result(result)
        }
        reporter.finish(results)
    }
}

class zz_TestRunner {
    _suites := []

    AddSuite(suite) {
        this._suites.Push(suite)
    }

    zzRun(config) {
        for suite in this._suites {
            suiteReporter := config.reporter
            suite.zzRun(suiteReporter.suite({
                suite: suite.Name
            }))
        }
    }
}