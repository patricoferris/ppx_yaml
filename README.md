# Ppx_yaml -- OCaml types to YAML types
----

This ppx is based on [ppx_yojson](https://github.com/NathanReb/ppx_yojson).

This is a small ppx rewriter that lets you convert your OCaml types to [yaml](https://github.com/avsm/ocaml-yaml) ones. 

~~~ocaml
# #require "yaml,ppx_yaml"
# type db = { users : person list } and person = {name : string; age: int }
type db = { users : person list; }
and person = { name : string; age : int; }
# let yaml : Yaml.value = [%yaml {users = [{name = "Alice"; age = 30}; {name = "Bob"; age = 31}]}]
val yaml : Yaml.value =
  `O
    [("users",
      `A
        [`O [("name", `String "Alice"); ("age", `Float 30.)];
         `O [("name", `String "Bob"); ("age", `Float 31.)]])]
~~~

Because of the careful construction of `ocaml-yaml` to match the types of [`ezjsonm`](https://github.com/mirage/ezjsonm), you should be able to use that too. 

~~~ocaml
# #require "ezjsonm,ppx_yaml"
# type db = { users : person list } and person = {name : string; age: int }
type db = { users : person list; }
and person = { name : string; age : int; }
# let yaml : Ezjsonm.value = [%yaml {users = [{name = "Alice"; age = 30}; {name = "Bob"; age = 31}]}]
val yaml : Ezjsonm.value =
  `O
    [("users",
      `A
        [`O [("name", `String "Alice"); ("age", `Float 30.)];
         `O [("name", `String "Bob"); ("age", `Float 31.)]])]
~~~
