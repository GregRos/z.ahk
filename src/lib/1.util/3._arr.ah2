zz_normIndex(index, len) {
    if index <= 0 {
        return len + index + 1
    }
    return index
}

class zz_Kvp {
    __New(key, value) {
        this.Key := key
        this.Value := value
    }

    ToString() {
        return zz_str.join([this.Key, this.Value], " => ")
    }
}

class zz_arr {

    static find(self, predicate) {
        predicate := zz_Inspect(predicate).normalizeIteratee()

        for key, value in zz_Inspect(self).withIndexing() {
            if predicate(key, value) {
                return zz_Kvp(key, value)
            }
        }
    }

    static findLast(self, predicate) {
        predicate := zz_Inspect(predicate).normalizeIteratee()
        
        for key, value in zz_Inspect(self).withIndexing() {
            if predicate(key, value) {
                kvp := zz_Kvp(key, value)
            }
        }
        return kvp ?? ""
    }

    static fromSeq(seq) {
        if seq is Array {
            return seq.Clone()
        }
        arr := []
        for x in seq {
            arr.Push(x)
        }
        return arr
    }

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
                if begin2 < middle and (end2 >= end or not comparer(arr[end2], arr[begin2])) {
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
        end := zz_normIndex(end, arr.Length)
        if end < start {
            return []
        }
        count := end - start + 1
        return this.take(arr, start, count)
    }


    static filter(self, predicate) {
        newArr := []
        predicate := zz_Inspect(predicate).normalizeIteratee()
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


    static map(self, projection) {
        inspected := zz_Inspect(projection)
        projection := inspected.normalizeIteratee()
        newArr := []
        for index, item in inspected.next(self).withIndexing() {
            newArr.Push(projection(index, item))
        }
        return newArr
    }

}