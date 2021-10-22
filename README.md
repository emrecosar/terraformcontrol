# terraformcontrol

Emre Cosar's Terraform Control repository to manage cloud components infra-as-code

## Current Projects

- polarissquad.fun


## AWS accounts

| Account Number | Account Name |
| --- | --- |
| 417361600516 | Emre

## Project layout

| Folder                                                                  | Description |
|-------------------------------------------------------------------------|-------------|
| [.github](./.github)                                                    | Contains default github Pull-Request template and workflows |
| [terraform](./terraform)                                                | Contains terraform and terragrunt files needed for automation deployment |
| [.pre-commit-config.yaml](./.pre-commit-config.yaml)                    | Git hook testing scripts |


## System requirements (macOS)

Install dependencies via Homebrew and setup terraform and terragrunt respectively:

  ```bash
  # Install packages
  brew install awsume awscli pre-commit tflint tfenv tgenv

  # Install terraform and terragrunt from inside terraform folder
  cd terraform
  tfenv install
  tgenv install
  ```

*You can uninstall `terraform` and `terragrunt` from your system, they will be managed by `tfenv` & `tgenv` tools.*

> Please run the following command regularly to ensure the installed tools are up to date:<br>```brew update && brew upgrade && brew cleanup```

## Tools used

- [tfenv](https://github.com/tfutils/tfenv) Terraform version manager.
- [tgenv](https://github.com/tfutils/tfenv) Terragrunt version manager.
- [tflint](https://github.com/terraform-linters/tflint) TFLint is a Terraform linter focused on possible errors, best practices, etc.

### Run the test across all files in repo

```bash
pre-commit run --all-files

# or you can use a short one:
pre-commit run -a
```

#### Available Hooks

There are several [pre-commit](http://pre-commit.com/) hooks to keep Terraform configurations (both `tf` and `tfvars`) and Terragrunt configurations (`hcl`) along with others (`json`, `yaml`, `sh`) in a good shape:

- `terraform_fmt` - Rewrites all Terraform configuration files to a canonical format.
- `terraform_validate` - Validates all Terraform configuration files.
- `terraform_tflint` - Validates all Terraform configuration files with [TFLint](https://github.com/wata727/tflint).
- `terraform_docs` - Runs `terraform-docs` and inserts input and output documentation into `README.md`.
- `terraform_docs_without_aggregate_type_defaults` - Sames as above without aggregate type defaults.
- `terraform_docs_replace` - Runs `terraform-docs` and pipes the output directly to README.md
- `terragrunt_fmt` - Rewrites all Terragrunt configuration files (`*.hcl`) to a canonical format.


## Branching strategy

Gitflow is a branching strategy model for Git but currently is not being used.
Please read [this doc](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) to understand it in more details.

## Merging PRs

We are using git sqush and merge for getting the PRs merged into the taget branch. It’s simple – before you merge a feature branch back into your main branch (often `main` or `develop`), your feature branch should be squashed down to a single buildable commit, and then rebased from the up-to-date main branch.

Please watch this [small video (1:27min)](https://www.youtube.com/watch?v=pa_xqXxm6ok) to understand the benefit of git squash:

## Useful links

- [terraform](https://www.terraform.io/)
- [terragrunt](https://terragrunt.gruntwork.io/)
- [awsume](https://awsu.me)
