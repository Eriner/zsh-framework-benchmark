#!/usr/bin/env zsh

local spin=('/' '-' '\' '|')
typeset -A results

spin() {
  for i in ${spin[@]}; do
    printf "\b${i}"
    sleep 0.1
  done
}

get_avg_startup() {
  local startup_time startup_total startup_avg

  startup_times=($(cut /tmp/zsh-benchmark/results/${1}.log -c49-53))
  for i in ${startup_times}; do (( startup_total += ${i} )); done
  for n in ${#startup_times}; do (( startup_avg = ${startup_total} / ${n} )); done

  results+=(${1} ${startup_avg})

  printf "\rThe average startup time for ${1} is: ${(kv)results[${1}]}"
}

# first we need to create the output folder(s)
mkdir -p /tmp/zsh-benchmark/results

print 'This will take a LONG time, as it runs each framework startup 100 times'
print 'Average startup times for each framework will be printed as the tests progress.'
sleep 5

# oh-my-zsh {{{
source ${0:h}/oh-my-zsh.zsh

# run the benchmarks
ZDOTDIR=${omz_install} zsh -ic "for i in {1..10}; do { time zsh -ic 'exit' } 2>>! /tmp/zsh-benchmark/results/oh-my-zsh.log; done" &
pid=$!

print -n "\rNow benchmarking oh-my-zsh... ${spin[1]}"
while kill -0 ${pid} 2> /dev/null; do
  spin
done

get_avg_startup "oh-my-zsh"

#}}}
# vim:foldmethod=marker:foldlevel=0
