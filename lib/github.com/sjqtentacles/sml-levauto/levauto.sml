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

  (* Optimal string alignment (restricted Damerau-Levenshtein). *)
  fun damerau s t =
    let
      val m = String.size s
      val n = String.size t
      val dp = Array.array ((m + 1) * (n + 1), 0)
      fun idx i j = i * (n + 1) + j
      fun get i j = Array.sub (dp, idx i j)
      fun set i j v = Array.update (dp, idx i j, v)
      val () = List.app (fn i => set i 0 i) (List.tabulate (m + 1, fn i => i))
      val () = List.app (fn j => set 0 j j) (List.tabulate (n + 1, fn j => j))
      val () =
        List.app (fn i =>
          List.app (fn j =>
            let
              val sc = String.sub (s, i - 1)
              val tc = String.sub (t, j - 1)
              val cost = if sc = tc then 0 else 1
              val base = Int.min (get (i-1) j + 1,
                          Int.min (get i (j-1) + 1, get (i-1) (j-1) + cost))
              val withSwap =
                if i > 1 andalso j > 1
                   andalso sc = String.sub (t, j - 2)
                   andalso String.sub (s, i - 2) = tc
                then Int.min (base, get (i-2) (j-2) + 1)
                else base
            in set i j withSwap end)
          (List.tabulate (n, fn j => j + 1)))
        (List.tabulate (m, fn i => i + 1))
    in get m n end

  (* Bounded Levenshtein with early abandonment: rolling two-row DP; if the
     minimum of a completed row exceeds k, no completion can be <= k, so we
     stop and return k+1. *)
  fun editDistUpTo k s t =
    if k < 0 then (if s = t then 0 else 1)  (* degenerate; treat like uncapped sign *)
    else
    let
      val m = String.size s
      val n = String.size t
      val cap = k + 1
      (* if the length difference alone exceeds k, distance > k *)
    in
      if Int.abs (m - n) > k then cap
      else
        let
          fun clamp v = Int.min (v, cap)
          val prev = Array.tabulate (n + 1, fn j => clamp j)
          fun rowMin a =
            Array.foldl (fn (x, acc) => Int.min (x, acc)) cap a
          fun step (i, prevRow) =
            if i > m then prevRow
            else
              let
                val cur = Array.array (n + 1, cap)
                val () = Array.update (cur, 0, clamp i)
                val () =
                  List.app (fn j =>
                    let
                      val cost = if String.sub (s, i-1) = String.sub (t, j-1) then 0 else 1
                      val del = Array.sub (prevRow, j) + 1
                      val ins = Array.sub (cur, j-1) + 1
                      val sub = Array.sub (prevRow, j-1) + cost
                      val v = Int.min (del, Int.min (ins, sub))
                    in Array.update (cur, j, clamp v) end)
                  (List.tabulate (n, fn j => j + 1))
              in
                if rowMin cur >= cap then cur   (* all entries saturated: abandon *)
                else step (i + 1, cur)
              end
          val finalRow = step (1, prev)
        in Array.sub (finalRow, n) end
    end

  fun within pat text k = editDistUpTo k pat text <= k

  fun similarity a b =
    let val m = String.size a val n = String.size b
        val mx = Int.max (m, n)
    in if mx = 0 then 1.0
       else 1.0 - real (editDist a b) / real mx
    end

  (* Find all words in dict within edit distance k of query (input order). *)
  fun search dict query k =
    List.filter (fn word => editDistUpTo k query word <= k) dict

  (* Stable insertion sort by the integer distance (ascending). *)
  fun sortByDist pairs =
    let fun ins (x as (_, dx), []) = [x]
          | ins (x as (_, dx), (y as (_, dy)) :: ys) =
              if dx <= dy then x :: y :: ys else y :: ins (x, ys)
    in List.foldr ins [] pairs end

  fun searchRanked dict query k =
    let val hits = List.foldr (fn (w, acc) =>
                     let val d = editDistUpTo k query w
                     in if d <= k then (w, d) :: acc else acc end) [] dict
    in sortByDist hits end

  fun nearest dict query =
    case dict of
        [] => NONE
      | w0 :: rest =>
          let
            fun go (best, bestD, []) = (best, bestD)
              | go (best, bestD, w :: ws) =
                  let val d = editDist query w
                  in if d < bestD then go (w, d, ws) else go (best, bestD, ws) end
            val (w, d) = go (w0, editDist query w0, rest)
          in SOME (w, d) end
end
