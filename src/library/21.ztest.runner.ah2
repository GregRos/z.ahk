#include 01.zinit.ah2
#include 08.zassert.ah2
#include 03.zstack.ah2
class zInvalidTestError extends Error {

}

class zz_TestAssertionFailed {
    __New(assertion, data) {
        this.Assertion := assertion
        this.Data := data
        frames := this.Stack := zz_stack.capture(1)

    }


}

class zz_TestResult {
    __New(suite, test, result) {
        this.suite := suite
        this.Test := test
        this.result := result
    }

    isOk {
        get =>this.result = True
    }

    isFail {
        get =>this.result is zz_AssertionFailed
    }

    isError {
        get =>this.result is Error
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
        config.reporter := zz_test_expandReporter(config.reporter)
        for suite in this._suites {
            suiteReporter := config.reporter
            suite.zzRun(suiteReporter.suite({
                suite: suite.Name
            }))
        }
    }
}