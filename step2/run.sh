#!/bin/bash

# Fancy colors
NOCOLOR='\033[0m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'

DC1_DATA_DIR=$(pwd)/data/prom-dc1
DC2_DATA_DIR=$(pwd)/data/prom-dc2


generateData(){
  echo -e "${YELLOW} Running thanos-bench${NOCOLOR}"

  # if [[ $1 == ${DC1_DATA_DIR} ]]; then
  #   docker container run --rm -it quay.io/thanos/thanosbench:v0.2.0-rc.1 block plan -p continuous-365d-tiny | docker container run --rm -v $1:/out -i quay.io/thanos/thanosbench:v0.2.0-rc.1 block gen --output.dir /out
  # else
  #   # We change the profil in order to avoid the supperposition of the samples for the two prom instance
  #   docker container run --rm -it quay.io/thanos/thanosbench:v0.2.0-rc.1 block plan -p continuous-1w-small | docker container run --rm -v $1:/out -i quay.io/thanos/thanosbench:v0.2.0-rc.1 block gen --output.dir /out
  # fi
}

checkAndGenerateData(){
  if [[ -d $1 ]]; then
    while true; do
      echo -en "${ORANGE} Data dir $1 already exist. Keep exisiting data (y/n) :${NOCOLOR}"
      read -n 1 answer
      case $answer in
        [Yy]* ) break;;
        [Nn]* ) rm -rf $1; generateData $1;  break;;
        * ) echo "Please answer y or n.";;
      esac
    done
  else
    generateData $1
  fi
}

startCompose(){
  docker-compose up -d
  echo -e "\n\n${GREEN}Grafana should be availaible at http://localhost:3100${NOCOLOR}"
  echo -e "\n\n${GREEN}Prometheus for DC1 should be availaible at http://localhost:9191${NOCOLOR}"
  echo -e "\n\n${GREEN}Prometheus for DC2 should be availaible at http://localhost:9192${NOCOLOR}"
  echo -e "\n\n${GREEN}Thanos global query should be availaible at http://localhost:9090${NOCOLOR}"
  
}

echo -e "\n\n${CYAN}************"
echo -e "${CYAN}Setting up local environment via Docker-compose"
echo -e "${CYAN}************${NOCOLOR}"

echo -e "${YELLOW}First let's stop existing stack if it exists${NOCOLOR}"
docker-compose down

echo -e "\n\n${CYAN}Generating 1 year of data for client cli1 in ${DC1_DATA_DIR}${NOCOLOR}"

checkAndGenerateData $DC1_DATA_DIR

echo -e "\n\n${CYAN}Generating 1 year of data for client cli2 in ${DC2_DATA_DIR}${NOCOLOR}"

checkAndGenerateData $DC2_DATA_DIR

echo -e "\n\n${GREEN}Starting local stack on docker-compose${NOCOLOR}"

startCompose