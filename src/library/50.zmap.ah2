#include 01.zinit.ah2
#include 13.zchecks.ah2
#include 30.zstr.ah2

zMap_FromKeys(keys) {
    zzutils_checkIter("keys", keys)
    myMap := Map()
    for x in keys {
        myMap.set(x, True)
    }
    return myMap
}

zMap_Assign(target, maps, assignValues) {
    zzutils_checkInstanceOf("target", Map, target)
    for cur in maps {
        zzutils_checkInstanceOf("maps" A_Index, Map, cur)
    }
    if mergeValues == True {
        mergeValues := (old, new) => new
    }
    if mergeValues == False {
        mergeValues := (old, new) => old
    }
    zzutils_checkFunc("assignValues", assignValues, 2)
    for curMap in maps {
        for k, v in curMap {
            merged := target.Has(k) ? mergeValues(target.Get(k), v) : v
            target.Set(k, merged)
        }
    }
    return target
}

zMap_Merge(maps, mergeValues) {
    return zMap_Assign(Map(), maps, mergeValues)
}