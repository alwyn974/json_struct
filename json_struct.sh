#!/bin/bash
#Dev By Alwyn974 (https://github.com/alwyn974)

################
#              #
#    Colors    #
#              #
################

ESC='\033['
NC="${ESC}0m"
BLACK="${ESC}0;30m"
RED="${ESC}0;31m"
GREEN="${ESC}0;32m"
BROWN="${ESC}0;33m"
BLUE="${ESC}0;34m"
PURPLE="${ESC}0;35m"
CYAN="${ESC}0;36m"
LIGHT_GRAY="${ESC}0;37m"
DARK_GRAY="${ESC}1;30m"
LIGHT_RED="${ESC}1;31m"
LIGHT_GREEN="${ESC}1;32m"
YELLOW="${ESC}1;33m"
LIGHT_BLUE="${ESC}1;34m"
LIGHT_PURPLE="${ESC}1;35m"
LIGHT_CYAN="${ESC}1;36m"
WHITE="${ESC}1;37m"

function printColor() {
  echo -e "${1}${NC}"
}

################
#              #
#    Prefix    #
#              #
################

PREFIX="${LIGHT_BLUE}[JsonStruct]${NC}"
INFO="${PREFIX} ${LIGHT_GREEN}[INFO]"
ERROR="${PREFIX} ${RED}[ERROR]"
WARN="${PREFIX} ${BROWN}[WARN]"

################
#              #
#   Variables  #
#              #
################

input_file=""
output_file=""
notypedef=false
inputContent=""

################
#              #
#   Functions  #
#              #
################

printCenter() {
  width=88
  local text="$1"
  local len=${#text}
  local pad=$(((width - len) / 2))
  printf "${INFO} %${pad}s%s${NC}\n" "" "$text"
}

function printHelp() {
  printCenter "------------------------========================================------------------------"
  printCenter "JsonStruct - A tool to generate C structure from json file"
  printCenter ""
  printCenter "USAGE:"
  printCenter "$0 json_file output_file <--notypedef>"
  printCenter ""
  printCenter "DESCRIPTION:"
  printCenter "json_file: The json file to parse"
  printCenter "output_file: The output file"
  printCenter "--notypedef: Don't use typedef"
  printCenter "------------------------========================================------------------------"
  exit 0
}

function checkArgs() {
  if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    printHelp
  elif [ "$#" -lt 2 ]; then
    printColor "$ERROR Please check the help ! Some argument are missing"
    exit 1
  elif [ "$#" == 3 ] && [ "$3" != "--notypedef" ]; then
    printColor "$ERROR Please check the help ! '$3' is not a valid argument"
    exit 1
  fi
  input_file="$1"
  output_file="$2"

  if [ "$#" == 3 ]; then
    notypedef=true
  fi
}

function checkRequiredLibraries() {
  if [ -z "$(which jq)" ]; then
    printColor "$ERROR jq is not installed"
    exit 1
  fi
}

function checkInputFile() {
  if [ ! -f "$input_file" ]; then
    printColor "$ERROR \"$input_file\" is not a valid file"
    exit 1
  fi
  inputContent=$(jq . <"$input_file")
  if [ "$?" != "0" ]; then
    printColor "$ERROR \"$input_file\" is not a valid json file"
    exit 1
  fi
}

function transfromInput() {
  local output=""

  tmpKeys=$(echo "$inputContent" | jq ". | keys")
  keysLen=$(echo "$inputContent" | jq ". | keys | length")
  keys=()

  for i in $(seq 0 $((keysLen - 1))); do
    keys+=("$(echo "$tmpKeys" | jq ".[$i]")")
  done

  local counter=0
  for key in "${keys[@]}"; do
    k=$(echo "$key" | tr -d '"')
    json=$(echo "$inputContent" | jq ". | .$key")
    if [ $notypedef == true ]; then
      output+="struct $k {\n"
    else
      output+="typedef struct {\n"
    fi

    contentKeys="$(echo "$json" | jq ". | keys")"
    contentKeysLen="$(echo "$json" | jq ". | keys | length")"
    for i in $(seq 0 $((contentKeysLen - 1))); do
      key=$(echo "$contentKeys" | jq ".[$i]" | tr -d '"')
      value=$(echo "$json" | jq ". | .$key" | tr -d '"')
      output+="\t$value $key;\n"
    done
    output+="}"

    if [ $notypedef == true ]; then
      output+=";\n"
    else
      output+=" ${k}_t;\n"
    fi

    if [ $counter -lt $((keysLen - 1)) ]; then
      output+="\n"
    fi
    counter=$((counter + 1))
  done

  echo -ne "$output" >"$output_file"
}

function main() {
  printColor "$INFO Starting..."
  checkArgs "$@"
  checkRequiredLibraries
  checkInputFile
  printColor "$INFO Input file: \"$input_file\" - Output file: \"$output_file\" - No-Typedef: $notypedef"
  transfromInput
  printColor "$INFO Done"
}

main "$@"
