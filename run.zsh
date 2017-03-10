#!/usr/bin/env zsh

# ensure that we're not running zsh from THREE AND A HALF YEARS AGO
if ! autoload -Uz is-at-least || ! is-at-least '5.0'; then
  print "${0}: running zsh < 5.0. Any further tests would be meaningless.
  Your shell has been outdated for over three and a half years." >&2
  return 1
fi

typeset -A results
spin=('/' '-' '\' '|')
test_dir="$(mktemp -d)-zsh-benchmark"
keep_frameworks=false
force_delete=false
integer iterations=100
frameworks=()
# adding vanilla first, because it should always be the baseline
available_frameworks=(vanilla)
for f in ${0:h}/frameworks/*; do
  if [[ ${f:t:r} != 'vanilla' ]]; then
    available_frameworks+=${f:t:r}
  fi
done

# ensure to use dot ('.') as decimal separator, because some locale (ex: it_IT) use comma (',')
unset LC_NUMERIC

usage="${0} [options]
Options:
    -h                  Show this help
    -k                  Keep the frameworks (don't delete) after the tests are complete (default: delete)
    -p <path>           Set the path to where the frameworks should be 'installed' (default: auto-generated)
    -n <num>            Set the number of iterations to run for each framework (default: 100)
    -f <framework>      Select a specific framework to benchmark (default: all; can specify more than once)
    -F                  Forcibly delete ~/.zplug and OMZ update files when cleaning up"

while [[ ${#} -gt 0 ]]; do
  case ${1} in
    -h) print ${usage}
        return 0
        ;;
    -k) keep_frameworks=true
        shift
        ;;
    -F) force_delete=true
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
        if [[ ${available_frameworks[(r)${1}]} == ${1} ]]; then
          frameworks+=${1}
        else
          print "${0}: framework \"${1}\" is not a valid framework.
Available frameworks are: ${available_frameworks}" >&2
          return 1
        fi
        shift
        ;;
    *) print ${usage}
       return 1
       ;;
  esac
done

if (( ${#} )); then
  print ${usage}
  return 1
fi

if (( ! ${#frameworks} )); then
  frameworks=($available_frameworks)
fi

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

  startup_times=($(sed -e 's/.*cpu //' -e 's/ total//' ${results_dir}/${1}.log))
  for i in ${startup_times}; do (( startup_total += ${i} )); done
  (( startup_avg = ${startup_total} / ${#startup_times} * 1000 ))
  startup_avg=$(printf "%.0f ms" ${startup_avg})

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
  get_avg_startup ${1}

}

# Useful for debugging.
print "Frameworks: ${test_dir}"
print "Results: ${results_dir}\n"

print "This may take a LONG time, as it runs each framework startup ${iterations} times.
Average startup times for each framework will be printed as the tests progress.\n"

for framework in ${frameworks}; do
  benchmark ${framework} || exit $status
done

# cleanup frameworks unless '-k' was provided
if ( ! ${keep_frameworks} ); then
  rm -rf ${test_dir}
fi

# cleanup any corpses/leftovers
if ( ${force_delete} ); then
  echo 'removing zplug'
  if ( ! ${has_zplug} ); then
    # echo rm -rf ${ZDOTDIR:-${HOME}}/.zplug
  fi

  if ( ! ${has_omz} ); then
    rm -f ${ZDOTDIR:-${HOME}}/.zsh-update
  fi
fi
