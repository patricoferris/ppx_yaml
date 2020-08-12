let yaml = Alcotest.testable Yaml.pp Yaml.equal

let test_primitives () =
  let correct_str = `String "hello world" in
  let test_str = [%yaml "hello world"] in
  let correct_float = `Float 1.234 in
  let test_float = [%yaml 1.234] in
  let correct_float_int = `Float 1. in
  let test_float_int = [%yaml 1] in
  let correct_bool = `Bool true in
  let test_bool = [%yaml true] in
  Alcotest.check yaml "same string" correct_str test_str;
  Alcotest.check yaml "same float" correct_float test_float;
  Alcotest.check yaml "same float from int" correct_float_int test_float_int;
  Alcotest.check yaml "same string" correct_bool test_bool

let test_records () =
  let correct = `O [ ("hello", `String "World"); ("pi", `Float 3.14) ] in
  let test = [%yaml { hello = "World"; pi = 3.14 }] in
  Alcotest.check yaml "same object" correct test

let test_lists () =
  let correct = `A [ `Float 1.; `Float 2.; `Float 3.; `Float 4. ] in
  let test = [%yaml [ 1; 2; 3; 4 ]] in
  Alcotest.check yaml "same list" correct test

type github_workflow = { name : string; on : string list; jobs : job }

and job = { run : run }

and run = {
  name : string;
  runs_on : string;
  strategy : strategy;
  steps : step list;
}

and strategy = { matrix : matrix }

and matrix = { operating_system : string list; ocaml_version : string list }

and step = { uses : string }

let handle_bos = function Ok s -> s | _ -> failwith "Failed to read file"

(* Note that this uses underscores not hyphens so is an invalid workflow file *)
let test_github_workflow () =
  let correct =
    Yaml.of_string_exn (handle_bos (Bos.OS.File.read (Fpath.v "./test.yml")))
  in
  let test =
    [%yaml
      {
        name = "Yaml";
        on = [ "push" ];
        jobs =
          {
            run =
              {
                name = "Tests";
                runs_on = "${{ matrix.operating-system }}";
                strategy =
                  {
                    matrix =
                      {
                        operating_system =
                          [ "macos-latest"; "ubuntu-latest"; "windows-latest" ];
                        ocaml_version = [ "4.08.1" ];
                      };
                  };
                steps = [ { uses = "avsm/setup-ocaml@v1.1" } ];
              };
          };
      }]
  in
  Alcotest.check yaml "same github workflow" correct test

let tests : unit Alcotest.test_case list =
  [
    ("test_primitives", `Quick, test_primitives);
    ("test_records", `Quick, test_records);
    ("test_lists", `Quick, test_lists);
    ("test_workflow", `Quick, test_github_workflow);
  ]

let () = Alcotest.run "PPX Yaml" [ ("ppx", tests) ]
