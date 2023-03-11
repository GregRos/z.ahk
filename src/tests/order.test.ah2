#include ../lib/0.index.ah2
class Order_tests extends zTestSuite {
    Reverse_array() {
        zExpect(zReverse([1, 2, 3])).toEqual([3, 2, 1])
        zExpect(zReverse([])).toEqual([])
        zExpect(zReverse([1])).toEqual([1])
    }

    Reverse_string() {
        zExpect(zReverse("abc")).toEqual("cba")
        zExpect(zReverse("")).toEqual("")
        zExpect(zReverse("a")).toEqual("a")
    }

    Order() {
        zExpect(zOrder([1, 10, -5])).toEqual([-5, 1, 10])
        zExpect(zOrder(["abc", "aab", "aaa"])).toEqual(["aaa", "aab", "abc"])
        zExpect(zOrder([])).toEqual([])
        zExpect(() => zOrder([{}])).toThrow()
    }

    OrderDesc() {
        zExpect(zOrderDesc([1, 10, -5])).toEqual([10, 1, -5])
        zExpect(zOrderDesc(["abc", "aab", "aaa"])).toEqual(["abc", "aab", "aaa"])
        zExpect(zOrderDesc([])).toEqual([])
        zExpect(() => zOrderDesc([{}])).toThrow()
    }

    OrderBy() {
        zExpect(zOrderBy([1, 10, -5], x => -x)).toEqual([10, 1, -5])
        zExpect(zOrderBy([100, 200, 5], String)).toEqual([100, 200, 5])
        zExpect(zOrderBy([], x => x)).toEqual([])
        zExpect(() => zOrderBy([{}], x => x)).toThrow()
    }

    OrderByDesc() {
        zExpect(zOrderByDesc([1, 10, -5], x => -x)).toEqual([-5, 1, 10])
        zExpect(zOrderByDesc([100, 200, 5], String)).toEqual([5, 200, 100])
        zExpect(zOrderByDesc([], x => x)).toEqual([])
        zExpect(() => zOrderByDesc([{}], x => x)).toThrow()
    }

    zSort() {
        arr := [1, 10, -5]
        zSort(arr)
        zExpect(arr).toEqual([-5, 1, 10])
        arr := ["abc", "aab", "aaa"]
        zSort(arr)
        zExpect(arr).toEqual(["aaa", "aab", "abc"])
        arr := []
        zSort(arr)
        zExpect(arr).toEqual([])
    }

    zSortDesc() {
        arr := [1, 10, -5]
        zSortDesc(arr)
        zExpect(arr).toEqual([10, 1, -5])
        arr := ["abc", "aab", "aaa"]
        zSortDesc(arr)
        zExpect(arr).toEqual(["abc", "aab", "aaa"])
        arr := []
        zSortDesc(arr)
        zExpect(arr).toEqual([])
    }

    zSortBy() {
        arr := [1, 10, -5]
        zSortBy(arr, x => -x)
        zExpect(arr).toEqual([10, 1, -5])
        arr := [100, 200, 5]
        zSortBy(arr, String)
        zExpect(arr).toEqual([100, 200, 5])
        arr := []
        zSortBy(arr, x => x)
        zExpect(arr).toEqual([])
    }

    zSortByDesc() {
        arr := [1, 10, -5]
        zSortByDesc(arr, x => -x)
        zExpect(arr).toEqual([-5, 1, 10])
        arr := [100, 200, 5]
        zSortByDesc(arr, String)
        zExpect(arr).toEqual([5, 200, 100])
        arr := []
        zSortByDesc(arr, x => x)
        zExpect(arr).toEqual([])
    }
}