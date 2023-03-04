#include ../lib/0.index.ah2

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

    zRange() {
        zExpect(zRange(0, 3)).toEqual([0, 1, 2])
        zExpect(zRange(0, -2)).toEqual([0, -1])
        zExpect(zRange(0, 5, 2)).toEqual([0, 2, 4])
        zExpect(zRange(0, 0)).toEqual([0])
        zExpect(() => zRange(0, 0, 0)).toThrow()
    }


    zGroupBy() {
        zExpect(zGroupBy([], x => 1)).toEqual(Map())
        zExpect(zGroupBy([1, 2, 3], x => 1)).toEqual(Map(1, [1, 2, 3]))
        zExpect(zGroupBy([1, 2], x => x)).toEqual(Map(1, [1], 2, [2]))
        
    }

    zFind() {
        arr := [0, 5, 10]
        zExpect(zFind(arr, a => a == 5)).toEqual(zz_Kvp(2, 5))
        zExpect(zFind(arr, x => x == 100)).toBe("")
        zExpect(() => zFind(arr, "a")).toThrow()
        ; With index:
        zExpect(zFind(arr, (i, x) => i == 1 and x == 0).Key).toEqual(1)
    }

    zIndexOf() {
        arr := [0, 5, 10]
        zExpect(zKvpOf(arr, 5).Key).toEqual(2)
        zExpect(zKvpOf(arr, 0).Key).toEqual(1)
        zExpect(zKvpOf(arr, 100)).toBe("")
    }


    zFilter() {
        arr := [0, 5, 10]
        zExpect(zFilter(arr, x => x == 5)).toEqual([5])
        zExpect(zFilter(arr, x => x == -1)).toEqual([])
        zExpect(zFilter(arr, x => True)).toEqual(arr)
        zExpect(zFilter(arr, (i, x) => Mod(i, 2) == 0 and x == 5)).toEqual([5])
    }

    zMap() {
        arr := [0, 5, 10]
        zExpect(zMap(arr, x => x + 1)).toEqual([1, 6, 11])
        zExpect(zMap(arr, x => {})).toEqual([{}, {}, {}])
        zExpect(zMap(arr, (i, x) => x + i)).toEqual([1, 7, 13])
    }

    zEvery() {
        arr := [0, 5, 10]
        zExpect(zEvery(arr, x => x == 5)).toEqual(False)
        zExpect(zEvery(arr, x => x < 11)).toEqual(True)
        zExpect(zEvery(arr, (i, x) => i < 4 and x < 11)).toEqual(True)
    }

    zFlatMap() {
        arr := [0, 5, 10]
        zExpect(zFlatMap(arr, x => [x, x])).toEqual([0, 0, 5, 5, 10, 10])
        zExpect(zFlatMap(arr, x => [])).toEqual([])
        zExpect(zFlatMap(arr, (i, x) => [i, x])).toEqual([1, 0, 2, 5, 3, 10])
        zExpect(() => zFlatMap(arr, "a")).toThrow()
    }

    zReverse() {
        arr := [0, 5, 10]
        zExpect(zReverse(arr)).toEqual([10, 5, 0])
        zExpect(zReverse([])).toEqual([])
    }

    zSlice() {
        zExpect(zSlice([1, 2], 1, 2)).toEqual([1, 2])
        zExpect(zSlice([1, 2], -1, -1)).toEqual([2])
        zExpect(zSlice([0], 1, 2)).toEqual([0])
        zExpect(zSlice([0, 1], 1, 1)).toEqual([0])

        zExpect(zSlice([], 100, -1)).toEqual([])
        zExpect(zSlice([0, 1, 2], 5, 7)).toEqual([])

    }

    zReduce() {
        zExpect(zReduce([1], (acc, cur) => 1)).toEqual(1)
        zExpect(zReduce([1, 2, 3], (acc, cur) => acc + cur)).toEqual(6)
        zExpect(zReduce([1, 2], (ix, acc, cur) => acc + cur * ix)).toEqual(5)
        zExpect(zReduce([1], (acc, cur) => acc + cur, 1)).toEqual(2)
        zExpect(zReduce([], (a, b) => 1, 5)).toEqual(5)
        zExpect(() => zReduce([], (a, b) => 1)).toThrow()
    }

    zPull() {
        zExpect(zPull([], 5, 1)).toEqual([])
        zExpect(zPull([1], 1)).toEqual([])
        zExpect(zPull([1, 2], 1)).toEqual([2])
        zExpect(zPull([1, 2, 3], 1, 2, 3)).toEqual([])
    }

    zSort() {
        zExpect(zSort([5, 2, 10])).toEqual([2, 5, 10])
        arr := [0, 5, -1]
        zSort(arr)
        zExpect(arr).toEqual([-1, 0, 5])
        zExpect(zSort([])).toEqual([])
        zExpect(zSort([1])).toEqual([1])
    }

    zOrder() {
        zExpect(zOrder([5, 2, 10])).toEqual([2, 5, 10])
        arr := [0, 5, -1]
        zOrder(arr)
        zExpect(arr).toEqual([0, 5, -1])
        zExpect(zOrder([])).toEqual([])
        zExpect(zOrder([1])).toEqual([1])
    }

    zOrderBy() {
        arr := makeArrayOfObjects(5, 2, 10)
        orig := arr.Clone()
        zExpect(zOrderBy(arr, x => x.a)).toEqual(makeArrayOfObjects(2, 5, 10))
        ; Stability:
        zExpect(zOrderBy(arr, x => x.a == 5 ? 1 : 2)).toEqual(makeArrayOfObjects(5, 2, 10))
        zExpect(arr).toEqual(orig)
    }

    zSortBy() {
        arr := makeArrayOfObjects(5, 2, 10)
        orig := arr.Clone()
        zExpect(zSortBy(arr, x => x.a)).toEqual(makeArrayOfObjects(2, 5, 10))


    }

    zUniq() {
        arr := [1, 1, 2, 2]
        zExpect(zUniq(arr)).toEqual([1, 2])
        zExpect(zUniq([])).toEqual([])
        zExpect(zUniq(["a", "A"])).toEqual(["a"])
        zExpect(zUniq(["a", "A"], True)).toEqual(["a", "A"])
    }

    zUniqBy() {
        arr := makeArrayOfObjects(1, 1, 2, 2)
        zExpect(zUniqBy(arr, x => x.a)).toEqual(makeArrayOfObjects(1, 2))
        zExpect(zUniqBy(arr, x => 1)).toEqual(makeArrayOfObjects(1))
        zExpect(zUniqBy(arr, x => "a")).toEqual(makeArrayOfObjects(1))
    }

}

