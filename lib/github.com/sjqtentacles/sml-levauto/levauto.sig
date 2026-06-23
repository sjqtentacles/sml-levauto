signature LEVAUTO =
sig
  val editDist : string -> string -> int
  val within   : string -> string -> int -> bool
  val search   : string list -> string -> int -> string list
end
