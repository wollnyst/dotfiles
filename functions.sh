alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"


# `s` with no arguments opens the current directory in Sublime Text, otherwise
# opens the given location
function s() {
    if [ $# -eq 0 ]; then
        subl .;
    else
        subl "$@";
    fi;
}

# `v` with no arguments opens the current directory in Visual Studio Code, otherwise
# opens the given location
function v() {
    if [ $# -eq 0 ]; then
        code .;
    else
        code "$@";
    fi;
}

# `i` with no arguments opens the current directory in Sublime Text, otherwise
# opens the given location
function i() {
    if [ $# -eq 0 ]; then
        idea .;
    else
        idea "$@";
    fi;
}

# git commit browser. needs fzf
log() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --toggle-sort=\` \
      --bind "ctrl-m:execute:
                echo '{}' | grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R'"
}



# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
    if [ $# -eq 0 ]; then
        open .;
    else
        open "$@";
    fi;
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
    local port="${1:-8000}";
    sleep 1 && open "http://localhost:${port}/" &
    # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
    # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
    python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}

# Use Git’s colored diff when available
hash git &>/dev/null;
if [ $? -eq 0 ]; then
    function diff() {
        git diff --no-index --color-words "$@";
    }
fi;

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
function targz() {
    local tmpFile="${@%/}.tar";
    tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;

    size=$(
        stat -f"%z" "${tmpFile}" 2> /dev/null; # OS X `stat`
        stat -c"%s" "${tmpFile}" 2> /dev/null # GNU `stat`
    );

    local cmd="";
    if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
        # the .tar file is smaller than 50 MB and Zopfli is available; use it
        cmd="zopfli";
    else
        if hash pigz 2> /dev/null; then
            cmd="pigz";
        else
            cmd="gzip";
        fi;
    fi;

    echo "Compressing .tar using \`${cmd}\`…";
    "${cmd}" -v "${tmpFile}" || return 1;
    [ -f "${tmpFile}" ] && rm "${tmpFile}";
    echo "${tmpFile}.gz created successfully.";
}

# Change working directory to the top-most Finder window location
function cdf() { # short for `cdfinder`
    cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')";
}

function replace() {
    grep -rl $1 . |xargs sed -i -e "s/${1}/${2}/"
}


function resetBC() {
    security delete-generic-password -l com.boxcryptor.osx.SCKeyServerSettings
    security delete-generic-password -l com.boxcryptor.osx.SCUserSettings
    security delete-generic-password -l Boxcryptor
    security delete-generic-password -l "Boxcryptor Storage"

    defaults delete com.boxcryptor.osx

    rm -rf ~/Library/Application\ Support/Boxcryptor
}


function enableMitmProxy() {
    networksetup -setsecurewebproxystate "Broadcom NetXtreme Gigabit Ethernet Controller" on
    networksetup -setwebproxystate "Broadcom NetXtreme Gigabit Ethernet Controller" on
}

function disableMitmProxy() {
    networksetup -setsecurewebproxystate "Broadcom NetXtreme Gigabit Ethernet Controller" off
    networksetup -setwebproxystate "Broadcom NetXtreme Gigabit Ethernet Controller" off
}

