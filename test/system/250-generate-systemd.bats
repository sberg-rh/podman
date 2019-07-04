#!/usr/bin/env bats   -*- bats -*-
#
# Tests generated configurations for systemd.
#

load helpers

# Be extra paranoid in naming to avoid collisions.
SERVICE_NAME="podman_test_$(random_string)"
UNIT_DIR="$HOME/.config/systemd/user"
UNIT_FILE="$UNIT_DIR/$SERVICE_NAME.service"

function setup() {
    basic_setup
    mkdir -p "$UNIT_DIR"
}

function teardown() {
    rm -f "$UNIT_FILE"
    systemctl --user stop "$SERVICE_NAME"
    basic_teardown
}

@test "podman generate - systemd - basic" {
    skip_if_not_systemd
    skip_if_remote

    run_podman create $IMAGE echo "I'm alive!"
    cid="$output"

    run_podman generate systemd $cid > "$UNIT_FILE"

    run systemctl --user start "$SERVICE_NAME"
    if [ $status -ne 0 ]; then
        die "The systemd service $SERVICE_NAME did not start correctly!"
    fi

    run_podman logs $cid
    is "$output" "I'm alive!" "Container output"
}

# vim: filetype=sh
