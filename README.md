# sml-levauto

[![CI](https://github.com/sjqtentacles/sml-levauto/actions/workflows/ci.yml/badge.svg)](https://github.com/sjqtentacles/sml-levauto/actions/workflows/ci.yml)

Levenshtein / Damerau-Levenshtein edit distance and dictionary fuzzy search for
Standard ML. Provides O(mn) DP edit distance, a bounded early-abandoning
variant, a restricted Damerau distance (adjacent transpositions), normalized
similarity, and dictionary search that can rank results by distance.

## API sketch

```sml
(* Edit distance between two strings *)
LevAuto.editDist "kitten" "sitting"    (* 3 *)
LevAuto.editDist ""       "abc"        (* 3 *)

(* Damerau-Levenshtein counts an adjacent swap as one edit *)
LevAuto.damerau "ab" "ba"              (* 1  (editDist would be 2) *)

(* Bounded distance: exact when <= k, else k+1 (cheap for small k) *)
LevAuto.editDistUpTo 1 "cat" "dog"     (* 2  (capped: distance is 3) *)

(* Is the edit distance within a threshold? *)
LevAuto.within "cat" "car" 1           (* true  — 1 substitution *)

(* Normalized similarity in [0,1] *)
LevAuto.similarity "cat" "bat"         (* 0.6667 *)

(* Search a dictionary for all words within edit distance k of a query *)
val dict = ["cat", "car", "bat", "hat", "dog"]
LevAuto.search dict "cat" 1            (* ["cat","car","bat","hat"] (input order) *)

(* Ranked by distance (stable), or just the single closest word *)
LevAuto.searchRanked dict "cat" 1      (* [("cat",0),("car",1),("bat",1),("hat",1)] *)
LevAuto.nearest dict "caz"             (* SOME ("cat", 1) *)
```

## API

```sml
val editDist     : string -> string -> int
val damerau      : string -> string -> int
val editDistUpTo : int -> string -> string -> int
val within       : string -> string -> int -> bool
val similarity   : string -> string -> real
val search       : string list -> string -> int -> string list
val searchRanked : string list -> string -> int -> (string * int) list
val nearest      : string list -> string -> (string * int) option
```

## Example

`make example` builds and runs [`examples/demo.sml`](examples/demo.sml), which
walks through edit distance, Damerau transpositions, bounded distance,
normalized similarity, and fuzzy dictionary search/ranking/nearest-match
(output is byte-identical under MLton and Poly/ML):

```
Edit distance:
  editDist "kitten" "sitting" = 3
  damerau  "ab" "ba"          = 1  (vs plain editDist = 2)
  editDistUpTo 1 "cat" "dog"  = 2  (capped at k+1)

Within a distance threshold:
  within "cat" "bat" 1 = true
  within "cat" "dog" 1 = false

Normalized similarity:
  similarity "cat" "cat" = 1.0000
  similarity "cat" "bat" = 0.6667
  similarity "abc" "xyz" = 0.0000

Fuzzy dictionary search, dict = [cat,bat,rat,car,bar,dog,log,fog,hat,mat], query "cat", k=2:
  search      -> [cat,bat,rat,car,bar,hat,mat]
  searchRanked (word:dist), sorted:
    cat:0, bat:1, rat:1, car:1, hat:1, mat:1, bar:2

Nearest match:
  nearest "kat" -> cat (distance 1)
  nearest "cat" in [] -> none
```

## Known limitations

- **Linear scan**: `search`/`searchRanked` iterate the entire dictionary. The
  per-word cost is reduced by `editDistUpTo` (early abandonment for small `k`),
  but for very large dictionaries a BK-tree or precomputed index is still
  preferable.
- **Restricted Damerau (OSA)**: `damerau` is optimal-string-alignment distance
  (no substring edited twice); it is not the unrestricted Damerau-Levenshtein
  distance. See `sml-editdist` for `jaroWinkler` and friends.
- **No automaton**: true Levenshtein automata are not implemented; `editDistUpTo`
  uses a banded/abandoning DP rather than an NFA.
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
make example     # build + run the demo
make clean
```

## Project layout

```
sml.pkg
Makefile
lib/github.com/sjqtentacles/sml-levauto/
  levauto.sig     LEVAUTO signature
  levauto.sml     DP editDist/damerau, bounded editDistUpTo, ranked search
  levauto.mlb
test/
  test.sml        editDist, damerau, bounded distance, similarity, ranked search
```

## License

MIT. See [LICENSE](LICENSE).
