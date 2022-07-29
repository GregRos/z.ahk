#Include 01.bootstrap.ah2

zz_maybeGet(what, key) {
    return HasProp(what, key) = True ? Some(what[key]) : None("Missing property")
}

class zNoValueError extends zUtilsError {
    __New(reason?) {
        reason := reason ?? "unknown"
        super.__New("Option has no value. Reason: " reason ".")
    }

}

class None {
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

class Some {
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
        return Some(projection(this.value))
    }

    filter(predicate) {
        if predicate(this.value) {
            return this
        }
        return None("filtered out")
    }

    flatMap(projection) {
        result := projection(this.value)
        if result is None or result is Some {
            return result
        }
        return Some(result)
    }
}