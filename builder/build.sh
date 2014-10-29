#!/bin/bash

#set -e

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

function finish
{
  echo $1 | curl -k -s -XPOST -d @- -u ${auth} -H 'Content-Type: application/json' -H "Token: ${APIKEY}" \
    "http://www.getitlive.io/api/Hooks/Repository/${taskId}/Done?success=false&image=${image}&commit=${remote_sha}"  
  echo "ERROR : $1"
  exit 1
}


### Commented out because e already pull in a previous stage, from app/Build.PullRepo()
#checkout=""
#checkout="$(GIT_WORK_TREE=${deployDir} git checkout -f ${branch} || cd ${deployDir} && git checkout -f ${branch} 2>&1)"
#if [ $? -ne 0 ]
#then
#  echo "Repository checkout failed, aborting build."
#  finish "$checkout"
#  exit 1
#fi

output=""
lastline=""
if [ "${cache}" == "False" ]; then
  useCache="--no-cache"
fi
test -z "${useCache}" && echo " ***** Building new Image (using cache)..." || echo " ***** Building new Image (not using cache)..."

# Send/Publish Dockerfile
dockerfile_path="./${dockerfile}/Dockerfile"
test -f ${dockerfile_path} || finish "Could not find Dockerfile in specified path '${dockerfile_path}'"

$(curl -k -s -XPOST --data-binary @${dockerfile_path} -u ${auth} -H 'Content-Type: text/plain' -H "Token: ${APIKEY}" \
    "http://www.getitlive.io/api/Hooks/Repository/${taskId}/Dockerfile" 2>&1)

#build_dockerfile=$(docker -H tcp://127.0.0.1:5555 build -q ${useCache} "${dockerfile}" 2>&1)
#if [ $? -ne 0 ]
#then
#  finish($build_dockerfile)
#fi

build_dockerfile=""
build_dockerfile=$(docker -H tcp://127.0.0.1:5555 build -q ${useCache} "${dockerfile}" 2>&1 | {
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

  sleep 5
  docker -H tcp://127.0.0.1:5555 inspect ${image} || $(finish "Could not find built image '${image}'"; exit 1) 

  echo " ***** Publishing ${image} into your '${repo}' images repository..."
  echo ${output} | curl -k -s -XPOST -d @- -u ${auth} -H 'Content-Type: application/json' -H "Token: ${APIKEY}" \
    "http://www.getitlive.io/api/Hooks/Repository/${taskId}/Done?success=true&image=${image}&commit=${remote_sha}"
} 2>&1)

if [ $? -ne 0 ]
then
  finish "$build_dockerfile"
fi 
