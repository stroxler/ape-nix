Nix commands target different parts of a config.

- The nix commands generally look for `packages.<system>` subkeys:
  - For example `nix build` and `nix build .#some-key` will typically
  - Look for `packages.<system>.{default,some-key}` and try to build it
    - Note that the name inside the flake doesn't necessarily have any
      relationship to the name of artifacts build (e.g. we could assign
      `thing1.thing1` to `pkgs.ripgrep`, the result will be `bin/rg`.
  - I think this is actually a simplification; it try `{default,some-key}`
    first, which allows you to specify not-system-dependent stuff
