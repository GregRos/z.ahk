/**
 * Picks elements for which a predicate returns True, returning them in an array.
 * @param {Collection} collection A map or an array
 * @param {`val => bool` or `(key, val) => bool`} predicate Whether to pick an element.
 * @example
 * ; Filters an array for even values:
 * zFilter([1, 2, 3, 4, 5], x => Mod(x, 2) == 0) ; [2, 4]
 * ; Filters an array for strings of length 2:
 * zFilter(["a", "b", "cc"], x => StrLen(x) == 2) ; ["cc"]
 */
zFilter(collection, predicate) {
    zExpectArg(collection, "collection").toBeCollection()
    zExpectArg(predicate, "predicate").toBeCallable(1, 2)
    return zz_arr.filter(collection, predicate)
}

/**
 * Picks distinct elements (as determined by a key function), returning them in an array.
 * @param {Collection} collection A map or an array.
 * @param {`val => ?` or `(key, val) => ?`} getKey Computes the key for each value.
 * @param {`bool`} caseSense Whether distinctnesss is case-sensitive.
 * @example
 * ; Picks strings with distinct length:
 * zUniqBy(["a", "bb", "cc"], x => StrLen(x)) ; ["a", "bb"]
 * ; Picks strings with distinct first letters:
 * zUniqBy(["a", "bb", "cc"], x => SubStr(x, 1, 1)) ; ["a", "bb"]
 * 
 */
zUniqBy(collection, getKey, caseSense := False) {
    return zSelect(zGroupBy(collection, getKey, caseSense), (k, vs) => vs[1])
}

/**
 * Picks distinct elements, returning them in an array.
 * @param {Collection} collection A map or an array.
 * @param {`bool`} caseSense Whether distinctnesss is case-sensitive.
 * @example
 * ; Remove duplicate numbers:
 * zUniq([1, 2, 2, 3, 3, 1, 3]) ; [1, 2, 3]
 * ; Split a sentence into words, remove duplicates:
 * zUniq(StrSplit("A very very big rock")) ; ["A", "very", "big", "rock"]
 */
zUniq(collection, caseSense := False) {
    return zUniqBy(collection, x => x, caseSense)
}

/**
 * Transforms each element in a collection using a function, returning the results in an array.
 * @param {Collection} collection A map or an array.
 * @param {`val => ?` or `(key, val) => ?`} projection The function that determines the result value.
 * @example
 * ; Multiplies every item in an array by 2:
 * zSelect([1, 2, 3], x => x * 2) ; [2, 4, 6]
 * ; Turns an array of strings into an array of their lengths:
 * zSelect(["a", "b", "c"], x => StrLen(x)) ; [1, 1, 1]
 * ; Uppercases an array of strings
 * zSelect(["hello", "world"], StrUpper) ; ["HELLO", "WORLD"]
 */
zSelect(collection, projection) {
    zExpectArg(collection, "collection").toBeCollection()
    zExpectArg(projection, "projection").toBeCallable(1, 2)
    return zz_arr.map(collection, projection)
}

/**
 * Transforms each element in a collection using a function, returning the results in an array. Any arrays returned by the function are flattened into the result.
 * @param {Collection} collection A map or an array.
 * @param {`val => ?` or `(key, val) => ?`} projection The function to apply on each value.
 * @remarks Note that only arrays are flattened. Other collections or sequences are not flattened.
 * @example
 * ; Repeats each element in an array twice:
 * zSelectMany([2, 3, 4], n => [n, n]) ; [2, 2, 3, 3, 4, 4]
 * ; Takes an array of pokemon and returns an array of all their moves:
 * zSelectMany([Pikachu, Bulbasaur, Eevee], x => x.moves) ; ["Electro Ball", "Thunderbolt", "Giga Drain", "Tackle"]
 */
zSelectMany(collection, projection) {
    zExpectArg(collection, "collection").toBeCollection()
    zExpectArg(projection, "projection").toBeCallable(1, 2)
    arr := []
    projection := zz_Inspect(projection).normalizeIteratee()
    for index, item in collection {
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
 * Recursively flattens arrays and non-array values into a single array.
 * @param {`Array`} params Zero or more arrays and other values.
 * @returns A new array containing the flattened results.
 * @remarks This will only flatten arrays. Maps and similar will be treated as values.
 * @example
 * ; Returns an array with one element:
 * zFlat(1) ; [1]
 * ; Returns an array with several elements:
 * zFlat(1, 2, 3) ; [1, 2, 3]
 * ; Returns a clone of the array passed in:
 * zFlat([1, 2, 3]) ; [1, 2, 3]
 * ; Concatenates an array with some more elements:
 * zFlat([1], 2, 3) ; [1, 2, 3]
 * ; Flattens a nested array:
 * zFlat([1, [1, 2]], 2) ; [1, 1, 2, 2]
 * ; Maps and similar and not flattened:
 * zFlat(Map()) ; [Map()]
 */
zFlat(params*) {
    static inner_flat(arr, where) {
        for x in arr {
            if x is Array {
                inner_flat(x, where)
            } else {
                where.Push(x)
            }
        }
    }
    result := []
    inner_flat(params, result)
    return result
}


/**
 * Slices a string or array using start and end indexes.
 * @param {Number} start The index at which to start, inclusive. 
 * @param {Number} end The index at which to end, also inclusive.
 * @example
 * ; Returns a slice of an array with just the first item:
 * zSlice([1, 2], 1, 1) ; [1]
 * ; A slice of an array with negative indexing:
 * zSlice([1, 2, 3, 4, 5], -2, -1) ; [4, 5]
 * ; Returns a slice of a string:
 * zSlice("hello", 2, 3) ; "el"
 * ; Returns a slice of a string with negative indexes:
 * zSlice("hello", -1) ; "o"
 * ; Returns an empty array because the indexes don't exist:
 * zSlice([1, 2, 3], 4, 5) ; []
 */
zSlice(strOrArray, start := 1, end := -1) {
    zExpectArg(start, "strOrArray").toBeOneOf(Array, String)
    zExpectArg(start, "start").toBeIntLike()
    zExpectArg(end, "end").toBeIntLike()
    if strOrArray is Array {
        return zz_arr.slice(strOrArray, start, end)
    } else if strOrArray is String {
        return zz_str.slice(strOrArray, start, end)
    } else {
        zExpectArg(strOrArray, "strOrArray").fail("to be a string or array")
    }
}

/**
 * Inverts a Map, returning a new Map with the keys and values swapped. 
 * @param {Map} mapSelf A map.
 * @example
 * ; Inverts a map:
 * zInvert(Map("a", 1, "b", 2)) ; Map(1, "a", 2, "b")
 * ; Inverts a map with duplicate values:
 * zInvert(Map("a", 1, "b", 1)) ; Map(1, "b")
 */
zInvert(mapSelf) {
    zExpectArg(mapSelf, "mapSelf").toBeMap()
    inverted := Map()
    for key, value in mapSelf {
        inverted[value] := key
    }
    return inverted
}

/**
 * Groups elements into arrays based on a shared key (as determined by a function), returning a Map of key => array of elements.
 * @param {Collection} collection An array or a map. 
 * @param {`val => gKey` or `(key, val) => gKey`} getKey Computes the grouping key for each value.
 * @param {`bool`} caseSense Whether the grouping is case-sensitive (default: false).
 * @example
 * nums := [1, 2, 3, 4]
 * ; Groups some numbers by their parity:
 * zGroupBy([1, 2, 3, 4], x => Mod(x, 2)) ; Map(1 => [1, 3], 0 => [2, 4])
 * ; Groups some strings based on length:
 * zGroupBy(["", "aa", "bb", "ccc"], x => StrLen(x)) ; Map(0 => [""], 2 => ["aa", "bb"], 3 => ["ccc"])
 */
zGroupBy(collection, getKey, caseSense := False) {
    zExpectArg(collection, "collection").toBeCollection()
    zExpectArg(getKey, "getKey").toBeCallable(1, 2)
    getKey := zz_Inspect(getKey).normalizeIteratee()
    outMap := Map()
    outMap.CaseSense := caseSense
    for key, val in zz_Inspect(collection).withIndexing() {
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