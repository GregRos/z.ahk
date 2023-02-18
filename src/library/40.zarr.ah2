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

zArr_Range(start, end, step := 1) {
    zz_checks.isGreater("step", step, 0)
    step := start > end ? -step : step
    result := []
    loop {
        if start >= end {
            break
        }
        result.Push(start)
        start += step
    }
    return result
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

zArr_FindIndex(self, predicate) {
    return zz_arr.findIndex(self, predicate)
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

; Returns if `self` is an array including value `what`.
zArr_Has(self, what) {
    zz_checks.isIter("self", self)
    return gArr_IndexOf(self, what) > 0
}


; Returns a new array made of elements from `self` that satisfy `predicate`.
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

; Creates a new array, its elements the result of applying `projection` on elements of `self.`
zArr_Map(self, projection) {
    zz_checks.isIter("self", self)
    zz_checks.isFunc("projection", projection)
    projection := zz_func.normalize(projection, 2)
    newArr := []
    for index, item in self {
        if predicate(item, index) {
            newArr.Push(projection(item))
        }
    }
    return newArr
}

; Returns the first element in `self` that match `predicate`. `predicate` can be a function name or function object.
zArr_Find(self, predicate) {
    result := zArr_Filter(self, predicate)
    if result.Length = 0 {
        return zSome(result[1])
    }
    return zNone("no element matching predicate")
}

; Returns true if `self` contains an element matching `predicate`.
zArr_Exists(self, predicate) {
    return zArr_Find(self, predicate).isSome
}

; Returns true if every element of `self` matches `predicate`.
zArr_Every(self, predicate) {
    return zArr_Filter(self, predicate).Length == self.Length
}

; Returns a new array by applying `projection` to each element of `self` and concatenating the resulting arrays.
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

; Flattens `self` one level
zArr_Flat(self) {
    return zArr_FlatMap(self, x => x)
}

; Returns a new array consisting of the elements of `self` in a reversed order.
zArr_Reverse(self) {
    zz_checks.isArray("self", self)
    return zz_arr.reverse(self)
}

; Adds an element to the start of `self`.
zArr_Prepend(self, items*) {
    zz_checks.isArray("self", self)
    self.InsertAt(0, items*)
}

; Returns a subsequence of `self` starting at `start` and ending at `end`, inclusive.
zArr_Slice(self, start := 1, end := 0) {
    zz_checks.isArray("self", self)
    zz_checks.isInt("start", start)
    zz_checks.isInt("end", end)

}

; Applies an accumulator on `self`, with the initial value `initial`.
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

; Removes all appearances of `values` from `self`.
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

; Sorts `self` in place using `comparer`, which defaults to `>`.
zArr_Sort(self, comparer := zz_defaultComparer) {
    zz_checks.isArray("self", self)
    work := self.Clone()
    zz_arr.mergeSort(work, self, comparer)
    return self
}

; Returns a copy of this array, its elements sorted using `comparer`.
zArr_Order(self, comparer := zz_defaultComparer) {
    zz_checks.isArray("self", self)
    work := []
    work.Capacity := self.Length
    return zz_arr.mergeSort(self, work, comparer)
}

; Returns a copy of this array, its elements sorted by applying `getKey` to each element and then sorting using `comparer`.
zArr_OrderBy(self, getKey, comparer := zz_defaultComparer) {
    zz_checks.isArray("self", self)
    zz_checks.isFunc("getKey", getKey, 1)
    return zArr_Order(self, zz_keyComparer(getKey, comparer))
}

; Sorts `self` in place according
zArr_SortBy(self, getKey, comparer := zz_defaultComparer) {
    zz_checks.isArray("self", self)
    zz_checks.isFunc("getKey", getKey, 1)
    return zArr_Sort(self, zz_keyComparer(getKey, comparer))
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