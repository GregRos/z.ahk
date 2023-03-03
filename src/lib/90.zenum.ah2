#Include 4.assert\0.index.ah2
#include 81.zsort.ah2
/**
 * Searches an array, map, or similar for a key-value pair that fulfills a predicate, returning "" if none is found.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`predicate(val): bool` or `predicate(key, val): bool`} predicate  An **iteratee** search predicate.
 * @returns {`{Key, Value}` or `""`} The key-value pair being searched for, or `""` if not found.
 * @example
 * ; Find a string that has length 3:
 * zEnumFind( ["a", "bb", "ccc"], x => StrLen(x) == 3) ; {Key: 3, Value: "ccc"}
 * ; Find the first kvp that has the value 2:
 * zEnumFind(Map("a", 1, "b", 2), (k, v) => v == 2) ; {Key: "b", Value: 2}
 * ; Try to find 5 in an array that doesn't have it:
 * zEnumFind([1, 2, 3], x => x = 5) ; ""
 * ; Use an `if` with an assignment:
 * if kvp := zEnumFind(arr, x => x.IsTrue) {
 *  zOut("Key: {.Key}, Value: {.Value}", kvp)
 * }
 * ; Or, if you're brave, skip the `if`:
 * key := zEnumFind([1, 2, 3], x => Mod(x, 2) == 0).Key
 */
zEnumFind(self, predicate) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(predicate, "predicate").toBeCallable(1, 2)
    return zz_arr.find(self, predicate)
}

/**
 * Seaches an array, map, or similar for the key-value pair for a given value, or `""` if none is found.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`?`} value A value to look for.
 * @param {`bool`} caseSense Whether the search is case-sensitive (False).
 * @returns {`{Key, Value}` or `""`} The key-value pair being searched for, or `""` if not found.
 * @example
 * ; Find the index of the value "c":
 * zEnumKvpOf(["a", "b", "c"], "c").Key ; 3
 * ; Check if an array doesn't have "c":
 * not EnumKvpOf(["a", "b"], "c") ; True
 */
zEnumKvpOf(self, value, caseSense := False) {
    return zEnumFind(self, x => caseSense ? x == value : x = value)
}

/**
 * Checks if every item in an array, map, or similar matches `predicate`.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`predicate(val): bool` or `predicate(key, val): bool`} predicate  An **iteratee** predicate.
 * @example
 * ; Check if every number in an array is less than 5:
 * zEnumEvery([1, 2, 3, 4], x => x < 5) ; True
 * ; Check if every number in an array is even:
 * zEnumEvery([1, 2, 3], x => Mod(x, 2) == 0) ; False
 */
zEnumEvery(self, predicate) {
    predicate := zz_func.wrapIteratee(predicate)
    return not zEnumFind(self, (k, v) => not predicate(k, v))
}

/**
 * Applies the reduce operation, from left to right, on an array, map, or similar, starting from a given initial value.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`acc(total, current) => ?` or `acc(key, total, current) => ?`} accumulator An **iteratee** accumulator.
 * @param {`?`} initial The initial value. If missing, the first value of `self` is used.
 * @throws {`UnsetError`} If initial is not given and `self` is empty.
 * @example
 * ; Sum numbers in an array:
 * sum := zEnumReduce([1, 2, 3], (acc, cur) => acc + cur, 0) ; 6
 * ; Multiply numbers in an array:
 * product := zEnumReduce([2, 2, 2], (acc, cur) => acc * cur, 1) ; 8
 * ; Concat strings in an array:
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
 * Sums the values of an array, map, or similar.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence, assumed to be numeric.
 * @example
 * ; Sum an array of numbers:
 * zEnumSum([2, 4, 8]) ; 14
 * ; Sum an empty array:
 * zEnumSum([]) ; 0
 */
zEnumSum(self) {
    return zEnumReduce(self, (key, acc, cur) => acc + cur, 0)
}


/**
 * Multiplies the values of an array, map, or similar.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence, assumed to be numeric.
 * @example
 * ; Multiply an array of numbers:
 * zEnumProd([1, 2, 3]) ; 6
 * ; Multiply an empty array:
 * zEnumProd([]) ; 1
 */
zEnumProd(self) {
    return zEnumReduce(self, (key, acc, cur) => acc * cur, 1)
}


/**
 * Computes the average of an array, map, or similar.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence, assumed to be numeric.
 * @example
 * ; Average of an array of numbers:
 * zEnumAvg([1, 2, 3]) ; 2
 * ; Average of an empty array:
 * zEnumAvg([]) ; 0
 */
zEnumAvg(self) {
    len := 0
    total := zEnumReduce(self, (tot, cur) => len++, cur + tot)
    if len == 0 {
        return 0
    }
    return total / len
}

/**
 * Tries to determine the *length* of an array, map, or similar. May enumerate it.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence. It may be enumerated.
 * 
 * @example
 * zEnumLength([1, 2, 3]) ; 3
 * zEnumLength(Map()) ; 0
 * zEnumLength("hello") ; 5
 */
zEnumLength(self) {
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
 * Groups the values in a map, array, or similar into arrays based on a generated key (as computed by a function), returning a new `Map` that links each key to a
 * matching array.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`getKey(val) => ?` or `getKey(key, val) => ?`} getKey A key-generating **iteratee**.
 * @param {`bool`} caseSense Whether the search is case-sensitive.
 * 
 * @example
 * ; Groups an array of full names by last name:
 * everyone := ["Bill Gates", "Melinda Gates", "Bill Nye"]
 * zEnumGroupBy(everyone, person => StrSplit(person, " ")[2]) ; Map(
 * ; "Gates", ["Bill Gates", "Melinda Gates"],
 * ; "Nye", ["Bill Nye"]
 * ; )
 */
zEnumGroupBy(self, getKey, caseSense := False) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(getKey, "getKey").toBeCallable(1)
    getKey := zz_func.wrapIteratee(getKey)
    outMap := Map()
    outMap.CaseSense := caseSense
    outMap.Default := []
    for key, val in zz_gen.withIndexing(self) {
        groupKey := getKey(key, val)
        if not outMap.Has(groupKey) {
            bucket := outMap[groupKey] := []
        } else {
            bucket := outMap[groupKey]
        }
        bucket.Push(val)
    }
    return outMap
}

/**
 * Filters an array, map, or similar using a predicate and returns the results in an array.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`predicate(val) => bool` or `predicate(key, val) => bool`} predicate  An **iteratee** predicate. Determines which values to include.
 * @example
 * ; Filters an array for even values:
 * zEnumFilter([1, 2, 3, 4, 5], x => Mod(x, 2) == 0) ; [2, 4]
 * 
 * ; Filters an array for strings of length 2:
 * zEnumFilter(["a", "b", "cc"], x => StrLen(x) == 2) ; ["cc"]
 */
zEnumFilter(self, predicate) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(predicate, "predicate").toBeCallable(1, 2)
    return zz_arr.filter(self, predicate)
}

/**
 * Applies a function on each value of an array, map, or similar, collecting the results in an array.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`project(val) => ?` or `project(key, val) => ?`} projection A function to apply on each key-value pair.
 * @example
 * ; Multiplies every item in an array by 2:
 * zEnumMap([1, 2, 3], x => x * 2) ; [2, 4, 6]
 * 
 * ; Turns an array of strings into an array of their lengths:
 * zEnumMap(["a", "b", "c"], x => StrLen(x)) ; [1, 1, 1]
 */
zEnumMap(self, projection) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(projection, "projection").toBeCallable(1, 2)
    projection := zz_func.wrapIteratee(projection)
    newArr := []
    for index, item in zz_gen.withIndexing(self) {
        newArr.Push(projection(index, item))
    }
    return newArr
}

/**
 * Applies a projection on each value of an array, map, or similar and collects the results in an array. Any
 * arrays returned by the projection are flattened or merged into the results and not added as elements.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`project(val) => ?` or `project(key, val) => ?`} projection The function to apply on each value.
 * @remarks Note that only arrays are flattened. Other collections or sequences are not flattened.
 * @example
 * ; Repeats each element in an array twice:
 * zEnumFlatMap([2, 3, 4], n => [n, n]) ; [2, 2, 3, 3, 4, 4]
 * ; Takes an array of pokemon and returns an array of all their moves:
 * zEnumFlatMap([Pikachu, Bulbasaur, Eevee], x => x.moves) ; ["Electro Ball", "Thunderbolt", "Giga Drain", "Tackle"]
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
 * Takes an array, map, or similar and returns an array of its values in the reverse order.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @remarks This operation may not make sense on `Map` collections.
 * @example
 * ; Reverses an array of numbers:
 * zEnumReverse([1, 2, 3]) ; [3, 2, 1]
 * ; Reverses an empty array:
 * zEnumReverse([]) ; []
 */
zEnumReverse(self) {
    zExpectArg(self, "self").toBeArray()
    return zz_arr.reverse(self)
}

/**
 * Takes an array, map, or similar and returns an array consisting of values with distinct keys, 
 * as determined by a key generating function.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`getKey(val) => ?` or `getKey(key, val) => ?`} getKey A key-generating **iteratee**.
 * @param {`bool`} caseSense Whether uniqueness is case-sensitive.
 * @example
 * ; Distinct last names:
 * zEnumUniqBy(["Bill Gates", "Steve Jobs", "Melinda Gates"], x => StrSplit(x, " ")[2]) ; ["Bill Gates", "Steve Jobs"]
 */
zEnumUniqBy(self, getKey, caseSense := False) {
    return zEnumMap(zEnumGroupBy(self, getKey, caseSense), (k, vs) => vs[1])
}
/**
 * Takes an array, map, or similar and returns an array consisting of only distinct values.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`bool`} caseSense Whether uniqueness is case-sensitive.
 * @example
 * ; Remove duplicate numbers:
 * zEnumUniq([1, 2, 2, 3, 3, 1, 3]) ; [1, 2, 3]
 * ; Split a sentence into words, remove duplicates:
 * zEnumUniq(StrSplit("I wanna wanna sweetie", " ")) ; ["I", "wanna", "sweetie"]
 */
zEnumUniq(self, caseSense := False) {
    return zEnumUniqBy(self, x => x, caseSense)
}

/**
 * Takes an array, map, or similar and returns a new array with the same elements sorted in ascending order.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 */
zEnumOrder(self) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    return zz_Ordering().ToArray(self)
}

/**
 * Takes an array, map, or similar and returns a new array with the same elements sorted in descending order.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 */
zEnumOrderDesc(self) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    return zz_Ordering().Flip.ToArray(self)
}

/**
 * Takes an array, map, or similar and returns a new array with the same elements sorted in ascending order by key.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`getOrderingKey(val): ?`} getOrderingKey A function that gets the key of each value.
 */
zEnumOrderBy(self, getOrderingKey) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(getOrderingKey, "getOrderingKey").toBeCallable(1)
    return zz_Ordering.byKey(getOrderingKey).ToArray(self)
}

/**
 * Takes an array, map, or similar and returns a new array with the same elements sorted in descending order by key.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`getOrderingKey(val): ?`} getOrderingKey A function that gets the key of each value.
 */
zEnumOrderByDesc(self, getOrderingKey) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(getOrderingKey, "getOrderingKey").toBeCallable(1)
    return zz_Ordering.byKey(getOrderingKey).Flip.ToArray(self)
}

/**
 * Sorts an array-like collection in ascending order.
 * @param {`ArrayLike`} self An array-like collection.
 */
zEnumSort(self) {
    zExpectArg(self, "self").toBeArrayLike()
    return zz_Ordering().InPlace(self)
}

/**
 * Sorts an array-like collection in descending order.
 * @param {`ArrayLike`} self An array-like collection.
 */
zEnumSortDesc(self) {
    zExpectArg(self, "self").toBeArrayLike()
    return zz_Ordering().Flip.InPlace(self)
}

/**
 * Sorts an array-like collection in ascending order by key.
 * @param {`ArrayLike`} self An array-like collection.
 * @param {`getOrderingKey(val): ?`} getOrderingKey A function that gets the key of each value.
 */
zEnumSortBy(self, getOrderingKey) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(getOrderingKey, "getOrderingKey").toBeCallable(1)
    return zz_Ordering.byKey(getOrderingKey).ToArray(self)
}

/**
 * Sorts an array-like collection in descending order by key.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`getOrderingKey(val): ?`} getOrderingKey A function that gets the key of each value.
 */
zEnumSortByDesc(self, getOrderingKey) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(getOrderingKey, "getOrderingKey").toBeCallable(1)
    return zz_Ordering.byKey(getOrderingKey).Flip.ToArray(self)
}