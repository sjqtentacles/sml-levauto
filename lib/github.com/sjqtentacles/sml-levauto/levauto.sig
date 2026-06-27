signature LEVAUTO =
sig
  (* Levenshtein edit distance (insert/delete/substitute), O(m*n). *)
  val editDist : string -> string -> int

  (* Optimal-string-alignment Damerau-Levenshtein distance, which additionally
     counts a swap of two adjacent characters as a single edit (restricted: a
     substring is not edited more than once). *)
  val damerau : string -> string -> int

  (* Levenshtein distance capped at `k`: returns min(editDist a b, k+1), so a
     result <= k means "within k" and k+1 means "further than k". Uses a banded
     DP that abandons rows once every cell exceeds k, so it is cheap for small
     k. *)
  val editDistUpTo : int -> string -> string -> int

  (* Within edit distance `k` (uses the bounded distance). *)
  val within : string -> string -> int -> bool

  (* Normalized similarity in [0,1]: 1 - editDist / max(|a|,|b|); two empty
     strings are defined as similarity 1.0. *)
  val similarity : string -> string -> real

  (* All dictionary words within edit distance `k` of the query (input order). *)
  val search : string list -> string -> int -> string list

  (* All dictionary words within `k`, paired with their distance and sorted by
     distance ascending (ties keep input order, a stable sort). *)
  val searchRanked : string list -> string -> int -> (string * int) list

  (* The single closest dictionary word to the query, with its distance, or
     NONE if the dictionary is empty. Ties resolve to the earliest word. *)
  val nearest : string list -> string -> (string * int) option
end
