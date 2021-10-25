#!/usr/bin/env bash

TF_VERSION=$(cat terraform/.terraform-version)
TG_VERSION=$(cat terraform/.terragrunt-version)

tfenv install "${TF_VERSION}" && tfenv use "${TF_VERSION}"
tgenv install "${TG_VERSION}" && tgenv use "${TG_VERSION}"
