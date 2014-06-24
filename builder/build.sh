#!/bin/bash

repo=$1
branch=$2
mode=$3
dockerfile=$4

# Expand content to 'deploy' repo
deployDir="/git/${repo}/${mode}"
mkdir -p ${deployDir}
GIT_WORK_TREE=${deployDir} git checkout -f ${branch}
cd ${deployDir}
echo " ***** Building new Image..."
lastline=""
docker -H tcp://127.0.0.1:@Model.Port build -q "${dockerfile}" | {
  while IFS= read -r line
  do
    echo "$line"
    lastline="$line"
  done
  image="`echo ${lastline} | awk '{print $3}'`"
  echo " ***** Publishing ${image} into your '${repo}' images repository..."
  curl -s -k -XPOST -d "" -H "Token: ${APIKEY}" "http://www.getitlive.io/api/Hooks/Repository/${guid}/Done?success=true&image=${image}"
  echo " ***** Image published!"
}
