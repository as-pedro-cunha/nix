#!/bin/bash

set -euo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

check_github_login() {
    log "Checking GitHub login status"
    if ! gh auth status &>/dev/null; then
        log "> Error: Not logged into GitHub. Please execute the following command to log in:"
        log "gh auth login"
        exit 1
    fi
    log "> GitHub login confirmed"
}

check_git_filter_repo() {
    log "Checking git-filter-repo installation"
    if ! command -v git-filter-repo &>/dev/null; then
        log "> Error: git-filter-repo is not installed. Please install it using your package manager, e.g.,"
        log "brew install git-filter-repo or nix-env -iA nixpkgs.git-filter-repo"
        exit 1
    fi
    log "> git-filter-repo installation confirmed"
}

delete_repo() {
    log "Deleting repository: $1"
    gh repo delete asqcapital/$1 --yes || log "> Repository $1 doesn't exist or couldn't be deleted"
}

create_repo() {
    log "Creating private repository: $1"
    gh repo create asqcapital/$1 --private
}

clone_and_setup() {
    local git_url=$1
    local repo=$2

    log "> Cloning and setting up $repo"
    git clone git@$git_url/$repo.git --recurse-submodules
    log "> Cloned $repo successfully"
    cd $repo
    log "> Setting up nix environment"
    eval "$(direnv export zsh 2> >(command egrep -v -e '^....direnv: export' >&2))"
    rye sync --no-lock
    cd .. # so the nix environment and the rye sync can be recognized by the shell
    cd -
    log "> Nix environment set up successfully"
}

fetch_all_branches() {
    log "> Fetching all branches"
    git fetch --all
    git branch -r | grep -v '\->' | sed 's/origin\///' | xargs -I{} git branch --track {} origin/{} 2>/dev/null || true
}

check_large_files() {
    log "> Checking for large files"
    git rev-list --objects --all |
    git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
    sed -n 's/^blob //p' |
    sort -k2 -n |
    numfmt --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest |
    awk '$2 >= "10M" {print $0}' |
    column -t
}

push_to_github() {
    local repo=$1
    log "> Pushing $repo to GitHub"
    git remote add github git@github.com:asqcapital/$repo.git
    git push github --no-verify --all
    git push github --no-verify --tags
    log "> Pushed $repo to GitHub successfully"
}

set_default_branch() {
    local repo=$1
    local branch=$2
    log "> Setting default branch of $repo to $branch"
    gh api -X PATCH /repos/asqcapital/$repo -f default_branch=$branch > /dev/null
    log "> Default branch of $repo set to $branch"
}

# Main script
log "> Starting repository migration process"

# Check GitHub login and git-filter-repo installation
check_github_login
check_git_filter_repo

log "> Deleting and creating repositories"
for repo in neumann aslib_deploy aslib_strat; do
    delete_repo $repo
    create_repo $repo
done
log "> Repositories deleted and created successfully"

cd /app
rm -rf neumann
clone_and_setup gitlab.asqcapital.com.br:tech neumann

# check_large_files

log "> Removing large files"
git filter-repo --invert-paths \
    --path 'aslib/containers/mt5/ubuntu/mt5.zip' \
    --path 'terraform/linux_docker_server/.terraform/providers/registry.terraform.io/linode/linode/1.27.1/linux_amd64/terraform-provider-linode_v1.27.1' \
    --path 'terraform/linux_docker_server/.terraform/providers/registry.terraform.io/hashicorp/aws/3.5.0/linux_amd64/terraform-provider-aws_v3.5.0_x5' --force
log "> Large files removed successfully"

log "> Updating .gitmodules"
cp ~/.config/home-manager/git_migration/.gitmodules .gitmodules
git add .gitmodules
git commit -m "chore(gitsubmodules): change to relative path for GitHub format"
log "> .gitmodules updated successfully"

push_to_github neumann master

for repo in aslib_strat aslib_deploy; do
    log "> Migrating $repo"
    cd /app/neumann/src/python/$repo
    fetch_all_branches
    push_to_github $repo
    log "> Repository $repo migrated successfully"
done

log "> Setting default branches"
set_default_branch neumann master
set_default_branch aslib_strat develop
set_default_branch aslib_deploy master
log "> Default branches set successfully"

# 
log "> Repository migration completed successfully"


log "> Removing the cloned repository and re-creating it from GitHub"
cd /app

rm -rf neumann
clone_and_setup github.com:asqcapital neumann
log "> Repository re-created successfully"