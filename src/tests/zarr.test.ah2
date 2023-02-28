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

    zArrFrom() {

    }

    zArrRepeat() {
        zExpect(zArrRepeat("a", 3)).toEqual(["a", "a", "a"])
        zExpect(zArrRepeat("a", 0)).toEqual([])
        zExpect(() => zArrRepeat("a", -1)).toThrow()
    }

    zArrFindIndex() {
        arr := [0, 5, 10]
        zExpect(zArrFindIndex(arr, x => x == 5)).toEqual(2)
        zExpect(zArrFindIndex(arr, x => x == 100)).toEqual(0)
        zExpect(() => zArrFindIndex(arr, "a")).toThrow()
        ; With index:
        zExpect(zArrFindIndex(arr, (i, x) => i == 1 and x == 0)).toEqual(1)
    }

    zArrIndexOf() {
        arr := [0, 5, 10]
        zExpect(zArrIndexOf(arr, 5)).toEqual(2)
        zExpect(zArrIndexOf(arr, 0)).toEqual(1)
        zExpect(zArrIndexOf(arr, 100)).toEqual(0)
    }

    zArrHas() {
        arr := [0, 5, 10]
        zExpect(zArrHas(arr, 5)).toBeTrue()
        zExpect(zArrHas(arr, -1)).toBeFalse()
    }

    zArrFilter() {
        arr := [0, 5, 10]
        zExpect(zArrFilter(arr, x => x == 5)).toEqual([5])
        zExpect(zArrFilter(arr, x => x == -1)).toEqual([])
        zExpect(zArrFilter(arr, x => True)).toEqual(arr)
        zExpect(zArrFilter(arr, (i, x) => Mod(i, 2) == 0 and x == 5)).toEqual([5])
    }

    zArrMap() {
        arr := [0, 5, 10]
        zExpect(zArrMap(arr, x => x + 1)).toEqual([1, 6, 11])
        zExpect(zArrMap(arr, x => {})).toEqual([{}, {}, {}])
        zExpect(zArrMap(arr, (i, x) => x + i)).toEqual([1, 7, 13])
    }

    zArrFind() {
        arr := [0, 5, 10]
        zExpect(zArrFind(arr, x => x == 5)).toEqual(5)
        zExpect(zArrFind(arr, (i, x) => x == 5 and i == 2)).toEqual(5)
        zExpect(zArrFind(arr, x => x == 11)).toEqual("")
    }

    zArrExists() {
        arr := [0, 5, 10]
        zExpect(zArrExists(arr, x => x == 5)).toEqual(True)
        zExpect(zArrExists(arr, x => x == 1111)).toEqual(False)
        zExpect(zArrExistS(arr, (i, x) => i == 2 and x == 5)).toEqual(True)
    }

    zArrEvery() {
        arr := [0, 5, 10]
        zExpect(zArrEvery(arr, x => x == 5)).toEqual(False)
        zExpect(zArrEvery(arr, x => x < 11)).toEqual(True)
        zExpect(zArrEvery(arr, (i, x) => i < 4 and x < 11)).toEqual(True)
    }

    zArrFlatMap() {
        arr := [0, 5, 10]
        zExpect(zArrFlatMap(arr, x => [x, x])).toEqual([0, 0, 5, 5, 10, 10])
        zExpect(zArrFlatMap(arr, x => [])).toEqual([])
        zExpect(zArrFlatMap(arr, (i, x) => [i, x])).toEqual([1, 0, 2, 5, 3, 10])
        zExpect(() => zArrFlatMap(arr, "a")).toThrow()
    }

    zArrReverse() {
        arr := [0, 5, 10]
        zExpect(zArrReverse(arr)).toEqual([10, 5, 0])
        zExpect(zArrReverse([])).toEqual([])
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

    zArrReduce() {
        zExpect(zArrReduce([1], () => 1)).toEqual(1)
        zExpect(zArrReduce([1, 2, 3], (acc, cur) => acc + cur)).toEqual(6)
        zExpect(zArrReduce([1, 2], (acc, cur, ix) => acc + cur * ix)).toEqual(5)
        zExpect(zArrReduce([1], (acc, cur) => acc + cur, 1)).toEqual(2)
        zExpect(zArrReduce([], () => 1, 5)).toEqual(5)
        zExpect(() => zArrReduce([], () => 1)).toThrow()
    }

    zArrPull() {
        zExpect(zArrPull([], 5, 1)).toEqual([])
        zExpect(zArrPull([1], 1)).toEqual([])
        zExpect(zArrPull([1, 2], 1)).toEqual([2])
        zExpect(zArrPull([1, 2, 3], 1, 2, 3)).toEqual([])
    }

    zArrSort() {
        zExpect(zArrSort([5, 2, 10])).toEqual([2, 5, 10])
        arr := [0, 5, -1]
        zArrSort(arr)
        zExpect(arr).toEqual([-1, 0, 5])
        zExpect(zArrSort([])).toEqual([])
        zExpect(zArrSort([1])).toEqual([1])
    }

    zArrOrder() {
        zExpect(zArrOrder([5, 2, 10])).toEqual([2, 5, 10])
        arr := [0, 5, -1]
        zArrOrder(arr)
        zExpect(arr).toEqual([0, 5, -1])
        zExpect(zArrOrder([])).toEqual([])
        zExpect(zArrOrder([1])).toEqual([1])
    }

    zArrOrderBy() {
        arr := makeArrayOfObjects(5, 2, 10)
        orig := arr.Clone()
        zExpect(zArrOrderBy(arr, x => x.a)).toEqual(makeArrayOfObjects(2, 5, 10))
        ; Stability:
        zExpect(zArrOrderBy(arr, x => x.a == 5 ? 1 : 2)).toEqual(makeArrayOfObjects(5, 2, 10))
        zExpect(arr).toEqual(orig)
    }

    zArrSortBy() {
        arr := makeArrayOfObjects(5, 2, 10)
        orig := arr.Clone()
        zExpect(zArrSortBy(arr, x => x.a)).toEqual(makeArrayOfObjects(2, 5, 10))


    }

    zArrUniq() {
        arr := [1, 1, 2, 2]
        zExpect(zArrUniq(arr)).toEqual([1, 2])
        zExpect(zArrUniq([])).toEqual([])
        zExpect(zArrUniq(["a", "A"])).toEqual(["a"])
        zExpect(zArrUniq(["a", "A"], True)).toEqual(["a", "A"])
    }

    zArrUniqBy() {
        arr := makeArrayOfObjects(1, 1, 2, 2)
        zExpect(zArrUniqBy(arr, x => x.a)).toEqual(makeArrayOfObjects(1, 2))
        zExpect(zArrUniqBy(arr, x => 1)).toEqual(makeArrayOfObjects(1))
        zExpect(zArrUniqBy(arr, x => "a")).toEqual(makeArrayOfObjects(1))
    }

    zArrZip() {
        arr := [[1, 2, 3], [1, 2, 3], [1, 2, 3]]
        zExpect(zArrZip(arr*)).toEqual([[1, 1, 1], [2, 2, 2], [3, 3, 3]])
        zExpect(zArrZip([], [], [])).toEqual([])
        zExpect(zArrZip([], [1], [1])).toEqual([])
        zExpect(zArrZip([, 2], [1, 1])).toEqual([[, 1], [2, 1]])
    }
}