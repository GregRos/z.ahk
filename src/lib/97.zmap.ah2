#include ../lib/4.assert/0.index.ah2
#include 93.zstr.ah2
#include 91.zarr.ah2
#include 1.util\0.index.ah2


zMapFromArray(obj) {
    zExpectArg(obj, "obj").toBeObj()
    result := Map()
    for key, value in ObjOwnProps(obj) {
        result[key] := value
    }
    return result
}

zMapFromKeys(keys) {
    zExpectArg(keys, "keys").toBeEnum()
    myMap := Map()
    for x in keys {
        myMap.set(x, True)
    }
    return myMap
}

zMapJoin(maps, operator) {
    zExpectArg(maps, "maps").toBeArray()
    zExpectArg(operator, "operator").toBeCallable()
    merged := zMapMerge(maps*)
    for key, value in merged {
        args := zArrUnset(maps.Length)
        for i, cur in maps {
            if cur.Has(key) {
                args[i] := cur[key] 
            }
        }
        joined := operator(args*)
        merged.Set(key, joined)
    }
    return merged
}

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
    merged := zMapMerge(maps*)
    for key, value in merged {
        target[key] := value
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

zMapValues(map) {
    zExpectArg(map, "map").toBeArray(x => x.toBe(5))
    values := []
    for key, value in map {
        values.Push(value)
    }
    return values
}

zMapDefaults(target, others*) {

}
