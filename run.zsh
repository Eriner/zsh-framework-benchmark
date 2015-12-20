#!/usr/bin/env zsh

# we will use zpty to run all of the tests asynchronously
zmodload zsh/zpty

local test_dir='/tmp/zsh-benchmark'
local results_dir='/tmp/zsh-benchmark-results'
local spin=('/' '-' '\' '|')
typeset -A results

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
  zpty -b ${1}-setup "${0:h}/${1}.zsh"
  while zpty -t ${1}-setup 2> /dev/null; do
    spin
  done

  # set up the zpty for the framework
  print -n "\rNow benchmarking ${1}... ${spin[1]}"
  zpty -b ${1} "ZDOTDIR=${test_dir}/${1} zsh -c \"for i in {1..10}; do {time zsh -ic 'exit' } 2>>! ${results_dir}/${1}.log; done\""
  while zpty -t ${1} 2> /dev/null; do
    spin
  done

  # cleanup zpty
  zpty -d ${1}
  zpty -d ${1}-setup

  # print average time
  get_avg_startup ${1}

}
# first we need to create the output folder(s)
mkdir -p /tmp/zsh-benchmark/results

print "This will take a LONG time, as it runs each framework startup 100 times"
print "Average startup times for each framework will be printed as the tests progress.\n"
sleep 5

benchmark 'oh-my-zsh'
benchmark 'zplug'

# for testing, may add option to keep these for user-testing of individual frameworks
rm -rf ${test_dir}
