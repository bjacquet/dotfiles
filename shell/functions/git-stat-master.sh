#!/bin/bash
# -*- mode: shell-script -*-

# Shows a diffstat against master.
.git_stat_master() {
    git diff origin/master --stat
}
