#include ../lib/0.index.ah2

class Create_tests extends zTestSuite {
    zArr_empty() {
        zExpect(zArr()).toEqual([])
    }
    
    zArr_clones() {
        a := [1, 2, 3]
        b := zArr(a)
        b[1] := 4
        zExpect(a).toEqual([1, 2, 3])
        zExpect(b).toEqual([4, 2, 3])
    }

    zArr_from_Map() {
        m := Map("a", 1, "b", 2, "c", 3)

        zExpect(zArr(m)).toEqual([1, 2, 3])
    }

    zArr_from_string() {
        zExpect(zArr("abc")).toEqual(["a", "b", "c"])
    }

    zArr_from_value_and_count() {
        zExpect(zArr(1, 3)).toEqual([1, 1, 1])
    }

    zArr_empty_with_count() {
        unsetArr := []
        unsetArr.Length := 3
        zExpect(zArr( , 3)).toEqual(unsetArr)
    }

    zRange_one_element() {
        zExpect(zRange(1, 1)).toEqual([1])
    }

    zRange_two_elements() {
        zExpect(zRange(1, 2)).toEqual([1, 2])
    }

    zRange_two_elements_step() {
        zExpect(zRange(1, 4, 3)).toEqual([1, 3])
    }

    zRange_two_elements_reversed() {
        zExpect(zRange(2, 1)).toEqual([2, 1])
    }

    zRange_two_elements_reversed_step() {
        zExpect(zRange(2, 0, 2)).toEqual([2, 0])
    }

    zRange_two_elements_uneven_step() {
        zExpect(zRange(1, 5, 3)).toEqual([1, 4])
    }

    zRepeat_string() {
        zExpect(zRepeat("a", 3)).toEqual("aaa")
        zExpect(zRepeat("a", 0)).toEqual("")
        zExpect(zRepeat("", 3)).toEqual("")
    }

    zRepeat_array() {
        zExpect(zRepeat([1, 2], 3)).toEqual([1, 2, 1, 2, 1, 2])
        zExpect(zRepeat([1, 2], 0)).toEqual([])
        zExpect(zRepeat([], 3)).toEqual([])
    }

    zRepeat_map() {
        m := Map("a", 1, "b", 2)
        zExpect(zRepeat(m, 3)).toEqual([1, 2, 1, 2, 1, 2])
        zExpect(zRepeat(m, 0)).toEqual([])
        zExpect(zRepeat(Map(), 3)).toEqual([])
    }

    zDict_empty() {
        zExpect(zDict()).toEqual(Map())
    }

    zDict_empty_object() {
        zExpect(zDict({})).toEqual(Map())
    }

    zDict_of_object() {
        zExpect(zDict({a: 1, b: 2})).toEqual(Map("a", 1, "b", 2))
    }

    zDict_of_object_with_prototype() {
        o := {a: 1, b: 2}
        o.base := {c: 3}
        zExpect(zDict(o)).toEqual(Map("a", 1, "b", 2))
    }

    zDict_of_array() {
        zExpect(zDict([1, 2])).toEqual(Map(1, 1, 2, 2))
    }
}