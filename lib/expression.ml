open Ppxlib

let string ~loc s = [%expr `String [%e Ast_builder.Default.estring ~loc s]]

let float ~loc f = [%expr `Float [%e Ast_builder.Default.efloat ~loc f]]

let bool ~loc b = [%expr `Bool [%e Ast_builder.Default.ebool ~loc b]]

let a ~loc vlst = [%expr `A [%e Ast_builder.Default.elist ~loc vlst]]

let o ~loc alst = [%expr `O [%e Ast_builder.Default.elist ~loc alst]]

let unsupported_expression ~loc =
  Location.raise_errorf ~loc "ppx_yaml: unsupported expression"

let unsupported_record_field ~loc =
  Location.raise_errorf ~loc "ppx_yaml: unsupported record field"

let rec expand ~loc ~path expr =
  match expr with
  | [%expr true] -> bool ~loc true
  | [%expr false] -> bool ~loc false
  | { pexp_desc = Pexp_constant (Pconst_string (s, None)); _ } -> string ~loc s
  | { pexp_desc = Pexp_constant (Pconst_integer (i, None)); _ } ->
      let f = string_of_float (float_of_int (int_of_string i)) in
      float ~loc f
  | { pexp_desc = Pexp_constant (Pconst_float (f, None)); _ } -> float ~loc f
  | [%expr []] -> a ~loc []
  | [%expr [%e? _] :: [%e? _]] -> a ~loc (expand_list ~loc ~path expr)
  | { pexp_desc = Pexp_record (l, None); _ } -> expand_record ~loc ~path l
  | _ -> unsupported_expression ~loc:expr.pexp_loc

and expand_list ~loc ~path = function
  | [%expr []] -> []
  | [%expr [%e? hd] :: [%e? tl]] ->
      let hd = expand ~loc ~path hd in
      let tl = expand_list ~loc ~path tl in
      hd :: tl
  | _ -> assert false

and expand_record ~loc ~path l =
  let field = function
    | { txt = Lident s; _ } -> Ast_builder.Default.estring ~loc s
    | _ -> unsupported_record_field ~loc
  in
  let value v = [%expr [%e expand ~loc ~path v]] in
  let map lst =
    List.map (fun (f, v) -> [%expr [%e field f], [%e value v]]) lst
  in
  o ~loc (map l)
