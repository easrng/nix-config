{
  lib,
  writeShellScriptBin,
  bubblewrap,
  opencode,
}:

writeShellScriptBin "opencode" ''
  set -euo pipefail

  cfg="''${XDG_CONFIG_HOME:-$HOME/.config}"
  data="''${XDG_DATA_HOME:-$HOME/.local/share}"
  cache="''${XDG_CACHE_HOME:-$HOME/.cache}"

  ro_binds=()
  for dir in /etc /lib /lib64 /usr /bin /nix /run/current-system/sw; do
    [[ -e $dir ]] && ro_binds+=(--ro-bind "$dir" "$dir")
  done

  [[ -e $HOME/.nix-profile/bin ]] && ro_binds+=(--ro-bind "$HOME/.nix-profile/bin" "$HOME/.nix-profile/bin")

  [[ -d $cfg/opencode ]] && ro_binds+=(--ro-bind "$cfg/opencode" "$cfg/opencode")

  rw_binds=()
  [[ -d "$HOME/.cargo" ]] && rw_binds+=(--bind "$HOME/.cargo" "$HOME/.cargo")
  [[ -d "$HOME/.rustup" ]] && rw_binds+=(--bind "$HOME/.rustup" "$HOME/.rustup")
  [[ -d "$HOME/.local/share/pnpm" ]] && rw_binds+=(--bind "$HOME/.local/share/pnpm" "$HOME/.local/share/pnpm")
  [[ -d $data/opencode ]] && rw_binds+=(--bind "$data/opencode" "$data/opencode")
  [[ -d $cache/opencode ]] && rw_binds+=(--bind "$cache/opencode" "$cache/opencode")

  keep=(
    TERM COLORTERM TERMINFO TERMINFO_DIRS
    LANG LC_ALL
    SHELL HOME
    EDITOR VISUAL NO_COLOR PAGER
    XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME XDG_STATE_HOME
  )
  env_args=(--clearenv)
  for v in "''${keep[@]}"; do
    val="''${!v:-}"
    [[ -n $val ]] && env_args+=(--setenv "$v" "$val")
  done
  env_args+=(
    --setenv PATH "/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:/usr/bin:/bin"
    --setenv TMPDIR /tmp
  )

  exec ${lib.getExe bubblewrap} \
    --unshare-all \
    --share-net \
    --die-with-parent \
    --chdir /app \
    --bind "$(pwd -P)" /app \
    --dev /dev \
    --proc /proc \
    --tmpfs /tmp \
    --tmpfs /run \
    --tmpfs "''${HOME:-/root}" \
    "''${ro_binds[@]}" \
    "''${rw_binds[@]}" \
    "''${env_args[@]}" \
    ${lib.getExe opencode} "$@"
''
