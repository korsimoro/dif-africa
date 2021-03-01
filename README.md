# dif-apac
Support DIF APAC/ASEAN Data Collection

Please feel free to make any pull requests at any time, about any thing.

## Branches

  * setup
    Commits to this branch trigger the publication of a jekyll
    driven github pages static site.

  * gh-pages
    this contains only a docs directory which serves the content.

## Repository Layout

### top level
  * companies.csv
    Feel free to add your company information to this spreadsheet.

  * regulations.csv


### jekyll-src

  * this is a jekyll site using the minimal mistakes theme
  * data-processing is responsible for combining data from various data
    sources and putting it in data-processing/site directory, which is
    also the jekyll-src/_data directory.
  * .github/workflows/github-pages.yml defines the workflow that
    publishes data.

### data-processing

  * ```scripts``` contains scripts which munge the data.  this takes
    care of munging that can not or ought not be performed by the ruby
    scripts in the ```jekyll-src/_plugins``` directory.

  * ```scopes```

    - ```repo``` contains symlinks to the files at the top level that
      represent repo-based data.

    - ```notion``` contains downloads from the notion environment

    - ```google``` contains google/kumu data.  kumu can read from
      google sheets, but not github (yet).

  * ```site``` contains the data visible as ```jekyll-src/_data```
    and which is the output of the data munging process.
