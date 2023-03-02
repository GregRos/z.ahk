#Include 4.assert\0.index.ah2

/**
 * Returns true if there is a value in `self` matching `predicate`. If so, the key will be assigned to `gotK` and the 
 * value to `gotV`. If there is no key, `A_Index` will be used.
 * @param self `Enum2` or `Enum1` An enumerable with one or two params. If `Enum2`, the first param is taken to be a key.
 * @param predicate `value => bool` or `(key, value) => bool` A predicate used to search for the value.
 * @remarks If you pass in an `Enum1`, you can still pass in a predicate with 2 params. The key will be `A_Index`.
 * @example
 * zEnumFind( ["a", "bb", "ccc"], x => StrLen(x) == 3) ; theKey == "ccc"
 * zEnumFind(Map("a", 1, "b", 2), (k, v) => v == 2) ; "b"
 */
zEnumFind(self, predicate, &gotK?, &gotV?) {
    return zz_gen.findKey(self, predicate)
}

/**
 * Returns the key of the first appearance of `what` in `self`, or `unset` otherwise. If `self` takes only one
 * parameter, the `key` will be `A_Index`.
 * @param self `Enum1` or `Enum2` An enumerable with one or two params. If `Enum2`, the first param is taken to be a key.
 * @param what `?` A value
 * @param caseSense `bool` Whether the search is case-sensitive.
 * @example
 * zEnumKeyOf(["a", "b"], "b") ; 2
 * 
 * zEnumKeyOf(Map("a", 1, "b", 2), 2) ; "b"
 */
zEnumKeyOf(self, what, found, caseSense := False) {
    zExpectArg(self, "self").toBeEnum()
    zExpectArg(caseSense, "caseSensitive").toBeBool()
    for ix, value in zz_gen.withIndexing(what) {
        if (!caseSense and what = value) or what == value {
            return key
        }
    }
    return unset
}

/**
 * Returns True if `what` appears as a value in `self`.
 * @param self `Enum1` or `Enum2` An enumerable with one or two parameters.
 * @param what `?` A value.
 * @param caseSense `bool` Whether the search is case-sensitive.
 * @example
 * if zEnumHas([1, 2, 3], 3) {
 *     OutputDebug("The value was found!")
 * }
 */
zEnumHas(self, what, caseSense := False) {
    x := zEnumKeyOf(self, what, caseSense) ?? unset
    return IsSet(x)
}

/**
 * Returns the first value matching `predicate` in `self`, and `unset` otherwise.
 * @param self `Enum1` or `Enum2` An enumerable with one or two parameters. If `Enum2`, the first param is taken to be a key.
 * @param predicate `val => ?` or `(key, val) => ?` A predicate used to search for a matching value.
 * @remarks If you pass in an `Enum1`, you can still pass in a predicate with 2 params. The key will be `A_Index`.
 * @example
 * zEnumFind(["hello", "world"], (k, v) => InStr(v, "w")) ; "world"
 */
zEnumFind(self, predicate) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(predicate, "predicate").toBeCallable(0, 2)
    predicate := zz_func.wrapIteratee(predicate)
    for key, value in zz_gen.withIndexing(self) {
        if predicate(key, value) {
            return value
        }
    }
    return unset
}

/**
 * Returns True if there exists a value matching `predicate` in `self`.
 * @param self `Enum1` or `Enum2` An enumerable with one or two parameters. If `Enum2`, the first param is taken to be a key.
 * @param predicate `val => ?` or `(key, val) => ?` A predicate used to search for a matching value.
 * @remarks If you pass in an `Enum1`, you can still pass in a predicate with 2 params. The key will be `A_Index`.
 * @example
 * if zEnumExists([1, 2, 3], x => Mod(x, 2) == 0) {
 *     OutputDebug("Found even number!")
 * }
 */
zEnumExists(self, predicate) {
    key := zEnumFindKey(self, predicate) ?? unset
    return IsSet(key)
}

/**
 * Returns True if every value in `self` matches `predicate`.
 * @param self `Enum1` or `Enum2` An enumerable with one or two parameters. If `Enum2`, the first param is taken to be a key.
 * @param predicate `val => ?` or `(key, val) => ?` The predicate.
 * @remarks If you pass in an `Enum1`, you can still pass in a predicate with 2 params. The key will be `A_Index`.
 * @example
 * if zEnumEvery([1, 2, 3], x => x is Integer) {
 *     OutputDebug("They were all integers!")
 * }
 */
zEnumEvery(self, predicate) {
    predicate := zz_func.wrapIteratee(predicate)
    return not zEnumExists(self, (k, v) => not predicate(k, v))
}

/**
 * Applies the reduce operation, from left to right, on `self` starting with initial value
 * `initial`. This is a general form of aggregating a list, such as by summing, multiplying, or concatenating.
 * @param self `Enum1` or `Enum2` An enumerable with one or two params. If `Enum2`, the first param is taken to be a key.
 * @param accumulator `(acc, cur) => ?` or `(key, acc, cur) => ?` The accumulator function that generates the next value.
 * @param initial `?` Used as the initial value. If missing, the first value in `self` is used. If there is none, `UnsetError` is thrown.
 * @remarks If you pass in an `Enum1`, you can still pass in a predicate with a key param. The key will be `A_Index`.
 * @example
 * sum := zEnumReduce([1, 2, 3], (acc, cur) => acc + cur, 0) ; 6
 * product := zEnumReduce([1, 2, 3], (acc, cur) => acc * cur, 1) ; 6
 * concat := zEnumReduce(["hello", " ", "world"], (acc, cur) => acc cur, "") ; "hello world"
 * @see https://docs.python.org/3/library/functools.html#functools.reduce
 * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce
 */
zEnumReduce(self, accumulator, initial := unset) {
    zExpectArg(self, "self").toBeEnum(2)
    zExpectArg(accumulator, "accumulator").toBeCallable(2, 3)
    accumulator := zz_func.wrapAccumulator(accumulator)
    current := initial ?? unset
    for index, item in self {
        if not IsSet(current) {
            current := item
            continue
        }
        current := accumulator(index, current, item)
    }
    if not IsSet(current) {
        throw UnsetError("Parameter 'initial' was unset and 'self' was empty.")
    }
    return current
}

/**
 * Sums the values of `self`, which are assumed to be numeric.
 * @param self An enumerable with one or two params. If `Enum2`, the first param is taken to be a key.
 * @example
 * zEnumSum([2, 4, 8]) ; 14
 * zEnumSum([]) ; 0
 */
zEnumSum(self) {
    return zEnumReduce(self, (key, acc, cur) => acc + cur, 0)
}
/**
 * Tries to determine the number of items in `self`. May enumerate `self`.
 * @param self `Enum1` or `Enum2` An enumerable with one or two parameters
 */
zEnumCount(self) {
    if self is String {
        return StrLen(self)
    }
    if not IsObject(self) {
        throw zBadInputError("The parameter 'self' must be an object or a string")
    }
    if HasProp(self, "Length") {
        return self.Length
    } else if HasProp(self, "Count") {
        return self.Count
    }
    if zz_obj.isEnum(self, 1) {
        for x in self {
            last := A_Index
        }
    } else if zz_obj.isEnum(self, 2) {
        for a, b in self {
            last := A_Index
        }
    } else {
        throw zBadInputError("Parameter 'self' is not a valid enumerable.")
    }
    return last
}

/**
 * Multiplies the values of `self`, which are assumed to be numeric.
 * @param self An enumerable with one or two params. If `Enum2`, the first param is a key.
 * @example
 * zEnumProd([1, 2, 3]) ; 6
 * zEnumProd([]) ; 1
 */
zEnumProd(self) {
    return zEnumReduce(self, (key, acc, cur) => acc * cur, 1)
}

/**
 * Computes the average or mean of `self`, which is assumed to be numeric.
 * @param self An enumerable with one or two params. If `Enum2`, the first param is taken to be a key.
 * @example
 * zEnumAvg([1, 2, 3]) ; 2
 */
zEnumAvg(self) {
    return zEnumSum(self) / zEnumCount(self)
}

/**
 * Applies `getKey` on each value in `self`, groups the values with the same result into an array, and returns everything in a `Map`.
 * @param self `Enum1` or `Enum2` An enumerable with one or two params. If `Enum2`, the first param is taken to be a key.
 * @param getKey `val => ?` or `(key, val) => ?` Used to determine the key for each value.
 * @remarks If you pass in an `Enum1`, you can still pass in a predicate with a key param. The key will be `A_Index`.
 * Note that in any case, the key for the grouping comes from `getKey`.
 * @example
 * names := [{name: "Tony", data: 1}, {name: "Tony", data: 2}, {name: "Lyra", data: 0}]
 * gradesByName := zEnumGroupBy(names, x => x.name)
 * for key, datas in namesGroupedByFirstName {
 *     OutputDebug("The name " key " appears " datas.Length " times.")
 * }
 */
zEnumGroupBy(self, getKey) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(getKey, "getKey").toBeCallable(1)
    getKey := zz_func.wrapIteratee(getKey)
    outMap := Map()
    outMap.Default := []
    for key, val in zz_gen.withIndexing(self) {
        outMap[getKey(key, val)].Push(val)
    }
    return outMap
}

/**
 * Returns an array consisting of values of `self` that match `predicate`.
 * @param self `Enum1` or `Enum2` An enumerable with one or two params. If `Enum2`, the first param is taken to be a key.
 * @param predicate `val => bool` or `(key, val) => bool` Called on each value or key-value to decide if it goes in the array.
 * @remarks If you pass in an `Enum1`, you can still pass in a predicate with a key param. The key will be `A_Index`.
 * @example
 * zEnumFilter([1, 2, 3, 4, 5], x => Mod(x, 2) == 0) ; [2, 4]
 * zEnumFilter(["a", "b", "cc"], x => StrLen(x) == 2) ; ["cc"]
 */
zEnumFilter(self, predicate) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(predicate, "predicate").toBeCallable()
    return zz_arr.filter(self, predicate)
}

/**
 * Applies `projection` on each value in `self`, returning the results in an array.
 * @param self `Enum1` or `Enum2` An enumerable with one or two params. If `Enum2`, the first param is taken to be a key.
 * @param projection `val => ?` or `(key, val) => ?` Applied on each value.
 * @remarks If you pass in an `Enum1`, you can still pass in a predicate with a key param. The key will be `A_Index`.
 * @example
 * zEnumMap([1, 2, 3], x => x * 2) ; [2, 4, 6]
 * zEnumMap(["a", "b", "c"], x => StrLen(x)) ; [1, 1, 1]
 */
zEnumMap(self, projection) {
    zExpectArg(self, "self").toBeEnum()
    zExpectArg(projection, "projection").toBeCallable()
    projection := zz_func.wrapIteratee(projection)
    newArr := []
    for index, item in self {
        newArr.Push(projection(index, item))
    }
    return newArr
}

/**
 * Applies `projection` on each value in `self`, returning the results in an array. Any array results are merged together.
 * @param self `Enum1` or `Enum2` An enumerable with one or two params. If `Enum2`, the first param is taken to be a key.
 * @param projection `val => ?` or `(key, val) => ?` Applied on each value, and array returns are merged into the result.
 * @remarks If you pass in an `Enum1`, you can still pass in a predicate with a key param. The key will be `A_Index`.
 * @example
 * zEnumFlatMap([2, 2], n => zArrRepeat(n, n)) ; [2, 2, 2, 2]
 */
zEnumFlatMap(self, projection) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(projection, "projection").toBeCallable(1, 2)
    arr := []
    projection := zz_func.wrapIteratee(projection)
    for index, item in self {
        result := projection(index, item)
        if result is Array {
            arr.Push(result*)
        } else {
            arr.Push(result)
        }
    }
    return arr
}

/**
 * Returns an array of the values of `self` in reverse order.
 * @param self `Enum1` or `Enum2` An enumerable with one or two params. If `Enum2`, the first param is taken to be a key.
 * @example
 * zEnumReverse([1, 2, 3]) ; [3, 2, 1]
 * zEnumReverse([]) ; []
 */
zEnumReverse(self) {
    zExpectArg(self, "self").toBeArray()
    return zz_arr.reverse(self)
}

/**
 * Returns an array of the values of `self in sorted order.
 * @param self `Enum1` or `Enum2` 
 * @param 
 */
zArrOrder(self, comparer := zz_defaultComparer) {
    zExpectArg(self, "self").toBeArray()
    clone := self.Clone()
    work := self.Clone()
    zz_arr.mergeSort(clone, work, comparer)
    return clone
}

; Returns a copy of this array, its elements sorted by applying `getKey` to each element and then sorting using `comparer`.
zArrOrderBy(self, getKey, comparer := zz_defaultComparer) {
    zExpectArg(self, "self").toBeArray()
    zExpectArg(getKey, "getKey").toBeCallable()
    return zArrOrder(self, zz_keyComparer(getKey, comparer))
}