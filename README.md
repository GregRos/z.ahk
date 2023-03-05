# zee.ahk

This is `zee.ahk`, a comprehensive utility library for AHK v2. `zee` aims to provide a lot of the functionality found in other languages, such as JavaScript, and Python. It gives you lots of tools to work with objects, arrays, collections, and strings.

Every function the library introduces starts with lowercase `z` so it appears last in alphabetical listings, and in a single group. This makes the globals it sets up a lot less annoying. Internal members start with the ugly sequence `zz_`.

`zee` is inspired by many, many libraries including `lodash`, `jest`, and more, but tries to embrace many of the conventions that make AHK the language it is.

`zee` is tested automatically and is fully documented. It even has usage examples. This is the first release, though, so there will probably be bugs.

`zee` is a massive undertaking, way too big for a single person to complete. Any contributions you can make will be appreciated. I’d particularly love to see:

1. A `Path` class like in `Python`.
2. A `RegEx` class.
3. Classes for working with the registry.
4. Binary readers/writers.
5. JSON implementations or other formats.

Existing areas that could be improved:

1. The sorting algorithm. The best thing you can say about it is that it works.
2. The text templating system can be more powerful.
3. Text formatting could render to RTF.
4. 