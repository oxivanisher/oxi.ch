---
title: Ansible roles and collections on Ansible Galaxy
author: oxi
subtitle: ""
header_img: "img/it-header.jpg"
comment: false
toc: true
draft: false
lang: en
type: post
date: "2023-10-31"
categories:
  - IT
tags:
  - English
  - Ansible
series: []
---
# Background
In my day job as a Linux System Engineer I write a lot of linux automation stuff (often [ansible](https://www.ansible.com) things). But sadly very little of this is made public due to sensitive information, cost or just no interest of the customer or employer. My personal home lab is not nearly as complex as my jobs environments, but I rather write one role than do stuff manually multiple times. I try to adopt the infrastructure as code idea as much as possible also in my home lab.

I dreaded this step for a long time, since it was VERY time consuming, but I migrated all my roles which are still in use and not "internal only" from my own GitLab instance to [GitHub](https://github.com/oxivanisher/). All roles are called `role-NAME` and the collections containing the roles are called `collection-NAME`.

I split up the 68 roles into five collections withing my [Ansible Galaxy Namespace](https://galaxy.ansible.com/ui/namespaces/oxivanisher/):
* [linux_base](https://galaxy.ansible.com/ui/repo/published/oxivanisher/linux_base/)
* [linux_desktop](https://galaxy.ansible.com/ui/repo/published/oxivanisher/linux_desktop/)
* [linux_server](https://galaxy.ansible.com/ui/repo/published/oxivanisher/linux_server/)
* [raspberry_pi](https://galaxy.ansible.com/ui/repo/published/oxivanisher/raspberry_pi/)
* [windows_desktop](https://galaxy.ansible.com/ui/repo/published/oxivanisher/windows_desktop/)

# Migration to GitHub

First, I decided which roles to migrate and bundle them up into the collection. Once I had that, I used the following script to migrate the roles to GitHub. I did this in batches just to ensure everything is working as expected, but theoretically you could use this to migrate all roles at once. This script does the following tasks for each role:
1) Clones it to a temporary directory
1) Renames the branch `master` to `main` if it exists
1) Replaces the linter pipeline I used on gitlab with a corresponding GitHub action
1) Updates the `$ANSIBLE_DIR/requirements.yml` file
1) Archives the role on GitLab

## `migrate_roles.sh`
```bash
!/bin/bash
set -e

echo "Preparing environment"

GITHUB_TOKEN=github_pat_SOMETHING_VERY_SECURE
GITLAB_TOKEN=ALSO_VERY_SECURE
GITLAB_URL=https://gitlab.somewhere.lan/api/v4
TMP_DIR=~/.ansible
ANSIBLE_DIR=~/ansible

mkdir -p $TMP_DIR

REPOS=$'
  git@gitlab.somewhere.lan:ansible/role-win_debloat.git
  git@gitlab.somewhere.lan:ansible/role-win_explorer.git
  git@gitlab.somewhere.lan:ansible/role-win_startmenu.git
  git@gitlab.somewhere.lan:ansible/role-win_taskbar.git
'

for REPO in $REPOS
do
  echo -e "\n\nWorking on $REPO"
  cd $TMP_DIR

  REPO_NAME=$(echo $REPO | sed "s|git@gitlab.somewhere.lan:ansible/||g" | sed "s/.git//g")
  echo "> Discovered repo name: $REPO_NAME"

  git clone $REPO
  cd $REPO_NAME

  if [ "$(git rev-parse --abbrev-ref HEAD)" == "master" ];
  then
    echo "> Renaming master branch to main"
    git branch -m master main
  fi

  echo "> Creating github repo"
  curl -s -H "Authorization: token $GITHUB_TOKEN" --data "{\"name\":\"$REPO_NAME\"}" https://api.github.com/user/repos

  echo "> Updating repo origin url"
  git remote set-url origin git@github.com:YOUR_GITHUB_USER/$REPO_NAME.git

  echo "> Fix linting"
  git rm .gitlab-ci.yml
  mkdir -p .github/workflows/
  cp $TMP_DIR/push.yml .github/workflows/push.yml
  git add .github/workflows/push.yml
  git commit -m "migrate pipeline from gitlab to github"

  echo "> Pushing data to github"
  git push -u origin main

  echo "> Fix requirements file for ansible from $REPO to $NEW_ORIGIN_URL"
  NEW_ORIGIN_URL=$(git config --get remote.origin.url)
  sed -i "s|$REPO|$NEW_ORIGIN_URL|g" $ANSIBLE_DIR/requirements.yml

  echo "> Update ansible requirements file"
  cd $ANSIBLE_DIR
  git add requirements.yml
  git commit -m "Migrate role $REPO_NAME to github"
  git push

  echo "> Archive repo in gitlab"

  # Function to get the project ID by repository name
  get_project_id() {
    local search_response
    search_response=$(curl --request GET --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL/projects?search=$1")

    # Extract the project ID from the response
    project_id=$(echo "$search_response" | jq -r '.[0].id')
    echo "$project_id"
  }

  # Function to archive a project by project ID
  archive_project() {
    local project_id="$1"
    local archive_response
    archive_response=$(curl --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL/projects/$project_id/archive")

    # Check if the archive request was successful based on the "archived" field
    archived=$(echo "$archive_response" | jq -r '.archived')

    if [ "$archived" == "true" ]; then
      echo "> Repository '$REPO_NAME' (Project ID: $project_id) has been archived."
    else
      echo "> Failed to archive repository '$REPO_NAME' (Project ID: $project_id)."
      echo "> Response: $archive_response"
    fi
  }

  # Main script logic
  project_id=$(get_project_id "$REPO_NAME")

  if [ -n "$project_id" ]; then
    archive_project "$project_id"
  else
    echo "> Repository '$REPO_NAME' not found."
  fi

  echo "> Cleaning up $TMP_DIR/$REPO_NAME"
  rm -rf $TMP_DIR/$REPO_NAME
done
```


## `.github/workflows/push.yml`
```yaml
name: ansible-lint

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    name: ansible-lint
    steps:
      - uses: actions/checkout@master
      - uses: actions/setup-python@v2
      - run: pip install ansible ansible-lint
      - run: ansible-lint --version
      - run: ansible-lint --show-relpath .
```

# Ansible collections

The collections contain only some meta information and all included roles as git submodules, which will then be packaged into collection releases. After creating a empty collection, I had to change several things:

## Ansible version in `meta/runtime.yml`
Since my environment is at current versions, I was able to just choose the latest version. You might have to change that depending on the age of your roles and such.
```yaml
[..]
requires_ansible: '>=2.9.10'
[..]
```

## Galaxy configuration `galaxy.yml`
You can use this as a working example. Keep in mind that the requirements of the roles contained within this collection have to be defined here. If you define dependencies in the roles as well, it will fail and annoy you. See the [top answer on stackoverflow](https://stackoverflow.com/questions/69508170/ansible-role-dependency-handling-for-collections) for more info.

```yaml
### REQUIRED
# The namespace of the collection. This can be a company/brand/organization or product namespace under which all
# content lives. May only contain alphanumeric lowercase characters and underscores. Namespaces cannot start with
# underscores or numbers and cannot contain consecutive underscores
namespace: oxivanisher

# The name of the collection. Has the same character restrictions as 'namespace'
name: linux_base

# The version of the collection. Must be compatible with semantic versioning
version: 1.0.15

# The path to the Markdown (.md) readme file. This path is relative to the root of the collection
readme: README.md

# A list of the collection's content authors. Can be just the name or in the format 'Full Name <email> (url)
# @nicks:irc/im.site#channel'
authors:
  - Marc Urben

### OPTIONAL but strongly recommended
# A short summary description of the collection
description: Collection of linux base roles

# Either a single license or a list of licenses for content inside of a collection. Ansible Galaxy currently only
# accepts L(SPDX,https://spdx.org/licenses/) licenses. This key is mutually exclusive with 'license_file'
license:
  - GPL-2.0-or-later

# The path to the license file for the collection. This path is relative to the root of the collection. This key is
# mutually exclusive with 'license'
license_file: ""

# A list of tags you want to associate with the collection for indexing/searching. A tag name has the same character
# requirements as 'namespace' and 'name'
tags:
  - linux
  - base

# Collections that this collection requires to be installed for it to be usable. The key of the dict is the
# collection label 'namespace.name'. The value is a version range
# L(specifiers,https://python-semanticversion.readthedocs.io/en/latest/#requirement-specification). Multiple version
# range specifiers can be set and are separated by ','
dependencies:
  "ansible.posix": "*"
  "community.general": "*"

# The URL of the originating SCM repository
repository: https://github.com/oxivanisher/collection-linux_base.git

# The URL to any online docs
documentation: https://github.com/oxivanisher/collection-linux_base/blob/main/README.md

# The URL to the homepage of the collection/project
homepage: https://oxi.ch

# The URL to the collection issue tracker
issues: https://github.com/oxivanisher/collection-linux_base/issues

# A list of file glob-like patterns used to filter any files or directories that should not be included in the build
# artifact. A pattern is matched from the relative path of the file or directory of the collection directory. This
# uses 'fnmatch' to match the files or directories. Some directories and files like 'galaxy.yml', '*.pyc', '*.retry',
# and '.git' are always filtered. Mutually exclusive with 'manifest'
build_ignore: []
# A dict controlling use of manifest directives used in building the collection artifact. The key 'directives' is a
# list of MANIFEST.in style
# L(directives,https://packaging.python.org/en/latest/guides/using-manifest-in/#manifest-in-commands). The key
# 'omit_default_directives' is a boolean that controls whether the default directives are used. Mutually exclusive
# with 'build_ignore'
# manifest: null
```

## Add the roles as submodules
Since I created the collection manually and configured several things, some lines are commented.
```bash
#!/bin/bash

# Define the source GitLab repositories and their roles
gitlab_repositories=(
    "https://github.com/oxivanisher/role-apt_unattended_upgrade.git"
    "https://github.com/oxivanisher/role-apt_source.git"
    "https://github.com/oxivanisher/role-oxiscripts.git"
    "https://github.com/oxivanisher/role-ssh_server.git"
    "https://github.com/oxivanisher/role-os_upgrade.git"
    "https://github.com/oxivanisher/role-rebootcheck.git"
    "https://github.com/oxivanisher/role-nullmailer.git"
    "https://github.com/oxivanisher/role-smartd.git"
    "https://github.com/oxivanisher/role-packages.git"
    "https://github.com/oxivanisher/role-timezone.git"
    "https://github.com/oxivanisher/role-locales.git"
    "https://github.com/oxivanisher/role-ssh_keys.git"
    "https://github.com/oxivanisher/role-syslog.git"
    "https://github.com/oxivanisher/role-ntp.git"
    "https://github.com/oxivanisher/role-logwatch.git"
    "https://github.com/oxivanisher/role-realtime_clock.git"
    "https://github.com/oxivanisher/role-dnscache.git"
    "https://github.com/oxivanisher/role-hosts_file.git"
    "https://github.com/oxivanisher/role-hosts_override.git"
    "https://github.com/oxivanisher/role-nextcloud_davfs.git"
    "https://github.com/oxivanisher/role-keyboard_layout.git"
)

# Define the destination GitHub repository for the Ansible collection
#github_repo="https://github.com/your-user/ansible-collection.git"

# Clone the GitHub repository
#git clone $github_repo ansible-collection
#cd ansible-collection

# Initialize an empty Git repository if not already done
#git init

# Add a remote for the GitHub repository
#git remote add github $github_repo

# Loop through GitLab repositories
for repo_url in "${gitlab_repositories[@]}"
do
    # Extract the role name from the repository URL (adjust this if needed)
    role_name=$(basename $repo_url .git | sed 's/role-//g')

    # Add the GitLab repository as a submodule
    git submodule add $repo_url roles/$role_name

    # Commit the submodule addition
    git add .gitmodules roles/$role_name
    git commit -m "Add submodule for role $role_name from Github repository"

    # Push the changes to GitHub
    #git push origin master
done

# Clean up - remove local clones
#cd ..
#rm -rf ansible-collection
```

## Automatically create releases and upload them to Ansible Galaxy
And now to the magic bit. Since I am (probably) the only one using those roles, my aim is to automate this as much as possible ... I don't have to check this with anyone else and can do whatever I want. 🤪 So I created this GitHub workflow which automatically updates all the submodules to the latest commit, creates a release and then uploads it to Ansible Galaxy. This only happens, if I increase the `version` in `galaxy.yml`.

### `.github/workflows/release-new-version.yml`
```yaml
name: Auto Release and Publish to Ansible Galaxy

on:
  push:
    branches:
      - main
  workflow_run:
    workflows: ["Check for Version Change"]
    types:
      - completed

jobs:
  check_version:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          submodules: false

      - name: Update Submodules
        run: |
          git submodule update --init --recursive
          git submodule update --remote --merge

      - name: Check for Submodule Changes
        id: submodule_changes
        run: |
          # Check if there are changes in submodules
          if git diff --quiet --exit-code && git diff --quiet --exit-code --cached; then
            echo "No submodule changes detected."
            exit 0
          fi
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git commit -am "Update submodules from workflow"
          git push
          echo "Submodule changes detected and pushed to repository."
        continue-on-error: true

      - name: Check for Version Change
        id: version_change
        run: |
          # Get the current version in galaxy.yml
          CURRENT_VERSION=$(grep -Eo 'version: [0-9]+\.[0-9]+\.[0-9]+' galaxy.yml | cut -d ' ' -f 2)

          # Get the previous version in galaxy.yml from the last commit
          PREVIOUS_VERSION=$(git log -1 --pretty=format:"%h" -- galaxy.yml~1)

          # Check if the versions are different
          if [ "$CURRENT_VERSION" != "$PREVIOUS_VERSION" ]; then
            echo "Version change detected."
          else
            echo "No version change detected."
            exit 0
          fi
        continue-on-error: true

  create_release:
    runs-on: ubuntu-latest
    outputs:
      my_output: ${{ steps.get_new_version.outputs.new_version }}
    needs: check_version

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          ref: main
          submodules: true

      - name: Get New Version
        id: get_new_version
        run: |
          # Extract the new version from galaxy.yml
          NEW_VERSION=$(grep -Eo 'version: [0-9]+\.[0-9]+\.[0-9]+' galaxy.yml | cut -d ' ' -f 2)
          echo "New version: $NEW_VERSION"
          echo "new_version=$NEW_VERSION" >> "$GITHUB_ENV"

      - name: Get Submodule Commit Messages
        if: env.new_version != ''
        id: submodule_commit_messages
        run: |
          # Get the latest commit messages from all updated submodules
          SUBMODULE_COMMIT_MESSAGES=$(git submodule foreach --quiet 'git log -1 --pretty=format:"%s"')
          echo "submodule_commit_messages=$SUBMODULE_COMMIT_MESSAGES" >> "$GITHUB_ENV"

      - name: Create Release on Github
        id: release_created
        if: env.new_version != ''
        run: |
          # Use the submodule commit messages as release notes
          RELEASE_NOTES="Release notes for version $new_version:\n$SUBMODULE_COMMIT_MESSAGES"
          echo "Release notes:"
          echo "$RELEASE_NOTES"

          # Create a new release using the GitHub API
          RESULT=$(curl -X POST \
            -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
            -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/repos/${{ github.repository }}/releases \
            -d "{\"tag_name\":\"v$new_version\",\"name\":\"Release v$new_version\",\"body\":\"$RELEASE_NOTES\"}")

      - name: Build ansible galaxy collection
        if: env.new_version != ''
        run: |
          ansible-galaxy collection build .
        working-directory: ${{ github.workspace }}

      - name: Publish collection to Ansible Galaxy
        if: env.new_version != ''
        env:
          ANSIBLE_GALAXY_API_TOKEN: ${{ secrets.ANSIBLE_GALAXY_API_TOKEN }}
        run: |
          ansible-galaxy collection publish --token $ANSIBLE_GALAXY_API_TOKEN *.tar.gz
        working-directory: ${{ github.workspace }}
```

## Set `ANSIBLE_GALAXY_API_TOKEN` on GitHub
Add a Action Secret named `ANSIBLE_GALAXY_API_TOKEN` containing your [Galaxy API token](https://galaxy.ansible.com/ui/token/). The GitHub URL to this setting looks something like: `https://github.com/user/repo/settings/secrets/actions`

## Set permissions on the collection repository
On `https://github.com/user/repo/settings/actions` you have to set:
* Actions permissions to `Allow all actions and reusable workflows`
* Workflow permissions to `Read and write permissions`

## Push and upload
After all this is done, you should be able to push all this to GitHub and see the magic happen. Since I had the luck to do this during the surprise deployment of Ansible Galaxy NG by Red Hat, those steps took more than a month for me to be working. So if anything is missing or does not work, drop me a line so that I can update this page.

# Usage
To ensure all requirements are at the latest version, I run the following commands:
```bash
ansible-galaxy collection install --force --requirements-file requirements.yml
ansible-galaxy role install --force -r requirements.yml
```

I use a "master playbook" which contains all the different plays. This is how I configure all the basic things on all linux systems.

## `site.yaml`
```yaml
---
- name: Basic system updates, packages and settings
  hosts: all,!windows
  collections:
    - oxivanisher.linux_base
  roles:
    - role: oxivanisher.linux_base.packages                           # install site specific packages
    - role: oxivanisher.linux_base.ssh_server                         # configure root login
    - role: oxivanisher.linux_base.os_upgrade                         # upgrade system packages
      tags:
        - upgrade
        - never
    - role: oxivanisher.linux_base.rebootcheck                        # check if a reboot is required and if requested with the reboot tag, do the reboot
    - role: oxivanisher.linux_base.syslog                             # configure syslog
      tags:
        - syslog
    - role: oxivanisher.linux_base.logwatch                           # configure logwatch
    - role: oxivanisher.linux_base.apt_unattended_upgrade             # configure automatic security updates
    - role: oxivanisher.linux_base.oxiscripts                         # configure oxiscripts
      tags:
        - oxiscripts
    - role: oxivanisher.linux_base.timezone                           # configure timezone
    - role: oxivanisher.linux_base.apt_source                         # configure apt-sources
      tags:
        - apt_sources
    - role: oxivanisher.linux_base.locales                            # ensure basic locales
    - role: oxivanisher.linux_base.keyboard_layout                    # configure keyboard layout
    - role: oxivanisher.linux_base.prometheus_node_exporter           # prometheus node exporter
    - role: oxivanisher.linux_base.smartd                             # configure smartd to not crash if no disks are available (i.e. on rpis)
      tags:
        - smartd

- name: Basic for the really limited OpenElec (busy box based)
  hosts: all,!windows
  collections:
    - oxivanisher.linux_base
  roles:
    - role: oxivanisher.linux_base.ssh_keys                           # install ssh keys and configure root login
      tags:
        - basic_access

- name: Desktop/client only roles
  hosts: client,!windows
  collections:
    - oxivanisher.linux_base
    - oxivanisher.linux_desktop
  roles:
    - role: oxivanisher.linux_desktop.nextcloud_client                # configure nextcloud client package
    - role: oxivanisher.linux_desktop.vivaldi                         # install vivaldi browser
    - role: oxivanisher.linux_desktop.vscode                          # install visual studio code
    - role: oxivanisher.linux_desktop.sublime                         # install sublime text
    - role: oxivanisher.linux_desktop.signal_desktop                  # install signal desktop
    - role: oxivanisher.linux_desktop.keepassxc                       # install keepass xc
    - role: oxivanisher.linux_desktop.howdy                           # install howdy
    - role: oxivanisher.linux_desktop.wol                             # install and setup wol
    - role: oxivanisher.linux_desktop.fonts                           # install fonts
    - role: oxivanisher.linux_desktop.nas_mounts                      # mount nas drives
    - role: oxivanisher.linux_base.realtime_clock                     # set clock to use local rtc (thanks windows -.-)
    - role: oxivanisher.linux_desktop.ubuntu_hide_amazon_link         # disable ubuntu amazon spam
    - role: oxivanisher.linux_desktop.gnome_disable_inital_setup      # disable gnome initial setup
    - role: oxivanisher.linux_desktop.gnome_loginscreen_configure     # configure gnome loginscreen
[..]
```

## `requirements.yml`
```yaml
[..]
collections:
  - oxivanisher.linux_base
  - oxivanisher.linux_desktop
  - oxivanisher.linux_server
  - oxivanisher.raspberry_pi
  - oxivanisher.windows_desktop
[..]
```

# Development workflow for roles
To still be able to develop and test the roles without creating releases all the time, I link a development version into `roles/` and change the corresponding entry in the playbook. If you add a `dev` tag, it will speed up test runs massively.


```yaml
- name: Jump hosts
  hosts: jump
  collections:
    - oxivanisher.linux_base
    - oxivanisher.linux_server
  roles:
    # - role: oxivanisher.linux_server.jump_host                      # configure jumphost specific things
    - role: jump_host_dev                                             # configure jumphost specific things
      tags:
        - dev
```

# Final thoughts
Please be aware, that lots of roles don't have a readme yet and are even missing default variables and such. I will update the roles I touch for other reasons and update them, but use them at your own risk in the current state!

Also the GitHub workflow should use the newly created SHA on role submodule updates, since it theoretically is possible that a newer commit gets released if two pushes withing a short time window would mess things up. Since I am the only one doing stuff there, this is not really a concern fpr me.

Remember that you have to increase the version in `galaxy.yml` to trigger a release. For example if you updated one of the roles.

Ansible Galaxy would like to have a changelog and there are mechanisms to automate that also for the collections. But this is not yet implemented.
