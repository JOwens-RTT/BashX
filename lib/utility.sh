#!/usr/bin/env bash

# Naming: All names will be uppercase words separated with underscores
#         and an appropriate prefix. Prefixes may be dropped on
#         exported variables. External variables do not need to
#         conform to any of these rules.
# Prefixes:
#   v: variable (Both string and numerical)
#   c: constant (Both string and numerical)
#   a: array    (Both string, numerical, and mixed)
#   p: path
#   f: function
#   l: local
#   g: global
#   d: directory (directory name only)
#   n: file name (file name only)
# Examples:
#   gcp_Path    -> global constant path named Path
#   lv_Var      -> local variable named Var
#   f_Print     -> function named Print
#   lcn_File    -> local constant file name named File

gc_Appliation=$(basename "$0")

gc_TRUE=1
gc_FALSE=0

source "exitCodes"

function f_Throw ()
{
    local lc_lineNumber=$1
    local lc_message=$2
    local lc_code=${3:-1}
    if [[ -n "$lc_message" ]]; then
        echo "${gc_Appliation}: Error on or near line ${lc_lineNumber}: ${lc_message} (exiting with status ${lc_code})" >&2
    else
        echo "${gc_Appliation}: Error on or near line ${lc_lineNumber} (exiting with status ${lc_code})" >&2
    fi
    exit "${lc_code}"
}
#trap 'throw ${LINENO}' ERR

function f_Debug ()
{
    if [[ "${gv_enableDebug:=$gc_FALSE}" == "$gc_TRUE" ]]; then
        echo "$@"
    fi
}

function f_IsDeclared()
{
    declare -p "$1" &>/dev/null
}


# Only works with: declare -A <LIST>=( ["<KEY0>"]="<VALUE0>" ["<KEY1>"]="<VALUE1>" ["<KEY2>"]="<VALUE2>" ... )
# contains <VALUE> ${<LIST>[@]}
# or
# contains <KEY> ${!<LIST>[@]}
function f_Contains()
{
    if [[ "$#" -lt 2 ]]; then
        f_Throw "${LINENO}" "Expected two arguements. Arg1 = dictionary, Arg2 = key." "$ec_INVALID_ARG"
    fi
    local lv_testKey=$1
    local lv_array=("${@:2}")
    for lv_key in "${lv_array[@]}"; do 
        echo "Checking if $lv_key equals $lv_testKey"
        if [[ "$lv_testKey" == "$lv_key" ]]; then
            return $gc_TRUE
        fi
    done
    return $gc_FALSE
}

declare -a gv_posArgs=()
declare -A gv_tagArgs=()

# Usage: f_ProcessArgs "$@"
# Produces posArgs and tagArgs
function f_ProcessArgs () 
{
    # Set debug enable
    gv_enableDebug="$gc_FALSE"

    # Local variables
    local lv_activeFlag=""
    local lv_index=0
    local lv_count=0
    local lc_tag=""

    # Iterate through arguments list
    for lv_arg in "$@"; do
        lv_count=$((lv_count + 1))
        f_Debug "Arg #$lv_count: $lv_arg"
        f_Debug "Active flag: $lv_activeFlag"

        # Check for flags, switches, and options
        if [[ "$lv_arg" == "-"* ]]; then
            # Check if the last arguement was a switch
            if [[ "$lv_activeFlag" != "" ]]; then
                # Remove leading dashes from switch
                lc_tag=$(echo "$lv_activeFlag" | tr -s [:punct:])
                lc_tag=${lc_tag#"-"}

                # Store switch as active
                gv_tagArgs+=(["$lc_tag"]="$gc_TRUE")

                # Debug printout
                f_Debug "Enabled $lc_tag switch"

                # Clear tag variable for later use
                lc_tag=""
            fi

            # Store curent flag
            lv_activeFlag="$lv_arg"

        # Check if arg belongs to a flag or option
        elif [[ "$lv_activeFlag" != "" ]]; then
            # Remove leading dashes from flag or option
            lc_tag=$(echo "$lv_activeFlag" | tr -s [:punct:])
            lc_tag=${lc_tag#"-"}

            # Store data in option
            gv_tagArgs+=(["$lc_tag"]="$lv_arg")

            # Debug printout
            f_Debug "$lv_arg stored in $lc_tag option"

            # Clear variables for later use
            lv_activeFlag=""
            lc_tag=""

        # Arg is positional
        else
            gv_posArgs+=(["$lv_index"]="$lv_arg")
            f_Debug "$lv_arg stored in position $lv_index arg"
            lv_index=$((lv_index + 1))
        fi
    done

    # Save any switches that come at the end of the arg list
    if [[ "$lv_activeFlag" != "" ]]; then
        # Remove leading dashes from switch
        lc_tag=$(echo "$lv_activeFlag" | tr -s [:punct:])
        lc_tag=${lc_tag#"-"}

        # Store switch as active
        gv_tagArgs+=(["$lc_tag"]="$gc_TRUE")

        # Debug printout
        f_Debug "Enabled $lc_tag switch"

        # Clear tag variable for later use
        lc_tag=""
    fi

    # Set verbose mode
    gv_enableDebug=$(getTagArg "v" "$gc_FALSE")
}

function exists()
{
 echo "foo"
}

function getTagArg()
{
    local lc_key=$1
    local lc_default=${2:-""}
    
    for lv_k in "${!gv_tagArgs[@]}"; do
        # echo "Key: $lv_k"
        if [[ "$lv_k" == "$lc_key" ]]; then
            echo "${gv_tagArgs[$lv_k]}"
            return $gc_TRUE
        fi
    done

    echo "$lc_default"
    return $gc_FALSE
}

function getPosArg()
{
    local lc_ind=$1
    local lc_default=${2:=""}

    if [[ $lc_ind -lt 0 ]] || [[ $lc_ind -ge ${#gv_posArgs[@]} ]]; then
        echo "$lc_default"
        return $gc_FALSE
    else
        echo "${gv_posArgs[$lc_ind]}"
        return $gc_TRUE
    fi 
}

function diskRemaining()
{
    local lc_size
    lc_size=$(df -k --output=avail "$1" | grep -o '[[:digit:]]*')
    echo "$lc_size" # Returns KiB
}

function fileUsage()
{
    local lc_size
    lc_size=$(du -s "$1" | grep -o '^[[:digit:]]*')
    echo "$lc_size" # Returns KiB
}

function split()
{
    local lc_split="$1"
    local lc_raw="$2"
    IFS="$lc_split" read -ra SPLIT_RESULT <<< "$lc_raw"
    export SPLIT_RESULT
}

function terminalWidth()
{
    tput cols
}

function terminalHeight()
{
    tput lines
}


declare MENU_SELECTION
function menu()
{
    declare lv_count
    declare -A lv_optList
    declare lv_choice

    # Loop until a valid choice is made
    while true; do
        lv_count=1
        lv_optList=()
        lv_choice=''

        # List options
        echo "Select option:"
        for opt in "$@"; do
            lv_optList["$lv_count"]="$opt"
            echo "$lv_count: $opt"
            lv_count=$((lv_count+1))
        done
        lv_optList["$lv_count"]="Exit"
        echo "$lv_count: Exit"

        # Read user response
        read -r
        lv_choice="$REPLY"

        # Check response against available choices
        for i in "${!lv_optList[@]}"; do
            if [[ "$i" == "$lv_choice" ]]; then
                MENU_SELECTION="${lv_optList[$i]}"
                export MENU_SELECTION
                return 0;
            fi
        done

        echo "$lv_choice is invalid. Choose an option between 1 and ${#lv_optList[@]}."
    done
}

function f_dispHelp()
{
    cat << EOM
disp [OPTIONAL: message] [OPTION]...
    -h, -?, --help          Show help
ARGS:
    message                 Message to print
OPTIONS:
    -t [val]                Enable footer (Can disable progress bar)
    -f                      Set footer message
    -p [val]                Enable progress bar (Can enable footer)
    -v                      Set progress bar value
    -l                      Set progress bar minimum value (default 0)
    -u                      Set progress bar maximum value (default 100)
EOM

    exit 0
}

# Default values for progress bar & footer
gv_FooterMessage=""
gv_ProgValue=0
gv_MinValue=0
gv_MaxValue=100
gv_LastFooterEnable="$gc_FALSE"
gv_LastProgEnable="$gc_FALSE"
function disp()
{
    # Process Arguments
    f_ProcessArgs "$@"

    local lc_message
    local lv_FooterEnable
    local lv_ProgEnable

    lc_message=$(getPosArg 0 "")
    lv_FooterEnable=$(getTagArg "t" "$gv_LastFooterEnable")
    lv_ProgEnable=$(getTagArg "p" "$gv_LastProgEnable")
    gv_FooterMessage=$(getTagArg "f" "$gv_FooterMessage")
    gv_ProgValue=$(getTagArg "v" "$gv_ProgValue")
    gv_MinValue=$(getTagArg "l" "$gv_MinValue")
    gv_MaxValue=$(getTagArg "u" "$gv_MaxValue")

    if [[ "$(getTagArg 'h' $gc_FALSE)" == "$gc_TRUE" ]] || [[ "$(getTagArg 'help' $gc_FALSE)" == "$gc_TRUE" ]] || [[ "$(getTagArg '?' $gc_FALSE)" == "$gc_TRUE" ]]; then
        f_dispHelp
    fi

    # Handle display states
    local lv_FooterToggled="$gc_FALSE"
    local lv_ProgToggled="$gc_FALSE"

    [[ "$gv_LastFooterEnable" != "$lv_FooterEnable" ]] && lv_FooterToggled="$gc_TRUE"
    [[ "$gv_LastProgEnable" != "$lv_ProgEnable" ]] && lv_ProgToggled="$gc_TRUE"

    gv_LastFooterEnable="$lv_FooterEnable"
    gv_LastProgEnable="$lv_ProgEnable"

    if [[ "$lv_FooterEnable" == "$gc_FALSE" ]]; then printf '%s' "$lc_message"; return; fi
}

function vercomp () 
{
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

function isMinVersion()
{
    local lc_minVersion=$1
    local lc_version=$2

    vercomp "$lc_version" "$lc_minVersion"
    if [[ $? -eq 2 ]]; then
        return $gc_FALSE
    fi
    return $gc_TRUE
}

function test_isMinVersion()
{
    isMinVersion "1.0.0" "1.0.0"
    if [[ $? -ne $gc_TRUE ]]; then
        echo "Failed test 1"
    else
        echo "Passed test 1"
    fi

    isMinVersion "1.0.0" "1.0.1"
    if [[ $? -ne $gc_TRUE ]]; then
        echo "Failed test 2"
    else
        echo "Passed test 2"
    fi

    isMinVersion "1.0.0" "0.9.9"
    if [[ $? -ne $gc_FALSE ]]; then
        echo "Failed test 3"
    else 
        echo "Passed test 3"
    fi
}

function test_dpkg()
{
    dpkgVersion=$(dpkg --version | grep -o "\([[:digit:]]\+\.\)\+[[:digit:]]\+")
    dpkgMinVersion="1.21.0"
    echo "dpkg version: $dpkgVersion"
    echo "dpkg min version: $dpkgMinVersion"
    isMinVersion $dpkgMinVersion $dpkgVersion
    if [[ "$?" -eq $gc_TRUE ]]; then
        echo "dpkg is up to date: $dpkgVersion"
        
    else
        echo "dpkg update required: $dpkgVersion -> $dpkgMinVersion"
    fi
}