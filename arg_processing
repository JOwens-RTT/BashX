#!/bin/bash

# Declares and resets arg processing variables
resetArgs() {
  declare -ag args_POSITIONAL=()
  declare -Ag args_SWITCHES=()
  declare -Ag args_OPTIONS=()
}
resetArgs

f_SHOW_HELP()
{
  printf "$1"
  exit 0
}


processArgs() {
  # Parse variables
  local lv_HELP_MSG="$1"
  local lv_ARG=""
  local lv_MODE="POS"
  local lv_OPT=""
  local lv_IND=0

  # Reset return variables
  resetArgs

  # Parse arguements
  for lv_ARG in "${@:2}"; do
    if [[ "$lv_ARG" == "--"* ]]; then
      if [[ "$lv_OPT" != "" ]]; then
        echo "ERROR: No value provided for previous option $lv_OPT"
        f_SHOW_HELP "$lv_HELP_MSG"
      fi
      if [[ "$lv_ARG" == "--help" ]]; then f_SHOW_HELP "$lv_HELP_MSG"; fi
      lv_OPT="${lv_ARG:2}"
    elif [[ "$lv_ARG" == "-"* ]]; then
      if [[ "$lv_OPT" != "" ]]; then
        echo "ERROR: No value provided for previous option $lv_OPT"
        f_SHOW_HELP
      fi
      if [[ "$lv_ARG" == *"h"* ]]; then f_SHOW_HELP "$lv_HELP_MSG"; fi
      if [[ "$lv_ARG" == *"?"* ]]; then f_SHOW_HELP "$lv_HELP_MSG"; fi

      lv_ARG="${lv_ARG:1}"
      for ((lv_IND=0; lv_IND < ${#lv_ARG}; lv_IND++)); do
        args_SWITCHES["${lv_ARG:$lv_IND:1}"]+=1
      done
    elif [[ "$lv_OPT" != "" ]]; then
      args_OPTIONS["${lv_OPT}"]+="$lv_ARG"
      lv_OPT=""
    else
      args_POSITIONAL+=("$lv_ARG")
    fi
  done
}

f_ARG_UNIT_TEST() {
  processArgs pos0 pos1 -s -tvx --opt0 o0 pos2 --op1 o1 -z
  for arg in "${args_POSITIONAL[@]}"; do echo "POS: $arg"; done
  for arg in "${!args_SWITCHES[@]}"; do echo "SW: $arg"; done
  for arg in "${args_OPTIONS[@]}"; do echo "OPT: $arg"; done
}

# f_ARG_UNIT_TEST