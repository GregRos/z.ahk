#include 45.zstr.ah2

zMapFromKeys(keys) {
    zExpectArg(keys, "keys").toBeEnum()
    myMap := Map()
    for x in keys {
        myMap.set(x, True)
    }
    return myMap
}

zMapAssign(target, maps, assignValues) {
    zExpectArg(target, "target").toBeInstanceOf(Map)
    for cur in maps {
        zExpectArg(cur, "maps" A_Index).instanceOf(Map)
    }
    if mergeValues == True {
        mergeValues := (old, new) => new
    }
    if mergeValues == False {
        mergeValues := (old, new) => old
    }
    zExpectArg(assignValues, "assignValues").toBeFunc(assignValues)
    for curMap in maps {
        for k, v in curMap {
            merged := target.Has(k) ? mergeValues(target.Get(k), v) : v
            target.Set(k, merged)
        }
    }
    return target
}

zMapMerge(maps, mergeValues) {
    return zMapAssign(Map(), maps, mergeValues)
}