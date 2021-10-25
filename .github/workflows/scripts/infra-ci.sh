#!/usr/bin/env bash

# This function is used to create full report in markdown format
# This report has no format dependencies on github to ensure the file can be rendered locally
function create_plain_md() {
  local MD_FILE_NAME
  MD_FILE_NAME="${REPORT_FILE_NAME}.md"
  echo "## Drifts Account: \`${ACCOUNT_NAME}\` in \`${ENV_NAME}\`" >"${MD_FILE_NAME}"
  if [[ "${TG_EXIT}" != "0" ]]; then
    echo "### Terragrunt run failed." >>"${MD_FILE_NAME}"
  else
    echo "### Terragrunt run successfully." >>"${MD_FILE_NAME}"
  fi

  # Go through modules
  for TG_PATH in "${PATHS[@]}"; do
    local MODULE_PATH
    local EXIT_CODE
    local OUTPUT
    local LANGUAGE
    local STATUS

    MODULE_PATH=$(grep -Rilx "${TG_PATH}" ./tmp/*.path)
    EXIT_CODE=$(cat "${MODULE_PATH/%.path/.exit}")
    OUTPUT=$(cat "${MODULE_PATH/%.path/.output}")
    LANGUAGE=""
    STATUS=""

    if [[ "${EXIT_CODE}" == "1" ]]; then
      LANGUAGE=""
      STATUS="ERROR"
    elif [[ "${EXIT_CODE}" == "2" ]]; then
      LANGUAGE="terraform"
      STATUS="DRIFT"
    fi

    {
      echo "<details>"
      echo "<summary>Show Output [${TG_PATH#$ACCOUNT_NAME/$ENV_NAME/}] ${STATUS}</summary>"
      echo ""
      echo "\`\`\`${LANGUAGE}"
      echo "${OUTPUT}"
      echo "\`\`\`"
      echo "</details>"
    } >>"${MD_FILE_NAME}"
  done
  echo "Full report is saved in '${MD_FILE_NAME}'."
}

# This function is used to get the emoji in the PR header
function get_tg_emoji() {
  local TG_EMOJI
  if [[ "${TG_EXIT}" != "0" ]]; then
    TG_EMOJI=":warning:"
  else
    # Get all exit codes
    local EXIT_CODES=()
    while IFS='' read -r line; do
      EXIT_CODES+=("$line")
    done < <(cat ./tmp/*.exit | sort -u)

    if [[ " ${EXIT_CODES[*]} " =~ " 1 " ]]; then
      TG_EMOJI=":warning:"
    elif [[ " ${EXIT_CODES[*]} " =~ " 2 " ]]; then
      TG_EMOJI=":partly_sunny:"
    else
      TG_EMOJI=":white_check_mark:"
    fi
  fi

  echo "${TG_EMOJI}"
}

# This function is used to create trimmed report in markdown format
# This is needed as Github has a limited body size on comment with maximum 65536 characters
function create_trimmed_md() {
  local MD_FILE_NAME
  MD_FILE_NAME="${REPORT_FILE_NAME}-trimmed.md"
  echo "## Plan for account \`${ACCOUNT_NAME}\` in \`${ENV_NAME}\` $(get_tg_emoji)" >"${MD_FILE_NAME}"

  # Go through modules
  for TG_PATH in "${PATHS[@]}"; do
    local MODULE_PATH
    local EXIT_CODE
    local OUTPUT
    local LANGUAGE
    local EMOJI
    local TMP_OUTPUT
    local TMP_OUTPUT_ALL
    local TMP_EXEEDED
    local TMP_EXEEDED_ALL

    MODULE_PATH=$(grep -Rilx "${TG_PATH}" ./tmp/*.path)
    EXIT_CODE=$(cat "${MODULE_PATH/%.path/.exit}")
    OUTPUT=$(cat "${MODULE_PATH/%.path/.output}")
    LANGUAGE=""
    EMOJI=""

    if [[ "${EXIT_CODE}" == "1" ]]; then
      EMOJI=":boom:"
    elif [[ "${EXIT_CODE}" == "2" ]]; then
      LANGUAGE="terraform"
      EMOJI=":partly_sunny:"
    else
      EMOJI=":thumbsup:"
    fi

    TMP_OUTPUT=$(
      {
        echo "<details><summary>Show Output [${TG_PATH#$ACCOUNT_NAME/$ENV_NAME/}] ${EMOJI}</summary>"
        echo ""
        echo "\`\`\`${LANGUAGE}"
        echo "${OUTPUT}"
        echo "\`\`\`"
        echo "</details>"
      }
    )
    TMP_OUTPUT_ALL="$(cat "${MD_FILE_NAME}")${TMP_OUTPUT}"

    if [ ${#TMP_OUTPUT_ALL} -ge 65400 ]; then
      TMP_EXEEDED=$(
        {
          echo "<details><summary>Show Output [${TG_PATH#$ACCOUNT_NAME/$ENV_NAME/}] ${EMOJI}</summary>"
          echo ""
          echo "\`\`\`${LANGUAGE}"
          echo "Plan output is too long."
          echo "\`\`\`"
          echo "</details>"
        }
      )
      TMP_EXEEDED_ALL="$(cat "${MD_FILE_NAME}")${TMP_EXEEDED}"

      if [ ${#TMP_EXEEDED_ALL} -ge 65400 ]; then
        echo -e "\n_Maximum body size exceeded. You can download the full report from artifacts._" >>"${MD_FILE_NAME}"
        break
      else
        echo "${TMP_EXEEDED}" >>"${MD_FILE_NAME}"
      fi
    else
      echo "${TMP_OUTPUT}" >>"${MD_FILE_NAME}"
    fi
  done
  echo "Trimmed report is saved in '${MD_FILE_NAME}'."
}

function unexpected_error() {
  local MD_FILE_NAME
  MD_FILE_NAME="${REPORT_FILE_NAME}-trimmed.md"
  echo "## Plan for account \`${ACCOUNT_NAME}\` in \`${ENV_NAME}\` :poop:" >"${MD_FILE_NAME}"
  echo "Terragrunt ran into an unexpected error. Please check the full report from the artifacts." >>"${MD_FILE_NAME}"
  echo "Unexpected error is saved in '${MD_FILE_NAME}'."
}

TG_EXIT="${1}"
REPORT_FILE_NAME="${2}"
ACCOUNT_NAME="${3}"
ENV_NAME="${4}"

CHANGES_DETECTED=0
PATHS=()
SORTED_PATHS=()
CHANGES=()

if [ -d "./tmp" ]; then
  # Get list of all modules path
  while IFS='' read -r -d $'\0'; do
    PATHS+=("$(cat "${REPLY}")")
  done < <(find ./tmp -name "*.path" -print0)

  # Sort paths
  while IFS='' read -r line; do
    SORTED_PATHS+=("$line")
  done < <(printf "%s\n" "${PATHS[@]}" | sort)
  PATHS=("${SORTED_PATHS[@]}")

  create_plain_md
  create_trimmed_md

  # Check if there were any drift or error files in the ./tmp folder.
  while IFS='' read -r line; do
    CHANGES+=("$line")
  done < <(grep -lw '1\|2' ./tmp/*.exit)

  if [ ${#CHANGES[@]} -eq 0 ]; then
    echo "No drifts or errors are found."
  else
    CHANGES_DETECTED=1
  fi
else
  unexpected_error
fi

message="$(cat "${REPORT_FILE_NAME}-trimmed.md")"
# https://github.community/t/set-output-truncates-multiline-strings/16852/9
message="${message//'%'/'%25'}"
message="${message//$'\n'/'%0A'}"
message="${message//$'\r'/'%0D'}"

echo "::set-output name=changes_detected::${CHANGES_DETECTED}"
echo "::set-output name=message::${message}"
