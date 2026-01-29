#!/bin/bash
# -*- mode: shell-script -*-

.timestamp() {
  case "${1:-}" in
    -h|--help)
      cat <<'EOF'
.timestamp — print the current Unix timestamp in milliseconds (UTC)

Usage:
  .timestamp
  .timestamp -h | --help

Examples:
  ts=$(.timestamp)
  echo "$ts"
EOF
      return 0
      ;;
  esac

  case "$(uname)" in
    Linux)
      date -u +%s%3N
      ;;
    Darwin)
      # macOS (BSD date): derive milliseconds from nanoseconds
      printf '%s%03d\n' \
        "$(date -u +%s)" \
        "$((10#$(date -u +%N) / 1000000))"
      ;;
    *)
      echo ".timestamp: unsupported OS: $(uname)" >&2
      return 1
      ;;
  esac
}
