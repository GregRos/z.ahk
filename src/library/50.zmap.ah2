#include 1.init\0.index.ah2
#include 45.zstr.ah2

zMapFromKeys(keys) {
    zCheck(keys, "keys").isEnumerable()
    myMap := Map()
    for x in keys {
        myMap.set(x, True)
    }
    return myMap
}

zMapAssign(target, maps, assignValues) {
    zCheck(target, "target").isInstanceOf(Map)
    for cur in maps {
        zCheck(cur, "maps" A_Index).instanceOf(Map)
    }
    if mergeValues == True {
        mergeValues := (old, new) => new
    }
    if mergeValues == False {
        mergeValues := (old, new) => old
    }
    zCheck(assignValues, "assignValues").isFunc(assignValues)
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