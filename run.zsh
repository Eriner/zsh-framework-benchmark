#!/usr/bin/env zsh

typeset -A results
local spin=('/' '-' '\' '|')
local test_dir='/tmp/zsh-benchmark'
local results_dir='/tmp/zsh-benchmark-results'
local iterations=100
local usage="${0} [-h] [-n] -- benchmark various zsh frameworks for startup speed.

options:
    -h  show this help
    -n  set the number of iterations to run for each framework (default 100)"

while getopts ':hn:' option; do
  case ${option} in
    h) print ${usage}
       return 0
       ;;
    n) iterations=${OPTARG}
       ;;
    :) print "missing argument for -%s\n" "${OPTARG}" >&2
       print "${usage}" >&2
       return 1
       ;;
   \?) print "illegal option: -%s\n" "${OPTARG}" >&2
       print "${usage}" >&2
       return 1
       ;;
   esac
done
shift $(( OPTIND - 1 ))

# we will use zpty to run all of the tests asynchronously
zmodload zsh/zpty


# the test_dir will be created by any (and every) framework's init script
# create the directory for the results.
mkdir -p ${results_dir}


spin() {
  for i in ${spin[@]}; do
    printf "\b${i}"
    sleep 0.1
  done
}

get_avg_startup() {
  local startup_time startup_total startup_avg

  startup_times=($(cut ${results_dir}/${1}.log -c49-53))
  for i in ${startup_times}; do (( startup_total += ${i} )); done
  for n in ${#startup_times}; do (( startup_avg = ${startup_total} / ${n} )); done

  results+=(${1} ${startup_avg})

  printf "\rThe average startup time for ${1} is: ${(kv)results[${1}]}\n"
}

benchmark() {
  # source the installer
  print -n "\rNow setting up ${1}... ${spin[1]}"
  zpty -b ${1}-setup "source ${0:h}/${1}.zsh"
  while zpty -t ${1}-setup 2> /dev/null; do
    spin
  done

  # set up the zpty for the framework
  print -n "\rNow benchmarking ${1}... ${spin[1]}"
  zpty -b ${1} "ZDOTDIR=${test_dir}/${1} zsh -c \"for i in {1..${iterations}}; do {time zsh -ic 'exit' } 2>>! ${results_dir}/${1}.log; done\""
  while zpty -t ${1} 2> /dev/null; do
    spin
  done

  # cleanup zpty
  zpty -d ${1}
  zpty -d ${1}-setup

  # print average time
  get_avg_startup ${1}

}

print "This may take a LONG time, as it runs each framework startup ${iterations} times"
print "Average startup times for each framework will be printed as the tests progress.\n"
sleep 5

benchmark 'oh-my-zsh'
benchmark 'zplug'
benchmark 'prezto'
benchmark 'zim'

# for testing, may add option to keep these for user-testing of individual frameworks
rm -rf ${test_dir}
