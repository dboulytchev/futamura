open Printf
    
(*
int p (int n, int k) {
  int r = 1;

  while (k) {
    r *= k % 2 ? n : 1;
    n *= n;
    k /= 2;
  }

  return r;
}
*)

let genpow k =
  let b = Buffer.create 256 in
  Buffer.add_string b (sprintf "int pow_%d (int n) {\n" k);
  Buffer.add_string b (sprintf "  int r = 1;\n\n");
  let rec inner k =
    if k > 0 then (
      if k mod 2 = 1 then (Buffer.add_string b "  r *= n;\n");
      if k / 2 > 0 then (Buffer.add_string b "  n *= n;\n");
      inner (k / 2)
    )
  in
  inner k;
  Buffer.add_string b "\n  return r;\n}\n";
  Buffer.contents b

let _ =
  let k = int_of_string @@ read_line () in
  printf "# include <stdio.h>\n\n";    
  printf "%s\n" (genpow k);
  printf "\nint main (int argc, char *argv[]) {\n";
  printf "  int n;\n\n";
  printf "  scanf  (\"%%d\", &n);\n";
  printf "  printf (\"%%d\", pow_%d (n));\n" k; 
  printf "}\n"
    
