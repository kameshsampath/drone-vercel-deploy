#!/usr/bin/env bash

set -o pipefail
set -e 

basedir() {
  # Default is current directory
  local script=${BASH_SOURCE[0]}

  # Resolve symbolic links
  if [ -L $script ]; then
      if readlink -f $script >/dev/null 2>&1; then
          script=$(readlink -f $script)
      elif readlink $script >/dev/null 2>&1; then
          script=$(readlink $script)
      elif realpath $script >/dev/null 2>&1; then
          script=$(realpath $script)
      else
          echo "ERROR: Cannot resolve symbolic link $script"
          exit 1
      fi
  fi

  local dir=$(dirname "$script")
  local full_dir=$(cd "${dir}" && pwd)
  echo ${full_dir}
}

drone exec --secret-file="$(basedir)/secret.local" .drone.yml