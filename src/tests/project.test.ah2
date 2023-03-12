#include ../lib/0.index.ah2
makeArrayOfObjects(values*) {
    arr := []
    for i, value in values {
        arr.Push({ a: value })
    }
    return arr
}
class Project_tests extends zTestSuite {

    zInvert() {
        zExpect(zInvert(Map("a", 1, "b", 2))).toEqual(Map(1, "a", 2, "b"))
        zExpect(zInvert(Map("a", 1, "b", 1))).toEqual(Map(1, "b"))
        zExpect(zInvert(Map())).toEqual(Map())
    }
    zGroupBy() {
        zExpect(zGroupBy([], x => 1)).toEqual(Map())
        zExpect(zGroupBy([1, 2, 3], x => 1)).toEqual(Map(1, [1, 2, 3]))
        zExpect(zGroupBy([1, 2], x => x)).toEqual(Map(1, [1], 2, [2]))
        zExpect(zGroupBy(Map("a", 1, "b", 2), (key, val) => key val)).toEqual(Map("a1", ["1"], "b2", ["2"]))
    }


    zFilter() {
        arr := [0, 5, 10]
        zExpect(zFilter(arr, x => x == 5)).toEqual([5])
        zExpect(zFilter(arr, x => x == -1)).toEqual([])
        zExpect(zFilter(arr, x => True)).toEqual(arr)
        zExpect(zFilter(arr, (i, x) => Mod(i, 2) == 0 and x == 5)).toEqual([5])
        myMap := Map("a", 1, "b", 2)
        zExpect(zFilter(myMap, (key, val) => key == "a")).toEqual([1])
    }

    zSelect() {
        arr := [0, 5, 10]
        zExpect(zSelect(arr, x => x + 1)).toEqual([1, 6, 11])
        zExpect(zSelect(arr, x => {})).toEqual([{}, {}, {}])
        zExpect(zSelect(arr, (i, x) => x + i)).toEqual([1, 7, 13])
        myMap := Map("a", 1, "b", 2)
        zExpect(zSelect(myMap, (key, val) => key val)).toEqual(["a1", "b2"])
    }

    zSlice_array() {
        zExpect(zSlice([1, 2], 1, 2)).toEqual([1, 2])
        zExpect(zSlice([1, 2], -1, -1)).toEqual([2])
        zExpect(zSlice([0], 1, 2)).toEqual([0])
        zExpect(zSlice([0, 1], 1, 1)).toEqual([0])

        zExpect(zSlice([], 100, -1)).toEqual([])
        zExpect(zSlice([0, 1, 2], 5, 7)).toEqual([])
    }

    zSlice_string() {
        zExpect(zSlice("abc", 1, 2)).toEqual("ab")
        zExpect(zSlice("abc", -1, -1)).toEqual("c")
        zExpect(zSlice("abc", 1, 1)).toEqual("a")
        zExpect(zSlice("abc", 5, 7)).toEqual("")
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

    
    zSelectMany() {
        arr := [0, 5, 10]
        zExpect(zSelectMany(arr, x => [x, x])).toEqual([0, 0, 5, 5, 10, 10])
        zExpect(zSelectMany(arr, x => [])).toEqual([])
        zExpect(zSelectMany(arr, (i, x) => [i, x])).toEqual([1, 0, 2, 5, 3, 10])
        ; Doesn't flatten recursively
        zExpect(zSelectMany([[arr]], x => x)).toEqual([arr])
        zExpect(() => zSelectMany(arr, "a")).toThrow()
    }

    zFlat() {
        zExpect(zFlat([1, 2, [3, 4]])).toEqual([1, 2, 3, 4])
        zExpect(zFlat(1, [2])).toEqual([1, 2])
        zExpect(zFlat(1, [2, [3]])).toEqual([1, 2, 3])
        zExpect(zFlat(1, [2, [3, [4]]])).toEqual([1, 2, 3, 4])
        zExpect(zFlat()).toEqual([])
        zExpect(zFlat(1, 1)).toEqual([1, 1])
        zExpect(zFlat(Map())).toEqual([Map()])
    }
    
    

    
}