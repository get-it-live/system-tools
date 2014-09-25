#!/bin/bash
set -e

repo=$1
branch=$2
mode=$3
dockerfile=$4
taskId=$5
auth=$6
cache=$7
force=$8

# Expand content to 'deploy' repo
deployDir="/git/${repo}/${mode}"
mkdir -p ${deployDir}
cd ${deployDir}

# Remote latest commit
remote_sha="`GIT_WORK_TREE=${deployDir} git ls-remote ${repo} refs/heads/${branch} | awk '{print $1}'`"
local_sha="`GIT_WORK_TREE=${deployDir} git rev-parse ${repo}/${branch}`"
echo "remote_sha=$remote_sha, local_sha=$local_sha"

if test "$remote_sha" = "$local_sha"
then
  if test "$force" = "False" 
  then
    echo "No commits since last check and build not forced, exiting."
    exit 0
  fi
fi

GIT_WORK_TREE=${deployDir} git checkout -f ${branch} || cd ${deployDir} && git checkout -f ${branch}

echo " ***** Building new Image..."
output=""
lastline=""

if [ "${cache}" == "False" ]; then
  useCache="--no-cache"
fi
test -z "${useCache}" && echo " ***** Building new Image (using cache)..." || echo " ***** Building new Image (not using cache)..."

docker -H tcp://127.0.0.1:5555 build -q ${useCache} "${dockerfile}" 2>&1 | {
  while IFS= read -r line
  do
    echo "  $line"
    output+="\\n${line}"
    lastline="$line"
  done
  image="`echo ${lastline} | awk '{print $3}'`"

  # Publish Dockerfile
  dockerfile_path="./${dockerfile}/Dockerfile"
  curl -k -s -XPOST --data-binary @${dockerfile_path} -u ${auth} -H 'Content-Type: text/plain' -H "Token: ${APIKEY}" \
    "http://www.getitlive.io/api/Hooks/Repository/${taskId}/Dockerfile"

  echo " ***** Publishing ${image} into your '${repo}' images repository..."
  success="true"
  if [ -z "$image" ]; then
    success="false"
  fi

  echo ${output} | curl -k -s -XPOST -d @- -u ${auth} -H 'Content-Type: application/json' -H "Token: ${APIKEY}" \
    "http://www.getitlive.io/api/Hooks/Repository/${taskId}/Done?success=${success}&image=${image}&commit=${remote_sha}"
  echo " ***** Image published!"
}

