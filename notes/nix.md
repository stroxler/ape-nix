# Viewing flakes

The main unit of nix code in the new world is a flake. You can
see a flake at a glance with `nix flake show`.

But this only shows some standard information by default, when
you're dealing with frameworks like home-manager or nix-darwin
that use custom output keys, you may not be able to see them
very clearly.

For that, you can use
```
nix repl --expr '{flake = builtins.getFlake "path:'$(pwd)'"; }
```
to get a nix repl session where `flake` is bound to the output
of the current directory, as a flake. You can then use normal
nix (with tab completion!) to understand the structure of the
flake.
