#include ../lib/4.assert/0.index.ah2
#include 93.zstr.ah2
#include 91.zarr.ah2
#include 1.util\0.index.ah2


; Converts an `Array[T]`, `Enumerable[T]`, or `Enumerator[T]` into a `Map[T, T]`.
zMap1(obj := [], caseSense := False) {
    zExpectArg(obj, "obj").toBeEnum(1)
    zExpectArg(caseSense, "caseSense").toBeBool()
    result := Map()
    result.CaseSense := caseSense
    if zz_obj.isEnum(obj, 1) {
        for x in obj {
            if not result.Has(x) {
                result[x] := x
            }
        }
    }
    return result
}

; Converts an `Enumerable[T, S]`, `Enumerator[T, S]`, or arbitrary object into a Map[T, S].
zMap2(obj := [], caseSense := False) {
    zExpectArg(obj, "obj").toBeObj()
    zExpectArg(caseSense, "caseSense").toBeBool()
    result := Map()
    result.CaseSense := caseSense
    if zz_obj.isEnum(obj, 2) {
        for k, v in obj {
            result[k] := v
        }
    } else {
        for key, value in ObjOwnProps(obj) {
            result[key] := value
        }
    }

    return result
}

; Maps each value in `self` via `projection`.
zMapMap(self, projection) {
    zExpectArg(self, "self").toBeMap()
    zExpectArg(projection, "projection").toBeCallable(1, 2)
    projection := zz_func.wrapIteratee(projection)
    myMap := Map()
    for k, v in self {
        myMap[k] := projection(k, v)
    }
    return myMap
}

/** Similar to `zMapMerge`, with...
 * @param {(key, val1?, ..., valN?) => any} operator An operator used to compute the values in the result `Map`. 
 * @param {...Map} maps Zero or more maps
 * @example
 * ; Cross-references a map of Id->Person and a map of I
 * zMapJoin(
 *     Map("a", 1, "b", 2),
 *     Map("a", 1)
 * )
 */
zMapJoin(maps*) {
    zExpectArg(maps, "maps").toBeEnum(1)
    if maps.Length = 0 {
        return Map()
    }
    maps := zArr(maps)
    merged := zMapMerge(maps*)
    for key, value in merged {
        vec := zArrCreate(maps.Length + 1)
        vec[1] = key
        for i, cur in maps {
            if cur.Has(key) {
                vec[i + 1] := cur[key]
            }
        }
        merged.Set(key, vec)
    }
    return merged
}

; Returns a new map that includes the key-value pairs of all `maps`.
; In case of collision, the left pair takes precedence.
zMapMerge(maps*) {
    newMap := Map()
    for cur in zArrReverse(maps) {
        for key, value in cur {
            if not newMap.Has(key) {
                newMap[key] := value
            }
        }
    }
    return newMap
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

zMapKeys(map) {
    keys := []
    for key, value in map {
        keys.Push(key)
    }
    return key
}

zMapReduce(self, reducer, initial?) {
    zExpectArg(self, "self").toBeMap()
    zExpectArg(acc, "acc").toBeCallable(2, 3)
    if self.Count = 0 {
        zExpectArg(initial ?? "<unset>", "initial").toNotEqual("<unset>")
    }
    for key, value in self {
        if not IsSet(initial) {
            initial := value
            continue
        }
        initial := reducer(key, initial, value)
    }

    return initial
}

zMapVals(map) {
    values := []
    for key, value in map {
        values.Push(value)
    }
    return values
}