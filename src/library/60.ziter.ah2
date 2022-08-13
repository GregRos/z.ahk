#include 01.zinit.ah2

zz_negotiateIterCount(iter, fExample, forceCount := unset) {
    if IsSet(forceCount) {
        return forceCount
    }
    if iter.MinParams <= fExample.MaxParams {
        return Max(iter.MinParams, fExample.MinParams)
    } else if fExample.IsVariadic {
        return iter.MinParams
    } else {
        throw zInvalidCallError(
            Format("Iterator needs {1} params, function has only up to {2}.", iter.MinParams, fExample.MaxParams)
        )
    }
}

zz_errIteratorNope(count) {
    return zInvalidCallError(Format("This iterator doesn't support iterating with {1} outputs.", count))
}

class zMappingEnumerator {
    __New(iter, projection, inputCount?) {
        inputCount := zz_negotiateIterCount(iter, projection, inputCount?)
        this._iter := zz_refArgs_to_arrayReturn(iter, inputCount)
        this._projection := projection
    }

    Call(out) {
        more := this._iter.Call()
        if not more {
            return False
        }
        %out% := this._projection.Call(more*)
        return 1
    }

    static Operator(projection) {
        operator(enum, count) {
            if count != 1 {
                throw zInvalidCallError("This enumerator only accepts 1 variable.")
            }
            return zMappingEnumerator(enum.__Enum(projection.MinParams), projection)
        }
        return operator
    }
}

class zFilteringEnumerator {
    __New(iter, predicate, count?) {
        iter := zz_iter_refToArray(iter, count)
        next(this, outs*) {
            while (true) {
                result := iter.Call()
                if not result {
                    return 0
                }
                pass := predicate.Call(result*)
                if not pass {
                    continue
                }
                for out in outs {
                    %out% := result[A_Index]
                }
                return 1
            }
        }
        count := zz_negotiateIterCount(iter, predicate, count)
        this.Call :=  zz_func_wrapVariadic(next, count + 1)
    }

    makeInvoker() {

        return zz_func_wrapVariadic
        
    }

    static Operator(predicate) {
        return (enum, count) => zFilteringEnumerator(enum.__Enum(count), predicate, count)
    }
}
class zEnumerableBase {

    ; Loops over the seq and returns the last item or `default` if none exists.
    ; @param default A default value to return if the seq is empty. Can be unset.
    ; @self `Seq[T]`
    ; @returns `T`
    Last(default := unset) {
        for x in this {
            default := x
        }
        return default
    }

    ; Loops over the seq and returns the first item or `default` if none exists
    ; @param default A default value to return if the seq is empty. Can be unset.
    ; @self `Seq[T]`
    ; @returns `T`
    First(default := unset) {
        for x in this {
            return x
        }
        return default
    }

    ; Filters the vars of the seq, yielding only those that match `predicate`.
    ; @param predicate `(t₁, ⋯, tₙ) => Bool` A function that returns True (to keep the element) or False (to discard it).
    ; @self `Seq[T₁, ⋯, Tₙ]`
    ; @returns `Seq[T₁, ⋯, Tₙ]`
    Filter(predicate) {
        return zOperatorEnumerable(this, zFilteringEnumerator.Operator(predicate))
    }

    ; Loops over the seq and returns a Map, where each item is a key and all have value True (1).
    ; @self `Seq[T]`
    ; @returns `Map[T, 1]`
    ToSet() {

    }

    ; Loops over a `Seq[K, V]` and converts it into a Map, with `K` being the key and `V` the value.
    ; Later keys supersede previous ones.
    ; @self `Seq[K, V]`
    ; @returns `Map[K, V]`
    ToMap() {

    }

    ; Returns a seq that's a slice of this seq, containing elements starting at `start` (inclusive)
    ; and ending at `end` (exclusive).
    ; @param start Start index. May be negative. Inclusive.
    ; @param end End index. May be negative. Exclusive.
    ; @self `Seq[T₁, ⋯, Tₙ]`
    ; @returns `Seq[T₁, ⋯, Tₙ]`
    Slice(start := 1, end := 0) {

    }

    ; Loops over the sequence until the end and returns an Array of all the results.
    ; @self `Seq[T]`
    ; @returns `Array[T]`
    ToArray() {
        arr := []
        for x in this {
            arr.Push(x)
        }
        return arr
    }

    ; Applies a projection on every item and returns an enum yielding the results.
    ; @param projection `(t₁, ⋯, tₙ) => R` A function to apply on each item.
    ; @self `Seq[T₁, ⋯, Tₙ]`
    ; @returns `Seq[R]`
    Map(projection) {
        return zOperatorEnumerable(this, zMappingEnumerator.Operator(projection))
    }

    ; Returns a seq with a single output variable that's an array of the output variables of `this`.
    ; @self `Seq[T₁, ⋯, Tₙ]`
    ; @returns `Seq[[T₁, ⋯, Tₙ]]`
    Collect() {

    }

    ; Takes a Seq with `n` output variables and returns a seq with `m` output variables
    ; by calling `distributor(e₁, ⋯, eₙ)` on each output.
    ; @param distributor `(R₁, ⋯,   tₙ) => [s₁, ⋯, sₘ]` A function that distributes the outputs of `this`
    ; differently.
    ; @self `Seq[T₁, ⋯, Tₙ]`
    ; @returns `Seq[S₁, ⋯, Sₘ]`
    DistributeMap(distributor) {

    }

    ; Takes a seq with `n` output variables and projects each set of outputs into an enumerable,
    ; with all the enumerables being combined for the final result.
    ; @param projection `(t₁, ⋯, tₙ) => Enum[S]`
    ; @self `Seq[T₁, ⋯, Tₙ]`
    ; @returns `Seq[S]`
    FlatMap(projection) {

    }

    ; Joins the corresponding outputs of `this` with all of `others`, returning a seq with many outputs.
    Zip(others*) {

    }

    ; Takes a seq with many output variables and returns an array of seqs each with a single output variable.
    ; @self `Seq[T₁, ⋯, Tₙ]`
    ; @returns `[Seq[T₁], ⋯, Seq[Tₙ]]`
    Unzip() {

    }

    ; Returns a seq consisting of the outputs of `this`, until `predicate(⋯outputs)` returns False.
    ; @param predicate `(T₁, ⋯, Tₙ) => Bool` A predicate to fullfill.
    ; @self `Seq[T₁, ⋯, Tₙ]`
    ; @returns Seq[T₁, ⋯, Tₙ]`
    TakeWhile(predicate) {

    }

    ; Skips items in the seq until `predicate` returns False.
    ; @param predicate `(T₁, ⋯, Tₙ) => Bool` A predicate to fulfill.
    ; @self `Seq[T₁, ⋯, Tₙ]`
    ; @returns `Seq[T₁, ⋯, Tₙ]`
    SkipWhile(predicate) {

    }
    
    ; @param reducer `(acc, cur₁, cur₂, ...) => acc` the reducer.
    ; @param initial An initial value. 
    Reduce(reducer, initial) {

    }

    ; Returns True if all the elements of the Seq fulfill `predicate`.
    ; @param predicate `(in₁, in₂, ...) => Bool` A predicate to fulfill.
    Every(predicate) {

    }

    ; Returns True if one of the elements in the Seq fulfills `predicate`.
    ; @param predicate `(in₁, in₂, ...) => Bool` A predicate to fulfill.
    Some(predicate) {

    }

    ; Returns the first item in the Seq that matches `predicate`, or `default` if no such item exists.
    ; @param predicate `(in₁, in₂, ...) => Bool` A predicate to fulfill.
    Find(predicate, default := unset) {

    }

    ; Returns a Seq that will expect to have `count` input variables.
    Outs(count) {

    }
}

class zWrappingEnumerable extends zEnumerableBase {
    __New(iter) {
        this._iter := iter
    }

    __Enum(count) {
        return this._iter
    }
}

class zOperatorEnumerable extends zEnumerableBase {
    __New(input, operator) {  
        this._input := input
        this._operator := operator 
    }

    __Enum(count) {
        return this._operator.Call(this._input, count)
    }
}

zIter(enumerable) {
    if HasMethod(enumerable, "__Enum") {
        return zOperatorEnumerable(enumerable, (input, count) => input.__Enum(count))
    }
    return zWrappingEnumerable(enumerable)
}


