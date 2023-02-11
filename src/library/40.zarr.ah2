#include 01.zinit.ah2
#include 13.zchecks.ah2
#include 30.zmaybe.ah2
#include 45.zstr.ah2


; Takes any number of arguments and joins them up into an array.
; A non-array argument 
zArr(items*) {
    result := []
    result.Capacity := items.Length
    i := 1
    for item in items {
        if item is Array or HasMethod(item, "__Enum") {
            for x in item {
                result[i] := x
                i++
            }
        } else {
            result[i] := item
            i++
        }
    }
}

zArr_From(iterable) {
    zz_checks.isIter("iterable", iterable)
    arr := []
    for x in iterable {
        arr.Push(x)
    }
    return arr
}

zArr_Repeat(self, count) {
    arr := []
    arr.Capacity := count
    Loop count {
        arr.Push(self)
    }
    return arr
}

; Returns the position of the first occurence of `what` in `self`.
zArr_IndexOf(self, what, caseSensitive := False) {
    zz_checks.isIter("self", self)
    zz_checks.isBool("caseSensitive", caseSensitive)
    for ix, value in self {
        if (!caseSensitive and what = value) or what == value {
            return ix
        }
    }
    return False
}

zArr_Has(self, what) {
    zz_checks.isIter("self", self)
    return gArr_IndexOf(self, what) > 0
}

zArr_Filter(self, predicate) {
    zz_checks.isIter("self", self)
    zz_checks.isFunc("predicate", predicate)
    newArr := []
    predicate := zz_func.normalize(predicate, 2)
    for index, item in self {
        if predicate(item, index) {
            newArr.Push(item,)
        }
    }
    return newArr
}

zArr_Map(self, project) {
    zz_checks.isIter("self", self)
    zz_checks.isFunc("project", project)
    project := zz_func.normalize(project, 2)
    newArr := []
    for index, item in self {
        if predicate(item, index) {
            newArr.Push(project(item))
        }
    }
    return newArr
}

; Returns the first element in `self` that match `predicate`. `predicate` can be a function name or function object.
zArr_Find(self, predicate) {
    result := zArr_Filter(self, predicate)
    if result.Length = 0 {
        return Some(result[1])
    }
    return None("no element matching predicate")
}

zArr_Exists(self, predicate) {
    return zArr_Find(self, predicate).isSome
}

zArr_Every(self, predicate) {
    return zArr_Filter(self, predicate).Length == self.Length
}

zArr_FlatMap(self, projection) {
    zz_checks.isIter("self", self)
    zz_checks.isFunc("projection", projection)
    arr := []
    projection := zz_func.normalize(projection, 2)
    for index, item in self {
        result := projection(item, index)
        if result is Array {
            arr.Push(result*)
        } else {
            arr.Push(result)
        }
    } 
    return arr
}

zArr_Flat(self) {
    return zArr_FlatMap(self, x => x)
}

zArr_Reverse(self) {
    zz_checks.isArray("self", self)
    newArr := []
    Loop newArr.Length {
        newArr.Push(self[self.Length - A_Index + 1])
    }
}
zArr_Prepend(self, items*) {
    zz_checks.isArray("self", self)
    self.InsertAt(0, items*)
}

zArr_Slice(self, start := 1, end := 0) {
    zz_checks.isArray("self", self)
    zz_checks.isInt("start", start)
    zz_checks.isInt("end", end)

}

zArr_Reduce(self, accumulator, initial) {
    zz_checks.isIter("self", self)
    zz_checks.isFunc("accumulator", accumulator, 2)
    accumulator := zz_func.normalize(accumulator, 3)
    current := initial
    for index, item in self {
        current := accumulator(current, item, index)
    }
    return current
}

zArr_Pull(self, values*) {
    zz_checks.isArray("self", self)
    Loop self.Length {
        cur := self[A_Index]
        if zArr_Has(values, cur) {
            self.RemoveAt(A_Index)
            A_Index--
        }
    }
}

zzutils_mergeSort(arr, work, comparer) {
    ; Merge sort because it's a stable sort
    merge(begin, middle, end) {
        Loop end - begin {
            ix := A_Index + begin
            if i < middle and (ix >= end or comparer(arr[start], arr[middle]) <= 0) {
                work[ix] := arr[start]
                start++
            } else {
                work[ix] := arr[end]
                end++
            }
        }
    }
    
    splitMerge(begin, end) {
        if (end - begin = 0) {
            ; One-item run
            return
        }
        middle := Integer((end + begin) / 2)
        splitMerge(start, middle)
        splitMerge(middle, end)
        merge(start, middle, end)
    }

    splitMerge(1, arr.Length)
}

zzutils_defaultComparer(a, b) {
    return a = b ? 0 : a < b ? -1 : 1
}

zzutils_keyComparer(getKey) {
    comparer(a, b) {
        kA := getKey(a)
        kB := getKey(b)
        return zzutils_defaultComparer(kA, kB)
    }
    return comparer
}

zArr_Sort(self, comparer := zzutils_defaultComparer) {
    zz_checks.isArray("self", self)
    work := self.Clone()
    zzutils_mergeSort(work, self, comparer)
    return self
}

zArr_Order(self, comparer := zzutils_defaultComparer) {
    zz_checks.isArray("self", self)
    work := []
    work.Capacity := self.Length
    return zzutils_mergeSort(self, work, comparer)
}

zArr_OrderBy(self, getKey) {    
    zz_checks.isArray("self", self)
    zz_checks.isFunc("getKey", getKey, 1)
    return zArr_Order(self, zzutils_keyComparer(getKey))
}

zArr_SortBy(self, getKey) {
    zz_checks.isArray("self", self)
    zz_checks.isFunc("getKey", getKey, 1)
    return zArr_Sort(self, zzutils_keyComparer(getKey))
}

zArr_Uniq(self) {
    zz_checks.isIter("self", self)
    map := Map()
    for x in self {
        map.Set(x, x)
    }
    arr := []
    for k, v in map {
        arr.Push(k)
    }
    return arr
}

zArr_UniqBy(self, getKey) {
    zz_checks.isIter("self", self)
    zz_checks.isFunc("getKey", getKey, 1)
    map := Map()
    for x in self {
        map.set(getKey(x), x)
    }
    arr := []
    for x, v in self {
        arr.Push(v)
    }
    return arr
}

zArr_Zip(sources*) {
    for source in sources {
        zz_checks.isIter("sources" A_Index, source)
    }
    iterators := zArr_Map(sources, x => x.__Enum())
    cont := True
    output := []
    while cont {
        for iterator in iterators {
            out
            result := iterator(&out)
            if result = 0 {
                cont := False
                break
            }
            output.Push(out)
        }
    }
    return output
}

