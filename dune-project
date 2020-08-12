(lang dune 2.6)

(name ppx_yaml)

(generate_opam_files true)

(source
 (github patricoferris/ppx_yaml))

(license ISC)

(authors "Patrick Ferris")

(maintainers "pf341@patricoferris.com")

(package
 (name ppx_yaml)
 (synopsis "Yaml PPX Rewriter")
 (description "Build Yaml values from OCaml values")
 (depends
  (alcotest :with-test)
  (core :with-test)
  (ezjsonm :with-test)
  (ocaml
   (>= 4.08.1))
  ppxlib
  yaml))

(using mdx 0.1)
