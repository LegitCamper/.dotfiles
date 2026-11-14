My personal dot files managed by stow.

Mantle clipboard history needs host `wl-paste`, `wl-copy`, and `cliphist`.
Run `just clipboard-setup` from an environment with Go to install a static
`cliphist` in `~/.local/bin` (shared with the host). Mantle owns the text and
image collectors; opening clipboard history retries dependency discovery.

Bar sides scroll horizontally when crowded; time and date stay centered.
Network and Bluetooth buttons open the existing system settings tools.

Checks: `lua tests/bar.lua`, `bash tests/clipboard-copy.sh`, and
`bash tests/mantle-check.sh`. Run shell integration checks on the desktop host
or from a toolbox with `flatpak-spawn --host` available.
