class zz_Inspect {
    __New(REAL?) {
        this.REAL := REAL ?? ""
    }

    next(other) {
        return zz_Inspect(other)
    }

    isEnum(arity?) {
        obj := this.REAL
        if this.isCallable(arity?) {
            return True
        }
        if not IsSet(arity) {
            return True
        }
        try {
            iterator := obj.__Enum(arity)
            return this.next(iterator).isCallable(arity)
        } catch Error as e {
            return False
        }
    }

    HasProp(name) {
        return HasProp(this.REAL, name)
    }

    isArrayLike {
        get {
            obj := this.REAL
            return this.HasProp("Length") and this.isEnum(1) and this.hasIndexer(1)
        }
    }

    minParams {
        get {
            f := this.REAL
            if f is Func {
                return f.MinParams
            }
            return f.Call.MinParams - 1
        }
    }

    isVariadic {
        get {
            f := this.REAL
            if f is Func {
                return f.IsVariadic
            }
            return f.Call.IsVariadic
        }
    }

    isObject {
        get => IsObject(this.REAL)
    }


    maxParams {
        get {
            f := this.REAL
            if f is Func {
                return f.MaxParams
            }
            return f.Call.MaxParams - 1
        }
    }

    keys {
        get {
            mp := this.REAL
            arr := []
            for key, val in mp {
                arr.Push(key)
            }
            return arr
        }
    }

    length {
        get {
            vector := this.REAL
            if vector is String {
                return StrLen(vector)
            } else if not this.isObject {
                throw zBadInputError("Cannot get length of a number.", vector)
            }
            if this.HasProp("Count") {
                return vector.Count
            } else if this.HasProp("Length") {
                return vector.Length
            }
            throw zBadInputError("Cannot get length of this object.", vector)
        }
    }

    contains(item) {
        container := this.REAL
        if not IsObject(container) {
            return !!InStr(container, item)
        }
        if container is Array {
            return zz_arr.find(container, item)
        } else if container is Map {
            return container.Has(item)
        } else if container.HasMethod("IndexOf") {
            return !!container.IndexOf(item)
        }

    }

    isCallable(withParams?) {
        input := this.REAL
        if not HasMethod(input) {
            return False
        }
        if not IsSet(withParams) {
            return True
        }

        return withParams >= this.minParams and withParams <= this.maxParams
    }

    normalizeIteratee() {
        f := this.REAL
        if this.maxParams = 2 or this.isVariadic {
            return f
        }
        if this.maxParams = 1 {
            return (i, x) => f(x)
        }

        throw zBadInputError("Expected function to take 1 or 2 parameters", f.MaxParams)
    }

    normalizeAccumulator() {
        f := this.REAL
        if this.isCallable(3) {
            return this.REAL
        }
        switch this.maxParams {
            case 2:
                return (key, acc, cur) => f(acc, cur)
            case 1:
                return (key, acc, cur) => f(acc)
            case 0:
                return (key, acc, cur) => f()
        }
        return this.REAL
    }

    shortString {
        get {
            self := this.REAL
            if IsObject(self) {
                if HasMethod(self, "ToString") or HasProp(self, "ToString") {
                    return self.ToString()
                }
                return Type(self)
            } else {
                return String(self)
            }
        }
    }

    withIndexing() {
        source := this.REAL
        pos := 0
        if this.isEnum(2) {
            return source.__Enum(2)
        } else if this.isEnum(1) {
            session := source.__Enum(1)
            return ((key, value) => session(value), %key% := pos)
        }

    }

    funcName {
        get {
            f := this.REAL
            if f is Func {
                return f.Name
            }
            return "<anonymous>"
        }
    }

    normalizeJoinIteratee(dimension) {
        f := this.REAL
        maxParams := this.maxParams
        ; Variadic functions don't need to be wrapped
        if this.isVariadic or this.maxParams == dimension + 1 {
            return f
        } else if maxParams > dimension + 1 {
            ; This means it requires more parameters than is allowed.
            throw zInvalidCallError(f, Format("Function takes {1} params, but expected up to {2}.", f.MaxParams, dimension + 1))
        } else {
            ; The full signature of a join iteratee is (key, item1, ..., itemN) => joinResult
            ; However, you can pass in a function taking fewer parameters so the later inputs are ignored.

            invokeJoinIteratee(args*) {
                ; Next we trim the number of args to be the maximum allowed.
                args.Length := maxParams
                return f.Call(args*)
            }
            return invokeIteratee
        }


    }


    hasIndexer(arity?) {
        if not HasProp(this.REAL, "__Item") {
            return False
        }
        indexer := this.REAL.__Enum

        return this.next(indexer).isCallable(arity?)
    }
}