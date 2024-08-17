# Remember to commit

Nix flakes will refuse to use a flake file that isn't tracked
by version control when in a git repo.

In itself this is fine, but when you first add a `flake.nix` the
error is truly awful, you'll see something along the lines of
```
error: getting status of '/nix/store/rib8wshq9fb2953jz9xd2v3nk29qnqp8-source/ch1/flake.nix': No such file or directory
```
with no hints whatsoever that the problem is just git integration.

# Finding old nixpkgs

If you are trying to nixify an old repository, it's likely you'll
need an old pin of nixpkgs.

It's actually not trivial to find a listing of the old lts releases,
but you can poke around the releases page at
https://releases.nixos.org/?prefix=nixpkgs/
to find them.

# How a flake is organized, how to relate it to flake commands

Nix commands target different parts of a config.

- The nix commands generally look for `packages.<system>` subkeys:
  - For example `nix build` and `nix build .#some-key` will typically
  - Look for `packages.<system>.{default,some-key}` and try to build it
    - Note that the name inside the flake doesn't necessarily have any
      relationship to the name of artifacts build (e.g. we could assign
      `thing1.thing1` to `pkgs.ripgrep`, the result will be `bin/rg`.
  - I think this is actually a simplification; it try `{default,some-key}`
    first, which allows you to specify not-system-dependent stuff
