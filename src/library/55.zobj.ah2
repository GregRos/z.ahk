#include 13.zchecks.ah2
#include 50.zmap.ah2


zObjProps(self, inherited := False) {
    zCheck(self, "self").isObjectLike()
    zCheck(inherited, "inherited").isBool()
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

zObjGetOwnDescs(self) {
    zCheck(self, "self").isObjectLike()
    descs := {}
    for k in self.OwnProps() {
        descs[k] := self.GetOwnPropDesc(k)
    }
    return descs
}

zObjGetDescsDownTo(self, stopPrototype := Object.Prototype) {
    zCheck(self, "self").isObjectLike()
    zCheck(stopPrototype, "stopPrototype").isObjectLike()
    descList := []
    while IsObject(self) and self != stopPrototype {
        curDescs := zObjGetOwnDescs(self)
        descList.Push(curDescs)
    }
    return zMapMerge(descList, False)
}

; Returns a Map consisting of the object's property descriptors
zObjGetDescs(self, stopCondition := True) {
    zCheck(self, "self").isObjectLike()
    zCheck(inherited, "inherited").isBool()
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
    zCheck(self, "self").isObjectLike()
    result := {}
    for i, k in keys {

        result.DefineProp(k, {
        })
    }
    return result
}

; Creates an object with all the keys in `keys`, all having the value `value`.
zObjFromKeys(keys, value := True) {
    zCheck(keys, "keys").isInstanceOf(Array)
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

; Returns a new object with defaults from `sources`.
zObjDefaults(self, sources*) {
    for i, source in sources {
        for key, value in source {
            if not self.HasKey()
        }
    }

    return self
}
