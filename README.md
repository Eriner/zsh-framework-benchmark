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

See the [Zim wiki 'Speed' page](https://github.com/Eriner/zim/wiki/Speed) for my personal benchmarks.
