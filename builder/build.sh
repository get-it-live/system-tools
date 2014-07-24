#!/bin/bash

repo=$1
branch=$2
mode=$3
dockerfile=$4
taskId=$5
auth=$6

# Expand content to 'deploy' repo
deployDir="/git/${repo}/${mode}"
mkdir -p ${deployDir}
GIT_WORK_TREE=${deployDir} git checkout -f ${branch} || cd ${deployDir} && git checkout -f ${branch}
cd ${deployDir}
echo " ***** Building new Image..."
output=""
lastline=""
docker -H tcp://127.0.0.1:5555 build -q "${dockerfile}" 2>&1 | {
  while IFS= read -r line
  do
    echo "$line"
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

  echo ${output} | curl -k -XPOST -d @- -u ${auth} -H 'Content-Type: application/json' -H "Token: ${APIKEY}" \
    "http://www.getitlive.io/api/Hooks/Repository/${taskId}/Done?success=${success}&image=${image}"
  echo " ***** Image published!"
}

