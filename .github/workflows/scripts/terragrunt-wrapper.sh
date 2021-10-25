#!/usr/bin/env bash
# shellcheck disable=SC2086,SC2046,SC2068

function suppress_tg() {
  local action=$1
  shift 1
  command terragrunt $action "$@" 2>&1
  local exit_code="${PIPESTATUS[0]}"
  return $exit_code
}

exec 5>&1
TG_STDOUT=$(
  suppress_tg $@ 2>&1 | tee /dev/fd/5
  exit ${PIPESTATUS[0]}
)
EXIT_CODE=$?

echo "$TG_STDOUT" >"terragrunt.log"

echo "::set-output name=exit_code::${EXIT_CODE}"
