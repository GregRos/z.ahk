#include 4.zzfunc.ah2
class zz_gen {
    static contains(container, item) {


        if not IsObject(container) {
            return !!InStr(container, item)
        }

        if container is Array {
            return zz_arr.has(container, item)
        } else if container is Map {
            return container.Has(item)
        } else if container.HasMethod("IndexOf") {
            return !!container.IndexOf(item)
        }

    }

    static length(vector) {
        if vector is String {
            return StrLen(vector)
        } else if not IsObject(vector) {
            throw zBadInputError("Cannot get length of a number.", vector)
        }
        if vector.HasProp("Count") {
            return vector.Count
        } else if vector.HasProp("Length") {
            return vector.Length
        }
        throw zBadInputError("Cannot get length of this object.", vector)
    }

    static justValues(source) {

    }

    static withIndexing(source) {
        pos := 0
        if zz_obj.isEnum(source, 2) {
            return source.__Enum(2)
        } else if zz_obj.isEnum(source, 1) {
            session := source.__Enum(1)
            return ((key, value) => session(value), %key% := pos)
        }

    }
    static find(self, predicate, &key?, &value?) {
        predicate := zz_func.wrapIteratee(predicate)
        for i, x in zz_gen.withIndexing(self) {
            if predicate(i, x) {
                if IsSet(key) {
                    key := i
                }
                if IsSet(value) {
                    value := x
                }
                return True
            }
        }
        return unset
    }

    static findKey(self, predicate) {
        predicate := zz_func.wrapIteratee(predicate)
        for i, x in zz_gen.withIndexing(self) {
            if predicate(i, x) {
                return i
            }
        }
        return unset
    }

    static findLastKey(self, predicate) {
        predicate := zz_func.wrapIteratee(predicate)
        found := 0
        for i, x in zz_gen.withIndexing(self) {
            if predicate(i, x) {
                found := i
            }
        }
        return found
    }


    static hasAny(arr, options*) {
        return zz_gen.has(options, arr, False)
    }

    static has(arr, item, caseMode := False) {
        for x in arr {
            if item == x {
                return True
            } else if not caseMode and item = x {
                return True
            }
        }
        return False
    }

    static comparer(comparer) {
        if zz_func.isCallable(comparer, 2) {
            ; It's a callable with the right number of params.
            return comparer
        }
    }

}