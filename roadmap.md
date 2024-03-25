# smarter
## Why basic
- https://world.hey.com/dhh/finding-the-last-editor-dae701cc
- Doug McIlroy : We used to sit around in the Unix Room saying, 'What can we throw out? Why is there this option?' It's often because there is some deficiency in the basic design — you didn't really hit the right design point. Instead of adding an option, think about what was forcing you to add that option.
- The more you code the more you have to maintain, upgrade, port to other systems.

### Counter case
- simplicity takes time (Bliase Pacal: 
  <em>Je n'ai fait celle-ci plus longue que parce que je n'ai pas eu le loisir de la faire plus courte.</em>
  I would have written a shorter letter, but I did not have the time.)
- Complexity sells (or, more accurately, the maintaince income associated with complexity sells).
- Complexity is attractive (lures in the unwary, locks them in with so many decisions they mever want to remake)
- less is a bore
- teaching package manager, codespaces, vscode. markmap

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
