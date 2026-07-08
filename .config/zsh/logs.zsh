# Log levels: DEBUG=0 INFO=1 WARN=2 ERROR=3
# Set LOG_LEVEL=DEBUG (or 0) etc. to control verbosity. Default: INFO.

_log_level_value() {
  case "${LOG_LEVEL:-INFO}" in
    DEBUG|debug|0) echo 0 ;;
    INFO|info|1)   echo 1 ;;
    WARN|warn|2)   echo 2 ;;
    ERROR|error|3) echo 3 ;;
    *)             echo 1 ;;
  esac
}

log_debug() {
  (( $(_log_level_value) <= 0 )) || return 0
  print -P "%F{8}[DEBUG]%f $*" >&2
}

log_info() {
  (( $(_log_level_value) <= 1 )) || return 0
  print -P "%F{blue}[INFO]%f $*" >&2
}

log_warn() {
  (( $(_log_level_value) <= 2 )) || return 0
  print -P "%F{yellow}[WARN]%f $*" >&2
}

log_error() {
  (( $(_log_level_value) <= 3 )) || return 0
  print -P "%F{red}[ERROR]%f $*" >&2
}
