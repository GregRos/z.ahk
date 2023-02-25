#include ../lib/40.zarr.ah2

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
        this.expect(zArr(my_arr)).toEqual(my_arr)
        this.expect(zArr()).toEqual([])
    }

    zArrRange() {
        this.expect(zArrRange(0, 3)).toEqual([0, 1, 2])
        this.expect(zArrRange(0, -2)).toEqual([0, -1])
        this.expect(zArrRange(0, 5, 2)).toEqual([0, 2, 4])
        this.expect(zArrRange(0, -2, -2)).toEqual([0])
        this.expect(zArrRange(0, 0, 10)).toEqual([])
        this.expect(() => zArrRange(0, 0, 0)).toThrow()
    }

    zArrFrom() {

    }

    zArrRepeat() {
        this.expect(zArrRepeat("a", 3)).toEqual(["a", "a", "a"])
        this.expect(zArrRepeat("a", 0)).toEqual([])
        this.expect(() => zArrRepeat("a", -1)).toThrow()
    }

    zArrFindIndex() {
        arr := [0, 5, 10]
        this.expect(zArrFindIndex(arr, x => x == 5)).toEqual(2)
        this.expect(zArrFindIndex(arr, x => x == 100)).toEqual(0)
        this.expect(() => zArrFindIndex(arr, "a")).toThrow()
        ; With index:
        this.expect(zArrFindIndex(arr, (i, x) => i == 1 and x == 0)).toEqual(1)
    }

    zArrIndexOf() {
        arr := [0, 5, 10]
        this.expect(zArrIndexOf(arr, 5)).toEqual(2)
        this.expect(zArrIndexOf(arr, 0)).toEqual(1)
        this.expect(zArrIndexOf(arr, 100)).toEqual(0)
    }

    zArrHas() {
        arr := [0, 5, 10]
        this.expect(zArrHas(arr, 5)).toBeTrue()
        this.expect(zArrHas(arr, -1)).toBeFalse()
    }

    zArrFilter() {
        arr := [0, 5, 10]
        this.expect(zArrFilter(arr, x => x == 5)).toEqual([5])
        this.expect(zArrFilter(arr, x => x == -1)).toEqual([])
        this.expect(zArrFilter(arr, x => True)).toEqual(arr)
        this.expect(zArrFilter(arr, (i, x) => Mod(i, 2) == 0 and x == 5)).toEqual([5])
    }

    zArrMap() {
        arr := [0, 5, 10]
        this.expect(zArrMap(arr, x => x + 1)).toEqual([1, 6, 11])
        this.expect(zArrMap(arr, x => {})).toEqual([{}, {}, {}])
        this.expect(zArrMap(arr, (i, x) => x + i)).toEqual([1, 7, 13])
    }

    zArrFind() {
        arr := [0, 5, 10]
        this.expect(zArrFind(arr, x => x == 5)).toEqual(5)
        this.expect(zArrFind(arr, (i, x) => x == 5 and i == 2)).toEqual(5)
        this.expect(zArrFind(arr, x => x == 11)).toEqual("")
    }

    zArrExists() {
        arr := [0, 5, 10]
        this.expect(zArrExists(arr, x => x == 5)).toEqual(True)
        this.expect(zArrExists(arr, x => x == 1111)).toEqual(False)
        this.expect(zArrExistS(arr, (i, x) => i == 2 and x == 5)).toEqual(True)
    }

    zArrEvery() {
        arr := [0, 5, 10]
        this.expect(zArrEvery(arr, x => x == 5)).toEqual(False)
        this.expect(zArrEvery(arr, x => x < 11)).toEqual(True)
        this.expect(zArrEvery(arr, (i, x) => i < 4 and x < 11)).toEqual(True)
    }

    zArrFlatMap() {
        arr := [0, 5, 10]
        this.expect(zArrFlatMap(arr, x => [x, x])).toEqual([0, 0, 5, 5, 10, 10])
        this.expect(zArrFlatMap(arr, x => [])).toEqual([])
        this.expect(zArrFlatMap(arr, (i, x) => [i, x])).toEqual([1, 0, 2, 5, 3, 10])
        this.expect(() => zArrFlatMap(arr, "a")).toThrow()
    }

    zArrReverse() {
        arr := [0, 5, 10]
        this.expect(zArrReverse(arr)).toEqual([10, 5, 0])
        this.expect(zArrReverse([])).toEqual([])
    }

    zArrPrepend() {
        this.expect(zArrPrepend([0], 1, 2)).toEqual([1, 2, 0])
        this.expect(zArrPrepend([0])).toEqual([0])
        this.expect(zArrPrepend([], 1)).toEqual([1])
    }

    zArrSlice() {
        this.expect(zArrSlice([1, 2], 1, 2)).toEqual([1])
        this.expect(zArrSlice([1, 2], -1, -1)).toEqual([2])
        this.expect(zArrSlice([0], 1, 2)).toEqual([0])
        this.expect(zArrSlice([0, 1], 1, 1)).toEqual([])

        this.expect(zArrSlice([], 100, -1)).toEqual([])
        this.expect(zArrSlice([0, 1, 2], 5, 7)).toEqual([])

    }

    zArrReduce() {
        this.expect(zArrReduce([1], () => 1)).toEqual(1)
        this.expect(zArrReduce([1, 2, 3], (acc, cur) => acc + cur)).toEqual(6)
        this.expect(zArrReduce([1, 2], (acc, cur, ix) => acc + cur * ix)).toEqual(5)
        this.expect(zArrReduce([1], (acc, cur) => acc + cur, 1)).toEqual(2)
        this.expect(zArrReduce([], () => 1, 5)).toEqual(5)
        this.expect(() => zArrReduce([], () => 1)).toThrow()
    }

    zArrPull() {
        this.expect(zArrPull([], 5, 1)).toEqual([])
        this.expect(zArrPull([1], 1)).toEqual([])
        this.expect(zArrPull([1, 2], 1)).toEqual([2])
        this.expect(zArrPull([1, 2, 3], 1, 2, 3)).toEqual([])
    }

    zArrSort() {
        this.expect(zArrSort([5, 2, 10])).toEqual([2, 5, 10])
        arr := [0, 5, -1]
        zArrSort(arr)
        this.expect(arr).toEqual([-1, 0, 5])
        this.expect(zArrSort([])).toEqual([])
        this.expect(zArrSort([1])).toEqual([1])
    }

    zArrOrder() {
        this.expect(zArrOrder([5, 2, 10])).toEqual([2, 5, 10])
        arr := [0, 5, -1]
        zArrOrder(arr)
        this.expect(arr).toEqual([0, 5, -1])
        this.expect(zArrOrder([])).toEqual([])
        this.expect(zArrOrder([1])).toEqual([1])
    }

    zArrOrderBy() {
        arr := makeArrayOfObjects(5, 2, 10)
        orig := arr.Clone()
        this.expect(zArrOrderBy(arr, x => x.a)).toEqual(makeArrayOfObjects(2, 5, 10))
        ; Stability:
        this.expect(zArrOrderBy(arr, x => x.a == 5 ? 1 : 2)).toEqual(makeArrayOfObjects(5, 2, 10))
        this.expect(arr).toEqual(orig)
    }

    zArrSortBy() {
        arr := makeArrayOfObjects(5, 2, 10)
        orig := arr.Clone()
        this.expect(zArrSortBy(arr, x => x.a)).toEqual(makeArrayOfObjects(2, 5, 10))


    }

    zArrUniq() {
        arr := [1, 1, 2, 2]
        this.expect(zArrUniq(arr)).toEqual([1, 2])
        this.expect(zArrUniq([])).toEqual([])
        this.expect(zArrUniq(["a", "A"])).toEqual(["a"])
        this.expect(zArrUniq(["a", "A"], True)).toEqual(["a", "A"])
    }

    zArrUniqBy() {
        arr := makeArrayOfObjects(1, 1, 2, 2)
        this.expect(zArrUniqBy(arr, x => x.a)).toEqual(makeArrayOfObjects(1, 2))
        this.expect(zArrUniqBy(arr, x => 1)).toEqual(makeArrayOfObjects(1))
        this.expect(zArrUniqBy(arr, x => "a")).toEqual(makeArrayOfObjects(1))
    }

    zArrZip() {
        arr := [[1, 2, 3], [1, 2, 3], [1, 2, 3]]
        this.expect(zArrZip(arr*)).toEqual([[1, 1, 1], [2, 2, 2], [3, 3, 3]])
        this.expect(zArrZip([], [], [])).toEqual([])
        this.expect(zArrZip([], [1], [1])).toEqual([])
        this.expect(zArrZip([, 2], [1, 1])).toEqual([[, 1], [2, 1]])
    }
}