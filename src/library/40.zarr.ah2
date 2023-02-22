#include 01.zinit.ah2
#include 13.zchecks.ah2
#include 45.zstr.ah2

; Takes any number of arguments and joins them up into an array.
; A non-array argument
zArr(iterable := []) {
    zz_checks.isIter("iterable", iterable)
    arr := []
    for x in iterable {
        arr.Push(x)
    }
    return arr
}

zArrRange(start, end, step := 1) {
    zz_checks.isNotEqual("step", step, 0)
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
    zz_checks.isIter("iterable", iterable)
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
    zz_checks.isIter("self", self)
    zz_checks.isBool("caseSensitive", caseSensitive)
    for ix, value in self {
        if (!caseSensitive and what = value) or what == value {
            return ix
        }
    }
    return False
}

; Returns if `self` is an array including value `what`.
zArrHas(self, what) {
    zz_checks.isIter("self", self)
    return zArrIndexOf(self, what) > 0
}


; Returns a new array made of elements from `self` that satisfy `predicate`.
zArrFilter(self, predicate) {
    zz_checks.isIter("self", self)
    zz_checks.isFunc("predicate", predicate)
    newArr := []
    predicate := zz_func.wrapIteratee(predicate)
    for index, item in self {
        if predicate(index, item) {
            newArr.Push(item)
        }
    }
    return newArr
}

; Creates a new array, its elements the result of applying `projection` on elements of `self.`
zArrMap(self, projection) {
    zz_checks.isIter("self", self)
    zz_checks.isFunc("projection", projection)
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
    zz_checks.isIter("self", self)
    zz_checks.isFunc("projection", projection)
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
    zz_checks.isArray("self", self)
    return zz_arr.reverse(self)
}

; Adds an element to the start of `self`.
zArrPrepend(self, items*) {
    zz_checks.isArray("self", self)
    self.InsertAt(1, items*)
    return self
}

; Returns a subsequence of `self` of values with positions `start` (inclusive) to `end` (exclusive).
zArrSlice(self, start := 1, end := 0) {
    zz_checks.isArray("self", self)
    zz_checks.isInt("start", start)
    zz_checks.isInt("end", end + 1)
    zz_checks.isLte("start", start, self.Length)
    zz_checks.isLte("end", end, self.Length + 1)
    return zz_arr.slice(self, start, end)

}

; Applies an accumulator on `self`, with the initial value `initial`.
zArrReduce(self, accumulator, initial) {
    zz_checks.isIter("self", self)
    zz_checks.isFunc("accumulator", accumulator, 2)
    accumulator := zz_func.normalize(accumulator, 3)
    current := initial
    for index, item in self {
        current := accumulator(current, item, index)
    }
    return current
}

; Removes all appearances of `values` from `self`.
zArrPull(self, values*) {
    zz_checks.isArray("self", self)
    Loop self.Length {
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
    zz_checks.isArray("self", self)
    work := self.Clone()
    zz_arr.mergeSort(work, self, comparer)
    return self
}

; Returns a copy of this array, its elements sorted using `comparer`.
zArrOrder(self, comparer := zz_defaultComparer) {
    zz_checks.isArray("self", self)
    work := []
    work.Capacity := self.Length
    return zz_arr.mergeSort(self, work, comparer)
}

; Returns a copy of this array, its elements sorted by applying `getKey` to each element and then sorting using `comparer`.
zArrOrderBy(self, getKey, comparer := zz_defaultComparer) {
    zz_checks.isArray("self", self)
    zz_checks.isFunc("getKey", getKey, 1)
    return zArrOrder(self, zz_keyComparer(getKey, comparer))
}

; Sorts `self` in place according
zArrSortBy(self, getKey, comparer := zz_defaultComparer) {
    zz_checks.isArray("self", self)
    zz_checks.isFunc("getKey", getKey, 1)
    return zArrSort(self, zz_keyComparer(getKey, comparer))
}

zArrUniq(self) {
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

zArrUniqBy(self, getKey) {
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

zArrZip(sources*) {
    for source in sources {
        zz_checks.isIter("sources" A_Index, source)
    }
    iterators := zArrMap(sources, x => x.__Enum())
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


zz_defaultComparer(a, b) {
    return a = b ? 0 : a < b ? -1 : 1
}

zz_keyComparer(getKey, comparer := zz_defaultComparer) {
    compare_keys(a, b) {
        kA := getKey(a)
        kB := getKey(b)
        return comparer(kA, kB)
    }
    return comparer
}