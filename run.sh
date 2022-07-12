#!/usr/bin/env bash

set -e
set -o pipefail

if [ -z "${PLUGIN_VERCEL_TOKEN}" ];
then
	echo "Please set Vercel Token to use (Settings Name: vercel_token)"
	exit 1
fi

VERCEL_ENV="${PLUGIN_VERCEL_ENVIRONMENT}"

if [ "${PLUGIN_LOG_LEVEL}" == "debug" ];
then
  printf "\n Vercel Environment %s \n" "${VERCEL_ENV}"
fi

if [ -z "${PLUGIN_VERCEL_SITE_DIR}" ];
then
  PLUGIN_VERCEL_SITE_DIR=.
fi

printf "\nUsing directory '%s' as site directory\n" "${PLUGIN_VERCEL_SITE_DIR}"

cd "${PLUGIN_VERCEL_SITE_DIR}"

VERCEL_COMMAND+=("vercel" "deploy" "--prebuilt" "-t" "${PLUGIN_VERCEL_TOKEN}")

if [ "${VERCEL_ENV}" == "production" ];
then
  VERCEL_COMMAND+=("--prod")
fi

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
fi

VERCEL_COMMAND+=("-c")

export VERCEL_ORG_ID
export VERCEL_PROJECT_ID
export VERCEL_ENV

if [ "${PLUGIN_LOG_LEVEL}" == "debug" ];
then
  printf " \n Vercel Runtime Env %s  \n" "${PLUGIN_VERCEL_ENVIRONMENT_VARIABLES}"
fi

if [ -f "${PLUGIN_VERCEL_ENVIRONMENT_VARIABLE_FILE}" ];
then
  printf " \n Loading Environment variable files from  %s  \n" "${PLUGIN_VERCEL_ENVIRONMENT_VARIABLE_FILE}"
  while IFS= read -r l; do
      if [ -n "$PLUGIN_VERCEL_ENVIRONMENT_VARIABLES" ];
      then
        PLUGIN_VERCEL_ENVIRONMENT_VARIABLES="$PLUGIN_VERCEL_ENVIRONMENT_VARIABLES,$l"
      else 
        PLUGIN_VERCEL_ENVIRONMENT_VARIABLES="$l"
      fi
  done < "${PLUGIN_VERCEL_ENVIRONMENT_VARIABLE_FILE}"
fi

OLDIFS=$IFS
if [ -n "${PLUGIN_VERCEL_ENVIRONMENT_VARIABLES}" ] ;
then
   IFS=, read -ra envarray <<< "${PLUGIN_VERCEL_ENVIRONMENT_VARIABLES}"
   for i in "${!envarray[@]}";
   do
      IFS='=' read -ra kv <<< "${envarray[i]//[$'\t\r\n']}"
      # Remove it to ensure we add it afresh, handle Error if key not found
      vercel env rm -y -t "${PLUGIN_VERCEL_TOKEN}" "${kv[0]}" "${VERCEL_ENV}" || true &>/dev/null
      echo -n "${kv[1]}" | vercel env add -t "${PLUGIN_VERCEL_TOKEN}" "${kv[0]}" "${VERCEL_ENV}" 
   done
fi
IFS=$OLDIFS

printf "\nBuilding Vercel Project for environment %s \n" "${VERCEL_ENV}"

vercel pull -t "${PLUGIN_VERCEL_TOKEN}" --environment="${VERCEL_ENV}"
if [ "${VERCEL_ENV}" == "production" ];
then
  vercel build --prod
else
  vercel build
fi

printf "\n"

CLEAN_COMMANDS=("rm" "-rf" ".vercel" ".next")

if [ "${PLUGIN_LOG_LEVEL}" == "debug" ];
then
  printf " \n Vercel COMMAND %s  \n" "${VERCEL_COMMAND[*]}"
fi

exec bash -c "${VERCEL_COMMAND[*]} && ${CLEAN_COMMANDS[*]}"
