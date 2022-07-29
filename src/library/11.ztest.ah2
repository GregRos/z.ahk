#include 10.zassert.ah2
#include 02.zmaybe.ah2


class zInvalidTestError extends Error {
    
}

class zzTestRegistry {
    _suites := Map()
    __New() {

    }

    Count {
        get => this._suites.Count
    }

    Add(suite) {
        if this._suites.Has(suite.Name) {
            throw zInvalidTestError(Format("A test suite with the name '{1}' already exists.", suite.Name))
        }
        this._suites.Set(suite.Name, suite)
    }

    Run(suite) {
        proto := suite.Base

    }

    RunAll() {

    }
}

global registry := zzTestRegistry()

class zTestSuite extends zAssert {

    __New() {
        base.__New(ObjBindMethod(this, "assertFailed"))
    }

    assertFailed() {

    }

    Name {
        get {
            return Type(this)
        }
    }

    static __New() {
        if (this != zTestSuite) {
            registry.Add(this())
        }
    }
}

