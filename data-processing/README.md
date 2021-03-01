
# Data-Processing

This directory contains scripts that call ruby utilities to massage the
data in ways that are convenient.

The ruby required should match static-site, so that if you can run jekyll
to build the site, you can run this data mgmt environment.

This will be executed by github actions as well as at the command line.  In
both cases environment variables will be used to communicate relevant
API keys.



- Manages a _data directory as a .git submodule
  - clones from a given space
  - 
