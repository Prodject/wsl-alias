#!/bin/bash

# getting the arguments
pwd_win="$1"
shift
cmd="$@"

# loading the custom environment
wslalias_dir="$HOME/.wsl-alias"
wslalias_interactive="0"
if [ -z "$cmd" ]; then
  wslalias_interactive="1"
fi
if [ -f "$wslalias_dir/env.sh" ]; then
  source "$wslalias_dir/env.sh"
fi

# parsing the path
pwd_wsl=$(echo "$pwd_win" | sed 's/\\/\//g')
pwd_wsl=$(echo "$pwd_wsl" | sed 's/://g')
pwd_wsl=$(echo "$pwd_wsl" | sed 's/^./\L&\E/')
pwd_wsl="/mnt/$pwd_wsl"

# mounting the drive if its not mounted
pwd_drive=${pwd_wsl:5:1}
pwd_drive_ls=$(ls -A "/mnt/$pwd_drive" 2>/dev/null)
if [ ! -d "$pwd_wsl" ] || [ -z "$pwd_drive_ls" ]; then
  user=$(whoami)
  user_uid=$(id -u "$user")
  user_gid=$(id -g "$user")
  echo "wsl: attempting to mount drive $pwd_drive:"
  mkdir -p "/mnt/$pwd_drive"
  sudo mount -o uid=$user_uid,gid=$user_gid -t drvfs $pwd_drive: /mnt/$pwd_drive
fi

cd "$pwd_wsl" 2>/dev/null
if [ -z "$cmd" ]; then
  cmd="$SHELL"
fi

eval "$cmd"
