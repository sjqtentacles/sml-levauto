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
in Harness.run () end end
