This repository contains OPAM package definitions for various C
Libraries intended for use with the official
[OPAM repository](https://opam.ocaml.org) and is used by the default
of [OPAM](https://opam.ocaml.org/) on native Windows.

## How to Contribute

You are welcome to clone this repository and send us pull
requests. You can find more documentation and useful work-flows at
[https://opam.ocaml.org](https://opam.ocaml.org/).

The following basic guidelines apply to this repository:

 - Package names must begin `win32-`
 - Packages should wherever possible support both the
   [Mingw-w64](http://mingw-w64.org) and Microsoft C Compiler (i.e.
   Visual Studio) for both 32 and 64-bit variants.
 - The `available` field in `opam` files must always include
   `os = "win32"` and should only restrict `libc` and `cc` for actual
   limitations (i.e. `libc != "cl"` should only be used if there's a
   fundamental reason that the package can never be compiled with the
   Microsoft C Compiler, not simply that the build system and/or
   package don't yet support it)

## License

All the metadata contained in this repository are licensed under the
[CC0 1.0 Universal](http://creativecommons.org/publicdomain/zero/1.0/)
license.

Moreover, as the collection of the metadata in this repository is
technically a "Database" -- which is subject to a "sui generis" right
in Europe -- we would like to stress that even the *collection* of
the metadata contained in opam-repository is licensed under CC0 and
thus the simple act of cloning opam-repository is perfectly legal.
