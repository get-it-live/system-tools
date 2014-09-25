#!/bin/bash

repo=$1
branch=$2
mode="pull"
deployDir="/git/${repo}/${mode}"

cd ${deployDir}
remote_sha="`git ls-remote ${repo} refs/heads/${branch} | awk '{print $1}'`"
local_sha="`git rev-parse ${repo}/${branch}`"
echo "${remote_sha}:${local_sha}"
