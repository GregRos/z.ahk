#include ./4.assert/0.index.ah2




zDict(self, inherited := False) {
    zExpectArg(self, "self").toBeObj()
    zExpectArg(inherited, "inherited").toBeBool()

    for key, val in ObjOwnProps(self) {

    }
}

zObjProps(self, inherited := False) {
    zExpectArg(self, "self").toBeObjectLike()
    zExpectArg(inherited, "inherited").toBeBool()
    keys := []
    while (IsObject(self)) {
        for k in ObjOwnProps(self) {
            keys.Push(k)
        }
        if (!inherited) {
            return keys
        }
        self := ObjGetBase(self)
    }
    return keys
}


zObjGetDescsDownTo(self, stopPrototype := Object.Prototype) {
    zExpectArg(self, "self").toBeObjectLike()
    zExpectArg(stopPrototype, "stopPrototype").toBeObjectLike()
    descList := []
    while IsObject(self) and self != stopPrototype {
        curDescs := zObjGetOwnDescs(self)
        descList.Push(curDescs)
    }
    return zMapMerge(descList, False)
}

; Returns a Map consisting of the object's property descriptors
zObjGetDescs(self, stopCondition := True) {
    zExpectArg(self, "self").toBeObjectLike()
    zExpectArg(inherited, "inherited").toBeBool()
    descs := Map()
    while IsObject(self) and self != stopPrototype {
        for k in self.OwnProps() {
            descs[k] := self.GetOwnPropDesc()
        }
        if not inherited {
            return descs
        }
        self := ObjGetBase(self)
    }
    return descs
}

; Returns a subset of `self` including only keys from `keys`.
zObjPick(self, keys*) {
    zExpectArg(self, "self").toBeObjectLike()
    result := {}
    for i, k in keys {

        result.DefineProp(k, {
        })
    }
    return result
}

; Creates an object with all the keys in `keys`, all having the value `value`.
zObjFromKeys(keys, value := True) {
    zExpectArg(keys, "keys").toBeInstanceOf(Array)
    result := {}
    for i, k in keys {
        result[k] := value
    }
    return result
}

; Returns a subset of `self` without keys from `keys`.
gObj_Omit(self, keys*) {
    result := {}
    keysObj := zObjFromKeys(keys)
    for i, k in self {
        if (!keysObj.HasKey(k)) {
            result[k] := self[k]
        }
    }
    return result
}

; Assigns all the keys from sources, in order, to `self`.
zObjAssign(self, sources*) {
    return zz_obj.assign(self, sources*)
}
