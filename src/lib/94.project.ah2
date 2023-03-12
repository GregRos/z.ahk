/**
 * For each value in a collection, computes a key and then groups the values into arrays based on their key. 
 * Returns a map of key to array of values.
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self A collection. Strings are treated as arrays of characters.
 * @param {`getKey(val) => ?` or `getKey(key, val) => ?`} getKey A key-generating **iteratee**.
 * @param {`bool`} caseSense Whether the search is case-sensitive.
 * 
 * @example
 * ; Groups an array of full names by last name:
 * everyone := ["Bill Gates", "Melinda Gates", "Bill Nye"]
 * zGroupBy(everyone, person => StrSplit(person, " ")[2]) ; Map(
 * ; "Gates", ["Bill Gates", "Melinda Gates"],
 * ; "Nye", ["Bill Nye"]
 * ; )
 */
zGroupBy(self, getKey, caseSense := False) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(getKey, "getKey").toBeCallable(1, 2)
    getKey := zz_Inspect(getKey).normalizeIteratee()
    outMap := Map()
    outMap.CaseSense := caseSense
    for key, val in zz_Inspect(self).withIndexing() {
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
 * Goes over each element and apply a predicate,
 * returning an array of all the elements for which the predicate returns True.
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self n array, map, or sequence. Strings are treated as arrays of characters.
 * @param {`predicate(val) => bool` or `predicate(key, val) => bool`} predicate  An **iteratee** predicate. Determines which values to include.
 * @example
 * ; Filters an array for even values:
 * zFilter([1, 2, 3, 4, 5], x => Mod(x, 2) == 0) ; [2, 4]
 * ; Filters an array for strings of length 2:
 * zFilter(["a", "b", "cc"], x => StrLen(x) == 2) ; ["cc"]
 */
zFilter(self, predicate) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(predicate, "predicate").toBeCallable(1, 2)
    return zz_arr.filter(self, predicate)
}

/**
 * Takes a collection and applies a function on each value to generate a key. Returns all the values with distinct keys in an array.
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self A collection. Strings are treated as arrays of characters.
 * @param {`getKey(val) => ?` or `getKey(key, val) => ?`} getKey A key-generating **iteratee**.
 * @param {`bool`} caseSense Whether uniqueness is case-sensitive.
 * @example
 * ; Distinct last names:
 * zUniqBy(["Bill Gates", "Steve Jobs", "Melinda Gates"], x => StrSplit(x, " ")[2]) ; ["Bill Gates", "Steve Jobs"]
 */
zUniqBy(self, getKey, caseSense := False) {
    return zSelect(zGroupBy(self, getKey, caseSense), (k, vs) => vs[1])
}
/**
 * Takes a collection and returns an array consisting of only distinct values.
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self A collection. Strings are treated as arrays of characters.
 * @param {`bool`} caseSense Whether uniqueness is case-sensitive.
 * @example
 * ; Remove duplicate numbers:
 * zUniq([1, 2, 2, 3, 3, 1, 3]) ; [1, 2, 3]
 * ; Split a sentence into words, remove duplicates:
 * zUniq(StrSplit("I wanna wanna sweetie", " ")) ; ["I", "wanna", "sweetie"]
 */
zUniq(self, caseSense := False) {
    return zUniqBy(self, x => x, caseSense)
}

/**
 * Applies a projecting function on each value of an input collection or string, returning the results in a collection of the same type.
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self A collection. Strings are treated as arrays of characters.
 * @param {`p(val) => ?` or `p(key, val) => ?`} projection A function to apply on each key-value pair.
 * @example
 * ; Multiplies every item in an array by 2:
 * zSelect([1, 2, 3], x => x * 2) ; [2, 4, 6]
 * ; Turns an array of strings into an array of their lengths:
 * zSelect(["a", "b", "c"], x => StrLen(x)) ; [1, 1, 1]
 * ; Uppercases an array of strings
 * zSelect(["hello", "world"], StrUpper) ; ["HELLO", "WORLD"]
 */
zSelect(self, projection) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(projection, "projection").toBeCallable(1, 2)
    return zz_arr.map(self, projection)
}

/**
 * Applies a projection on each value of an array, map, or similar and collects the results in an array. Any
 * arrays returned by the projection are flattened or merged into the results, instead of being added like elements.
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self A collection. Strings are treated as arrays of characters.
 * @param {`project(val) => ?` or `project(key, val) => ?`} projection The function to apply on each value.
 * @remarks Note that only arrays are flattened. Other collections or sequences are not flattened.
 * @example
 * ; Repeats each element in an array twice:
 * zSelectMany([2, 3, 4], n => [n, n]) ; [2, 2, 3, 3, 4, 4]
 * ; Takes an array of pokemon and returns an array of all their moves:
 * zSelectMany([Pikachu, Bulbasaur, Eevee], x => x.moves) ; ["Electro Ball", "Thunderbolt", "Giga Drain", "Tackle"]
 */
zSelectMany(self, projection) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(projection, "projection").toBeCallable(1, 2)
    arr := []
    projection := zz_Inspect(projection).normalizeIteratee()
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
 * Concatenates and recursively flattens one or more arrays and non-array values into one array.
 * @param {`Array`} params Zero or more arrays and other values.
 * @returns A new array consisting of all values flattened together.
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
 * Returns a slice (a substring or subarray) of an array or string.
 * @param {Number} start The index at which to start, inclusive. 
 * @param {Number} end The index at which to end, also inclusive.
 * @throws {zz_BadInputError} If `start` indicates a position after `end`.
 * @example
 * ; Returns a slice of an array with just the first item:
 * zSlice([1, 2], 1, 1) ; [1]
 * ; A slice of an array with negative indexing:
 * zSlice([1, 2, 3, 4, 5], -2, -1) ; [4, 5]
 * ; Returns a slice of a string:
 * zSlice("hello", 2, 3) ; "el"
 * ; Returns a slice of a string with negative indexes:
 * zSlice("hello", -1) ; "o"
 */
zSlice(self, start := 1, end := -1) {
    zExpectArg(start, "start").toBeIntLike()
    zExpectArg(end, "end").toBeIntLike()
    if self is Array {
        return zz_arr.slice(self, start, end)
    } else if self is String {
        return zz_str.slice(self, start, end)
    } else {
        zExpectArg(self, "self").fail("to be a string or array")
    }
}

/**
 * Returns a map with the keys and values swapped, the last value taking precedence.
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