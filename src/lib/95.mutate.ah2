

/**
 * Applies a predicate on every value in a collection and removes those for which it returns True.
 * @param {`Map` or `Array`} self The collection to modify.
 * @param {`val => bool` or `(key, val) => bool`} predicate The predicate that determines which elements to remove.
 * @returns A reference to the input collection.
 * @example
 * ; Removes all strings from an array:
 * zRemove([1, "a", {}], x => x is String) ; [1, {}]
 * ; Removes all elements from an array:
 * zRemove([1, 2, 3], x => True) ; []
 * ; Removes elements at even indexes:
 * zRemove([5, 6, 12], (ix, val) => Mod(ix, 2) == 0) ; [6]
 * ; Removes string values from a Map:
 * zRemove(Map("a", "a", "b", 1), x => x is String) ; Map("b", 1)
 */
zRemove(self, predicate) {
    if not (self is Array or self is Map) {
        zExpectArg(self, "self").fail("to be an array or map")
    }
    predicate := zz_Inspect(predicate).normalizeIteratee()
    keys := []
    for key, val in self {
        if predicate(key, val) {
            keys.Push(key)
        }
    }
    if self is Map {
        for k in keys {
            self.Delete(k)
        }
    } else {
        backslide := 0
        for k in keys {
            self.RemoveAt(k - backslide)
            backslide++
        }
    }
    return self
}

/**
 * Removes all occurences of values from a collection.
 * @param {`Map` or `Array`} self The collection to modify.
 * @param {`?`} values Zero or more values to remove.
 * @returns A reference to the input collection.
 * @example
 * ; Removes numbers from an array:
 * zPull([1, 2], 1) ; [2]
 * ; Removes numbers that don't exist, doing nothing:
 * zPull([5], 1) ; [5]
 * ; Removes values from a map.
 * zPull(Map("a", 1, "b", 2), 2) ; Map("a", 1)
 */
zPull(self, values*) {
    toRemove := Map()
    for v in values {
        toRemove[v] := v
    }
    return zRemove(self, v => toRemove.Has(v))
}

zMapAssign(target, maps*) {
    zExpectArg(target, "target").toBeMap()
    if maps.Length = 0 {
        return target
    }
    merged := maps.Length == 1 ? maps[1] : zMapMerge(zArrReverse(maps*)*)
    for key, value in merged {
        target[key] := value
    }
    return target
}

zMapDefaults(target, defaults*) {
    zExpectArg(target, "target").toBeMap()
    merged := zMapMerge(defaults*)
    for key, value in merged {
        if not target.Has(key) {
            target[key] := value
        }
    }
    return target
}