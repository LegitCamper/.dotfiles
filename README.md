My personal dot files managed by stow.

Mantle clipboard history needs host `wl-paste`, `wl-copy`, and `cliphist`.
Run `just clipboard-setup` from an environment with Go to install a static
`cliphist` in `~/.local/bin` (shared with the host). Mantle owns the text and
image collectors; opening clipboard history retries dependency discovery.

Bar sides scroll horizontally when crowded; time and date stay centered.
Network and Bluetooth buttons open the existing system settings tools.

Wallpaper opens a searchable thumbnail picker for `~/.config/Wallpapers`
(`$XDG_CONFIG_HOME/Wallpapers` when set). Click a picture or use arrows and
Enter; Escape or clicking outside closes it. One wallpaper covers all monitors,
with a short crossfade. Selection saves in
`${XDG_STATE_HOME:-~/.local/state}/mantle/desktop.json` and restores at login.
No wallpaper is replaced until the first selection; missing saved files are
reported in the picker. Mantle renders the background; Waypaper is not needed.
`mantle toggle wallpaper_open` also opens the picker.

The idle button toggles a manual keep-awake hold; right-click lists reported
inhibitors. `mantle toggle caffeine` does the same. The hold survives config
reloads, not shell restarts, and turning it off never clears another app's hold.
**While enabled, the hold prevents idle-triggered locking through swayidle.**
Manual locking remains available; existing Swayidle/Swaylock startup is unchanged.

Click the battery indicator for charge/time estimates, battery watts, power
profile, and mouse/headset/keyboard charge when UPower reports them. Without a
system battery, the indicator stays visible if peripheral batteries exist.
No package update counter or installer is added: Atomic/Flatpak updates stay
with the existing system services.

Checks: `lua tests/bar.lua`, `bash tests/clipboard-copy.sh`, and
`bash tests/mantle-check.sh`. Run shell integration checks on the desktop host
or from a toolbox with `flatpak-spawn --host` available.
