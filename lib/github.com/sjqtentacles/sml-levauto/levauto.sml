structure LevAuto :> LEVAUTO =
struct
  (* DP Levenshtein: O(m*n) time and space *)
  fun editDist s t =
    let
      val m = String.size s
      val n = String.size t
      val dp = Array.array ((m + 1) * (n + 1), 0)
      fun idx i j = i * (n + 1) + j
      val () = List.app (fn i => Array.update (dp, idx i 0, i)) (List.tabulate (m + 1, fn i => i))
      val () = List.app (fn j => Array.update (dp, idx 0 j, j)) (List.tabulate (n + 1, fn j => j))
      val () =
        List.app (fn i =>
          List.app (fn j =>
            let
              val cost = if String.sub (s, i - 1) = String.sub (t, j - 1) then 0 else 1
              val del = Array.sub (dp, idx (i - 1) j) + 1
              val ins = Array.sub (dp, idx i (j - 1)) + 1
              val sub = Array.sub (dp, idx (i - 1) (j - 1)) + cost
            in
              Array.update (dp, idx i j, Int.min (del, Int.min (ins, sub)))
            end)
          (List.tabulate (n, fn j => j + 1)))
        (List.tabulate (m, fn i => i + 1))
    in
      Array.sub (dp, idx m n)
    end

  fun within pat text k = editDist pat text <= k

  (* Find all words in dict within edit distance k of query *)
  fun search dict query k =
    List.filter (fn word => editDist query word <= k) dict
end
