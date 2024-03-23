# smarter

## The Basics

### Python

- Sequences
  - sets
    - Removing duplicates
    - disjunction
    - Conjunction
  - Slicing
  - Dictionary: and, or
    - Counter
  - Comprehensions
    - List
    - Set
    - Dictionary
- Ternary
- Printing
  - Secrets of print (sep,end), flush
  - Fstring
  - super print (from the parent)
- Swap in place
- Start-up (__name__ == “__main__”)
- Exception handling
- Args & Kwargs
- lambda (closures)
- toto: complete this from ase24/docs/ninjas

### Just enough statistics

- normal
  - incremental update
- triangular
- cdf
- [entropy](entropy.md) 
- discretization (simple) recall doherty icml'95
- difference
  - effect size
  - significance
  - ranking (SK)

### Shell

- Regex
- awk
- Makefile
- shebang
- pipes

## Smarter Scripting

- little languages (regx, data models headers, __d__2options)
- DRY, not WET
- licensing
- packaging
- information hiding
  - [API](https://www.hyrumslaw.com/) (you get one chance to write an API)

### scripting

- script101
  - documentation
  - exposed control parameters
  - test suite
  - source control
    - config in source control. eg. my fav tmus start up
  - piping
    - shut the heck up (quiet execution)
    - standard files STDIN, STDERR, STDOUT
  - seed control
- automate everything (makefile: insert awkward stuff there)
- test engine
  - setup,
    - reset
  - tear down
  - $?
  - static code analysis (language server protocol)
- documentation (docstrings)
  - tuning
- decomposition (pipes, stdio)
- less is more (technical debt, my DATA model)
- pre-commit hooks
  - e.g. badging

## Easier AI

- active learning (one thing per leaf)
Data

classifier:

- Naive bayes
- knn (no clustering) <== can be regressions as well
- decision tree

clustering:

- one sample per leaf (tiny training)
- regression and classification
- sample plus propagate

- lessons:
  - data reduction (just one sample per leaf)
  - when recursively clustering, use less and less to find poles.

## KE

W1: data.

- Little languages: data headers (bigger: regular expressions)
- Test suite
- documentation
- Pipe and filter/ architecture

W2: classification

- Bayes
- Labelling

## Read More
