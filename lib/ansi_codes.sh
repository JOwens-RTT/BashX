#!/bin/bash

#include flow_control
if [[ ! -f "flow_control" ]]; then
  echo "Could not import flow_control."
  exit 1
fi
. flow_control

# Include arg_processing
if [[ ! -f "arg_processing" ]]; then close "Could not import arg_processing."; fi
. arg_processing

# ANSI Escape sequences
ansi_ESC='\e'
ansi_SINGLE_SHIFT_TWO="${ansi_ESC}N"
ansi_SINGLE_SHIFT_THREE="${ansi_ESC}O"
ansi_DEVICE_CONTROL_STRING="${ansi_ESC}P"
ansi_CONTROL_SEQUENCE_INTRODUCER="${ansi_ESC}["
ansi_STRING_TERMINATOR="${ansi_ESC}\\"
ansi_OPERATING_SYSTEM_COMMAND="${ansi_ESC}]"
ansi_START_OF_STRING="${ansi_ESC}X"
ansi_PRIVACY_MESSAGE="${ansi_ESC}^"
ansi_APPLICATION_PROGRAM_COMMAND="${ansi_ESC}_"

# Return a color code
# Usage: getColor color_name ground
#   color_name:
#     BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE,
#     BRIGHT_BLACK, BRIGHT_RED, etc.
#   ground: FG or BG
# return int gv_getColor_RETURN
gv_getColor_RETURN=
getColor() {
  local lc_NAME="$1"
  local lc_GROUND="$2"

  declare -A lca_COLOR_CODES=(
    ["BLACK_FG"]=30
    ["BLACK_BG"]=40
    ["RED_FG"]=31
    ["RED_BG"]=41
    ["GREEN_FG"]=32
    ["GREEN_BG"]=42
    ["YELLOW_FG"]=33
    ["YELLOW_BG"]=43
    ["BLUE_FG"]=34
    ["BLUE_BG"]=44
    ["MAGENTA_FG"]=35
    ["MAGENTA_BG"]=45
    ["CYAN_FG"]=36
    ["CYAN_BG"]=46
    ["WHITE_FG"]=37
    ["WHITE_BG"]=47
    ["BRIGHT_BLACK_FG"]=90
    ["BRIGHT_BLACK_BG"]=100
    ["BRIGHT_RED_FG"]=91
    ["BRIGHT_RED_BG"]=101
    ["BRIGHT_GREEN_FG"]=92
    ["BRIGHT_GREEN_BG"]=102
    ["BRIGHT_YELLOW_FG"]=93
    ["BRIGHT_YELLOW_BG"]=103
    ["BRIGHT_BLUE_FG"]=94
    ["BRIGHT_BLUE_BG"]=104
    ["BRIGHT_MAGENTA_FG"]=95
    ["BRIGHT_MAGENTA_BG"]=105
    ["BRIGHT_CYAN_FG"]=96
    ["BRIGHT_CYAN_BG"]=106
    ["BRIGHT_WHITE_FG"]=97
    ["BRIGHT_WHITE_BG"]=107
  )

  gv_getColor_RETURN="${lca_COLOR_CODES["${lc_NAME}_${lc_GROUND}"]}"
  echo "$gv_getColor_RETURN"
}

gv_setFormat_RETURN=
setFormat() {
  local lc_HELP=$(cat <<EOF
usage: setFormat [SWITCHES] [OPTIONS]
  Returns an ANSI escape code used to format text.
  For Ubuntu based systems, this does not work with echo. Use printf instead. Also the format code is only
  valid when used in the first argument. Subsequent arguments will print the code as plain text instead of applying it.
  Note that not all formatting options will be available on your system. Use this help section to determine what your
  terminal application is capable of utilizing. For details see: https://en.wikipedia.org/wiki/ANSI_escape_code
  This function will decrease performance if used in excess. It may become necessary to use this function as a code
  lookup tool by printing the result to screen so you can hard code the value into a static string.

  Shows help:
    -h, -?, --help      Shows this help with formatting
    -!                  Shows this help with formatting codes printed as plain text

  SWITCHES:
    -b                  Bold                      ex: \e[1mBold\e[0m
    -c                  Cross out                 ex: \e[9mCrossed Out\e[0m
    -d                  Hide                      ex: This is \e[8mHidden\e[0m!
    -f                  Faint                     ex: \e[2mFaint\e[0m
    -g                  Gothic                    ex: \e[20mGothic\e[0m
    -i                  Italic                    ex: \e[3mItalic\e[0m
    -m                  Frame                     ex: \e[51mFramed\e[0m
    -n                  Encircle                  ex: \e[52mEncircled\e[0m
    -o                  Overline                  ex: \e[53mOverline\e[0m
    -p                  Proportional spacing      ex: \e[26mThis is proportional spacing\e[0m
    -r                  Reset format to default
    -s                  Subscript                 ex: X\e[74msubscript\e[0m
    -S                  Superscript               ex: X\e[73msuperscript\e[0m
    -t                  Stress                    ex: \e[64mStress\e[0m
    -v                  Invert                    ex: \e[7mInverted\e[0m

  OPTIONS:
    --background-color  Set the background color to one of a list of color presets. See: COLORS
    --background-rgb    Set the background color to an RGB value specified with 'R G B'
    --blink             Blinks text according to the following options:
      NONE
      \e[6mFAST\e[0m
      \e[5mSLOW\e[0m
    --font              Set font to one of 10 options
      1:  \e[10mPrimary Font\e[0m
      2:  \e[11mAlternate Font 1\e[0m
      3:  \e[12mAlternate Font 2\e[0m
      4:  \e[13mAlternate Font 3\e[0m
      5:  \e[14mAlternate Font 4\e[0m
      6:  \e[15mAlternate Font 5\e[0m
      7:  \e[16mAlternate Font 6\e[0m
      8:  \e[17mAlternate Font 7\e[0m
      9:  \e[18mAlternate Font 8\e[0m
      10: \e[19mAlternate Font 9\e[0m
    --foreground-color  Set the foreground color to one of a list of color presets. See: COLORS
    --foreground-rgb    Set the foreground color to an RGB value specified with 'R G B'
    --leftline          Set a left vertical line or overline style depending on the system.
      NONE
      \e[62mSINGLE\e[0m
      \e[63mDOUBLE\e[0m
    --rightline         Set a right vertical line or underline style depending on the system.
      NONE
      \e[60mSINGLE\e[0m
      \e[61mDOUBLE\e[0m
    --underline         Set an underline style.
      NONE
      \e[4mSINGLE\e[0m
      \e[21mDOUBLE\e[0m
    --underline-color   Set the underline color to one of a list of color presets. See: COLORS
    --underline-rgb     Set the underline color to an RGB value specified with 'R G B'

  COLORS:
    \e[1;40;37m BLACK \e[0m
    \e[1;41;37m RED \e[0m
    \e[1;42;37m GREEN \e[0m
    \e[1;43;30m YELLOW \e[0m
    \e[1;44;30m BLUE \e[0m
    \e[1;45;37m MAGENTA \e[0m
    \e[1;46;30m CYAN \e[0m
    \e[1;47;30m WHITE \e[0m
    \e[1;100;37m BRIGHT_BLACK \e[0m
    \e[1;101;37m BRIGHT_RED \e[0m
    \e[1;102;30m BRIGHT_GREEN \e[0m
    \e[1;103;30m BRIGHT_YELLOW \e[0m
    \e[1;104;30m BRIGHT_BLUE \e[0m
    \e[1;105;30m BRIGHT_MAGENTA \e[0m
    \e[1;106;30m BRIGHT_CYAN \e[0m
    \e[1;107;30m BRIGHT_WHITE \e[0m
\n
EOF
)

  processArgs "$lc_HELP" "$@"
  local lv_RESET="${args_SWITCHES["r"]:-0}"
  local lv_BOLD="${args_SWITCHES["b"]:-0}"
  local lv_FAINT="${args_SWITCHES["f"]:-0}"
  local lv_ITALIC="${args_SWITCHES["i"]:-0}"
  local lv_UNDERLINE="${args_OPTIONS["underline"]:-'NONE'}"
  local lv_BLINK="${args_OPTIONS['blink']:-'NONE'}"
  local lv_INVERT="${args_SWITCHES["v"]:-0}"
  local lv_HIDE="${args_SWITCHES["d"]:-0}"
  local lv_CROSS_OUT="${args_SWITCHES["c"]:-0}"
  local lv_FONT="${args_OPTIONS['font']:-1}"
  local lv_GOTHIC="${args_SWITCHES["g"]:-0}"
  local lv_PROPRTIONAL_SPACING="${args_SWITCHES["p"]:-0}"
  local lv_FOREGROUND_COLOR="${args_OPTIONS["foreground-color"]:-'NONE'}"
  local lv_FOREGROUND_RGB="${args_OPTIONS["foreground-rgb"]:-'NONE'}"
  local lv_BACKGROUND_COLOR="${args_OPTIONS["background-color"]:-'NONE'}"
  local lv_BACKGROUND_RGB="${args_OPTIONS["background-rgb"]:-'NONE'}"
  local lv_FRAMED="${args_SWITCHES["m"]:-0}"
  local lv_ENCIRCLED="${args_SWITCHES["n"]:-0}"
  local lv_OVERLINED="${args_SWITCHES["o"]:-0}"
  local lv_UNDERLINE_COLOR="${args_OPTIONS["underline-color"]:-'NONE'}"
  local lv_UNDERLINE_RGB="${args_OPTIONS["underline-rgb"]:-'NONE'}"
  local lv_RIGHTLINE="${args_OPTIONS["rightline"]:-'NONE'}"
  local lv_LEFTLINE="${args_OPTIONS["leftline"]:-'NONE'}"
  local lv_STRESS="${args_SWITCHES["t"]:-0}"
  local lv_SUPERSCRIPT="${args_SWITCHES["S"]:-0}"
  local lv_SUBSCRIPT="${args_SWITCHES["s"]:-0}"
  local lv_SHOW_PLAIN_HELP="${args_SWITCHES["!"]:-0}"

  # Show plain text help if requested
    if [[ "$lv_SHOW_PLAIN_HELP" -eq 1 ]]; then
      echo "$lc_HELP"
      return 0
    fi

  # Create a list of format specifiers from provided arguements
  local lv_SPEC=()

  # Apply switch codes
  if [[ "$lv_BOLD" -eq 1 ]]; then lv_SPEC+=("1"); fi
  if [[ "$lv_CROSS_OUT" -eq 1 ]]; then lv_SPEC+=("9"); fi
  if [[ "$lv_HIDE" -eq 1 ]]; then lv_SPEC+=("8"); fi
  if [[ "$lv_FAINT" -eq 1 ]]; then lv_SPEC+=("2"); fi
  if [[ "$lv_GOTHIC" -eq 1 ]]; then lv_SPEC+=("20"); fi
  if [[ "$lv_ITALIC" -eq 1 ]]; then lv_SPEC+=("3"); fi
  if [[ "$lv_FRAMED" -eq 1 ]]; then lv_SPEC+=("51"); fi
  if [[ "$lv_ENCIRCLED" -eq 1 ]]; then lv_SPEC+=("52"); fi
  if [[ "$lv_OVERLINED" -eq 1 ]]; then lv_SPEC+=("53"); fi
  if [[ "$lv_PROPRTIONAL_SPACING" -eq 1 ]]; then lv_SPEC+=("26"); fi
  if [[ "$lv_RESET" -eq 1 ]]; then lv_SPEC+=("0"); fi
  if [[ "$lv_SUBSCRIPT" -eq 1 ]]; then lv_SPEC+=("74"); fi
  if [[ "$lv_SUPERSCRIPT" -eq 1 ]]; then lv_SPEC+=("73"); fi
  if [[ "$lv_STRESS" -eq 1 ]]; then lv_SPEC+=("64"); fi
  if [[ "$lv_INVERT" -eq 1 ]]; then lv_SPEC+=("7"); fi

  # Apply option codes
  if [[ "$lv_BACKGROUND_COLOR" != 'NONE' ]]; then
    lv_SPEC+=("$(getColor "$lv_BACKGROUND_COLOR" BG)")
  elif [[ "$lv_BACKGROUND_RGB" != 'NONE' ]]; then
    echo "PROCESS FOREGROUND RGB"
  fi
  if [[ "$lv_BLINK" != 'NONE' ]]; then
    if [[ "$lv_BLINK" == "SLOW" ]]; then
      lv_SPEC+=("5")
    elif [[ "$lv_BLINK" == "FAST" ]]; then
      lv_SPEC+=("6")
    fi
  fi
  if [[ "$lv_FONT" -ge 1 ]] && [[ "$lv_FONT" -le 10 ]]; then
    lv_SPEC+=("$((lv_FONT+9))")
  else
    close "Font out of range ($lv_FONT). Expect a number between 1 and 10."
  fi
  if [[ "$lv_FOREGROUND_COLOR" != 'NONE' ]]; then
    lv_SPEC+=("$(getColor "$lv_FOREGROUND_COLOR" FG)")
  elif [[ "$lv_FOREGROUND_RGB" != 'NONE' ]]; then
    echo "PROCESS FOREGROUND RGB"
  fi
  if [[ "$lv_LEFTLINE" != 'NONE' ]]; then
    if [[ "$lv_LEFTLINE" == "SINGLE" ]]; then
      lv_SPEC+=("62")
    elif [[ "$lv_LEFTLINE" == "DOUBLE" ]]; then
      lv_SPEC+=("63")
    fi
  fi
  if [[ "$lv_RIGHTLINE" != 'NONE' ]]; then
    if [[ "$lv_RIGHTLINE" == "SINGLE" ]]; then
      lv_SPEC+=("60")
    elif [[ "$lv_RIGHTLINE" == "DOUBLE" ]]; then
      lv_SPEC+=("61")
    fi
  fi
  if [[ "$lv_UNDERLINE" != 'NONE' ]]; then
    if [[ "$lv_UNDERLINE" == "SINGLE" ]]; then
      lv_SPEC+=("4")
    elif [[ "$lv_UNDERLINE" == "DOUBLE" ]]; then
      lv_SPEC+=("21")
    fi
  fi

  # Turn specifiers into format string
  local lv_FORMAT="$ansi_CONTROL_SEQUENCE_INTRODUCER"
  local lv_FIRST=1
  local lv_ARG=""
  for lv_ARG in "${lv_SPEC[@]}"; do
    if [[ "$lv_FIRST" -eq 0 ]]; then lv_FORMAT+=";"
    else lv_FIRST=0; fi
    lv_FORMAT+="$lv_ARG"
  done
  lv_FORMAT+="m"
  gv_setFormat_RETURN="$lv_FORMAT"
  echo "$lv_FORMAT"
}