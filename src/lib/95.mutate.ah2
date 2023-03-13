

/**
 * Removes elements matching a predicate from a collection.
 * @param {Map or Array} mapOrArray A map or array to modify.
 * @param {`val => bool` or `(key, val) => bool`} predicate The predicate used to pick elements to remove.
 * @returns A reference to the input collection.
 * @example
 * ; For arrays:
 * arr := [1, "a", {}, []]
 * ; Removes all strings from an array:
 * zRemove(arr, x => x is String) ; arr => [1, {}, []]
 * ; Removes the 2nd element from an array:
 * zRemove(arr, (i, x) => i == 2) ; arr => [1, []]
 * ; Removes everything from an array:
 * zRemove(arr, x => true) ; arr => []
 * ; For maps:
 * myMap := Map("a", "a", "b", 2)
 * ; Removes string values from a Map:
 * zRemove(myMap, x => x is String) ; myMap => Map("b", 2)
 * ; Removes the "b" key from a Map:
 * zRemove(myMap, (k, v) => k == "b") ; myMap => Map()
 */
zRemove(mapOrArray, predicate) {
    if not (mapOrArray is Array or mapOrArray is Map) {
        zExpectArg(mapOrArray, "mapOrArray").fail("to be an array or map")
    }
    predicate := zz_Inspect(predicate).normalizeIteratee()
    keys := []
    for key, val in mapOrArray {
        if predicate(key, val) {
            keys.Push(key)
        }
    }
    if mapOrArray is Map {
        for k in keys {
            mapOrArray.Delete(k)
        }
    } else {
        backslide := 0
        for k in keys {
            mapOrArray.RemoveAt(k - backslide)
            backslide++
        }
    }
    return mapOrArray
}

/**
 * Removes all occurences of one or more values from a collection.
 * @param {`Map` or `Array`} mapOrArray A map or array to modify.
 * @param {`?`} values Zero or more values to remove.
 * @returns A reference to the input collection.
 * @example
 * ; For arrays:
 * arr := ["a", 1, "b", 3]
 * ; Removes 1 from the array:
 * zPull(arr, 1) ; arr => ["a", "b", 3]
 * ; Removes 1 again, doing nothing:
 * zPull(arr, 1) ; arr => ["a", "b", 3]
 * ; Removes "a" and 3 from the array:
 * zPull(arr, "a", 3) ; arr => ["b"]
 * myMap := Map("a", 1, "b", 2)
 * ; Removes the value 2 from a map:
 * zPull(myMap, 2) ; Map("a", 1)
 * 
 */
zPull(mapOrArray, values*) {
    toRemove := Map()
    for v in values {
        toRemove[v] := v
    }
    return zRemove(mapOrArray, v => toRemove.Has(v))
}
/**
 * Assigns values from one or more collections to a target collection.
 * @param {`Map or Array`} target A map or array to modify.
 * @param {`Map or Array`} maps One or more collections of the same type as the target.
 * @returns A reference to the target collection.
 * @example
 * ; For Maps:
 * myMap := Map("a", 1)
 * ; Assign values from a map
 * zAssign(myMap, Map("b", 2)) ; Map("a", 1, "b", 2)
 * ; Assign values from multiple maps:
 * zAssign(myMap, Map("b", -2), Map("c", 3)) ; Map("a", 1, "b", -2, "c", 3)
 * 
 * ; For Arrays:
 * arr := [1, 2]
 * zAssign(arr, [3, 4]) ; [3, 4]
 * zAssign(arr, [ , , 3, 4]) ; [3, 4, 3, 4]
 */
zAssign(target, maps*) {
    zExpectArg(target, "target").toBeMap()
    if maps.Length = 0 {
        return target
    }
    merged := maps.Length == 1 ? maps[1] : zMerge(zReverse(maps*)*)
    for key, value in merged {
        target[key] := value
    }
    return target
}
