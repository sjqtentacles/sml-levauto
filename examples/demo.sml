(* demo.sml - Levenshtein / Damerau-Levenshtein edit distance, similarity,
   and fuzzy dictionary search. Deterministic: identical output on every run
   and both compilers. *)

structure L = LevAuto

fun fmtR r = Real.fmt (StringCvt.FIX (SOME 4)) (if Real.== (r, 0.0) then 0.0 else r)

val dict = ["cat","bat","rat","car","bar","dog","log","fog","hat","mat"]

val () = print "Edit distance:\n"
val () = print ("  editDist \"kitten\" \"sitting\" = "
                ^ Int.toString (L.editDist "kitten" "sitting") ^ "\n")
val () = print ("  damerau  \"ab\" \"ba\"          = "
                ^ Int.toString (L.damerau "ab" "ba") ^ "  (vs plain editDist = "
                ^ Int.toString (L.editDist "ab" "ba") ^ ")\n")
val () = print ("  editDistUpTo 1 \"cat\" \"dog\"  = "
                ^ Int.toString (L.editDistUpTo 1 "cat" "dog") ^ "  (capped at k+1)\n")

val () = print "\nWithin a distance threshold:\n"
val () = print ("  within \"cat\" \"bat\" 1 = " ^ Bool.toString (L.within "cat" "bat" 1) ^ "\n")
val () = print ("  within \"cat\" \"dog\" 1 = " ^ Bool.toString (L.within "cat" "dog" 1) ^ "\n")

val () = print "\nNormalized similarity:\n"
val () = print ("  similarity \"cat\" \"cat\" = " ^ fmtR (L.similarity "cat" "cat") ^ "\n")
val () = print ("  similarity \"cat\" \"bat\" = " ^ fmtR (L.similarity "cat" "bat") ^ "\n")
val () = print ("  similarity \"abc\" \"xyz\" = " ^ fmtR (L.similarity "abc" "xyz") ^ "\n")

val () = print "\nFuzzy dictionary search, dict = ["
val () = print (String.concatWith "," dict ^ "], query \"cat\", k=2:\n")
val () = print ("  search      -> [" ^ String.concatWith "," (L.search dict "cat" 2) ^ "]\n")
val ranked = L.searchRanked dict "cat" 2
val () = print "  searchRanked (word:dist), sorted:\n"
val () = print ("    "
                ^ String.concatWith ", "
                    (List.map (fn (w, d) => w ^ ":" ^ Int.toString d) ranked)
                ^ "\n")

val () = print "\nNearest match:\n"
val () = case L.nearest dict "kat" of
  NONE => print "  nearest \"kat\" -> none\n"
| SOME (w, d) => print ("  nearest \"kat\" -> " ^ w ^ " (distance " ^ Int.toString d ^ ")\n")
val () = case L.nearest [] "cat" of
  NONE => print "  nearest \"cat\" in [] -> none\n"
| SOME (w, d) => print ("  nearest \"cat\" in [] -> " ^ w ^ " (distance " ^ Int.toString d ^ ")\n")
