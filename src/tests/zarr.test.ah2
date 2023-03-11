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




    zEvery() {
        arr := [0, 5, 10]
        zExpect(zEvery(arr, x => x == 5)).toEqual(False)
        zExpect(zEvery(arr, x => x < 11)).toEqual(True)
        zExpect(zEvery(arr, (i, x) => i < 4 and x < 11)).toEqual(True)
    }

    zSelectMany() {
        arr := [0, 5, 10]
        zExpect(zSelectMany(arr, x => [x, x])).toEqual([0, 0, 5, 5, 10, 10])
        zExpect(zSelectMany(arr, x => [])).toEqual([])
        zExpect(zSelectMany(arr, (i, x) => [i, x])).toEqual([1, 0, 2, 5, 3, 10])
        zExpect(() => zSelectMany(arr, "a")).toThrow()
    }

    zReverse() {
        arr := [0, 5, 10]
        zExpect(zReverse(arr)).toEqual([10, 5, 0])
        zExpect(zReverse([])).toEqual([])
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



}

