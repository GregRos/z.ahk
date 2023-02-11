#Include 01.zinit.ah2

class zNoValueError extends zError {
    __New(reason?) {
        reason := reason ?? "unknown"
        super.__New("Option has no value. Reason: " reason ".")
    }

}

class zNone {
    __New(reason?) {
        if IsSet(reason) {
            this.reason := reason
        }
    }

    isSome {
        get => false
    }

    isNone {
        get => true
    }

    map(projection) {
        return this
    }

    filter(predicate) {
        return this
    }

    flatMap(projection) {
        return this
    }

    value {
        get {
            throw zNoValueError(this.reason)
        }
    }
}

class zSome {
    __New(value) {
        this.value := value
    }
    isSome {
        get => true
    }

    isNone {
        get => false
    }

    map(projection) {
        return zSome(projection(this.value))
    }

    filter(predicate) {
        if predicate(this.value) {
            return this
        }
        return zNone("filtered out")
    }

    flatMap(projection) {
        result := projection(this.value)
        if result is zNone or result is zSome {
            return result
        }
        return zSome(result)
    }
}