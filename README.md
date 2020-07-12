# cc_scripts

My personal common shell functions for general purpose.

You can call cc_scripts functions inside:
- docker (or any container)s
- remote machine via ssh
- any terminal
- inside another script file

# Example usage:

```sh
c_environment_search java
# prints all lines which includes java
```

```sh
c_system_details
# prints external ip, internal ip, hostname, system date...
```

```sh
c_download_with_curl_script www.ubuntu.com/desktop.iso
# starts download background of shell. also it creates a simple script file. so you can resume the same download any time from that script file.
```

```sh
ls | color_line
# "ls" output will be different color on each line.
# any command can be used instead of "ls".
```

# Installation

  There is no an installation. You just load it:
  
  ```sh
  . cc_scripts.sh # do not forget"." (dot)
  ```

  ready! Now type on terminal __"c"__ and press __TAB__, terminal will show you all available functions.

# Auto startup (optional)

download this script to your local machine:

```sh
cd $HOME # or anywhere you want
curl https://raw.githubusercontent.com/yusufd89/cc_scripts/master/cc_scripts.sh | sh
# or use the shortened URL:
# curl kutt.it/sS3dOB | sh
```

then call "c_ccscripts_import" function to import cc_scripts to your .bashrc and .zshrc.

```sh
c_ccscripts_import
```

Now if you open your terminal window, scirpt will load automatically.

# Use it inside docker (or any other container)

inside dockerfile:

```dockerfile
ADD "https://raw.githubusercontent.com/yusufd89/cc_scripts/master/cc_scripts.sh" "/my_scripts/cc_scripts.sh"
# or if is already downloaded on your local:
# COPY "cc_scripts.sh" "/my_scripts/cc_scripts.sh"
```

attach on docker and run this command:

```sh
. /my_scripts/cc_scripts.sh
```

# Supported platforms

- # Shell
    - bash
    - zsh

- # OS
    - Linux
    - MacOS

- ## Tested platforms and versions

  - bash 4.4.19(1)-release (x86_64-pc-linux-gnu) on Ubuntu 18.04 Eng 64 bit
  - zsh 5.4.2 (x86_64-ubuntu-linux-gnu) on Ubuntu 18.04 Eng 64 bit
