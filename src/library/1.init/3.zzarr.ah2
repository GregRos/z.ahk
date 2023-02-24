zz_normIndex(index, len) {
    if index <= 0 {
        return len + index + 1
    }
    return index
}

class zz_arr {
    static mergeSort(arr, work, comparer) {
        ; Merge sort because it's a stable sort
        merge(arr, begin, middle, end, work) {
            count := end - begin
            begin2 := begin
            end2 := middle
            Loop count {
                ix := A_Index + begin - 1
                if ix >= end {
                    break
                }
                if begin2 < middle and (end2 >= end or comparer(arr[begin2], arr[end2]) <= 0) {
                    work[ix] := arr[begin2]
                    begin2++
                } else {
                    work[ix] := arr[end2]
                    end2++
                }
            }
        }

        splitMerge(work, begin, end, arr) {
            if (end - begin <= 1) {
                ; One-item run7
                return
            }

            middle := Integer((end + begin) / 2)
            splitMerge(arr, begin, middle, work)
            splitMerge(arr, middle, end, work)
            merge(work, begin, middle, end, arr)
        }

        splitMerge(work, 1, arr.Length + 1, arr)
    }

    static take(arr, start := 1, count := -1) {
        newArr := []
        start := zz_normIndex(start, arr.Length)
        count := count == -1 ? arr.Length - start + 1 : count
        loop count {
            curIndex := start + A_Index - 1
            if curIndex > arr.Length {
                return newArr
            }
            newArr.Push(arr[curIndex])
        }

        return newArr
    }

    static slice(arr, start := 1, end := -1) {
        start := zz_normIndex(start, arr.Length)
        end := zz_normIndex(end, arr.Length + 1)
        count := end - start
        return this.take(arr, start, count)
    }

    static findIndex(self, predicate) {
        predicate := zz_func.wrapIteratee(predicate)
        for i, x in self {
            if predicate(i, x) {
                return i
            }
        }
        return 0
    }

    static first(self, predicate?) {
        if not IsSet(predicate) {
            return self[1]
        }
        ix := this.findIndex(self, predicate)
        return self[ix]
    }

    static findLastIndex(self, predicate) {
        predicate := zz_func.wrapIteratee(predicate)
        found := 0
        for i, x in self {
            if predicate(i, x) {
                found := i
            }
        }
        return found
    }

    static filter(self, predicate) {
        newArr := []
        predicate := zz_func.wrapIteratee(predicate)
        for index, item in self {
            if predicate(index, item) {
                newArr.Push(item)
            }
        }
        return newArr
    }


    static hasUnsetItems(arr) {
        lastIndex := 0
        for index, item in arr {
            if index != lastIndex + 1 {
                return True
            }
            lastIndex := index
        }
        return False
    }

    static repeat(value, count) {
        arr := []
        loop count {
            arr.Push(value)
        }
        return arr
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

    static map(self, projection) {
        projection := zz_func.wrapIteratee(projection)
        newArr := []
        for index, item in self {
            newArr.Push(projection(index, item))
        }
        return newArr
    }


    static hasAny(arr, options*) {
        return zz_arr.has(options, arr, False)
    }

    static reverse(self) {
        newArr := []
        Loop self.Length {
            newArr.Push(self[self.Length - A_Index + 1])
        }
        return newArr
    }
}
