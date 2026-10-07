#!/bin/bash
# -*- mode: shell-script -*-

# Tries to checkout main and pulls from origin.
.git_checkout_main_pull() {
    git checkout main && git pull --ff-only
}
