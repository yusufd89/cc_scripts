#!/bin/sh

##############################################
# PRE-LOADED FUNCTIONS
##############################################

___is_empty_string() {

   # -z -> checks if it is empty
   if [ -z "$@" ]; then
      return 0
   fi

   # NULL is a custom string which is using in this project. it's not a standart.
   if [ "$@" = "NULL" ]; then
      return 0
   fi

   return 1
}

___do_executables_exist() {

   for COMMAND in "$@"; do
      # do not use 'which' command to check if executable exist.
      # we prefer 'command' because it is POSIX standart.
      # reason why: https://stackoverflow.com/a/677212 ("web.archive.org" and "archive.is". archived date: 01/05/2020)
      command -v "$COMMAND" >/dev/null 2>&1 || {
         ___print_screen "command does not exist: $COMMAND"
         return 1
      }
   done
}

___do_executables_exist_without_output() {

   for COMMAND in "$@"; do
      # do not use 'which' command to check if executable exist.
      # we prefer 'command' because it is POSIX standart.
      # reason why: https://stackoverflow.com/a/677212 ("web.archive.org" and "archive.is". archived date: 01/05/2020)
      command -v "$COMMAND" >/dev/null 2>&1 || { return 1; }
   done
}

##############################################
# OPTIONAL VARIABLES
##############################################

# we don't use nix daemon. we prefer to create a new user only for nix installations.
# so any user who knows the password of $CC_NIX_USER can install packages on nix.
# otherwise nix does not allow multi-users installation of nix packages.
___is_empty_string "$CC_NIX_USER" && CC_NIX_USER='nixuser'

# this folder can include one of these:
# - official portable/standalone versions of apps
# - extracted (official) '.deb' files of apps
___is_empty_string "$CC_STANDALONE_APPS_PATH_ROOT" && CC_STANDALONE_APPS_PATH_ROOT="$HOME/APPS/EXTRACTED_FILES"

# We set $HOME as $CC_APPS_HOME/appName before start any app which use GUI (except development apps like: Eclipse, IntelliJ, VSCode)
___is_empty_string "$CC_APPS_HOME" && CC_APPS_HOME="$HOME/APPS/HOME"

# this is the directory where the nix binaries storing.
# you do not need to add $CC_NIX_BIN_ALL_PATH to your $PATH. all below cc_script functions reads both CC_NIX_BIN_ALL_PATH and PATH.
___is_empty_string "$CC_NIX_BIN_ALL_PATH" && CC_NIX_BIN_ALL_PATH="/nix/var/nix/profiles/per-user/$CC_NIX_USER/profile/bin"

# text editors
___is_empty_string "$CC_TEXT_EDITOR_FOR_NON_ROOT_FILES" && CC_TEXT_EDITOR_FOR_NON_ROOT_FILES="$CC_STANDALONE_APPS_PATH_ROOT/VSCodium-1.42.1-1581651960.glibc2.16-x86_64.AppImage"
___is_empty_string "$CC_TEXT_EDITOR_FOR_ROOT_FILES" && CC_TEXT_EDITOR_FOR_ROOT_FILES='gedit'

# enable/disable echo color
___is_empty_string "$CC_ECHO_COLOR" && CC_ECHO_COLOR='true'

##############################################
# COLORS FOR ECHO COMMAND
##############################################

# We prefer to change the backgroud color. because the background of terminal interpreter can be any color (same or similar color with our echo output).

CC_COLOR_RED=""   # only ___print_title command will use it
CC_COLOR_GREEN="" # use it only if you don't use ___print_screen function and use a different color than others.
CC_COLOR_BLUE=""  # only ___print_screen command will use it
CC_COLOR_RESET="" # every end of echo command

if ___do_executables_exist "tput"; then
   TPUT_BOLD="$(tput bold)" # we prefer bold. text are cleaner/bigger.
   TPUT_WHITE="$(tput setaf 7)"
   CC_COLOR_RED="$TPUT_BOLD$TPUT_WHITE$(tput setab 1)"
   CC_COLOR_GREEN="$TPUT_BOLD$TPUT_WHITE$(tput setab 2)"
   CC_COLOR_BLUE="$TPUT_BOLD$TPUT_WHITE$(tput setab 4)"
   CC_COLOR_RESET="$(tput sgr 0)"
else
   # We prefer "\x1B" as escape character. Do not use "\e" which not compatible with old versions of bash.
   CC_COLOR_RED='\x1B[1;41m'
   CC_COLOR_GREEN='\x1B[1;42m'
   CC_COLOR_BLUE='\x1B[1;44m'
   CC_COLOR_RESET='\x1B[0m'
fi

##############################################
# PRINT SCREEN FUNCTIONS
##############################################

___print_screen() {

   ___is_empty_string "$@" && {
      echo
      return
   }

   if [ "$CC_ECHO_COLOR" = "true" ]; then
      echo -e "$CC_COLOR_BLUE""** $@""$CC_COLOR_RESET"
      return
   fi

   echo "** $@"
}

___print_title() {

   if [ "$CC_ECHO_COLOR" = "true" ]; then
      echo -e "$CC_COLOR_RED""*** $@""$CC_COLOR_RESET"
      return
   fi

   echo "*** $@"
}

##############################################
# GENERIC HELP FUNCTIONS FOR cc_script SEARCH
##############################################

c_aa_help() {

   ___print_title 'quick search on everywhere:'
   ___print_screen 'c_help keyword'
   ___print_screen
   ___print_title 'other help functions:'
   ___print_screen 'c_help_* (press tab to list them)'
   ___print_screen
   ___print_title 'colorize commands:'
   ___print_screen '-- myCommand | color_line'
}

c_help() {

   ##############################
   # ABOUT
   ##############################
   # search the keyword inside this(cc_scripts.sh) file
   ##############################
   ##############################
   ##############################

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local KEYWORD="$@"
   ##############################
   ##############################
   ##############################

   ___do_files_exist "$CC_SCRIPTS_FILE_PATH" || return 100

   ___do_executables_exist "grep" "sed" || { return 1; }

   local OLD_DELIMITER="--"

   local NEW_DELIMITER="$CC_COLOR_GREEN*************************************************$CC_COLOR_RESET"
   NEW_DELIMITER=" \n""$NEW_DELIMITER""\n""$NEW_DELIMITER""\n" # do not remove the first space character on this line. otherwise the output will not show properly.

   # -C --> how many lines will be printed above and below of founded line
   # IGNORE CASE = -i
   # sed command = replaces the text
   # -e = replace with given regex
   # sed regex meaning = replace the lines which ends $OLD_DELIMITER with $NEW_DELIMITER
   # we use grep again after sed, because sed removes the colors of founded texts. so we use grep again to make output colorfull.
   grep "$KEYWORD" -C 12 -i "$CC_SCRIPTS_FILE_PATH" | sed -e "s/$OLD_DELIMITER$/\\$NEW_DELIMITER/g" | grep -C 99 -i "$KEYWORD"
}

c_help_search_in_function_names() {

   ##############################
   # ABOUT
   ##############################
   # search the keyword of functions inside this(cc_scripts.sh) file
   ##############################
   ##############################
   ##############################

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local KEYWORD="$@"
   ##############################
   ##############################
   ##############################

   ___do_files_exist "$CC_SCRIPTS_FILE_PATH" || return 100

   ___do_executables_exist "grep" || { return 1; }

   # IGNORE CASE = -i
   # grep regex meaning = starts with 'c_'
   (grep -i "^c_" | grep "$KEYWORD") <"$CC_SCRIPTS_FILE_PATH"
}

c_help_open_cc_scripts_with_text_editor() {

   ___do_files_exist "$CC_SCRIPTS_FILE_PATH" || return 100

   "$CC_TEXT_EDITOR_FOR_NON_ROOT_FILES" "$CC_SCRIPTS_FILE_PATH"
}

##############################################
# CC_SCRIPTS
##############################################

c_ccscripts_import() {

   ##############################
   # ABOUT
   ##############################
   # adds a new line (to .bashrc and .zshrc files) which executes(imports) this(cc_scripts.sh) file
   ##############################
   ##############################
   ##############################

   ___do_executables_exist "cp" "grep" || { return 1; }

   ___do_files_exist "$CC_SCRIPTS_FILE_PATH" || return 100

   local LINE_TO_IMPORT="source \"$CC_SCRIPTS_FILE_PATH\""

   for SHELL_RC_FILE_NAME in ".bashrc" ".zshrc"; do
      local SHELL_RC_FILE="$HOME/$SHELL_RC_FILE_NAME"

      # backup file.
      # backup process is before editing the file. if any error happens, the user will manually edit the file. before he edits, we will have already a backup for him.
      if ___do_files_exist "$SHELL_RC_FILE"; then
         ___execute_with_eval cp "$SHELL_RC_FILE" "$SHELL_RC_FILE""_backup" || {
            echo "error 101"
            return
         }
      fi

      # checking if LINE_TO_IMPORT already exist
      if grep "$LINE_TO_IMPORT" "$SHELL_RC_FILE" >"/dev/null"; then
         ___print_screen "$SHELL_RC_FILE have already imported cc_scripts file."
         return
      fi

      # if we have a keyword of 'cc_scripts' anywehere on file, stop the script.
      if grep "cc_scripts" "$SHELL_RC_FILE" >"/dev/null"; then
         ___print_screen "$SHELL_RC_FILE have something about cc_scripts but the format is unknown. you must fix it manually."
         return
      fi

      # everyting is OK. importing lines...
      echo "


$LINE_TO_IMPORT


" >>"$SHELL_RC_FILE"

      ___print_screen "added to $SHELL_RC_FILE"
   done # en of loop of '.bashrc', '.zshrc' files
}

c_mac_adress_change_random() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local NETWORK_INTERFACE="$1"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("NETWORK_INTERFACE (c_ip function can print the network interfaces.)")
   ___check_parameters "$@" || { return 2; }

   ___do_executables_exist "ip" "sed" "service" || { return 1; }

   local hexchars="0123456789ABCDEF"
   local end=$(for i in {1..6}; do echo -n ${hexchars:$((RANDOM % 16)):1}; done | sed -e 's/\(..\)/:\1/g')
   local MAC_ADRESS="00:60:2F$end"

   ___print_screen "new mac: $MAC_ADRESS"

   ___run_command_as_root ip link set dev "$NETWORK_INTERFACE" down || {
      echo "error 101"
      return
   }

   ___run_command_as_root ip link set dev "$NETWORK_INTERFACE" address "$MAC_ADRESS" || {
      echo "error 102"
      return
   }

   ___run_command_as_root ip link set dev "$NETWORK_INTERFACE" up || {
      echo "error 103"
      return
   }

   ___run_command_as_root service network-manager restart || {
      echo "error 104"
      return
   }

   ___print_screen "now you should wait 5-10 seconds because network-manager service is restarting."
   ___print_screen "mac adress will revert to default after reboot of OS."
}

___string_ends_with() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local ALL_STRING="$1"
   local ENDS_WITH="$2"
   ##############################
   ##############################
   ##############################

   if [[ "$ALL_STRING" == *"$ENDS_WITH" ]]; then
      return 0
   fi
   return 1
}

___string_starts_with() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local ALL_STRING="$1"
   local START_WITH="$2"
   ##############################
   ##############################
   ##############################

   if [[ "$ALL_STRING" == "$START_WITH"* ]]; then
      return 0
   fi
   return 1
}

___string_contains() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local ALL_STRING="$1"
   local SUB_STRING="$2"
   ##############################
   ##############################
   ##############################

   if [[ "$ALL_STRING" == *"$SUB_STRING"* ]]; then
      return 0
   fi
   return 1
}

c_shell_variable_search() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local KEYWORD="$1"
   ##############################
   ##############################
   ##############################

   ___do_executables_exist "set" "grep" || { return 1; }

   GREP_COMMAND_PARAM="$KEYWORD"
   ___execute_and_grep_and_color_line "set"
}

c_path_add() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local DIR="$1"
   ##############################
   ##############################
   ##############################

   ___is_empty_string "$DIR" && {
      ___print_screen "$DIR is empty."
      return
   }

   ___string_contains "$PATH" "$DIR" && {
      ___print_screen "$DIR already exist."
      return
   }

   PATH="$DIR:$PATH"

   ___print_screen "Path added. New PATH: $PATH"
}

c_environment_search() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local KEYWORD="$1" # keyword to search inside environment variables
   ##############################
   ##############################
   ##############################

   ___do_executables_exist "env" "grep" || { return 1; }

   GREP_COMMAND_PARAM="$KEYWORD"
   ___execute_and_grep_and_color_line "env"
}

c_path_search() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local KEYWORD="$1" # keyword to search inside $PATH
   ##############################
   ##############################
   ##############################

   ___do_executables_exist "grep" "tr" || { return 1; }

   # IGNORE CASE = -i
   ___execute_with_eval "echo \"$PATH\" | tr ':' '\n' | grep \"$KEYWORD\" -i | color_line"
}

c_system_details() {

   # --backend off --> do not print OS logo as ASCII
   # refresh_rate --> print refresh rate of screen
   # --travis --> prints more detail
   # --no_config --> Do not create a config file inside $HOME/config/neofetch directory
   ___execute_with_eval "$CC_STANDALONE_APPS_PATH_ROOT/neofetch \
           --cpu_temp C \
           --travis \
           --no_config \
           --backend off \
           --kernel_shorthand off \
           --title_fqdn on \
           --distro_shorthand off \
           --os_arch on \
           --uptime_shorthand off \
           --memory_percent on \
           --package_managers on \
           --shell_path on \
           --shell_version on \
           --cpu_brand on \
           --cpu_speed on \
           --gpu_brand on \
           --gpu_type all \
           --refresh_rate on \
           --gtk_shorthand off \
           --gtk2 on \
           --gtk3 on \
           --ip_timeout 8 \
           --de_version on"

   ___print_screen "current user name"
   ___execute whoami
   ___print_screen "LOGNAME env: $LOGNAME"
   ___print_screen "USER env: $USER"
   ___print_screen "HOME env: $HOME"

   ___print_screen "TERMINAL INFO:"
   ___print_screen "SHELL env: $SHELL"
   ___print_screen "TERM env: $TERM"
   ___execute "tput longname"
   ___print_screen
   ___execute "tput colors"

   ___execute locale

   # PRINT ALL INFO = -a
   ___execute_with_eval "uname -a"

   # SHOW ALL INFORMATION = -a
   ___execute_with_eval "lsb_release -a" # standart of: linuxbase.org

   # lsb-release, redhat-release, suse-release...
   # standart of: freedesktop.org and systemd
   for file in "/etc/"*"release"; do
      ___execute_with_eval "cat $file"
   done

   ___print_screen "list of all full host names"
   ___execute_with_eval hostname -A

   ___print_screen "list of all IP addresses for this host"
   ___execute_with_eval hostname -I

   ___print_screen "external ip"
   ___execute_with_eval "dig +short myip.opendns.com @resolver1.opendns.com"

   ___print_screen "current time date"
   ___execute_with_eval "date '+%Y-%m-%d   %H:%M:%S   %z   Nanoseconds:%N'"

   local BACKUP_LC_TIME="$LC_TIME"
   for TEMP_LC_TIME in "en_GB.UTF-8" "en_US.UTF-8" "el_GR.UTF-8" "tr_TR.UTF-8"; do
      ___print_screen "current date in: $TEMP_LC_TIME"
      LC_TIME="$TEMP_LC_TIME"
      ___execute_with_eval "date '+ Month:%B   Day:%A'"
   done
   LC_TIME="$BACKUP_LC_TIME"

   # http requests should last of this function. because they take time. user can stop the script if he does not want.

   ___print_screen "current time date from google http response 'Date' header"
   ___execute_with_eval "curl -s --head 'http://google.com' | grep '^Date:' | sed 's/Date: //g' "

   ___print_screen "current time date from 'National Institute of Standards and Technology'"
   ___execute_with_eval "timeout 5s nc 'time.nist.gov' 13"
}

color_line() {

   ##############################
   # USAGE
   ##############################
   # ls -a | color_line
   ##############################
   ##############################
   ##############################

   ___do_executables_exist "read" || { return 1; }

   while read line; do
      echo -e "\e[1;31m$line"
      read line
      echo -e "\e[1;32m$line"
   done
   echo -en "\e[0m"
}

c_notify_user() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local TIME_TO_BEEP="$1"
   local MESSAGE="$2"
   ##############################
   ##############################
   ##############################

   # MacOS GUI notification
   ___do_executables_exist_without_output "osascript" && { osascript -e "display notification \""$MESSAGE"\" with title "cc_scripts" "; }

   # Linux GUI notification
   ___do_executables_exist_without_output "notify-send" && { notify-send "$MESSAGE" --app-name "cc_scripts"; }

   local MS_WINDOWS_NOTIFY_COMMANDS='
   [reflection.assembly]::loadwithpartialname("System.Windows.Forms")
   [reflection.assembly]::loadwithpartialname("System.Drawing")
   $notify = new-object system.windows.forms.notifyicon
   $notify.icon = [System.Drawing.SystemIcons]::Information
   $notify.visible = $true
   $notify.showballoontip(20,"cc_scripts","'$MESSAGE'",[system.windows.forms.tooltipicon]::None)
   '

   ___do_executables_exist_without_output "powershell" && { powershell -c "$MS_WINDOWS_NOTIFY_COMMANDS"; }

   ___do_executables_exist_without_output "speaker-test" "timeout" || { return 1; }

   ___is_empty_string "$TIME_TO_BEEP" && TIME_TO_BEEP="3"

   timeout --kill-after="$TIME_TO_BEEP" 1 speaker-test --frequency 1000 --test sine >"/dev/null"

   return 0
}

c_logout_gnome_prompt_with_gui() {
   ___execute_with_eval gnome-session-quit --help
}

c_logout_awesome() {
   ___print_title 'command not implemented yet. temporary solutions:'
   ___print_screen '- keyboard: CTRL (or ALT or WIN) + SHIFT + Q'
   ___print_screen '- GUI: awesome menu from panel (or right click on desktop) --> awesome --> quit'
}

c_shutdown() {
   ___execute_with_eval shutdown --help
}

c_help_network_list_all_choices() {

   ___print_screen "c_network_details"
   ___print_screen "c_network_manager_gui"
   ___print_screen "c_wifi_connect"
   ___print_screen "c_network_disable"
   ___print_screen "c_network_enable"
   ___print_screen "c_network_disable_wifi"
   ___print_screen "c_network_enable_wifi"
}

c_network_manager_gui() {

   ___print_title 'select one of: '
   ___print_screen
   ___print_screen "1- nm-applet: this app opening on the system tray panel. this is different app that gnome shell panel built-in."
   ___print_screen
   ___print_screen "2- plasma-nm: kde-based wifi manager."
   ___print_screen
   ___print_screen "3- nm-connection-editor: same as nm-applet. nm-applet based on nm-connection-editor. but nm-applet is opening in system tray. if you could not open nm-applet try this one."
   ___print_screen
   ___print_screen "4- nmtui: opens a terminal GUI."
   ___print_screen
   ___print_screen "note: you can use other functions: c_network_manager_details, c_wifi_connect, c_network_disable..."
   ___print_screen
   read choice

   if [ "$choice" = "1" ]; then
      ___nohup_and_disown nm-applet
   elif [ "$choice" = "2" ]; then
      ___nohup_and_disown plasma-nm
   elif [ "$choice" = "3" ]; then
      ___nohup_and_disown nm-connection-editor
   elif [ "$choice" = "4" ]; then
      nmtui
   else
      ___print_screen "wrong choice"
   fi
}

c_network_details() {
   ___print_title "all networks and their details"
   ___execute_and_color_line nmcli device show
   ___print_screen
   ___print_title "status:"
   ___execute_with_eval nmcli general status
   ___print_screen
   ___print_title "wifi list:"
   ___execute_with_eval nmcli device wifi rescan # this should run before listing. otherwise it will not list all connections below.
   ___execute_with_eval nmcli device wifi list
}

c_wifi_connect() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local WIFI_NETWORK_NAME="$1"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("WIFI_NETWORK_NAME")
   ___check_parameters "$@" || { return 2; }

   ___print_screen 'type password for wifi: '
   read wifiPassword

   ___execute_with_eval nmcli device wifi connect "$WIFI_NETWORK_NAME" password "$wifiPassword"
}

c_network_disable() {
   ___execute nmcli networking off
}

c_network_enable() {
   ___execute nmcli networking on
}

c_network_disable_wifi() {
   ___execute nmcli radio wifi off
}

c_network_enable_wifi() {
   ___execute_with_eval nmcli radio wifi on
}

c_download_with_curl_script() {

   ##############################
   # ABOUT
   ##############################
   # this function creates a simple sh file on $HOME'/downloads_with_curl' directory and starts download backgound.
   # so you can resume anytime the download by that script.
   ##############################
   ##############################
   ##############################

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local DOWNLOAD_URL="$@"
   ##############################
   ##############################
   ##############################

   ___do_files_exist "$CC_SCRIPTS_FILE_PATH" || return 100

   ___required_parameters=("DOWNLOAD_URL")
   ___check_parameters "$@" || { return 2; }

   # some of below apps seem like optional. but if they are not exist, you can not stop the background script with simple/known ways.
   ___do_executables_exist "grep" "kill" "awk" "mkdir" "chmod" "nohup" "curl" "command" "nohup" "disown" "bash" || { return 1; }

   local randomFileName
   if ___is_empty_string "$RANDOM"; then
      ___print_screen "type any keyword to remember this download"
      read randomFileName

      if ___is_empty_string "$randomFileName"; then
         ___print_screen "you did not anything. script will exit."
         return
      fi
   else
      local randomFileName=$((RANDOM % 123456789))

      if ___is_empty_string "$randomFileName"; then
         echo "error 100"
         return
      fi
   fi

   local DOWNLOAD_DIR="$HOME/downloads_with_curl"

   mkdir -p "$DOWNLOAD_DIR" || {
      echo "error 101"
      return
   } # -p ignores the warning: folder already exist.

   # creating resume script
   local RESUME_SCRIPT_FILE="$DOWNLOAD_DIR/""$randomFileName""_resume_download.sh"

   # ********************
   # ********************
   # Creating file
   # ********************
   # ********************
   echo '#!/bin/bash

# run this script. it will resume the same downloaded file.
 
. "'"$CC_SCRIPTS_FILE_PATH"'" # inserting cc_scripts for "c_notify_user" function

# do not run this script directly. use "resume_download_as_thread.sh" instead.
# if we start this script and press CTRL+Z, backgprund curl process does not kill itself
# because we are in sub-shell. 

# curl is more advanced then wget. it can download from different protocols.

'$(command -v curl)'          \
   --connect-timeout 70       \
   --retry 999                `#it will retry N times if download fails` \
   --retry-connrefuse         `#retry even connection refused` \
   -C -                       `#continue if file already exist` \
   --limit-rate 9999999K      `#speed limit` \
   -l                         `#follow if redirection exist` \
   --output "'"$DOWNLOAD_DIR/$randomFileName"'" \
   "'"$DOWNLOAD_URL"'";

echo
echo "curl command end."

c_notify_user 5 "curl command end"
' >>"$RESUME_SCRIPT_FILE"
   # ********************
   # ********************
   # End of creating file
   # ********************
   # ********************

   chmod 777 "$RESUME_SCRIPT_FILE" || {
      echo "error 102"
      return
   }

   # creating resume as thread script
   local RESUME_AS_THREAD_SCRIPT_FILE="$DOWNLOAD_DIR/""$randomFileName""_resume_download_as_thread.sh"

   # ********************
   # ********************
   # Creating file
   # ********************
   # ********************
   echo '#!/bin/bash
 
# run this script. it will resume the same downloaded file on background.

nohup "'"$RESUME_SCRIPT_FILE"'" >"'"$DOWNLOAD_DIR/$randomFileName"'.log" 2>&1 & disown

' >>"$RESUME_AS_THREAD_SCRIPT_FILE"
   # ********************
   # ********************
   # End of creating file
   # ********************
   # ********************

   chmod 777 "$RESUME_AS_THREAD_SCRIPT_FILE" || {
      echo "error 103"
      return
   }

   # creating stop script
   local STOP_SCRIPT_FILE="$DOWNLOAD_DIR/""$randomFileName""_stop_download.sh"

   # ********************
   # ********************
   # Creating file
   # ********************
   # ********************
   echo '#!/bin/bash
 
# run this script. it will stop the download. you can resume it anytime by running the other scripts.

CURL_PROCESS_ID=$(ps -aux | grep "'"$DOWNLOAD_URL"'" | grep -v -e "grep" | awk ' "'" '{print $2}' "'" ')

kill -9 "$CURL_PROCESS_ID"

' >>"$STOP_SCRIPT_FILE"
   # ********************
   # ********************
   # End of creating file
   # ********************
   # ********************

   chmod 777 "$STOP_SCRIPT_FILE" || {
      echo "error 104"
      return
   }

   # script files are created. now download will resume...
   nohup "$RESUME_SCRIPT_FILE" >"$DOWNLOAD_DIR/$randomFileName.log" 2>&1 &
   disown

   ___print_title "downloading file:"
   ___print_screen "$DOWNLOAD_DIR/$randomFileName"
   ___print_title "stop download:"
   ___print_screen "$STOP_SCRIPT_FILE"
   ___print_title "resume download (as background thread):"
   ___print_screen "$RESUME_AS_THREAD_SCRIPT_FILE"
   ___print_screen
   ___print_screen "script started in background. you can close the shell."
}

c_file_find_locked_process() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local FILE_PATH="$1"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("FILE_PATH")
   ___check_parameters "$@" || { return 1; }

   if ___do_executables_exist "fuser"; then

      ___execute_with_eval fuser "$FILE_PATH"

      # print format info because fuser does not print column names
      ___print_title "format of above command:"
      ___print_screen "file-full-path: process-id"

   elif ___do_executables_exist "lsof"; then
      ___execute_with_eval lsof "$FILE_PATH"
   fi
}

c_file_name_microsoft_windows_incompatible_list() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local DIRECTORY_TO_VALIDATE="$1"
   local EXCLUDE_REGEX="$2"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("DIRECTORY_TO_VALIDATE" "EXCLUDE_REGEX")
   ___check_parameters "$@" || { return 1; }

   ___do_executables_exist "basename" "grep" "find" "while" "read" || { ___exit 2; }

   # Rules: https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file ("web.archive.org" and "archive.is". archived date: 01/05/2020)

   # do not use other loop types because they will break if file name have special character: https://stackoverflow.com/questions/9612090/how-to-loop-through-file-names-returned-by-find ("web.archive.org" and "archive.is". archived date: 01/05/2020)
   find "$DIRECTORY_TO_VALIDATE" -type f -name "*" ! -path "*/$EXCLUDE_REGEX/*" -print0 |
      while IFS= read -r -d '' FILE_OR_DIR_FULL_PATH; do
         ___print_screen "checking file: $FILE_OR_DIR_FULL_PATH"

         local FILE_OR_DIR_NAME="$(basename "$FILE_OR_DIR_FULL_PATH")"

         for RESERVED_NAME in "CON" "PRN" "AUX" "NUL" "COM1" "COM2" "COM3" "COM4" "COM5" "COM6" "COM7" "COM8" "COM9" "LPT1" "LPT2" "LPT3" "LPT4" "PT5" "LPT6" "LPT7" "LPT8" "LPT9"; do
            local REGEX1='^'"$RESERVED_NAME"'[.].*' # start with 'CON' & have dot character & have any character
            local REGEX2='^'"$RESERVED_NAME"'$'     # start with 'CON' & ends
            local REGEX3='^'"$RESERVED_NAME"'[.]$'  # start with 'CON' & have dot character & ends
            echo "$FILE_OR_DIR_NAME" | grep --line-regexp "$REGEX1" && ___print_title "Reserved name $RESERVED_NAME"
            echo "$FILE_OR_DIR_NAME" | grep --line-regexp "$REGEX2" && ___print_title "Reserved name $RESERVED_NAME"
            echo "$FILE_OR_DIR_NAME" | grep --line-regexp "$REGEX3" && ___print_title "Reserved name $RESERVED_NAME"
         done

         local MAX_FILE_LENGHT="252" # Max path lenght is 255. But there is drive directory letters which is 3 character (example: C:\ ).
         local FILE_OR_DIR_FULL_PATH_LENGHT="$(expr length \""$FILE_OR_DIR_FULL_PATH"\")"
         local DIRECTORY_TO_VALIDATE_LENGHT="$(expr length \""$DIRECTORY_TO_VALIDATE"\")"
         local RELATIVE_PATH_LENGHT="$(expr $FILE_OR_DIR_FULL_PATH_LENGHT - $DIRECTORY_TO_VALIDATE_LENGHT)"
         # -gt -> greater than
         if [ "$RELATIVE_PATH_LENGHT" -gt "$MAX_FILE_LENGHT" ]; then
            ___print_title "$FILE_OR_DIR_FULL_PATH"
            ___print_title "long file name"
         fi

         echo "$FILE_OR_DIR_NAME" | grep --line-regexp '^0$' && ___print_title "0 is rezerved" # start with zero & ends

         # start with 'dot' & ends
         echo "$FILE_OR_DIR_NAME" | grep --line-regexp '^[.]$' && ___print_title "'.' is rezerved"

         # start with double 'dot' & ends
         echo "$FILE_OR_DIR_NAME" | grep --line-regexp '..' && ___print_title "'..' is rezerved"

         if ___do_directories_exist "$FILE_OR_DIR_FULL_PATH"; then
            echo "$FILE_OR_DIR_NAME" | grep --line-regexp '[.]$' && ___print_title "ends with dot (period)"
            echo "$FILE_OR_DIR_NAME" | grep --line-regexp '[ ]$' && ___print_title "ends with space"
         fi

         for RESERVED_CHAR in '*' '?' ':' '"' '<' '>' '|' '\\' '/'; do
            echo "$FILE_OR_DIR_NAME" | grep "$RESERVED_CHAR" && ___print_title "Reserved character: $RESERVED_CHAR"
         done

         local EXTRA_CONTROL_NOTE="(this is an extra control. ignore it.)"

         echo "$FILE_OR_DIR_NAME" | grep -e '^ [^ ]' -e '[^ ] $' -e '[^ ] [^ ]' && ___print_title "includes space. $EXTRA_CONTROL_NOTE"

         echo "$FILE_OR_DIR_NAME" | grep "'" && ___print_title "includes ' character. $EXTRA_CONTROL_NOTE"

         echo "$FILE_OR_DIR_NAME" | grep '[[:cntrl:]]' && ___print_title "includes control character. ' $EXTRA_CONTROL_NOTE"

         echo "$FILE_OR_DIR_NAME" | grep '[^[:print:]]' && ___print_title "inculdes non-printable character. $EXTRA_CONTROL_NOTE"

         echo "$FILE_OR_DIR_NAME" | grep '[^[:print:]]' && ___print_title "inculdes non-printable character. $EXTRA_CONTROL_NOTE"

         echo "$FILE_OR_DIR_NAME" | grep -v --extended-regexp '^[a-zA-Z0-9_-.]{1,}$' && ___print_title "is not alpha-numeric and '_' and '-' and '.'. $EXTRA_CONTROL_NOTE"
      done
}

# String delimiter
# We can use also ', but " is microsoft reserved char.
# Threfor we prefer reserved char which can not use in microsoft windows compatible file paths.
export SD="\""

c_file_type_info() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local FILE="$1"
   ##############################
   ##############################
   ##############################

   local FILE_W="$SD""$1""$SD"

   ___required_parameters=("FILE")
   ___check_parameters "$@" || { return 1; }

   ___print_screen "mime type"
   # -b --> do not print the file name again
   ___execute file -i -b $FILE

   ___print_screen "type"
   # -b --> do not print the file name again
   ___execute file -b $FILE

   ___print_screen "first 60 characters"
   ___execute head -c60 $FILE

   # head command does not add end of line character. therefor we put two empty lines.
   ___print_screen
   ___print_screen

   if awk '/\r$/{exit 0;} 1{exit 1;}' $FILE; then
      ___print_screen "end of line character is: MS-Windows: CR+LF (\\\n\\\r)"
   else
      ___print_screen "end of line character is: POSIX: LF (\\\n)"
   fi
}

c_tor_run_with_command() {

   local TOR_CONFIG_FILE="$CC_STANDALONE_APPS_PATH_ROOT/../tor_config.txt"
   local TOR_EXECUTABLE="$CC_STANDALONE_APPS_PATH_ROOT/tor/usr/bin/tor"

   ___do_executables_exist "$TOR_EXECUTABLE" "cp" "x-terminal-emulator" "zsh" "read" || { return 1; }

   # getting default configs
   ___execute_with_eval cp "$CC_STANDALONE_APPS_PATH_ROOT/tor/etc/tor/torrc" "$TOR_CONFIG_FILE" || { return 2; }

   # adding custom configs
   echo '
   ControlPort 9051 # "torsocks" will connect this port as default.
   CookieAuthentication 0' >>"$TOR_CONFIG_FILE" || { return 3; }

   LIB_EVENT_PATH="$CC_STANDALONE_APPS_PATH_ROOT/libevent-2.1-6_2.1.8-stable-4build1_amd64/usr/lib/x86_64-linux-gnu"

   COMMAND__TO_RUN_ON_NEW_SHELL="zsh -c \" export LD_LIBRARY_PATH=\\\"$LIB_EVENT_PATH\\\"; \\\"$CC_STANDALONE_APPS_PATH_ROOT/tor/usr/bin/tor\\\" --defaults-torrc \\\"$CC_STANDALONE_APPS_PATH_ROOT/../tor_config.txt\\\" || { echo 'error hapepped'; sleep 9999 } \" "

   if ___do_executables_exist x-terminal-emulator; then
      # x-terminal-emulator --> opens default terminal emulator (example: gnome-terminal GUI) in a new window with another process.
      # this command does not work properly with ___execute_with_eval function. Therefor we run it directly.
      x-terminal-emulator -e $COMMAND__TO_RUN_ON_NEW_SHELL || { return 4; }
   else
      ___print_screen "x-terminal-emulator command does not exist. run below command on another terminal window:"
      ___print_screen "$COMMAND__TO_RUN_ON_NEW_SHELL"
   fi

   ___print_screen "check the other terminal if tor started (connected to any bridge) properly. if yes, then type 'y', otherwise 'n'."
   read userChoice

   if [ "$userChoice" = "y" ]; then
      # default settings are enough to run
      export TORSOCKS_CONF_FILE="$CC_STANDALONE_APPS_PATH_ROOT/torsocks/etc/tor/torsocks.conf"
      ___execute_with_eval "LD_PRELOAD=\"$CC_STANDALONE_APPS_PATH_ROOT/torsocks/usr/lib/x86_64-linux-gnu/torsocks/libtorsocks.so\" $@"
      ___print_screen "Close the other terminal window with CTRL+C. Otherwise it will work background."
   else
      ___print_screen "script will exit"
   fi
}

c_mount_ram() {
   # fastest drive

   # TODO unmount

   ___execute_with_eval mkdir -p "$HOME/mounted_ram"
   ___execute_with_eval mount -o size=1GB -t tmpfs none "$HOME/mounted_ram"
}

c_git_log() {
   ___execute_with_eval "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
}

c_git_list_all_branches() {

   # only standart colors of cc_scripts will be define globally. therefor we define locally.
   local COLOR_YELLOW='\x1B[1;33m'
   local COLOR_PURPLE='\x1B[0;35m'

   if [ "$CC_ECHO_COLOR" = "true" ]; then
      echo -e "$CC_COLOR_RED""REF""$CC_COLOR_RESET" "$CC_COLOR_BLUE""TRACKING REF""$CC_COLOR_RESET" "$COLOR_YELLOW""LATEST COMMIT TIME""$CC_COLOR_RESET" "$COLOR_PURPLE""AUTHOR""$CC_COLOR_RESET" "$CC_COLOR_GREEN""COMMIT SHA(SHORT)""$CC_COLOR_RESET" "COMMIT COMMENT"
   else
      echo "** $@"
   fi
   ___print_screen

   ___execute_with_eval "git for-each-ref --sort=-committerdate --format='%(color:red bold)%(refname)%(color:reset) %(color:blue bold)%(upstream)%(color:reset) %(color:yellow)%(committerdate:relative)%(color:reset) %(color:magenta bold)%(authorname)%(color:reset) %(color:green)%(objectname:short)%(color:reset) %(contents:subject)'"
}

___get_maven_command() {

   local MAVEN_WRAPPER="./mvnw"

   if ___do_executables_exist_without_output "$MAVEN_WRAPPER"; then
      echo "$MAVEN_WRAPPER"
   else
      echo "mvn"
   fi
}

c_maven_clean_install() {
   local MAVEN_EXECUTABLE="$(___get_maven_command)"

   local CURRENT_DIR_PATH="$(pwd)"
   local CURRENT_DIR_NAME="$(basename $CURRENT_DIR_PATH)"

   ___execute "$MAVEN_EXECUTABLE" clean install $@

   c_notify_user "0.1" "maven finish for $CURRENT_DIR_NAME"
}

c_maven_clean_install_update_snapshots() {
   local MAVEN_EXECUTABLE="$(___get_maven_command)"

   local CURRENT_DIR_PATH="$(pwd)"
   local CURRENT_DIR_NAME="$(basename $CURRENT_DIR_PATH)"

   ___execute "$MAVEN_EXECUTABLE" clean install -U $@

   c_notify_user '0.1' "maven finish for $CURRENT_DIR_NAME"
}

c_maven_clean_install_skip_tests() {
   local MAVEN_EXECUTABLE="$(___get_maven_command)"

   local CURRENT_DIR_PATH="$(pwd)"
   local CURRENT_DIR_NAME="$(basename $CURRENT_DIR_PATH)"

   ___execute "$MAVEN_EXECUTABLE" clean install -DskipTests $@

   c_notify_user '0.1' "maven finish for $CURRENT_DIR_NAME"
}

c_docker_list_all_containers() {
   # SHOW ALL CONTAINERS = -a
   # LIST THE CONTAINERS = ps
   ___execute_and_color_line docker ps -a
}

c_docker_remove_force_all_containers() {

   # ONLY DISPLAY NUMERIC ID'S = -q
   # SHOW ALL CONTAINERS = -a
   # LIST THE CONTAINERS = ps
   # FORCE REMOVE RUNNING CONTAINER = -f
   # REMOVE CONTAINER = rm
   ___execute_with_eval 'docker stop $(docker ps -a -q)'
   ___execute_with_eval 'docker rm -f $(docker ps -a -q)'
}

c_docker_show_container_ip() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local CONTAINER_NAME_OR_ID="$1"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("CONTAINER_NAME_OR_ID")
   ___check_parameters "$@" || { return 2; }

   ___print_screen "note: this will not work if network bridge has a name."

   # FORMAT THE INPECT OUTPUT GIVEN THE TEMPLATE = -f
   ___execute_with_eval docker inspect -f \'{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}\' $CONTAINER_NAME_OR_ID
}

c_read_environments_from_property_file() {

   ##############################
   # ABOUT
   ##############################
   # reads a property file and evaluates each property to an environment variable.
   # rules (format of file):
   # - It does not ignores the white spaces. Therefor do not use white space anywhere of file. even before and after of = character.
   # - Do not use an empty line at the end of file.
   # - Do not use comments inside file.
   # - Do not use . (dot) chartacter. because shell does not allow dot characters on variables.
   #
   # example file:
   #
   #HOME=/home/user9
   #MY_VAR=1234
   #MY_SECOND_VAR=HELLO
   ##############################
   ##############################
   ##############################

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local PROPERTY_FILE_PATH="$1"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("PROPERTY_FILE_PATH")
   ___check_parameters "$@" || { return 2; }

   ___do_files_exist "$PROPERTY_FILE_PATH" || { return 3; }
   ___do_executables_exist "while" "do" "read" "eval" || { return 1; } # TODO can be implement without eval?

   while IFS='=' read -r KEY VALUE; do
      eval ${KEY}=\${VALUE}
   done <"$PROPERTY_FILE_PATH"
}

#################################
#### CASSANDRA
#################################
# Default values
CC_CASSANDRA_USERNAME="cassandra"
CC_CASSANDRA_PASSWORD="cassandra"
CC_CASSANDRA_HOST="localhost"
CC_CASSANDRA_PORT="9042"

# Optional way to run cassandra functions for different profiles (environments):
# Create sh files at $HOME dir which exports CC_CASSANDRA_* variables for each profile
# and source them before run this command. Example:
#
# - open command interpreter (will open default at $HOME dir)
# - run ". ./cassandra_remote_1.sh" (this file includes EXPORT CC_CASSANDRA_HOST=remote.com)
# - run any cassandra command "c_cassandra*"

OUTPUT_FORMAT_HELP_TEXT="OUTPUT_FORMAT \n"
OUTPUT_FORMAT_HELP_TEXT="$OUTPUT_FORMAT_HELP_TEXT""  - 0 ---> open ouput with text editor\n"
OUTPUT_FORMAT_HELP_TEXT="$OUTPUT_FORMAT_HELP_TEXT""  - 1 ---> each row of table will print in new line (long lines will remove/truncate)\n"
OUTPUT_FORMAT_HELP_TEXT="$OUTPUT_FORMAT_HELP_TEXT""  - 2 ---> each row of table will print on a new block\n"

c_cassandra_execute_cql() {
   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local OUTPUT_FORMAT="$1"
   local CQL="$2"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("$OUTPUT_FORMAT_HELP_TEXT" "CQL (with double-quote character at the end and start)")
   ___check_parameters "$@" || { return 2; }

   local CQL_PREFIX=""
   local COLOR_ARG=""
   # Do not ask user the ouput format on this function. becuase user may redirect the outout to any file.
   if [ "$OUTPUT_FORMAT" = "1" ]; then
      COLOR_ARG="--color"
   elif [ "$OUTPUT_FORMAT" = "2" ]; then
      CQL_PREFIX="EXPAND ON;"
      COLOR_ARG="--color"
   elif [ "$OUTPUT_FORMAT" = "0" ]; then
      COLOR_ARG="--no-color"
   else
      ___print_screen "wrong OUTPUT_FORMAT. script will exit"
      return 1
   fi

   local CASSANDRA_COMMAND="\"$CC_STANDALONE_APPS_PATH_ROOT/apache-cassandra-3.11.6/bin/cqlsh\" $COLOR_ARG --username $CC_CASSANDRA_USERNAME --password $CC_CASSANDRA_PASSWORD \"$CC_CASSANDRA_HOST\" $CC_CASSANDRA_PORT --execute \"$CQL_PREFIX $CQL\" "

   if [ "$OUTPUT_FORMAT" = "0" ]; then
      local OUTPUT_FILE="cassandra_latest_output.json"
      local CURRENT_DATE_TIME="$(date '+%Y-%m-%d   %H:%M:%S   %z')"
      echo "Execution date-time: $CURRENT_DATE_TIME" >"$OUTPUT_FILE"
      echo "executed command: $CASSANDRA_COMMAND" >>"$OUTPUT_FILE"
      ___execute_with_eval "$CASSANDRA_COMMAND >> $OUTPUT_FILE "
      "$CC_TEXT_EDITOR_FOR_NON_ROOT_FILES" "$OUTPUT_FILE"

   elif [ "$OUTPUT_FORMAT" = "1" ]; then
      ___execute_with_eval_removed_long_lines "$CASSANDRA_COMMAND"
   else
      ___execute_with_eval "$CASSANDRA_COMMAND"
   fi
}

c_cassandra_list_all_tables_and_keyspaces() {
   c_cassandra_execute_cql "2" "describe tables;"
}

c_cassandra_table_print_data() {
   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local OUTPUT_FORMAT="$1"
   local NAMESPACE="$2"
   local TABLE_NAME="$3"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("$OUTPUT_FORMAT_HELP_TEXT" "NAMESPACE" "TABLE_NAME")
   ___check_parameters "$@" || { return 2; }

   c_cassandra_execute_cql "$OUTPUT_FORMAT" "USE $NAMESPACE; SELECT * FROM $TABLE_NAME;"
}
#################################
#### END OF - CASSANDRA
#################################

c_line_remove_long_enable() {
   if ___do_executables_exist "tput"; then
      tput rmam
   else
      printf '\033[?7l'
   fi
}

c_line_remove_long_disable() {
   if ___do_executables_exist "tput"; then
      tput smam
   else
      printf '\033[?7h'
   fi
}

c_traceroute() {

   # trace ip adress routings

   # prefer 'tracepath' because 'traceroute' is deprecated
   for APP_EXECUTABLE in "$CC_NIX_BIN_ALL_PATH/tracepath" "tracepath"; do
      if ___do_executables_exist "$APP_EXECUTABLE"; then
         ___execute_with_eval "$APP_EXECUTABLE $@ | color_line"
         return
      fi
   done

   for APP_EXECUTABLE in "$CC_NIX_BIN_ALL_PATH/traceroute" "traceroute"; do
      if ___do_executables_exist "$APP_EXECUTABLE"; then
         ___execute_with_eval "$APP_EXECUTABLE $@ | color_line"
         return
      fi
   done

   ___print_screen "'traceroute' or 'tracepath' command not found."
}

c_tree_directories_and_files() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local DIRECTORY="$1"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("DIRECTORY")
   ___check_parameters "$@" || { return 1; }

   for APP_EXECUTABLE in "$CC_NIX_BIN_ALL_PATH/tree" "tree"; do
      if ___do_executables_exist "$APP_EXECUTABLE"; then
         ___execute_with_eval "$APP_EXECUTABLE $DIRECTORY | color_line"
         return
      fi
   done

   if ___do_executables_exist "ls" "grep" "sed"; then
      ___execute_with_eval "ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/' | color_line"
      return
   fi
}

c_port_open_serving_string() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local TEXT_TO_SHARE="$1"
   local LOCAL_PORT="$2"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("TEXT_TO_SHARE" "LOCAL_PORT")
   ___check_parameters "$@" || { return 1; }

   ___execute_with_eval echo "$TEXT_TO_SHARE" "|" nc -v -l "$LOCAL_PORT"

   c_notify_user 1 "port closed"
}

c_port_open_serving_file() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local FILE_TO_SHARE="$1"
   local LOCAL_PORT="$2"
   ##############################
   ##############################
   ##############################

   local FILE_TO_SHARE_W="$SD""$1""$SD"

   ___required_parameters=("FILE_TO_SHARE" "LOCAL_PORT")
   ___check_parameters "$@" || { return 1; }

   ___execute_with_eval nc -v -l "$LOCAL_PORT" "<""$FILE_TO_SHARE_W"

   c_notify_user 1 "port closed $LOCAL_PORT"
}

c_port_kill_all_process() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local PORT_NUMBER="$1"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("PORT_NUMBER")
   ___check_parameters "$@" || { return 1; }

   ___execute lsof -i:"$PORT_NUMBER"

   # -t --> show only process ID
   # -i --> show only internet connections related process
   # -9 --> kill forcefully
   ___execute kill -9 $(lsof -t -i:$PORT_NUMBER)
}

c_port_details() {

   # prefer 'ss' because 'netstat' is deprecated.

   for APP_EXECUTABLE in "$CC_NIX_BIN_ALL_PATH/ss" "ss"; do
      if ___do_executables_exist "$APP_EXECUTABLE"; then
         # --processes --> show each port's porcess id and name
         # --tcp --udp  --> show tcp and udp sockets
         # --all --> display all sockets, not only "listening"
         ___execute_and_color_line "$APP_EXECUTABLE" --all --processes --tcp --udp
         return
      fi
   done

   for APP_EXECUTABLE in "$CC_NIX_BIN_ALL_PATH/netstat" "netstat"; do
      if ___do_executables_exist "$APP_EXECUTABLE"; then
         # PRINT PID AND NAME = -p
         # DISPLAY ALL SOCKET (default: connected) = -a
         # SHOW UDP SOCKETS = -u
         # SHOW TCP SOCKETS = -t
         ___execute_and_color_line "$APP_EXECUTABLE" -p -u -t -a
         return
      fi
   done

   ___print_screen "'netstat' or 'ss' command not found."
}

#######################
# THIS IS NOT READY YET
#######################
___execute_and_color_line() {
   if [ "$CC_ECHO_COLOR" = "true" ]; then
      # we can not use ___print_screen because ___print_screen does not support multiple colors in the same line.
      echo -e "$CC_COLOR_RED""** executing command: $CC_COLOR_GREEN $@ | color_line" "$CC_COLOR_RESET"
   else
      echo "** executing command: $@ | color_line"
   fi

   "$@" | color_line
}

___execute_and_grep_and_color_line() {
   if [ "$CC_ECHO_COLOR" = "true" ]; then
      # we can not use ___print_screen because ___print_screen does not support multiple colors in the same line.
      echo -e "$CC_COLOR_RED""** executing command: $CC_COLOR_GREEN $@ | grep -i "$GREP_COMMAND_PARAM" | color_line" "$CC_COLOR_RESET"
   else
      echo "** executing command: $@ | grep -i "$GREP_COMMAND_PARAM" | color_line"
   fi

   "$@" | grep -i "$GREP_COMMAND_PARAM" | color_line
}

___execute() {
   if [ "$CC_ECHO_COLOR" = "true" ]; then
      # we can not use ___print_screen because ___print_screen does not support multiple colors in the same line.
      echo -e "$CC_COLOR_RED""** executing command: $CC_COLOR_GREEN $@" "$CC_COLOR_RESET"
   else
      echo "** executing command: $@"
   fi

   "$@"
}
#######################
# THIS IS NOT READY YET - END
#######################

___execute_with_eval() {

   # * eval pros:
   #   ** eval is a must in some cases like:
   #      ___execute_with_eval echo hello | grep hello
   #      grep hello will grep whole ___execute_with_eval function which also prints the command itself.
   # * eval cons:
   #   ** eval should be installed on system otherwise command will not work.
   #   ** eval may side effect on some platforms
   #   ** a command which runs with command should be wrapped with " (double quote).
   #      therefor it is unreadable (especially when the command is long).

   if [ "$CC_ECHO_COLOR" = "true" ]; then
      # we can not use ___print_screen because ___print_screen does not support multiple colors in the same line.
      echo -e "$CC_COLOR_RED""** executing command: $CC_COLOR_GREEN $*" "$CC_COLOR_RESET"
   else
      echo "** executing command: $*"
   fi

   ___print_screen
   ___do_executables_exist "eval" && {
      eval "$@"
      return # returns last commands exit code
   }
   ___print_title "'eval' command does not exist. could not run the command."
   return 1 # must return 1 so caller of this function can catch error.
}

___execute_with_eval_removed_long_lines() {

   if [ "$CC_ECHO_COLOR" = "true" ]; then
      # we can not use ___print_screen because ___print_screen does not support multiple colors in the same line.
      echo -e "$CC_COLOR_RED""** executing command: $CC_COLOR_GREEN $*" "$CC_COLOR_RESET"
   else
      echo "** executing command: $*"
   fi

   c_line_remove_long_enable

   ___print_screen
   ___do_executables_exist "eval" && {
      eval "$@"
      c_line_remove_long_disable
      return
   }
   c_line_remove_long_disable
   ___print_title "'eval' command does not exist. could not run the command."
   return 1 # must return 1 so caller of this function can catch error.
}

___nohup_and_disown() {

   ___do_executables_exist "nohup" || {
      ___print_screen "___nohup_and_disown warning:"
      ___print_screen "command does not exist: nohup"
      "$@" &
      disown
      return # returns last commands exit code
   }

   ___do_executables_exist "disown" || {
      ___print_screen "___nohup_and_disown warning:"
      ___print_screen "command does not exist: disown"
      nohup "$@"
      return # returns last commands exit code
   }

   nohup "$@" &
   disown
}

c_partititon_manager___gparted() {

   local ENABLE_FIREJAIL="TRUE"
   local HOME_DIR_NAME="gparted"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_NIX_BIN_ALL_PATH/gparted"
   local ENABLE_ROOT="TRUE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_iso_to_usb___unetbootin() {

   c_path_add "$CC_STANDALONE_APPS_PATH_ROOT/7z"

   local ENABLE_FIREJAIL="TRUE"
   local HOME_DIR_NAME="unetbootin"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/unetbootin-linux64.bin"
   local ENABLE_ROOT="TRUE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_music_remove_metadata___easytag() {

   local ENABLE_FIREJAIL="TRUE"
   local HOME_DIR_NAME="easytag"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_NIX_BIN_ALL_PATH/easytag"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_android_remote_desktop() {

   ___print_screen 'The device should be: '
   ___print_screen '- connected via usb'
   ___print_screen '- usb debug mode should be enabled'
   ___print_screen '- file transfer should be enabled'

   ___do_executables_exist "adb" || { return 1; }

   ___execute adb devices

   local ENABLE_FIREJAIL="FALSE"
   local HOME_DIR_NAME="scrcpy"
   local LINUX_EXECUTABLE_FULL_PATH="scrcpy"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_android_studio() {

   local ENABLE_FIREJAIL="FALSE"
   local HOME_DIR_NAME=""
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/android-studio/bin/studio.sh"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_intellij_idea_community() {

   local ENABLE_FIREJAIL="FALSE"
   local HOME_DIR_NAME=""
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/idea-IC/bin/idea.sh"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS="$@"

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_insomnia() {

   # http client
   local ENABLE_FIREJAIL="FALSE"
   local HOME_DIR_NAME="INSOMNIA"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/Insomnia.AppImage"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_eclipse_ide() {

   local ENABLE_FIREJAIL="FALSE"
   local HOME_DIR_NAME=""
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/eclipse/eclipse"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS="$@"

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_vscode() {

   local ENABLE_FIREJAIL="FALSE"
   local HOME_DIR_NAME=""
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/VSCode-linux-x64/code"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS="$@"

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_vscodium() {

   local ENABLE_FIREJAIL="FALSE"
   local HOME_DIR_NAME=""
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/VSCodium-x86_64.AppImage"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS="$@"

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_atom() {

   local ENABLE_FIREJAIL="FALSE"
   local HOME_DIR_NAME=""
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/atom-amd64/atom"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS="$@"

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_dbeaver() {
   # search keyword: database
   export _JAVA_OPTIONS="-Duser.home=$CC_APPS_HOME/DBEAVER"

   local ENABLE_FIREJAIL="FALSE"
   local HOME_DIR_NAME="DBEAVER"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/dbeaver/dbeaver"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_soapui() {
   export _JAVA_OPTIONS="-Duser.home=$CC_APPS_HOME/SOAPUI"

   local ENABLE_FIREJAIL="FALSE"
   local HOME_DIR_NAME="SOAPUI"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/SoapUI/bin/soapui.sh"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_peazip() {
   # search keyword: rar 7z archive

   local ENABLE_FIREJAIL="TRUE"
   local HOME_DIR_NAME="peazip"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/peazip_portable.LINUX.x86_64.GTK2/peazip"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS="$HOME" # Peazip opens here as default. othwerwise we need to route manually to $HOME (which is using in most cases).

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_song_split___audacity() {

   local ENABLE_FIREJAIL="TRUE"
   local HOME_DIR_NAME="audacity"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_NIX_BIN_ALL_PATH/audacity"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_video_split___avidemux() {

   local ENABLE_FIREJAIL="TRUE"
   local HOME_DIR_NAME="AVIDEMUX"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/avidemux.appImage"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_calculator___speedcrunch() {

   local ENABLE_FIREJAIL="TRUE"
   local HOME_DIR_NAME="speedcrunch"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/speedcrunch"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_photo_editor___gimp() {

   local ENABLE_FIREJAIL="TRUE"
   local HOME_DIR_NAME="GIMP"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/GIMP_AppImage-git-2.10.19-20200227-withplugins-x86_64.AppImage"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_password_manager_KeePassXC() {

   local ENABLE_FIREJAIL="TRUE"
   local HOME_DIR_NAME="KeePassXC"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/KeePassXC-x86_64.AppImage"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_google_chrome() {

   local ENABLE_FIREJAIL="FALFE"
   local HOME_DIR_NAME="google-chrome"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/google-chrome/opt/google/chrome/google-chrome"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_chromium_ungoogled() {

   local ENABLE_FIREJAIL="FALFE"
   local HOME_DIR_NAME="ungoogled-chromium"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/ungoogled-chromium_linux.AppImage"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_tor_browser() {

   local ENABLE_FIREJAIL="FALSE"
   local HOME_DIR_NAME="tor-browser"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/tor-browser_en-US/Browser/start-tor-browser"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_ebook___calibre() {

   local ENABLE_FIREJAIL="TRUE"
   local HOME_DIR_NAME="CALIBRE"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/Calibre-3.18.0.glibc2.14-x86_64.AppImage"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

c_waterfox() {

   local ENABLE_FIREJAIL="FALFE"
   local HOME_DIR_NAME="WATERFOX"
   local LINUX_EXECUTABLE_FULL_PATH="$CC_STANDALONE_APPS_PATH_ROOT/waterfox/waterfox"
   local ENABLE_ROOT="FALSE"
   local APP_PARAMS=""

   ___start_gui_app "$ENABLE_FIREJAIL" "$HOME_DIR_NAME" "$LINUX_EXECUTABLE_FULL_PATH" "$ENABLE_ROOT" "$APP_PARAMS"
}

___start_gui_app() {

   local ENABLE_FIREJAIL="$1"
   local HOME_DIR_NAME="$2"
   local LINUX_EXECUTABLE_FULL_PATH="$3"
   local ENABLE_ROOT="$4"
   local APP_PARAMS="$5"

   ___create_home_and_switch_it "$HOME_DIR_NAME"

   # do not enable profiles on firejail commands. because profile rules (as default) does not allow to read from /nix/* and $HOME/app_name/* directories.

   # do not use "$APP_PARAMS". this makes problem if APP_PARAMS is empty string.

   if [ "$ENABLE_ROOT" = "TRUE" ]; then
      if ___do_executables_exist "firejail"; then
         if [ "$ENABLE_FIREJAIL" = "TRUE" ]; then
            ___run_command_as_root firejail --net=none --noprofile "$LINUX_EXECUTABLE_FULL_PATH" $APP_PARAMS
            return
         fi
      fi
      ___run_command_as_root "$LINUX_EXECUTABLE_FULL_PATH" $APP_PARAMS
   else
      if ___do_executables_exist "firejail"; then
         if [ "$ENABLE_FIREJAIL" = "TRUE" ]; then
            ___nohup_and_disown firejail --net=none --noprofile "$LINUX_EXECUTABLE_FULL_PATH" $APP_PARAMS
            return
         fi
      fi
      ___nohup_and_disown "$LINUX_EXECUTABLE_FULL_PATH" $APP_PARAMS
   fi
}

c_mp3_remove_metadata() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local DIRECTORY_TO_CLEAN="$@"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("DIRECTORY_TO_CLEAN")
   ___check_parameters "$@" || { return 2; }

   ___is_empty_string "$DIRECTORY_TO_CLEAN" && { DIRECTORY_TO_CLEAN="$(pwd)" || {
      echo "error 100"
      return
   }; }

   ___execute "$CC_NIX_BIN_ALL_PATH/eyeD3" --remove-all "$DIRECTORY_TO_CLEAN"
}

c_photo_remove_metadata() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local DIRECTORY_TO_CLEAN="$@"
   ##############################
   ##############################
   ##############################

   ___is_empty_string "$DIRECTORY_TO_CLEAN" && { DIRECTORY_TO_CLEAN="$(pwd)" || {
      echo "error 100"
      return
   }; }

   ___execute "$CC_STANDALONE_APPS_PATH_ROOT/Image-ExifTool-11.89/exiftool" -all= "$DIRECTORY_TO_CLEAN/"* # do not remove space character after =
}

c_photo_reduce_size() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local DIRECTORY_TO_CLEAN="$@"
   ##############################
   ##############################
   ##############################

   ##############################
   # HELP
   ##############################
   if [ "-h" = "$1" ]; then
      ___print_screen "parameters:"
      ___print_screen "1- DIRECTORY_TO_CLEAN (default: current dir)"
      return
   fi
   ##############################
   ##############################
   ##############################

   ___is_empty_string "$DIRECTORY_TO_CLEAN" && { DIRECTORY_TO_CLEAN="$(pwd)" || {
      echo "error 100"
      return
   }; }

   ##############################
   # RESUME WARNING
   ##############################
   ___print_screen "script will reduce all images of $DIRECTORY_TO_CLEAN . do you want to resume? y/n"
   read RESUME

   if [ "$RESUME" != "y" ]; then
      ___print_screen "script will exit."
      return
   fi
   ##############################
   ##############################
   ##############################

   ___execute_with_eval "$CC_NIX_BIN_ALL_PATH/jpegoptim" --max=60 "$DIRECTORY_TO_CLEAN/"*
}

c_date_reset_of_files_and_subdirs() {

   if [ "-h" = "$1" ]; then
      ___print_screen "no need for parameters. the script will clean durrent directory."
      return
   fi

   ___print_screen "script will reset all dates of sub files and directories of current directory. do you want to resume? y/n"
   read RESUME

   if [ "$RESUME" != "y" ]; then
      ___print_screen "script will exit."
      return
   fi

   ___execute_with_eval find -type f -exec touch {} +
}

c_calculator() {

   ___print_screen "Type directly and press 'enter'. examples:"
   ___print_screen "(1^2)*3"
   ___print_screen "sqrt(9)    ---> Square root"
   ___print_screen
   ___print_screen "Scale is 20 now. To change it type:"
   ___print_screen "scale=5;    ---> that means only 5 digits will print after comma."
   ___print_screen

   # -q --> do not print welcome text
   # -l --> set scale as 20
   bc -q -l
}

c_characters_print() {

   ___print_title "greek characters:"

   ___print_screen "Α α Β β Γ γ Δ δ Ε ε Ζ ζ Η η Θ θ Κ κ Λ λ Μ μ Ν ν Ξ ξ Ο ο Π π Ρ ρ Σ σ/ς Τ τ Υ υ Φ φ Χ χ Ψ ψ Ω ω"

   ___print_title "other characters:"

   ___print_screen "é € £ $ ¶"

   ___print_title "ascii table:"

   ___print_screen '! " # $ % & '\'' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ \ ] ^ _ ` a b c d e f g h i j k l m n o p q r s t u v w x y z { | } ~'

   ___print_title "turkish characters:"

   ___print_screen "ç ö ş ğ ü ı Ç Ö Ş Ğ Ü İ"

   # do not use ___print_screen here. otherwise "tab" character will not print.
   echo "Tab character is inside here -->\t<--there"

   # in some terminals tab character not showing with echo. I try also with printf which is more standart.
   printf "tab character is also here -->\t<--\n"
}

c_user_list() {
   ___execute_with_eval cat "/etc/passwd" "|" grep -v "/nologin" "|" grep -v "/bin/false" "|" color_line
}

c_calendar_print() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local YEAR="$1"
   ##############################
   ##############################
   ##############################

   ___is_empty_string "$YEAR" && { YEAR="$(date +%Y)" || {
      echo "error 100"
      return
   }; }

   if ___do_executables_exist "ncal"; then
      # -w --> show weeks
      # -M --> start weeks with Monday
      # -b --> old style layout
      ___execute ncal -w "$YEAR" -M -b

   elif ___do_executables_exist "gcal"; then
      ___execute gcal -with-week-number "$YEAR"

   elif ___do_executables_exist "cal"; then
      ___execute cal "$YEAR"
   fi
}

c_ip() {

   # ifconfig is deprecated. we prefer first 'ip' command.

   if ___do_executables_exist "ip"; then
      # COLORFULL OUTPUT = -c
      # SHOW ALL INTERFACES = -a
      ___execute ip -c a
      return
   fi

   for APP_EXECUTABLE in "$CC_NIX_BIN_ALL_PATH/ifconfig" "ifconfig"; do
      if ___do_executables_exist "$APP_EXECUTABLE"; then
         # SHOW ALL INTERFACES = -a
         ___execute "$APP_EXECUTABLE" -a
         return
      fi
   done

   ___print_screen "'ifconfig' or 'ip' command not found"
}

c_copy() {

   # TODO: this should be same like download script. it should be resumable.
   ___print_screen 'rsync --info=progress2 --bwlimit=10000 -a --append --progress source-file destination-file'
   ___print_screen
   ___print_screen '- istenildiği zaman CTRL+C ile komut satırı durdurulabilir. daha sonra aynı komut çalıştırıldığında işlem devam edecektir.'
   ___print_screen
   ___print_screen '- yukarıdaki komut kesilse bile targetta dosyayı kopyalandığı kadarki boyutu ile oluşturuyor.'
   ___print_screen '--append parametresi işte burada devreye giriyor. önceden kopyalanan kısmı validate etmeden sonuna ekleme yapmamızı sağlıyor. yani rsync hiçbir meta bilgi tutumuyor.'
}

c_find_text_inside_files() {
   ___print_title 'below command prints: first the file name and than the founded line (for binary files founded line is not printed)'
   ___print_screen 'grep -r -i text_to_search /dir'
   ___print_screen
   ___print_screen '-l : sometimes printed line is very long. therefore we can disable to print the founded line.'
   ___print_screen '-r : recursive directories'
   ___print_screen '-i : ignore case'
}

c_ocr() {
   ___print_screen "did not implemented yet"
   return
   # TODO: does not work
   tesseract --help
   ___print_screen "tesseract --tessdata-dir /my-language-files/dir /path/1.png /path/1.txt"
}

___prepare_youtubedl() {
   YOUTUBEDL_EXECUTABLE="$CC_STANDALONE_APPS_PATH_ROOT/youtube-dl/youtube-dl"

   if ___do_executables_exist python3; then
      if ! ___do_executables_exist python; then
         ___execute mkdir "$CC_STANDALONE_APPS_PATH_ROOT/python_3_link"
         ___execute ln --symbolic "$(which python3)" "$CC_STANDALONE_APPS_PATH_ROOT/python_3_link/python"
         c_path_add "$CC_STANDALONE_APPS_PATH_ROOT/python_3_link"
      fi
   fi

   # -U --> update youtubedl
   ___execute "$YOUTUBEDL_EXECUTABLE" -U

   ___print_screen '- youtube-dl command downloads from many services. not only youtube.'
   ___print_screen '- youtube list url example: https://www.youtube.com/playlist?list=PLOGi5-fAu8bEIDVIZAM9d73H8h94EDeRq'
   ___print_screen '- if download fails try new version. download the official portable.'
   ___print_screen "- if zsh will give 'no matches found' error, make sure URL is quoted string with \" "
}

c_media_download_video_or_list() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local VIDEO_URL="$1"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("VIDEO_URL")
   ___check_parameters "$@" || { return 1; }

   ___prepare_youtubedl

   # only for some web pages
   c_path_add "$CC_STANDALONE_APPS_PATH_ROOT/phantomjs-2.1.1-linux-x86_64/"

   # --write-sub --> download subtitles. subtitle details are given in: --sub-lang
   # -i --> ignore errors. if any error happens then resumes with the next media (if the URL is list)
   # --rm-cache-dir --> it removes cache. sometimes cache make bugs. it does not store too much files. so it is better to clean everytime.
   ___execute "$YOUTUBEDL_EXECUTABLE" -v --rm-cache-dir -i --write-sub --sub-lang "eng,tr,el,en,en-US,en-UK,en-GB" "$VIDEO_URL"
}

c_media_download_only_audio() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local MEDIA_URL="$1"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("MEDIA_URL")
   ___check_parameters "$@" || { return 1; }

   ___prepare_youtubedl

   # this is need if file conversion will need
   c_path_add "$CC_STANDALONE_APPS_PATH_ROOT/ffmpeg-4.2.2-amd64-static/"

   # only for some web pages
   c_path_add "$CC_STANDALONE_APPS_PATH_ROOT/phantomjs-2.1.1-linux-x86_64/"

   # --extract-audio --> it download the video container and it splits the audio with ffmpeg which should be on path.
   # --audio-quality 0 --> default is 5. 0 is best quality.
   # -i --> ignore errors. if any error happens then resumes with the next media (if the URL is list)
   # --rm-cache-dir --> it removes cache. sometimes cache make bugs. it does not store too much files. so it is better to clean everytime.
   ___execute "$YOUTUBEDL_EXECUTABLE" --rm-cache-dir -i --extract-audio --audio-quality 0 "$MEDIA_URL"
}

c_port_forward() {
   ___print_title 'list all forwardings:'
   ___print_screen "--upnpc -l"
   ___print_screen
   ___print_title 'create new:'
   ___print_screen '--upnpc -e personel_comment -a 192.168.0.22 6002 6002 TCP '
}

c_media_convert() {
   ___print_title "$CC_STANDALONE_APPS_PATH_ROOT/ffmpeg-4.2.2-amd64-static/ffmpeg"
   ___print_screen
   ___print_screen "convert only format (auto recognize from file extension):"
   ___print_screen "ffmpeg -i input_file.mp4 ouput_file.mp3"
   ___print_screen
   ___print_title 'remove only sound from video:'
   ___print_screen 'ffmpeg -vn -acodec copy -i input_file.mp4 ouput_file.mp4'
   ___print_screen
   ___print_title 'split video:'
   ___print_screen "* -c copy --> splits video in seconds. this should be pass after -i argument. this is a bug. othwise you will get: Unknown decoder copy."
   ___print_screen "* -ss --> start time"
   ___print_screen "* -t --> end time"
   ___print_screen 'ffmpeg -ss 00:10:00 -t 00:11:00 -i input_file.mp4 -c copy output_1_minute_part.mp4'
}

c_hardware_info() {

   ___do_executables_exist "lscpu" "lshw" "lsusb" || { return 1; }

   ___print_title '##############################'
   ___print_title 'cpu info'
   ___print_title '##############################'
   ___execute_with_eval lscpu
   ___print_title '##############################'
   ___print_title 'usb devices'
   ___print_title '##############################'
   ___execute_with_eval lsusb
   ___print_screen '##############################'
   ___print_screen
   ___print_title 'find the device informations with "dmesg" command.'
   ___print_screen
   ___print_title 'all data:'
   ___print_screen "-- sudo lshw > $HOME/all_hardware.yml"
}

c_disk_space_analyze() {

   local DUC_EXECUTABLE="$CC_NIX_BIN_ALL_PATH/duc"

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local DIR="$1"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("DIR")
   ___check_parameters "$@" || { return 2; }

   ___do_executables_exist "$DUC_EXECUTABLE" || { return 1; }

   ___print_screen
   ___print_title 'indexing the directory...'
   ___execute_with_eval $DUC_EXECUTABLE index "$DIR" || {
      echo "error 100"
      return
   }
   ___print_screen 'end of indexing.'
   ___print_screen
   ___print_title 'listing only root folder as tree:'
   ___execute_with_eval $DUC_EXECUTABLE ls -Fg "$DIR" || {
      echo "error 101"
      return
   }
   ___print_screen
   ___print_screen 'listing sub-directories as tree:'
   ___execute_with_eval $DUC_EXECUTABLE ls -FgR "$DIR" || {
      echo "error 102"
      return
   }
   ___print_screen
   ___print_title 'shows as an image:'
   ___print_screen "-- $DUC_EXECUTABLE gui $DIR"
   ___print_screen
   ___print_title 'interact (console) mode:'
   ___print_screen "-- $DUC_EXECUTABLE ui $DIR"
}

c_directory_size() {

   ___do_executables_exist "du" || { return 1; }

   ___print_title "parameters:"
   ___print_screen "- P : does not follows symbolic links"
   ___print_screen "- max-depth=1 : list only given directory"
   ___print_screen "- a: show files (not only directories)"
   ___print_screen "- total: shows also total above"
   ___print_screen "- b or h: human readble or only bytes"
   ___print_screen "- apparent-size: shows real size of file. not the disk size."
   ___print_screen
   ___print_title "Human readable:"
   ___execute_with_eval du -P -a --total -h --max-depth=1 "$1"
   ___print_screen
   ___print_screen "-----------------------"
   ___print_screen
   ___print_title "Bytes (exact values):"
   ___execute_with_eval du -P -a --total -b --max-depth=1 "$1"
}

c_partition_list() {

   ___do_executables_exist "parted" || { return 1; }

   # LIST PARTITIONS OF ALL DEVICES = -l
   ___run_command_as_root parted -l
}

c_rename_files_with_shell() {

   ##############################
   # ABOUT
   ##############################
   # massren alternative.
   # massren does not have any package installer (deb, rpm, snap, flatpak...) or standalone version.
   # massren depends on 'go' platform. this is a simple shell alternative.
   ##############################
   ##############################
   ##############################

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local DIRECTORY_TO_RENAME="$1"
   local EXLUDE_REGEX="$2"
   ##############################
   ##############################
   ##############################

   # TODO: a bug exist about for files which have $ character.

   # sort is needed when we want same changes apply to another (cloned) directory (like backup)
   ___do_executables_exist "mkdir" "mv" "expr" "find" "while" "read" "sort" || { return 1; }

   ___do_executables_exist "sed" || ___do_executables_exist "awk" || { return 2; }

   ___required_parameters=("DIRECTORY_TO_RENAME" "EXLUDE_REGEX")
   ___check_parameters "$@" || { return 3; }

   local DIRECTORY_TO_RENAME_LENGHT="$(expr length \""$DIRECTORY_TO_RENAME"\")"
   DIRECTORY_TO_RENAME_LENGHT=$((DIRECTORY_TO_RENAME_LENGHT - 2))

   OLD_FILE_LIST="$HOME/old_files_list.txt"
   NEW_FILE_LIST="$HOME/new_files_list.txt"
   echo "" >"$OLD_FILE_LIST"
   echo "" >"$NEW_FILE_LIST"

   # do not use other loop types because they will break if file name have special character: https://stackoverflow.com/questions/9612090/how-to-loop-through-file-names-returned-by-find ("web.archive.org" and "archive.is". archived date: 01/05/2020)
   find "$DIRECTORY_TO_RENAME" -type f -name "*" ! -path "*/$EXCLUDE_REGEX/*" -print0 | sort -z |
      while IFS= read -r -d '' FILE_OR_DIR_FULL_PATH; do
         echo "$FILE_OR_DIR_FULL_PATH" >>"$OLD_FILE_LIST"
         echo "${FILE_OR_DIR_FULL_PATH:$DIRECTORY_TO_RENAME_LENGHT}" >>"$NEW_FILE_LIST"
      done

   "$CC_TEXT_EDITOR_FOR_NON_ROOT_FILES" "$NEW_FILE_LIST"

   ___print_screen 'if you changed the file names, type "y" to resume...'
   read RESUME

   if [ "$RESUME" != "y" ]; then
      ___print_screen "script will exit."
      return
   fi

   local LINE_NUMBER="1"
   local FIRST_LINE_OF_OLD_FILE_LIST="TRUE"
   while read OLD_FILE_FULL_PATH; do
      if [ "$FIRST_LINE_OF_OLD_FILE_LIST" = "TRUE" ]; then
         FIRST_LINE_OF_OLD_FILE_LIST="FALSE"
      else
         LINE_NUMBER=$((LINE_NUMBER + 1))

         local NEW_RELATIVE_FILE_NAME=""

         if ___do_executables_exist "sed"; then
            NEW_RELATIVE_FILE_NAME=$(sed "$LINE_NUMBER"'!d' "$NEW_FILE_LIST")
         elif ___do_executables_exist "awk"; then
            NEW_RELATIVE_FILE_NAME=$(awk 'NR=='"$LINE_NUMBER" "$NEW_FILE_LIST")
         else
            return 4
         fi

         if [ "$OLD_FILE_FULL_PATH" != "$DIRECTORY_TO_RENAME$NEW_RELATIVE_FILE_NAME" ]; then
            # -p --> do not give error if dir already exist
            local FOLDER="$(dirname "$DIRECTORY_TO_RENAME$NEW_RELATIVE_FILE_NAME")"
            mkdir -p "$FOLDER"
            ___execute_with_eval "mv" \'"$OLD_FILE_FULL_PATH"\' \'"$DIRECTORY_TO_RENAME$NEW_RELATIVE_FILE_NAME"\'

         fi
      fi
   done <"$OLD_FILE_LIST"
}

c_rename_files_and_dirs___massren() {

   local MASSREN_EXECUTABLE="$CC_NIX_BIN_ALL_PATH/massren"

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local DIR="$1"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("DIR")
   ___check_parameters "$@" || { return 2; }

   ___do_executables_exist "$MASSREN_EXECUTABLE" "$CC_TEXT_EDITOR_FOR_NON_ROOT_FILES" || { return 1; }

   if [ "$DIR" = "." ]; then
      ___print_screen "directory parameter should be full path."
      return
   fi

   ___print_title 'setting your text editor:'
   ___execute_with_eval "$MASSREN_EXECUTABLE" --config editor "$CC_TEXT_EDITOR_FOR_NON_ROOT_FILES" || {
      echo "error 100"
      return
   }
   ___execute_with_eval "$MASSREN_EXECUTABLE" --verbose "$DIR""/*"
}

c_diff_directories() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local DIR1="$1"
   local DIR2="$2"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("DIR1" "DIR2")
   ___check_parameters "$@" || { return 2; }

   ___do_executables_exist "diff" || { return 1; }

   ___execute_with_eval diff --recursive --side-by-side "$DIR1" "$DIR2"
}

c_sync_directories() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local SOURCE_DIRECTORY="$1"
   local DESTINATION_DIRECTORY="$2"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("SOURCE_DIRECTORY" "DESTINATION_DIRECTORY")
   ___check_parameters "$@" || { return 2; }

   ___do_executables_exist "rsync" "eval" || { return 1; }

   # --omit-dir-times --no-perms --inplace parameters are required for android usb devices

   local RSYNC_COMMAND="rsync --recursive --archive -verbose --delete-excluded --size-only --progress --omit-dir-times --no-perms --recursive --inplace \"$SOURCE_DIRECTORY\"/ \"$DESTINATION_DIRECTORY\"/"

   ___print_screen "list only changes first?"
   ___print_screen "y/n"
   read listOnlyChanges

   if [ "$listOnlyChanges" = "y" ]; then
      ___execute_with_eval "$RSYNC_COMMAND --dry-run" || {
         echo "error 100"
         return
      }

      ___print_screen "accept above changes?"
      ___print_screen "y/n"
      read choice

      if [ "$choice" != "y" ]; then
         ___print_screen "wrong choice or decline by user."
         return
      fi

   elif [ "$listOnlyChanges" != "n" ]; then

      ___print_screen "wrong choice."
      return
   fi

   ___execute_with_eval "$RSYNC_COMMAND"

   c_notify_user 5 "sync finished"
}

___backup_directory_if_exist() {

   local EXTRACT_DIR="$1"

   if ___do_directories_exist "$EXTRACT_DIR"; then
      local DIR_SUFFIX="$(date '+%d_%H_%M_%S')"
      ___execute_with_eval mv "$EXTRACT_DIR" "$EXTRACT_DIR""_backup_$DIR_SUFFIX"
   fi
}

___return_new_dir_name_without_extension() {

   local EXTRACT_DIR="$1"
   local EXTENSION="$2"
   local ARCHIVE_FILE="$3"

   if [ "$EXTRACT_DIR" = "NOT_DEFINED_BY_USER" ]; then
      echo ${ARCHIVE_FILE%"$EXTENSION"}
      return
   else
      echo ${EXTRACT_DIR%"$EXTENSION"}
      return
   fi
}

c_archive_extract() {

   ##############################
   # ABOUT
   ##############################
   # this can extract also '.deb' files.
   # deb files have "control.tar.gz" and "data.tar.xz" inside. this command extracts only "data.tar.xz" from deb. this is enough to run the app inside the deb.
   #
   # 'Note: Peazip (GUI) shows the command line arguments for a compression operating which can be done from Peazip GUI.'
   #
   # keywords: zip, rar, tar, gz
   ##############################
   ##############################
   ##############################

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local ARCHIVE_FILE="$1"
   local EXTRACT_DIR="$2"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("ARCHIVE_FILE" "EXTRACT_DIR_(if_empty_then_generates_auto_name)")
   ___check_parameters "$@" || { return 1; }

   if ___is_empty_string "$EXTRACT_DIR"; then
      EXTRACT_DIR="NOT_DEFINED_BY_USER"
   fi

   if ___string_ends_with "$ARCHIVE_FILE" ".deb"; then
      EXTRACT_DIR="$(___return_new_dir_name_without_extension "$EXTRACT_DIR" ".deb" "$ARCHIVE_FILE")"
      ___backup_directory_if_exist "$EXTRACT_DIR"

      ___execute_with_eval dpkg-deb -xv "$ARCHIVE_FILE" "$EXTRACT_DIR"

   elif ___do_executables_exist "7z"; then
      # 7z autodetects the formats
      # x --> extract files with full paths (subdirectories)
      ___execute_with_eval 7z x -o"$EXTRACT_DIR" "$ARCHIVE_FILE"

   elif ___string_ends_with "$ARCHIVE_FILE" ".tar.gz"; then
      ___execute_with_eval mkdir -p "$EXTRACT_DIR"
      ___execute_with_eval tar xzf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

   elif ___string_ends_with "$ARCHIVE_FILE" ".zip"; then
      ___execute_with_eval unzip -q "$ARCHIVE_FILE" -d "$EXTRACT_DIR"

   elif ___string_ends_with "$ARCHIVE_FILE" ".tar.bz2"; then
      ___execute_with_eval mkdir -p "$EXTRACT_DIR"
      ___execute_with_eval tar xjf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

   elif ___string_ends_with "$ARCHIVE_FILE" ".bz2"; then
      ___execute_with_eval tar -jf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

   elif ___string_ends_with "$ARCHIVE_FILE" ".tar"; then
      ___execute_with_eval tar xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

   elif ___string_ends_with "$ARCHIVE_FILE" ".tbz2"; then
      ___execute_with_eval tar xjf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

   elif ___string_ends_with "$ARCHIVE_FILE" ".tgz"; then
      ___execute_with_eval tar xzf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

   elif ___string_ends_with "$ARCHIVE_FILE" ".rar"; then
      if ___do_executables_exist "rar"; then
         ___execute_with_eval rar x "$ARCHIVE_FILE" "$EXTRACT_DIR"
      elif ___do_executables_exist "unrar"; then
         ___execute_with_eval unrar x "$ARCHIVE_FILE" "$EXTRACT_DIR"/*
      else
         ___print_screen "unrar or rar command not found."
      fi

   elif ___string_ends_with "$ARCHIVE_FILE" "tar.xz"; then
      ___execute_with_eval mkdir -p "$EXTRACT_DIR"
      ___execute_with_eval tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"
   fi

   c_notify_user 1 "archive extract command finished"
}

c_archive() {

   ##############################
   # ABOUT
   ##############################
   # 'Note: Peazip (GUI) shows the command line arguments for a compression operating which can be done from Peazip GUI.'
   # keywords: zip, rar, tar, gz
   ##############################
   ##############################
   ##############################

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local DIR_TO_ARCHIVE="$1"
   local FORMAT="$2"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("DIR_TO_ARCHIVE" "FORMAT")
   ___check_parameters "$@" || { return 2; }

   # ADD FILES TO ARCHIVE = a
   # COMPRESSION METHOD STORE ONLY = -m0=Copy
   ___execute_with_eval 7z a -t"$FORMAT" -m0=Copy "$DIR_TO_ARCHIVE.$FORMAT" "$DIR_TO_ARCHIVE"
}

c_panel_polybar() {
   ___nohup_and_disown polybar "bar1"
}

___create_home_and_switch_it() {

   ___is_empty_string "$1" && return # this is for developer apps (like eclipse, other IDE, vscode...)

   mkdir -p "$CC_APPS_HOME" || {
      ___print_screen "Error: could not create $CC_APPS_HOME (\$CC_APPS_HOME) directory. \$HOME will not change. The script will resume."
      return
   } # -p ignores the warning: folder already exist.

   mkdir -p "$CC_APPS_HOME/$1" || {
      ___print_screen "Error: could not create directory under $CC_APPS_HOME/$1. \$HOME will not change. The script will resume."
      return
   } # -p ignores the warning: folder already exist.

   HOME="$CC_APPS_HOME/$1"
}

c_switch_home_to_current_user() {

   HOME="/home/$USER"
}

___nix_install_app() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local ATTRIBUTE="$1"
   local APP_ID="$2"
   local ADDITIONAL_CONFIG="$3"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("ATTRIBUTE" "APP_ID" "ADDITIONAL_CONFIG")
   ___check_parameters "$@" || { return 2; }

   ___is_empty_string "$ATTRIBUTE" && ATTRIBUTE=""
   ___is_empty_string "$ADDITIONAL_CONFIG" && ADDITIONAL_CONFIG=""

   ___run_command_as_nix_user "$CC_NIX_BIN_ALL_PATH/nix-env -i$ATTRIBUTE $APP_ID --arg config \"{ allowUnfree = true; $ADDITIONAL_CONFIG }\""
}

c_nix_install_app() {

   ___nix_install_app "NULL" "$1" "NULL"
}

c_nix_install_app_by_attribute() {

   ___nix_install_app "A" "$1" "NULL"
}

c_nix_install_app_with_config() {

   ___nix_install_app "NULL" "$1" "$2"
}

c_nix_remove_app() {

   ___run_command_as_nix_user "$CC_NIX_BIN_ALL_PATH/nix-env -e $1"
}

c_nix_list_all_apps() {

   ___run_command_as_nix_user "$CC_NIX_BIN_ALL_PATH/nix-env -q"
}

c_nix_install_all_updates() {

   ___run_command_as_nix_user "$CC_NIX_BIN_ALL_PATH/nix-channel --update nixpkgs --arg config \"{ allowUnfree = true; }\""
   ___run_command_as_nix_user "$CC_NIX_BIN_ALL_PATH/nix-env -u \"*\" --arg config \"{ allowUnfree = true; }\""
}

___run_command_as_nix_user() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local COMMAND_WITH_PARAMS="$1"
   ##############################
   ##############################
   ##############################

   if ___do_executables_exist "su"; then
      # RUN THE COMMAND = -c
      ___execute_with_eval "su $CC_NIX_USER -c '""$COMMAND_WITH_PARAMS""'"
   else
      ___print_screen "could not run command as $NIXUSER. reason: 'su' command not found."
   fi
}

___run_command_as_root() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local COMMAND_WITH_PARAMS="$@"
   ##############################
   ##############################
   ##############################

   if ___do_executables_exist "sudo"; then
      # env "PATH=$PATH" = set environment variables for sudo command
      ___execute_with_eval "sudo env \"PATH=$PATH\" $COMMAND_WITH_PARAMS"
      return
   fi

   if ___do_executables_exist "su"; then
      # TODO pass environmnt variable like above
      ___execute_with_eval "su -c '""$COMMAND_WITH_PARAMS""'"
      return
   fi

   ___print_screen "'sudo' or 'su' commands not found. script will try to execute the command as current user."

   # maybe the current user is privilaged
   ___execute_with_eval "$COMMAND_WITH_PARAMS"
}

c_firefox_profile_manager() {

   ___nohup_and_disown firefox -P -no-remote --class FIREFOX_PROFILE_MANAGER
}

c_firefox_create_new_profile() {

   ___do_executables_exist "cp" "firefox" "local" "read" || { return 1; }

   local randomProfileNameSuffix=""

   if ___is_empty_string "$RANDOM"; then
      ___print_screen "type any keyword to remember this profile"
      read randomProfileNameSuffix
      if ___is_empty_string "$randomProfileNameSuffix"; then
         ___print_screen "you did not anything. script will exit."
         return
      fi
   else
      randomProfileNameSuffix=$((RANDOM % 123456789))
   fi

   local RANDOM_PROFILE_NAME="profile$randomProfileNameSuffix"

   ___print_screen "new profile name: $RANDOM_PROFILE_NAME"

   firefox -CreateProfile "$RANDOM_PROFILE_NAME $HOME/.mozilla/firefox/$RANDOM_PROFILE_NAME" || {
      echo "error 100"
      return
   }

   cp "$HOME/APPS/only_mozilla_telemetry_blocked.js" "$HOME/.mozilla/firefox/$RANDOM_PROFILE_NAME/user.js" || {
      echo "error 101"
      return
   }

   ___nohup_and_disown firefox -P "$RANDOM_PROFILE_NAME"
}

c_csv_pritify() {

   ##############################
   # FUNCTION PARAMETERS
   ##############################
   local FILE_CSV="$1"
   ##############################
   ##############################
   ##############################

   ___required_parameters=("FILE_CSV")
   ___check_parameters "$@" || { return 2; }

   ___do_executables_exist "perl" "column" "less" || { return 1; }

   (perl -pe 's/((?<=,)|(?<=^)),/ ,/g;' <"$FILE_CSV") | column -t -s, | less -S
}

c_dns_change() {

   ___print_screen 'DNS LIST:
   
   UncensoredDNS
   91.239.100.100
   89.233.43.71

   adguard
   176.103.130.130
   176.103.130.131
   176.103.130.132
   176.103.130.134

   CZ.NIC
   193.17.47.1
   185.43.135.1

   level3
   209.244.0.3
   209.244.0.4

   Open
   208.67.222.222
   208.67.220.220

   google
   8.8.8.8
   8.8.4.4

   yandex
   77.88.8.8
   77.88.8.1

   comodo
   8.26.56.26
   8.20.247.20

   norton
   199.85.126.10
   199.85.127.10

   other DNS servers:
   https://www.privacytools.io/providers/dns/
   '

   ___do_executables_exist "cp" "read" "date" "service" "$CC_TEXT_EDITOR_FOR_ROOT_FILES" || { return 1; }

   local CONNECTION_LIST_DIR="/etc/NetworkManager/system-connections/"
   local CONNECTION_INDEX=0

   for CONNECTION_FILE_FULL_PATH in "$CONNECTION_LIST_DIR"*; do
      CONNECTION_INDEX=$((CONNECTION_INDEX + 1))
      local CONNECTION_FILE_NAME="$(basename "#$CONNECTION_FILE_FULL_PATH")"
      ___print_screen "$CONNECTION_INDEX - $CONNECTION_FILE_NAME"
   done

   ___print_screen "choose your connection above (type the number):"
   read userChoiceIndex

   CONNECTION_INDEX=0
   for CONNECTION_FILE_FULL_PATH in "$CONNECTION_LIST_DIR"*; do
      CONNECTION_INDEX=$((CONNECTION_INDEX + 1))

      if [ "$CONNECTION_INDEX" = "$userChoiceIndex" ]; then

         ___print_screen "Getting backup to $HOME"
         CONNECTION_FILE_NAME="$(basename "#$CONNECTION_FILE_FULL_PATH")"
         local NOW=$(date '+%Y-%m-%d__%H:%M:%S__%z') || {
            echo "error 100"
            return
         }
         ___run_command_as_root cp "$CONNECTION_FILE_FULL_PATH" "$HOME/$CONNECTION_FILE_NAME""_backup_$NOW" || {
            echo "error 101"
            return
         }
         ___run_command_as_root "$CC_TEXT_EDITOR_FOR_ROOT_FILES" "$CONNECTION_FILE_FULL_PATH" || {
            echo "error 102"
            return
         }
         ___run_command_as_root service network-manager restart || {
            echo "error 103"
            return
         }
         return
      fi
   done

   ___print_screen "index that you type is wrong. try again."
}

c_host_file_edit_or_view() {

   ___do_executables_exist "cat" "read" "$CC_TEXT_EDITOR_FOR_ROOT_FILES" || { return 1; }

   local HOST_FILE="/etc/hosts"

   ___do_files_exist "$HOST_FILE" || return 100

   ___execute_with_eval "cat $HOST_FILE | color_line"

   ___print_screen "do you wanna edit? y/n"
   read userEditChoice

   if [ "$userEditChoice" = "y" ]; then
      ___run_command_as_root "$CC_TEXT_EDITOR_FOR_ROOT_FILES" "$HOST_FILE"

      ___print_screen "no need restart a service here. hosts file changes takes effect immediately."
      return
   else
      ___print_screen "script will exit"
      return
   fi
}

c_apt_cleaner() {

   ___do_executables_exist "apt-get" || { return 1; }

   ___run_command_as_root apt-get autoclean
   ___run_command_as_root apt-get autoremove
   ___run_command_as_root apt-get clean
}

___echo_color_test() {

   ___do_files_exist "$CC_SCRIPTS_FILE_PATH" || return 100

   local TEST_COMMANDS=". \"$CC_SCRIPTS_FILE_PATH\"; ___echo_color_test_current_shell"

   echo "-- running on zsh"
   zsh -c "$TEST_COMMANDS" || return 102

   echo "-- running on bash"
   bash -c "$TEST_COMMANDS" || return 103
}

___echo_color_test_current_shell() {

   echo "** colors below should be on their names:"
   echo

   CC_ECHO_COLOR=true
   ___print_screen "blue"
   ___print_title "red"
   echo "default"

   CC_ECHO_COLOR=false
   ___print_screen "default"
   ___print_title "default"
   echo "default"
   echo
}

___exit() {
   echo "error $1"
   exit
}

___do_directories_exist() {

   for DIRECTORY in "$@"; do
      if [ ! -d "$DIRECTORY" ]; then
         return 1
      fi
   done
}

___do_files_exist() {

   for FILE in "$@"; do
      if [ ! -f "$FILE" ]; then
         ___print_screen "file does not exist: $FILE"
         return 1
      fi
   done
}

___check_parameters() {

   if [ "$1" = "-h" ]; then
      ___print_title "required parameters"
      for param in "${___required_parameters[@]}"; do
         ___print_screen "$param"
      done
      ___required_parameters=()
      return 1
   fi

   local REQUIRED_PARAM_COUNT="${#___required_parameters[@]}"
   local USER_SENDED_PARAM_COUNT="$#"

   if [ "$REQUIRED_PARAM_COUNT" = "$USER_SENDED_PARAM_COUNT" ]; then
      ___required_parameters=()
      return 0
   else
      ___print_screen "check the parameters. use -h to see the parameters."
      ___required_parameters=()
      return 2
   fi
}

# detect this script file path
# this variable can be use by other functions of this script. thus it's exporting.
export CC_SCRIPTS_FILE_PATH=""
if [ "$0" = "bash" ]; then
   # this case is only when script is sourcing on bash
   CC_SCRIPTS_FILE_PATH="$BASH_SOURCE" # "$BASH_SOURCE" is same as "$_". both can be use.
elif [ "$0" = "/usr/bin/bash" ]; then
   # this case is when using MINGW on ms-windows
   CC_SCRIPTS_FILE_PATH="$BASH_SOURCE" # "$BASH_SOURCE" is same as "$_". both can be use.
else
   # this case is on zsh
   CC_SCRIPTS_FILE_PATH="$0"
fi

# if cc_script sourced with relative path, we convert to full path.
if ___string_starts_with "$CC_SCRIPTS_FILE_PATH" "./"; then
   # ${CC_SCRIPTS_FILE_PATH:1} --> removed the first character which is "." (dot) in this case.
   CC_SCRIPTS_FILE_PATH="$(pwd)${CC_SCRIPTS_FILE_PATH:1}"
fi

___do_files_exist "$CC_SCRIPTS_FILE_PATH" || {
   ___print_screen "error 105"
   ___print_screen "Could not found the file: $CC_SCRIPTS_FILE_PATH . You are not be able to use some functions like c_help, c_download_with_curl_script..."
}

# print some information
___print_screen "cc_scripts version: 1.22 loaded from: $CC_SCRIPTS_FILE_PATH"

if [ "$CC_ECHO_COLOR" = "true" ]; then
   # we can not use ___print_screen because ___print_screen does not support multiple colors in the same line.
   echo -e "$CC_COLOR_GREEN""current dir: $(pwd)" "$CC_COLOR_RESET"
else
   echo "current dir: $(pwd)"
fi
