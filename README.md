# sml-levauto

[![CI](https://github.com/sjqtentacles/sml-levauto/actions/workflows/ci.yml/badge.svg)](https://github.com/sjqtentacles/sml-levauto/actions/workflows/ci.yml)

Levenshtein edit distance and dictionary fuzzy search for Standard ML.
Provides O(mn) DP edit distance and a linear dictionary scan for finding
all words within a given edit distance of a query.

## API sketch

```sml
(* Edit distance between two strings *)
LevAuto.editDist "kitten" "sitting"    (* 3 *)
LevAuto.editDist "abc"    "abc"        (* 0 *)
LevAuto.editDist ""       "abc"        (* 3 *)

(* Is the edit distance within a threshold? *)
LevAuto.within "cat" "car" 1           (* true  — 1 substitution *)
LevAuto.within "cat" "dog" 1           (* false — distance = 3 *)

(* Search a dictionary for all words within edit distance k of a query *)
val dict = ["cat", "car", "bat", "hat", "dog", "cats", "cast" (* ... *) ]
val hits : string list = LevAuto.search dict "cat" 1
(* ["cat", "car", "bat", "hat", "cats", "cast"] *)

(* Larger k for spelling correction *)
val hits2 : string list = LevAuto.search dict "recieve" 2
```

## API

```sml
val editDist : string -> string -> int
val within   : string -> string -> int -> bool
val search   : string list -> string -> int -> string list
```

## Known limitations

- **Linear scan**: `search` iterates the entire dictionary computing `editDist`
  for each word — O(|dict| × |query| × |word|). For large dictionaries
  (> 100 k words), use a BK-tree or precomputed index.
- **Levenshtein only**: does not implement Damerau–Levenshtein (transpositions).
  Use `sml-editdist` for `damerau` or `jaroWinkler`.
- **No automaton**: true Levenshtein automata (NFA states keyed on (position,
  error count)) are not implemented; each `search` call recomputes the full
  DP table per word.
- Operates on byte characters; multi-byte UTF-8 sequences count as multiple
  characters.

## Installing with smlpkg

```sh
smlpkg add github.com/sjqtentacles/sml-levauto
smlpkg sync
```

Reference from your `.mlb`:

```
lib/github.com/sjqtentacles/sml-levauto/levauto.mlb
```

## Building and testing

```sh
make test        # MLton
make test-poly   # Poly/ML
make all-tests   # both
make clean
```

## Project layout

```
sml.pkg
Makefile
lib/github.com/sjqtentacles/sml-levauto/
  levauto.sig     LEVAUTO signature
  levauto.sml     O(mn) DP editDist + search
  levauto.mlb
test/
  test.sml        editDist pairs, within, dictionary search tests
```

## License

MIT. See [LICENSE](LICENSE).
