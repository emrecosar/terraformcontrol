#!/usr/bin/env bash

# The returned value stored in variable called OUTPUT & EXIT_CODE
function run_pre_commit() {
  exec 5>&1
  OUTPUT=$(
    pre-commit run -a --color=never 2>&1 | tee /dev/fd/5
    exit "${PIPESTATUS[0]}"
  )
  EXIT_CODE=$?
  return ${EXIT_CODE}
}

run_pre_commit

OUTPUT=$(sed '/\[[^]]*\]/d' <<<"${OUTPUT}")

if [ $EXIT_CODE -ne 0 ]; then
  icon="warning"
else
  icon="white_check_mark"
fi

PR_HEAD="## Pre-commit code check :$icon:"

MESSAGE=$(
  {
    echo "${PR_HEAD}"
    echo "<details><summary>Show Output</summary>"
    echo ""
    echo "\`\`\`"
    echo "${OUTPUT}"
    echo "\`\`\`"
    echo "</details>"
  }
)

# https://github.community/t/set-output-truncates-multiline-strings/16852/9
MESSAGE="${MESSAGE//'%'/'%25'}"
MESSAGE="${MESSAGE//$'\n'/'%0A'}"
MESSAGE="${MESSAGE//$'\r'/'%0D'}"

echo "::set-output name=exit_code::${EXIT_CODE}"
echo "::set-output name=message::${MESSAGE}"
