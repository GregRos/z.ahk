#include ../lib/0.index.ah2
class Project_tests extends zTestSuite {
    zGroupBy() {
        zExpect(zGroupBy([], x => 1)).toEqual(Map())
        zExpect(zGroupBy([1, 2, 3], x => 1)).toEqual(Map(1, [1, 2, 3]))
        zExpect(zGroupBy([1, 2], x => x)).toEqual(Map(1, [1], 2, [2]))
        zExpect(zGroupBy(Map("a", 1, "b", 2), (key, val) => key val)).toEqual(Map("a1", ["1"], "a2", ["2"]))
    }


    zFilter() {
        arr := [0, 5, 10]
        zExpect(zFilter(arr, x => x == 5)).toEqual([5])
        zExpect(zFilter(arr, x => x == -1)).toEqual([])
        zExpect(zFilter(arr, x => True)).toEqual(arr)
        zExpect(zFilter(arr, (i, x) => Mod(i, 2) == 0 and x == 5)).toEqual([5])
        myMap := Map("a", 1, "b", 2)
        zExpect(zFilter(myMap, (key, val) => key == "a")).toEqual(Map("a", 1))
    }

    zSelect() {
        arr := [0, 5, 10]
        zExpect(zSelect(arr, x => x + 1)).toEqual([1, 6, 11])
        zExpect(zSelect(arr, x => {})).toEqual([{}, {}, {}])
        zExpect(zSelect(arr, (i, x) => x + i)).toEqual([1, 7, 13])
        myMap := Map("a", 1, "b", 2)
        zExpect(zSelect(myMap, (key, val) => key val)).toEqual(Map("a", "a1", "b", "b2"))
    }

    zSlice() {
        zExpect(zSlice([1, 2], 1, 2)).toEqual([1, 2])
        zExpect(zSlice([1, 2], -1, -1)).toEqual([2])
        zExpect(zSlice([0], 1, 2)).toEqual([0])
        zExpect(zSlice([0, 1], 1, 1)).toEqual([0])

        zExpect(zSlice([], 100, -1)).toEqual([])
        zExpect(zSlice([0, 1, 2], 5, 7)).toEqual([])

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