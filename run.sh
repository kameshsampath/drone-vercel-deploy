#!/usr/bin/env bash

set -e
set -o pipefail

VERCEL_COMMAND=("vercel" "--prod" "--prebuilt")

if [ -z "${PLUGIN_VERCEL_TOKEN}" ];
then
	echo "Please set Vercel Token to use (Settings Name: vercel_token)"
	exit 1
fi

VERCEL_COMMAND+=("-t" "${PLUGIN_VERCEL_TOKEN}")

if [[ -z "${PLUGIN_VERCEL_ORG_ID}" ]];
then
  echo "Please set Vercel Organization(Settings Name: vercel_org_id )"
	exit 1
fi 

if [ -n "${PLUGIN_VERCEL_ORG_ID}" ];
then
  VERCEL_ORG_ID="${PLUGIN_VERCEL_ORG_ID}"
fi 

if [[ -n "${PLUGIN_VERCEL_PROJECT_ID}" && "${PLUGIN_VERCEL_PROJECT_CREATE}" == "true" ]];
then
  printf "\nCreating Vercel Project %s\n" "${PLUGIN_VERCEL_PROJECT_ID}"
  vercel projects -t "$PLUGIN_VERCEL_TOKEN" add "$PLUGIN_VERCEL_PROJECT_ID"
fi

if [ -n "${PLUGIN_VERCEL_PROJECT_ID}" ];
then
  printf "\nUsing Vercel Project %s\n" "${PLUGIN_VERCEL_PROJECT_ID}"
  VERCEL_PROJECT_ID="${PLUGIN_VERCEL_PROJECT_ID}"
fi 

## parameters takes precedence
if [[ (  -z "${PLUGIN_VERCEL_PROJECT_ID}"  &&  -z "${PLUGIN_VERCEL_ORG_ID}" ) &&  -f "${DRONE_WORKSPACE}/.vercel/project.json"  ]];
then
  printf "Found .vercel config loading project from it"
  VERCEL_ORG_ID=$(jq -r '.orgId' "${DRONE_WORKSPACE}/.vercel/project.json")
  VERCEL_PROJECT_ID=$(jq -r '.projectId' "${DRONE_WORKSPACE}/.vercel/project.json")
else
  VERCEL_COMMAND+=("-c")
fi

if [ -n "${VERCEL_ORG_ID}" ] && [ -n "${VERCEL_ORG_ID}" ];
then 
  export VERCEL_ORG_ID
  export VERCEL_PROJECT_ID
fi

printf "\nBuilding Vercel Project\n"
vercel pull -t "${PLUGIN_VERCEL_TOKEN}"
vercel build --prod
printf "\n"

CLEAN_COMMANDS=("rm" "-rf" ".vercel" ".next")

exec bash -c "${VERCEL_COMMAND[*]} && ${CLEAN_COMMANDS[*]}"