# My nix-based setup: `ape-nix`

You can see how I set up the config by running
```bash
bash show-bootstrap-commands.sh
```
which prints out the steps to bootstrap a system (some steps are only run once,
like setting up nix and homebrew; some should be rerun later as config changes
like the `nix-darwin` and `home-manager` setups).


## Existing configurations to port

I have earlier bootstrapping setups at `ape_osx` and `dotconfar`.

The things I still need to port:
- doom emacs and spacemacs installs from `ape_osx`
- iterm2 colors from `ape_osx`
- basic neovim setup from `ape_osx`
- emacs config from `dotconfar`, including:
  - runemacs (maybe remake it using straight.el?)
  - doom config
  - .spacemacs
  - chemacs setup

## Backlog of things to do

Shell:
- I started working on a shell commands file in home-manager/dotfiles
  but I haven't hooked it up to nix yet.

Vim:
- Set up some simple neovim configs:
  - A bare-bones config to use as my default
  - A slightly fancier but simple setup using language servers
- Set up some more elaborate neovim configs:
  - A LazyVim setup
  - Some kind of lazy.vim from scratch
    - Figure out how to use lazy.lock!!
  - Try the aniseed from scratch demo
- Make some nixified vims:
  - Maybe look at zmre's simpler example first, then...
  - Figure out how pwnvim and pwnneovide work
  - Start making some of my own neovim setups?
- Learn some basic lua
  - Ideally code up a toy PL in lua to help me learn
  - It might be worth trying to use lua for interview prep someday
  - It might be interesting to try one of the game-scripting setups
  - It might be interesting to look at protoplug someday

Emacs:
- Go through some elisp resources
  - There are several great playlists / stand-alone videos on this
  - Ideally I should really try making some PL tools, lisp is great for this
- Play with some configs:
  - Make a bare-bones setup to use as an elisp playground
  - Review emacs-from-scratch, start reading some more
  - Start spending more time in doom
    - Use it for my local ocaml development
      - For local development, vscode has few real advantages
    - Read more about it, about how to customize things
  - Try out spacemacs again?

General editor:
- Learn to hook all editors up to direnv
  - Learn to use direnv with nix
- Learn to edit lisps
  - Paredit exists in both the vim and emacs ecosystems
  - There are quite a number of additional tools out there
    - I'm mostly looking for vim-oriented approaches
    - That said, I'd consider trying to use emacs-mode for lisp
