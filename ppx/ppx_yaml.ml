open Ppxlib

let name = "yaml"

let expr_rule =
  let expr_ext =
    Extension.declare name Extension.Context.expression
      Ast_pattern.(single_expr_payload __)
      Ppx_yaml_lib.Expression.expand
  in
  Ppxlib.Context_free.Rule.extension expr_ext

let () = Ppxlib.Driver.register_transformation ~rules:[ expr_rule ] name
