Dotfiles 2021
---

Dotfile bankruptcy after a couple decades of cruft.

Lightweight mode, for servers:

```bash
wget -q -O- https://git.io/JY0Yx | bash -x
```

```bash
curl -Ls https://git.io/JY0Yx | bash -x
```

Heavyweight mode, for bastions and development workstations:

```bash
# TODO
```

Layout
---

DOTDIR specifies the location of the dotfiles repo clone.  It's intended to be
at ~/.dot for servers which have a clone.  ~/dotfiles is intended for
workstations which sync all dotfiles using a tool like syncthing.

All installations have `~/.dotenv` which specifies the dotfile location and is
written during initial installation.  zshrc sources ~/.dotenv at login.  Shim
scripts source ~/.dotenv to find where asdf is installed, which is used to
provide a single context for neovim providers.

```bash
# ~/.dotenv
export DOTDIR="${HOME}/.dot"
```

The `${DOTDIR}/bin` directory is expected to be inserted at the front of the
path and has a small number of shim commands.  The primary use case is a `nvim`
shim for neovim.

The `${DOTDIR}/env` directory contains tools (Python, Node, NeoVim) installed
by the setup process, nothing in this directory should be committed to the
repository and the directory should be organized by OS and Architecture to
enable syncronization across devices.

Neovim is installed by unpacking the appimage for the correct platform and
architecture.

Shim scripts set the exact context needed.  For example, neovim:

```bash
#! /bin/bash
# Neovim shim at ${DOTDIR}/bin/nvim
source "${HOME}/.dotdir" # Set DOTDIR
# Node context for neovim
: "${UNAME:=$(uname)}"
: "${ARCH:=$(uname -m)}"
export ASDF_DATA_DIR="${DOTDIR}/env/${UNAME}/${ARCH}/asdf"
source "${ASDF_DATA_DIR}/asdf.sh"
# Python context for neovim
source "${DOTDIR}/env/${UNAME}/${ARCH}/python3/bin/activate"
# Finally, with Python and Node in the path, launch neovim:
if [[ -x "${DOTDIR}/env/${UNAME}/${ARCH}/squashfs-root/usr/bin/nvim" ]]; then
  # Most linux systems will use appimage to get the latest nvim
  exec "${DOTDIR}/env/${UNAME}/${ARCH}/squashfs-root/usr/bin/nvim" "$@"
else
  # macOS will use brew to get nvim
  exec nvim "$@"
fi
```
