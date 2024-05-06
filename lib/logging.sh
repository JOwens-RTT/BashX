#!/bin/bash

gv_LogFile=""
function startLog()
{
    local lc_StartTime="$(date +%s)"
    mkdir -p "$1"
    gv_LogFile="$1/${lc_StartTime}_${2}.log"
    local lc_Command="${BASH_EXECUTION_STRING}"
    local lc_BashVersion="${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}-${BASH_VERSINFO[3]} ${BASH_VERSINFO[4]} ${BASH_VERSINFO[5]}"

    echo -e "$2 Log File\t\t\tSystem Time: $lc_StartTime" > "$gv_LogFile"
    echo -e "Bash Version: $lc_BashVersion" >> "$gv_LogFile"

}

function stackTrace()
{
    local lc_TimeStamp="$(date "+%D %T.%N")"

    printf "%-30s STACK TRACE\n" "${lc_TimeStamp}" >> "$gv_LogFile"
    for ((i=0;i<=$((${#FUNCNAME[@]}-2));i++)); do
        printf "\t%3d:\tCALL %-50s\tFROM %-60s\n" \
            "$((i+1))" \
            "${BASH_SOURCE[$i]}::${FUNCNAME[$i]}" \
            "${BASH_SOURCE[$((i+1))]}::${FUNCNAME[$((i+1))]} [${BASH_LINENO[$i]}]" \
            >> "$gv_LogFile"
    done
}

function log()
{
    # Example: log EVENT ${FUNCNAME[0]}
    local lc_Type="$1"
    local lc_Message="$2"
    local lc_FuncName="${FUNCNAME[1]}"              # Gets caller's name
    local lc_LineNo="${BASH_LINENO[0]}"             # Gets the line where this function was called
    local lc_CallerLineNo="${BASH_LINENO[1]}"       # Gets the starting line number of the calling function
    local lc_TimeStamp="$(date "+%D %T.%N")"
    local lc_Source="${BASH_SOURCE[1]}"

    printf "%-30s %-10s\t%-50s :: %s\n" "$lc_TimeStamp" "$lc_Type" "$lc_Source::$lc_FuncName [$lc_CallerLineNo:$lc_LineNo]" "$lc_Message" >> "$gv_LogFile"

    if [[ "$lc_Type" == "ERROR" ]] || [[ "$lc_Type" == "FATAL" ]]; then
        stackTrace
    fi
}