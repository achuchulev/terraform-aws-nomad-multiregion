#!/usr/bin/env bash

# API endpoint for Nomad server Join Agent
curl \
    --request POST \
    $1/v1/agent/join?address=$2