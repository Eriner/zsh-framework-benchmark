Zsh Framework Benchmark
=======================

This is a small utility to benchmark various Zsh frameworks. All of the frameworks are 'installed' to a temporary directory (/tmp/zsh-benchmark). The raw results are saved in /tmp/zsh-benchmark-results. All of the frameworks are built with the instructions provided by the project README.md's.

To run, simply clone the repo and run `./run.zsh`.

The options are:
```
./run.zsh <options>
Options:
    -h                  Show this help
    -k                  Keep the frameworks (don't delete) after the tests are complete (default: delete)
    -p <path>           Set the path to where the frameworks should be 'installed' (default: /tmp/zsh-benchmark)
    -n <num>            Set the number of iterations to run for each framework (default: 100)
    -f <framework>      Select a specific framework to benchmark (default: all)
```

Benchmarks
----------

Here are some of my personal bechmarks. The various startup times differ based upon hardware (processor, HDD/SSD).

#### Raspberry Pi 2 (overclocked to ‘turbo’ preset)
```
The average startup time for oh-my-zsh is: 1.263948333333333
The average startup time for zplug is: 1.3285799999999985
The average startup time for prezto is: 0.89286727272727551
The average startup time for zim is: 0.61476090909091163
```

#### Desktop (HDD, AMD 8-core @5GHz)
```
The average startup time for oh-my-zsh is: 0.10499009900990101
The average startup time for zplug is: 0.11785148514851501
The average startup time for prezto is: 0.093247524752475261
The average startup time for zim is: 0.067990196078431459
```

#### Laptop (SSD, Lenovo X1 Carbon Gen 3)
```
The average startup time for oh-my-zsh is: 0.08309999999999937
The average startup time for zplug is: 0.090759999999999993
The average startup time for prezto is: 0.071940000000000004
The average startup time for zim is: 0.053629999999999969
```

#### Server (HDD, Intel 8-core @2.4GHz)
```
The average startup time for oh-my-zsh is: 0.81906000000000034
The average startup time for zplug is: 0.91442999999999997
The average startup time for prezto is: 0.73892999999999953
The average startup time for zim is: 0.38811000000000023
```
