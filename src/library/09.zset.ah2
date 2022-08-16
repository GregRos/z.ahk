#include 01.zinit.ah2
class zSet {
    _map := Map()
    __New(items*) {
        this.Add(items*)
    }

    CaseSense {
        get => this._map.CaseSense
        set => this._map.CaseSense := value
    }

    Default {
        get => this._map.Default
        set => this._map.Default := value
    }

    __Item[key] {
        get => this._map.Has(key)
        set => key ? this._map.Set(key) : this._map.Delete(key)
    }

    Add(items*) {
        for item in items {
            this._map[item] := True
        }
    }

    Clone() {
        set := zSet()
        set._map := this._map.Clone()
        return set
    }

    Delete(items*) {
        for item in items {
            this._map.Delete(item)
        }
    }

    Has(item) {
        return this._map.Has(item)
    }

    __Enum(count) {
        if count != 1 {
            throw zInvalidCallError("Cannot enumerate with " count " variables. Only supports 1.")
        }
        return this._map.__Enum(1)
    }

    Count {
        get => this._map.Count
    }

    Capacity {
        get => this._map.Capacity
        set => this._map.Capacity := value
    }

}