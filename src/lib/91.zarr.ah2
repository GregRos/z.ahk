#include 90.zenum.ah2
#include 93.zstr.ah2

; Takes an enumerable[T] or enumerator[T] into an Array[T].
zArr(iterable := []) {
    zExpectArg(iterable, "iterable").toBeEnum(1)
    arr := []
    for x in iterable {
        arr.Push(x)
    }
    return arr
}

zArrRange(start, end, step := 1) { 
    zExpectArg(step, "step").toNotEqual(0)
    if start > end and step > 0 {
        step := -step
    }
    result := []
    loop {
        if step < 0 ? start <= end : start >= end {
            break
        }
        result.Push(start)
        start += step
    }
    return result
}

zArrCreate(length) {
    arr := []
    arr.Length := length
    return arr
}

zArrRepeat(self, count) {
    arr := zArrCreate(count)
    Loop count {
        arr[A_Index] := self
    }
    return arr
}











; Adds an element to the start of `self`.
zArrPrepend(self, items*) {
    zExpectArg(self, "self").toBeArray()
    self.InsertAt(1, items*)
    return self
}

; Returns a subsequence of `self` of values with positions `start` (inclusive) to `end` (exclusive).
zArrSlice(self, start := 1, end := 0) {
    zExpectArg(self, "self").toBeArray()
    zExpectArg(start, "start").toBeIntLike()
    zExpectArg(end, "end").toBeIntLike()
    return zz_arr.slice(self, start, end)

}


; Removes all appearances of `values` from `self`.
zArrPull(self, values*) {
    zExpectArg(self, "self").toBeArray()

    Loop {
        if A_Index > self.Length {
            break
        }
        cur := self[A_Index]
        if zArrHas(values, cur) {
            self.RemoveAt(A_Index)
            A_Index--
        }
    }
    return self
}

; Sorts `self` in place using `comparer`, which defaults to `>`.
zArrSort(self, comparer := zz_defaultComparer) {
    zExpectArg(self, "self").toBeArray()
    work := self.Clone()
    zz_arr.mergeSort(self, work, comparer)
    return self
}



; Sorts `self` in place according
zArrSortBy(self, getKey, comparer := zz_defaultComparer) {
    zExpectArg(self, "self").toBeArray()
    zExpectArg(getKey, "getKey").toBeCallable()
    return zArrSort(self, zz_keyComparer(getKey, comparer))
}



zArrUniq(self, caseSense := False) {
    zExpectArg(self, "self").toBeEnum()
    myMap := Map()
    myMap.CaseSense := caseSense
    for x in self {
        myMap.Set(x, x)
    }
    arr := []
    for k, v in myMap {
        arr.Push(k)
    }
    return arr
}

zArrUniqBy(self, getKey, caseSense := False) {
    zExpectArg(self, "self").toBeEnum()
    getKey := zz_func.wrapIteratee(getKey)
    myMap := Map()
    myMap.CaseSense := caseSense
    for i, x in self {
        key := getKey(i, x)
        if not myMap.Has(key) {
            myMap.set(key, x)
        }
    }
    arr := []
    for k, v in myMap {
        arr.Push(v)
    }
    return arr
}

zArrZip(sources*) {
    for source in sources {
        zExpectArg(source, "sources" A_Index).toBeEnum()
    }
    iterators := zArrMap(sources, x => x.__Enum())
    cont := True
    index := 1
    output := []
    while cont {
        curRecord := []
        curRecord.Length := iterators.Length
        for iterIndex, iterator in iterators {
            result := iterator(&out)

            if result = 0 {
                cont := False
                break
            }
            if not IsSet(out) {
                continue
            }
            curRecord[iterIndex] := out
        }
        if cont {
            output.InsertAt(index, curRecord)
        }
        index++
    }
    return output
}


zz_defaultComparer(a, b) {
    return a = b ? 0 : a < b ? -1 : 1
}

zz_keyComparer(getKey, comparer := zz_defaultComparer) {
    compare_keys(a, b) {
        kA := getKey(a)
        kB := getKey(b)
        return comparer(kA, kB)
    }
    return compare_keys
}

zArrToMap(self) {
    for index, value in self {
        
    }
}

zArrIndexOf := zEnumKeyOf
zArrFindIndex := zEnumFindKey
zArrFindLastIndex := zEnumFind