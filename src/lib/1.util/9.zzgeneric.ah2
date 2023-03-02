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

    static withIndexing(source) {
        pos := 0
        if zz_obj.isEnum(source, 2) {
            return source.__Enum(2)
        } else if zz_obj.isEnum(source, 1) {
            session := source.__Enum(1)
            return ((key, value) => session(value), %key% := pos)
        }

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