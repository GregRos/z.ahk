#include 13.zchecks.ah2
#include 50.zmap.ah2


zObj_Props(self, inherited := False) {
    zz_checks.isObjectLike("self", self)
    zz_checks.isBool("inherited", inherited)
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

zObj_GetOwnDescs(self) {
    zz_checks.isObjectLike("self", self)
    descs := {}
    for k in self.OwnProps() {
        descs[k] := self.GetOwnPropDesc(k)
    }
    return descs
}

zObj_GetDescsDownTo(self, stopPrototype := Object.Prototype) {
    zz_checks.isObjectLike("self", self)
    zz_checks.isObjectLike("stopPrototype", stopPrototype)
    descList := []
    while IsObject(self) and self != stopPrototype {
        curDescs := zObj_GetOwnDescs(self)
        descList.Push(curDescs)
    }
    return zMap_Merge(descList, False)
}

; Returns a Map consisting of the object's property descriptors
zObj_GetDescs(self, stopCondition := True) {
    zz_checks.isObjectLike("self", self)
    zz_checks.isBool("inherited", inherited)
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
zObj_Pick(self, keys*) {
    zz_checks.isObjectLike("self", self)
    result := {}
    for i, k in keys {

        result.DefineProp(k, {
        })
    }
    return result
}

; Creates an object with all the keys in `keys`, all having the value `value`.
zObj_FromKeys(keys, value := True) {
    zz_checks.isInstanceOf("keys", Array, keys)
    result := {}
    for i, k in keys {
        result[k] := value
    }
    return result
}

; Returns a subset of `self` without keys from `keys`.
gObj_Omit(self, keys*) {
    result := {}
    keysObj := zObj_FromKeys(keys)
    for i, k in self {
        if (!keysObj.HasKey(k)) {
            result[k] := self[k]
        }
    }
    return result
}

; Assigns all the keys from sources, in order, to `self`.
zObj_Assign(self, sources*) {
    for i, source in sources {
        for k, v in source {
            self[k] := v
        }
    }
}

; Returns a new object with defaults from `sources`.
zObj_Defaults(self, sources*) {
    for i, source in sources {
        for key, value in source {
            if not self.HasKey()
        }
    }

    return self
}