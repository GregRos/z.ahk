#include 45.zstr.ah2

; Takes any number of arguments and joins them up into an array.
; A non-array argument
zArr(iterable := []) {
    zExpectArg(iterable, "iterable").toBeEnum()
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

zArrFrom(iterable) {
    zExpectArg(iterable, "iterable").toBeEnum()
    arr := []
    for x in iterable {
        arr.Push(x)
    }
    return arr
}

zArrRepeat(self, count) {
    arr := []
    arr.Capacity := count
    Loop count {
        arr.Push(self)
    }
    return arr
}

zArrFindIndex(self, predicate) {
    return zz_arr.findIndex(self, predicate)
}

; Returns the position of the first occurence of `what` in `self`.
zArrIndexOf(self, what, caseSensitive := False) {
    zExpectArg(self, "self").toBeEnum()
    zExpectArg(caseSensitive, "caseSensitive").toBeBool()
    for ix, value in self {
        if (!caseSensitive and what = value) or what == value {
            return ix
        }
    }
    return False
}

; Returns if `self` is an array including value `what`.
zArrHas(self, what) {
    zExpectArg(self, "self").toBeEnum()
    return zArrIndexOf(self, what) > 0
}


; Returns a new array made of elements from `self` that satisfy `predicate`.
zArrFilter(self, predicate) {
    zExpectArg(self, "self").toBeEnum()
    zExpectArg(predicate, "predicate").toBeCallable()
    return zz_arr.filter(self, predicate)
}

; Creates a new array, its elements the result of applying `projection` on elements of `self.`
zArrMap(self, projection) {
    zExpectArg(self, "self").toBeEnum()
    zExpectArg(projection, "projection").toBeCallable()
    projection := zz_func.wrapIteratee(projection)
    newArr := []
    for index, item in self {
        newArr.Push(projection(index, item))
    }
    return newArr
}

; Returns the first element in `self` that match `predicate`. `predicate` can be a function name or function object.
zArrFind(self, predicate) {
    result := zArrFilter(self, predicate)
    if result.Length > 0 {
        return result[1]
    }
    return ""
}

; Returns true if `self` contains an element matching `predicate`.
zArrExists(self, predicate) {
    return zArrFindIndex(self, predicate) != 0
}

; Returns true if every element of `self` matches `predicate`.
zArrEvery(self, predicate) {
    return zArrFilter(self, predicate).Length == self.Length
}

; Returns a new array by applying `projection` to each element of `self` and concatenating the resulting arrays.
zArrFlatMap(self, projection) {
    zExpectArg(self, "self").toBeEnum()
    zExpectArg(projection, "projection").toBeCallable()
    arr := []
    projection := zz_func.wrapIteratee(projection)
    for index, item in self {
        result := projection(index, item)
        if result is Array {
            arr.Push(result*)
        } else {
            arr.Push(result)
        }
    }
    return arr
}

; Returns a new array consisting of the elements of `self` in a reversed order.
zArrReverse(self) {
    zExpectArg(self, "self").toBeArray()
    return zz_arr.reverse(self)
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

; Applies an accumulator on `self`, with the initial value `initial`.
zArrReduce(self, accumulator, initial := unset) {
    zExpectArg(self, "self").toBeEnum()
    zExpectArg(accumulator, "accumulator").toBeCallable()
    accumulator := zz_func.wrapAccumulator(accumulator)
    current := initial ?? unset
    for index, item in self {
        if not IsSet(current) {
            current := item
            continue
        }
        current := accumulator(current, item, index)
    }
    if not IsSet(current) {
        throw zBadInputError(Format("Can't get initial value from array because it's empty."))
    }
    return current
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

; Returns a copy of this array, its elements sorted using `comparer`.
zArrOrder(self, comparer := zz_defaultComparer) {
    zExpectArg(self, "self").toBeArray()
    clone := self.Clone()
    work := self.Clone()
    zz_arr.mergeSort(clone, work, comparer)
    return clone
}

; Returns a copy of this array, its elements sorted by applying `getKey` to each element and then sorting using `comparer`.
zArrOrderBy(self, getKey, comparer := zz_defaultComparer) {
    zExpectArg(self, "self").toBeArray()
    zExpectArg(getKey, "getKey").toBeCallable()
    return zArrOrder(self, zz_keyComparer(getKey, comparer))
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