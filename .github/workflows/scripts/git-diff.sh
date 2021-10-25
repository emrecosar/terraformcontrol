#!/usr/bin/env bash

set -e

GIT_REF="${1}"
ACCOUNT_NAME="${2}"
ENV_NAME="${3}"

DIRECT_CHANGES=$(git diff --compact-summary --name-only --diff-filter=ACMRT "${GIT_REF}" -- "terraform/terragrunt/${ACCOUNT_NAME}/${ENV_NAME}/***" ":(exclude)terraform/terragrunt/${ACCOUNT_NAME}/${ENV_NAME}/env.yaml" ":(exclude)terraform/terragrunt/${ACCOUNT_NAME}/${ENV_NAME}/modules.yaml")
EXIT_CODE=$?

# Gets the modules updated in a 'local.modules.<module>' form if any modules are updated
MODULES_UPDATED=$(git diff --unified=0 --diff-filter=M "${GIT_REF}" -- "terraform/terragrunt/${ACCOUNT_NAME}/${ENV_NAME}/modules.yaml" | grep '^[+]' | grep -Ev '^(--- a/|\+\+\+ b/)' | cut -d ":" -f 1 | sed "s#+#local.modules.#g" )
EXIT_CODE_MODULES=$?

# if any modulese are updated, the bellow collects the path of the affected components
if [[ "${EXIT_CODE_MODULES}" == 0 ]]; then
  if [ -n "${MODULES_UPDATED}" ]; then
    echo -e "Modules updated:\n${MODULES_UPDATED}"
    # not enirely sure if *cache* exclussion is needed.
    MODULE_COMPONENTS=$(find "terraform/terragrunt/${ACCOUNT_NAME}/${ENV_NAME}" -type f -print0 |  xargs -0 grep -iw --exclude "*modules.yaml" --exclude "*cache*" --files-with-matches "${MODULES_UPDATED}")
    echo -e "Component affected by the module update:\n${MODULE_COMPONENTS}\n"
  else
    echo "No module updates"
  fi
else
  exit $EXIT_CODE_MODULES
fi

if [[ "${EXIT_CODE}" == "0" ]]; then
  # if any dirrect changes were done, the path to the component are appended to the module update components (if any exist)
  if [ -n "${DIRECT_CHANGES}" ]; then
    echo -e "Direct changes detected in:\n${DIRECT_CHANGES}\n"
    ALL_CHANGES=$(printf '%s\n%s' "${DIRECT_CHANGES}" "${MODULE_COMPONENTS}")
    # processes the paths to include terragrunt friendly path
    ALL_CHANGES=$(echo "${ALL_CHANGES}" |
      xargs -L1 dirname | sort -u |
      sed "s#terraform/terragrunt/${ACCOUNT_NAME}/${ENV_NAME}/##g" |
      sed 's/^/--terragrunt-include-dir /' | tr '\n' ' ')
    echo "${ALL_CHANGES}"
  # if no direct changes were made, the following lists only the module update components for git diff
  elif [ -n "${MODULE_COMPONENTS}" ]; then
      echo "No direct component changes detected, but module updates detected"
      ALL_CHANGES="${MODULE_COMPONENTS}"
      # processes the paths to include terragrunt friendly path
      ALL_CHANGES=$(echo "${ALL_CHANGES}" |
        xargs -L1 dirname | sort -u |
        sed "s#terraform/terragrunt/${ACCOUNT_NAME}/${ENV_NAME}/##g" |
        sed 's/^/--terragrunt-include-dir /' | tr '\n' ' ')
      echo "${ALL_CHANGES}"
  else
    echo "No changes detected"
  fi
else
  exit $EXIT_CODE

fi

echo "::set-output name=tg_dirs::${ALL_CHANGES}"
