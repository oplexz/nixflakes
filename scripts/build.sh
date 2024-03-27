#!/run/current-system/sw/bin/bash

validate_input() {
  while :; do
    read -r input
    case $input in
    [Yy] | "") return 0 ;; # Treat no answer as yes
    [Nn]) return 1 ;;
    *) echo "Invalid input. Please enter Y or n: " ;;
    esac
  done
}

# This always puts us in the root of the project, whether we cd into sh or execute script from root
cd "$(dirname "$(realpath "$0")")/.." || exit 1

echo "
#####################
#  _  _        _    #
# | || |___ __| |_  #
# | __ / _ (_-<  _| #
# |_||_\___/__/\__| #
#                   #
#####################
"

echo -n "Enter new hostname: "
read hostname

host_dir="hosts/$hostname"
host_file_path="$host_dir/default.nix"

if [ ! -f "$host_file_path" ]; then
  echo "Creating new host file $host_file_path..."
  mkdir -p "$host_dir"
  cat >"$host_file_path" <<EOF
{
  imports = [
  ./hardware-configuration.nix
  ];
  #----Host specific config ----
}
EOF
else
  echo "Host file $host_file_path already exists. Do you want to overwrite it? [Y/n]: "
  if validate_input; then
    echo "Overwriting existing $host_file_path..."
    cat >"$host_file_path" <<EOF
{
  imports = [
  ./hardware-configuration.nix
  ];
  #----Host specific config ----
}
EOF
  else
    echo "Keeping existing $host_file_path..."
  fi
fi

echo "
######################
#  _   _             #
# | | | |___ ___ _ _ #
# | |_| (_-</ -_) '_|#
#  \___//__/\___|_|  #
#                    #
######################
"

echo -n "Enter a new username: "
read username

user_dir="users/$username"
user_file_path="$user_dir/default.nix"

# Check if user file already exists
if [ -f "$user_file_path" ]; then
  echo "User file $user_file_path already exists. Do you want to overwrite it? [Y/n]: "
  if validate_input; then
    echo "Overwriting existing $user_file_path..."
    cat >"$user_file_path" <<EOF
{
  imports = [
  ./hardware-configuration.nix
  ];
  #----Host specific config ----
}
EOF
  else
    echo "Keeping existing $user_file_path..."
  fi
else
  echo "Creating new user file $user_file_path..."
  mkdir -p "$user_dir"
  cat >"$user_file_path" <<EOF
{ pkgs, username, ... }:
{
# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    shell = pkgs.bash;
    isNormalUser = true;
    initialPassword = "temp123";
    extraGroups = [ "wheel" "input" ];
  };
}
EOF
fi

echo -n "Do you use Nvidia? [Y/n]: "
if validate_input; then
  nvidia=true
else
  nvidia=false
fi

default_hardware_config_path="/etc/nixos/hardware-configuration.nix"
default_config_path="/etc/nixos/configuration.nix"

if test -s "$default_hardware_config_path"; then
  echo "/etc/nixos/hardware-configuration.nix exists, would you like to import it? [Y/n] "
  if validate_input; then
    echo "Importing existing $default_hardware_config_path..."
    bool_import=true
  fi
else
  echo "File does not exist, would you like to generate both config files? [Y/n] "
  if validate_input; then
    echo "Generating $default_hardware_config_path..."
    bool_generate_hardward_config=true
  fi
fi

if [ "$bool_generate_hardward_config" = true ]; then
  nixos-generate-config
  cp "$default_hardware_config_path" "$host_dir/" || {
    echo "Failed to copy $default_hardware_config_path"
    exit 1
  }
elif [ "$bool_import" = true ]; then
  cp "$default_hardware_config_path" "$host_dir/" || {
    echo "Failed to copy $default_hardware_config_path"
    exit 1
  }
fi

echo "Creating a basic system configuration in flake.nix..."

if [ "$nvidia" = true ]; then
  read -r -d '' NEW_CONFIG <<EOM
	
	# Appended new system
	$hostname =
       	let system = "x86_64-linux";
	in nixpkgs.lib.nixosSystem {
          specialArgs = {
            username = "$username";
            hostName = "$hostname";
            hyprlandConfig = "laptop";
	    inherit system;
          } // attrs;        
          modules = [
            ./.
	    ./modules/hardware/nvidia
          ];
        };#$hostname
EOM
else
  read -r -d '' NEW_CONFIG <<EOM
	
	# Appended new system
	$hostname =
       	let system = "x86_64-linux";
	in nixpkgs.lib.nixosSystem {
          specialArgs = {
            username = "$username";
            hostName = "$hostname";
            hyprlandConfig = "laptop";
	    inherit system;
          } // attrs;        
          modules = [
            ./.
          ];
        };#$hostname
EOM
fi
awk -v n="$NEW_CONFIG" '
    /}; # configurations/ { print n; print; next }
    { print }
' flake.nix >temp && mv temp flake.nix

echo "Validate that this import when okay by running 'nix flake check'."
