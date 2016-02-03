#!/usr/bin/env zsh

# ensure that we're not running zsh from THREE AND A HALF YEARS AGO
if ! autoload -Uz is-at-least || ! is-at-least '5.0'; then
  print "${0}: running zsh < 5.0. Any further tests would be meaningless.
  Your shell has been outdated for over three and a half years." >&2
  return 1
fi

typeset -A results
spin=('/' '-' '\' '|')
test_dir='/tmp/zsh-benchmark'
keep_frameworks=false
integer iterations=100
# adding vanilla first, because it should always be the baseline
frameworks=(vanilla)
for f in ${0:h}/frameworks/*; do
  if [[ ${f:t:r} != 'vanilla' ]]; then 
    frameworks+=${f:t:r}
  fi
done
usage="${0} [options]
Options:
    -h                  Show this help
    -k                  Keep the frameworks (don't delete) after the tests are complete (default: delete)
    -p <path>           Set the path to where the frameworks should be 'installed' (default: /tmp/zsh-benchmark)
    -n <num>            Set the number of iterations to run for each framework (default: 100)
    -f <framework>      Select a specific framework to benchmark (default: all)"

while [[ ${#} -gt 0 && ${1} == -[hkpnf] ]]; do
  case ${1} in
    -h) print ${usage}
        return 0
        ;;
    -k) keep_frameworks=true
        shift
        ;;
    -p) shift
        mkdir -p ${1}
        if [[ -d ${1} ]]; then
          test_dir=${1}
        else
          print "${0}: directory ${1} specified by option '-p' is invalid" >&2
          return 1
        fi
        shift
        ;;
    -n) shift
        iterations=${1}
        shift
        ;;
    -f) shift
        if [[ ${frameworks[(r)${1}]} == ${1} ]]; then
          frameworks=${1}
        else
          print "${0}: framework \"${1}\" is not a valid framework.
Available frameworks are: ${frameworks}" >&2
          return 1
        fi
        shift
        ;;
  esac
done

# do some checks of the current environment so we can do cleanups later
#NOTE: these are workarounds, and are not the ideal solution to the problem of 'leftovers'
if [[ -d ${ZDOTDIR:-${HOME}}/.zplug ]]; then
  has_zplug=true
else
  has_zplug=false
fi

if [[ -s ${ZDOTDIR:-${HOME}}/.zsh-update ]]; then
  has_omz=true
else
  has_omz=false
fi

# we will use zpty to run all of the tests asynchronously
zmodload zsh/zpty || return 1


# the test_dir will be created by any (and every) framework's init script
# create the directory for the results.
results_dir=${test_dir}-results
mkdir -p ${results_dir}


spin() {
  local i
  for i in ${spin[@]}; do
    print -n "\b${i}"
    sleep 0.1
  done
}

get_avg_startup() {
  local startup_time startup_total startup_avg
  local i n

  startup_times=($(cut ${results_dir}/${1}.log -c49-53))
  for i in ${startup_times}; do (( startup_total += ${i} )); done
  for n in ${#startup_times}; do (( startup_avg = ${startup_total} / ${n} )); done

  results+=(${1} ${startup_avg})

  print "\rThe average startup time for ${1} is: ${(kv)results[${1}]}"
}

benchmark() {
  # first delete any old instances of the frameworks
  rm -rf "${test_dir}/${1}"

  # setup the directory for the framework
  mkdir -p ${test_dir}/${1}

  # source the installer
  print -n "\rNow setting up ${1}... ${spin[1]}"
  zpty -b ${1}-setup "source ${0:h}/frameworks/${1}.zsh &>/dev/null"
  while zpty -t ${1}-setup 2> /dev/null; do
    spin
  done

  # ensure we have a file
  touch "${test_dir}-results/${1}.log"

  # setup for run counting
  if [[ -s "${test_dir}-results/${1}.log" ]]; then
    local integer total_runs=$(wc -l < "${test_dir}-results/${1}.log")
  else
    local integer total_runs=0
  fi

  # set up the zpty for the framework
  zpty -b ${1} "ZDOTDIR=${test_dir}/${1} zsh -c \"for i in {1..${iterations}}; do {time zsh -ic 'exit' } 2>>! ${results_dir}/${1}.log; done\""
  while zpty -t ${1} 2> /dev/null; do
    # calculate how many runs we've done
    local iter=$(( $(wc -l < "${test_dir}-results/${1}.log") - ${total_runs} ))
    print -n "\rNow benchmarking ${1}... (${iter} / ${iterations}) ${spin[1]}"
    spin
  done

  # cleanup zpty
  zpty -d ${1}
  zpty -d ${1}-setup

  # print average time
  get_avg_startup ${1} 2>/dev/null

}

print "This may take a LONG time, as it runs each framework startup ${iterations} times.
Average startup times for each framework will be printed as the tests progress.\n"

for framework in ${frameworks}; do
  benchmark ${framework}
done

# cleanup frameworks unless '-k' was provided
if ( ! ${keep_frameworks} ); then
  rm -rf ${test_dir}
fi

# cleanup any corpses/leftovers
if ( ! ${has_zplug} ); then
  rm -rf ${ZDOTDIR:-${HOME}}/.zplug
fi

if ( ! ${has_omz} ); then
  rm -f ${ZDOTDIR:-${HOME}}/.zsh-update
fi
