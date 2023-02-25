class zInvalidTestError extends Error {

}



class zz_TestResult {
    __New(suite, test, result) {
        this.suite := suite
        this.Test := test
        this.result := result

        
    }

    assertions {
        get => +this.result
    }

    isOk {
        get => this.result is Integer
    }

    isFail {
        get => this.result is zAssertionFailedError
    }

    isError {
        get => !this.isFail and this.result is Error
    }
}

class zz_Test {
    __New(name, definition) {
        this.Name := name
        this.definition := definition
    }

    zzRun() {
        try {
            return this.definition.Call()
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