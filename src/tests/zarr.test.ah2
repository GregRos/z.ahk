#include ../lib/91.zarr.ah2
#include ../lib/4.assert/0.index.ah2

my_empty := []
my_arr := [1, 2, 3]

makeArrayOfObjects(values*) {
    arr := []
    for i, value in values {
        arr.Push({ a: value })
    }
    return arr
}


class Array_operations extends zTestSuite {
    zArr() {
        zExpect(zArr(my_arr)).toEqual(my_arr)
        zExpect(zArr()).toEqual([])
    }

    zArrRange() {
        zExpect(zArrRange(0, 3)).toEqual([0, 1, 2])
        zExpect(zArrRange(0, -2)).toEqual([0, -1])
        zExpect(zArrRange(0, 5, 2)).toEqual([0, 2, 4])
        zExpect(zArrRange(0, -2, -2)).toEqual([0])
        zExpect(zArrRange(0, 0, 10)).toEqual([])
        zExpect(() => zArrRange(0, 0, 0)).toThrow()
    }


    zEnumGroupBy() {
        zExpect(zEnumGroupBy([], x => 1)).toEqual(Map())
        zExpect(zEnumGroupBy([1, 2, 3], x => 1)).toEqual(Map(1, [1, 2, 3]))
        zExpect(zEnumGroupBy([1, 2], x => x)).toEqual(Map(1, [1], 2, [2]))
        
    }

    zArrRepeat() {
        zExpect(zArrRepeat("a", 3)).toEqual(["a", "a", "a"])
        zExpect(zArrRepeat("a", 0)).toEqual([])
        zExpect(() => zArrRepeat("a", -1)).toThrow()
    }

    zEnumFind() {
        arr := [0, 5, 10]
        zExpect(zEnumFind(arr, a => a == 5)).toEqual(zz_Kvp(2, 5))
        zExpect(zEnumFind(arr, x => x == 100)).toBe("")
        zExpect(() => zEnumFind(arr, "a")).toThrow()
        ; With index:
        zExpect(zEnumFind(arr, (i, x) => i == 1 and x == 0).Key).toEqual(1)
    }

    zEnumIndexOf() {
        arr := [0, 5, 10]
        zExpect(zEnumKvpOf(arr, 5).Key).toEqual(2)
        zExpect(zEnumKvpOf(arr, 0).Key).toEqual(1)
        zExpect(zEnumKvpOf(arr, 100)).toBe("")
    }


    zEnumFilter() {
        arr := [0, 5, 10]
        zExpect(zEnumFilter(arr, x => x == 5)).toEqual([5])
        zExpect(zEnumFilter(arr, x => x == -1)).toEqual([])
        zExpect(zEnumFilter(arr, x => True)).toEqual(arr)
        zExpect(zEnumFilter(arr, (i, x) => Mod(i, 2) == 0 and x == 5)).toEqual([5])
    }

    zEnumMap() {
        arr := [0, 5, 10]
        zExpect(zEnumMap(arr, x => x + 1)).toEqual([1, 6, 11])
        zExpect(zEnumMap(arr, x => {})).toEqual([{}, {}, {}])
        zExpect(zEnumMap(arr, (i, x) => x + i)).toEqual([1, 7, 13])
    }

    zEnumEvery() {
        arr := [0, 5, 10]
        zExpect(zEnumEvery(arr, x => x == 5)).toEqual(False)
        zExpect(zEnumEvery(arr, x => x < 11)).toEqual(True)
        zExpect(zEnumEvery(arr, (i, x) => i < 4 and x < 11)).toEqual(True)
    }

    zEnumFlatMap() {
        arr := [0, 5, 10]
        zExpect(zEnumFlatMap(arr, x => [x, x])).toEqual([0, 0, 5, 5, 10, 10])
        zExpect(zEnumFlatMap(arr, x => [])).toEqual([])
        zExpect(zEnumFlatMap(arr, (i, x) => [i, x])).toEqual([1, 0, 2, 5, 3, 10])
        zExpect(() => zEnumFlatMap(arr, "a")).toThrow()
    }

    zEnumReverse() {
        arr := [0, 5, 10]
        zExpect(zEnumReverse(arr)).toEqual([10, 5, 0])
        zExpect(zEnumReverse([])).toEqual([])
    }

    zArrPrepend() {
        zExpect(zArrPrepend([0], 1, 2)).toEqual([1, 2, 0])
        zExpect(zArrPrepend([0])).toEqual([0])
        zExpect(zArrPrepend([], 1)).toEqual([1])
    }

    zArrSlice() {
        zExpect(zArrSlice([1, 2], 1, 2)).toEqual([1])
        zExpect(zArrSlice([1, 2], -1, -1)).toEqual([2])
        zExpect(zArrSlice([0], 1, 2)).toEqual([0])
        zExpect(zArrSlice([0, 1], 1, 1)).toEqual([])

        zExpect(zArrSlice([], 100, -1)).toEqual([])
        zExpect(zArrSlice([0, 1, 2], 5, 7)).toEqual([])

    }

    zEnumReduce() {
        zExpect(zEnumReduce([1], (acc, cur) => 1)).toEqual(1)
        zExpect(zEnumReduce([1, 2, 3], (acc, cur) => acc + cur)).toEqual(6)
        zExpect(zEnumReduce([1, 2], (ix, acc, cur) => acc + cur * ix)).toEqual(5)
        zExpect(zEnumReduce([1], (acc, cur) => acc + cur, 1)).toEqual(2)
        zExpect(zEnumReduce([], (a, b) => 1, 5)).toEqual(5)
        zExpect(() => zEnumReduce([], (a, b) => 1)).toThrow()
    }

    zArrPull() {
        zExpect(zArrPull([], 5, 1)).toEqual([])
        zExpect(zArrPull([1], 1)).toEqual([])
        zExpect(zArrPull([1, 2], 1)).toEqual([2])
        zExpect(zArrPull([1, 2, 3], 1, 2, 3)).toEqual([])
    }

    zEnumSort() {
        zExpect(zEnumSort([5, 2, 10])).toEqual([2, 5, 10])
        arr := [0, 5, -1]
        zEnumSort(arr)
        zExpect(arr).toEqual([-1, 0, 5])
        zExpect(zEnumSort([])).toEqual([])
        zExpect(zEnumSort([1])).toEqual([1])
    }

    zEnumOrder() {
        zExpect(zEnumOrder([5, 2, 10])).toEqual([2, 5, 10])
        arr := [0, 5, -1]
        zEnumOrder(arr)
        zExpect(arr).toEqual([0, 5, -1])
        zExpect(zEnumOrder([])).toEqual([])
        zExpect(zEnumOrder([1])).toEqual([1])
    }

    zEnumOrderBy() {
        arr := makeArrayOfObjects(5, 2, 10)
        orig := arr.Clone()
        zExpect(zEnumOrderBy(arr, x => x.a)).toEqual(makeArrayOfObjects(2, 5, 10))
        ; Stability:
        zExpect(zEnumOrderBy(arr, x => x.a == 5 ? 1 : 2)).toEqual(makeArrayOfObjects(5, 2, 10))
        zExpect(arr).toEqual(orig)
    }

    zEnumSortBy() {
        arr := makeArrayOfObjects(5, 2, 10)
        orig := arr.Clone()
        zExpect(zEnumSortBy(arr, x => x.a)).toEqual(makeArrayOfObjects(2, 5, 10))


    }

    zEnumUniq() {
        arr := [1, 1, 2, 2]
        zExpect(zEnumUniq(arr)).toEqual([1, 2])
        zExpect(zEnumUniq([])).toEqual([])
        zExpect(zEnumUniq(["a", "A"])).toEqual(["a"])
        zExpect(zEnumUniq(["a", "A"], True)).toEqual(["a", "A"])
    }

    zEnumUniqBy() {
        arr := makeArrayOfObjects(1, 1, 2, 2)
        zExpect(zEnumUniqBy(arr, x => x.a)).toEqual(makeArrayOfObjects(1, 2))
        zExpect(zEnumUniqBy(arr, x => 1)).toEqual(makeArrayOfObjects(1))
        zExpect(zEnumUniqBy(arr, x => "a")).toEqual(makeArrayOfObjects(1))
    }

}

