structure Tests = struct open Harness structure L = LevAuto
fun run () = let
  val () = section "edit distance (DP)"
  val () = checkInt "same word"   (0, L.editDist "cat" "cat")
  val () = checkInt "one subst"   (1, L.editDist "cat" "bat")
  val () = checkInt "one delete"  (1, L.editDist "cat" "ca")
  val () = checkInt "one insert"  (1, L.editDist "ca" "cat")
  val () = checkInt "kitten/sittting" (3, L.editDist "kitten" "sitting")

  val () = section "within k"
  val () = checkBool "k=1 cat->bat true"   (true,  L.within "cat" "bat" 1)
  val () = checkBool "k=1 cat->dog false"  (false, L.within "cat" "dog" 1)
  val () = checkBool "k=2 kitten->sitten"  (true,  L.within "kitten" "sitten" 2)

  (* dictionary search: 10 words, query within edit distance 2 *)
  val () = section "dictionary search"
  val dict = ["cat","bat","rat","car","bar","dog","log","fog","hat","mat"]
  (* "cat" within dist 2: "cat"(0), "bat"(1), "rat"(1), "car"(1), "hat"(1), "mat"(1), "bar"(2) *)
  val hits = L.search dict "cat" 2
  val () = checkBool "cat in hits"  (true,  List.exists (fn w => w = "cat") hits)
  val () = checkBool "bat in hits"  (true,  List.exists (fn w => w = "bat") hits)
  val () = checkBool "dog not k=1"  (false, L.within "cat" "dog" 1)
  val () = checkInt  "search k=1 count" (6, List.length (L.search dict "cat" 1))

  val () = section "damerau (transposition = 1 edit)"
  val () = checkInt "ab->ba is 1 (damerau)" (1, L.damerau "ab" "ba")
  val () = checkInt "ab->ba is 2 (plain lev)" (2, L.editDist "ab" "ba")
  val () = checkInt "ca->abc damerau" (3, L.damerau "ca" "abc")
  val () = checkInt "same word damerau" (0, L.damerau "cat" "cat")
  val () = checkInt "kitten/sitting damerau" (3, L.damerau "kitten" "sitting")

  val () = section "editDistUpTo (bounded, returns k+1 when over)"
  val () = checkInt "exact when within" (1, L.editDistUpTo 3 "cat" "bat")
  val () = checkInt "caps at k+1 when over" (2, L.editDistUpTo 1 "cat" "dog")
  val () = checkInt "length diff > k -> k+1" (3, L.editDistUpTo 2 "a" "abcde")
  val () = checkInt "0 when equal" (0, L.editDistUpTo 0 "cat" "cat")
  val () = checkBool "within via bounded" (true, L.within "kitten" "sitting" 3)
  val () = checkBool "not within via bounded" (false, L.within "kitten" "sitting" 2)

  val () = section "similarity (normalized)"
  val () = checkReal "identical = 1.0" (1.0, L.similarity "cat" "cat")
  val () = checkReal "both empty = 1.0" (1.0, L.similarity "" "")
  (* cat vs bat: editDist 1, max len 3 -> 1 - 1/3 = 0.6667 *)
  val () = checkRealTol 1E~9 "cat/bat" (1.0 - 1.0/3.0, L.similarity "cat" "bat")
  val () = checkReal "no overlap len-equal -> 0" (0.0, L.similarity "abc" "xyz")

  val () = section "searchRanked (sorted by distance)"
  val ranked = L.searchRanked dict "cat" 2
  (* distances: cat 0; bat/rat/car/hat/mat 1; bar 2 *)
  val () = checkInt "ranked count" (7, List.length ranked)
  val () = checkString "closest is cat" ("cat", #1 (hd ranked))
  val () = checkInt "closest dist 0" (0, #2 (hd ranked))
  val () = checkInt "last dist is 2" (2, #2 (List.last ranked))
  val () = checkString "last is bar" ("bar", #1 (List.last ranked))
  (* stable: among distance-1 words, input order bat,rat,car,hat,mat preserved *)
  val d1 = List.map #1 (List.filter (fn (_,d) => d = 1) ranked)
  val () = checkStringList "distance-1 order stable" (["bat","rat","car","hat","mat"], d1)

  val () = section "nearest"
  val () = checkBool "nearest of empty is NONE" (true, L.nearest [] "cat" = NONE)
  val () = checkBool "nearest cat -> cat/0"
             (true, L.nearest dict "cat" = SOME ("cat", 0))
  (* "caz": cat(1) is first at distance 1 *)
  val () = checkBool "nearest caz -> cat/1"
             (true, L.nearest dict "caz" = SOME ("cat", 1))
in Harness.run () end end
