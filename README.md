# My nix-based setup: `ape-nix`

As of today, I use a combination of ad-hoc docs to help me initialize a
computer and my `dotconfar` to configure most of it (with a number of things,
including emacs and vim, not really controlled by `dotconfar`).

I'm trying to move away from this toward a nix-based setup for both
initializing and configuring my system; at this stage `ape-nix` is an
experimental project to do so.

For now, I'm using only `home-manager`; I've seen that `nix-darwin` could be
really useful because there are many gui settings I care about too, but my work
computers are Centos-based so I want to make sure I learn the basic home
manager flow, which should apply to non-nixos distros, before I wrap
home-manager in nix-darwin.

Also I'm not yet attempting to generalize over multiple machines; at this point
the flake is only usable on my new Apple Silicon macbook. I'll need to do more
work before I can use it on centos work machines or my older intel-based
laptop.

# How to use nix and home-manager

I assume you're using flake-enabled nix. This happens by default if you use
the Determinate Nix installer, otherwise you'll have to download the flakes
tool and enable it in your nix configuration.

To bootstrap this setup on a suitable machine (at the moment this first stage
would work on any Apple Silicon macbook), just run `nix build .`, which will
build the `defaultPackage.${system}` for the current system.

At that point, you will have a `results/` directory, and you should have
`results/bin/home-manager`.

Next, you can run
```
result/bin/home-manager --flake .#macos-silicon switch
```
to actually run home manager configured for `aarch64-darwin`.

Note that the namespacing of the home configuration to point at isn't super
obvious; the actual key in the flake value is
`homeConfigurations.macos-silicon`, but home manager seems to inject the
`homeConfigurations` on its own so we give it the path `.#macos-silicon`.

# What's actually going on here?

We need to construct an attribute set that has:
- a key `defaultPackage.${system}` for the current system, in order
  to get the appropriate home-manager executable.
- a key `homeConfigurations.<config-name>` for whatever config we want to
  build; becuase of the nature of nixpkgs this will have to be at least as fine
  grained as `${system}` because you have to pick a system appropriate `pkgs`
  in order to resolve anything at all. It could be as fine-grained
  as you want (e.g. a config per machine).
  - Home manager has some defaults for how to choose the config-name,
    for example it will try using the username and host to guess, but
    I actually prefer the approach of not using a "magic" name and
    explicitly setting the name.
  - For the moment I'm tentatively expecting my configs to be at the
    same granularity as system, but it's easy to see how I might want finer
    groupings (e.g. if I eventually want divergent work vs personal setups
    then I could separate them).

How I actually create that is currently manual because I want to use the nix
language rather than magic libraries at least at first:
 - my whole config is constructed inside of a `foldl' recursiveUpdate` to
   merge a bunch of smaller attribute sets, which will eventually allow me
   to parametrize multiple configs based on the system (and potentially anything
   else).
 - for the moment, I'm only actually defining a `macos-silicon`, but I have
   the plubming in place to define other configurations, and I prove that the
   plumbing works by defining a defaultPackage for x86_64-darwin. You can see
   that this works by running `nix flake show .`.

# What goes into a home-manager configuration?

It appears that at the minimum you must pass it an attrset containing `pkgs`
and `modules`. The former is a handle to nixpkgs for one system; the latter is
a list of home-manager modules.

A home-manager module can be either an attrset or a function that takes
an attrset provided by home-manager (which will include a few things, one of
them `pkgs`) and returns an attrset.

The contents of the attrset from a module is any collection of keys as described
in [the manual](https://nix-community.github.io/home-manager/options.xhtml).

My preference for the moment is to make my modules attrsets already rather than
functions, the reason being that this allows me to do more work in nix myself
rather than relying on magic plumbing from home-manager; for example I do need
`pkgs`, but I can pass it down directly rather than handing it off java-beans
style.

I prefer this for two reasons:
- It makes control flow more explicit, which is nice while I'm getting used
  to nix.
- It makes it possible for me to pass extra keys that home-manager may not know
  about, for example if I need to have conditional logic based on `system` or
  some other configuration-specific information then I can just pass it down
  myself using the nix language, without worrying about the "home-manager" way
  of doing it.
  - This may come at the price of uglier syntax, but I'm basically choosing to
    use a programming language as my abstraction instead of a framework, which
    in my experience is a better bet (because languages are composable and
    usually easy to document in near-perfect detail, frameworks are not).

