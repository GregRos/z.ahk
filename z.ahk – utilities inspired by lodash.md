## z.ahk – utilities inspired by lodash

Hey, you! This is `z.ahk`. It’s a cool library for abstract programming with objects. You should read this.

So I’m a developer and 



A utility library inspired by [lodash](https://lodash.com/), the most popular library in the JavaScript ecosystem. It’s similar to a standard library and has all kinds of abstract operations for working with strings, arrays, and objects.

It fills in some other voids:

* Optionally, enable a cool interactive prompt on unhandled exceptions.
* Includes a minimal test framework.



`z.ahk` can help you:

1. Manipulate objects, arrays, and maps.
2. Work with text.
3. (In future) work with basic Win32 APIs.
4. Debug your code using the Oops subsystem.
5. Write tests.

`z.ahk` is unit tested using its own testing framework, hopefully reducing bugs.

## Conventions

`z.ahk` has a very simple interface that consists entirely of functions. The functions are named based on the module and the operation they perform:

* `zObjPick({a: “hello”, b: "goodbye"}, “a”)` – `Obj` is short for object.
* `zArrOrderBy(array, x => x.orderingKey)` – `Arr` is short for array.

So if you want to find functions dealing with strings, you should type `zStr` and your IDE will complete it for you. `z.ahk` uses classes but they’re rarely public. Some modules have a default function that’s just the module name, such as `zArr(1, 2, 3)`. 

The library has some functions it uses internally, but that you shouldn’t call yourself. These start with `zz_`. 

# List of available functions



* Arrays
  * `zArr` – Given any number of arguments, will return them in an array. 
  * `zArrFrom` – Makes `self`, an iterable, into an array.
  * `zArrRepeat` – Makes an array of size `count` filled with `value`.
  * `zArrIndexOf` – Finds the first index where `value` appears in `self`.
  * `zArrHas` – Checks if `value` appears in `self`.
  * `zArrFilter` – Makes a new array made of the elements of `self` that satisfy `predicate`.
  * `zArrMap` – Makes a new array consisting of elements of `projection` applied to each element of `self`.
  * `zArrFind` – Returns the first element in `self` matching `predicate`.
  * `zArrExists` – True if `value` exists in `self`.
  * `zArrEvery` – True if every value in `self` fulfills `predicate`.
  * `zArrFlatMap` – Projects every element of `self` into an array using `projection`, and then concatenates all the arrays.
  * `zArrFlatten` – Makes a new array 

The convention

First, all of them start with `z`. Private functions (ones you shouldn’t use) start with `zz_`. 



* Every function this library introduces starts with `z`. For example `zArr(1, 2, 3)`
* The first part of the name is the module component.

* The names of all functions are composed of the module 







`z.ahk` will never 

`z.ahk` contains 



