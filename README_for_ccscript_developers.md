# README FOR cc_scripts DEVELOPER

- ## functions
     - public functions starts with 'c_'. you can call these functions from terminal directly.
     - private functions starts with '___'. They have 3 underline characters as prefix. On some linux distros there are aliases/functions/executables that start with 2 underlines characters. Therefor to make sure cc_scripts not override those functions, we use 3 underline characters.
     
     Do not call the private functions from terminal directly. (In some cases you may call them from other script files but never from terminal directly.)

- ## variables
     always use 'local' variables. do not:
     - export variables
     - set or create new environment variables

- ## test inside docker container
     "docker_test_immortal_container" directory includes a test container which never exits.

     Run "start_container_and_attach_on.sh" file. It will attach automatically to container with new shell. Type this command:

     > . /tmp/cc_scripts.sh

     and start test any command:

     > c_print_details

# RULES
- standarts: https://github.com/koalaman/shellcheck
- formatter: https://github.com/mvdan/sh (open source vscode extension: "foxundermoon.shell-format")
