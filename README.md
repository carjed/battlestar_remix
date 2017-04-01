-   [TV script Twitter bot](#tv-script-twitter-bot)
    -   [Dependencies](#dependencies)
    -   [Running the script](#running-the-script)
    -   [Twitter API setup](#twitter-api-setup)
    -   [Configuration](#configuration)
    -   [Try with a new show](#try-with-a-new-show)
    -   [Automation](#automation)

------------------------------------------------------------------------
# TV script Twitter bot
------------------------------------------------------------------------

Scrape the scripts from your favorite TV show using the [Springfield! Springfield!](http://www.springfieldspringfield.co.uk/) database and remix them into tweetable quotes using a 2nd-order Markov chain with a modified version of the [Markov Sentence Generator](https://github.com/hrs/markov-sentence-generator).

This application was designed as the backbone for a [Battlestar Galactica-themed twitter bot](https://twitter.com/MightBeACylon), but with a little work can be adapted to perform similar tasks for any TV show in the Springfield! Springfield! database.

## Dependencies

This application was built using R v3.2.x or higher and Python v2.7.x/v3.5.x or higher. You must also have the following R packages installed:

``` r
require(rvest)
require(dplyr)
require(stringr)
require(twitteR)
require(yaml)
```

## Running the script
Running `Rscript /path/to/script_generator.R` from the command line (or `source(/path/to/script_generator.R)` from within an active R or RStudio session) outputs a single generated text string, such as:

`"[microphone screeching][sniffs] STARBUCK: It's an honor to have to talk, not really."`

You can also run this with the `tweet` argument (`Rscript /path/to/script_generator.R tweet`), which will load the `twitteR` package and the `_config.yml` file containing your unique API keys (see [Configuration](#configuration) below), then update the status of your twitter bot with the generated text:

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">[microphone screeching][sniffs] STARBUCK: It&#39;s an honor to have to talk, not really.</p>&mdash; Number Nine (@MightBeACylon) <a href="https://twitter.com/MightBeACylon/status/848220676280508418">April 1, 2017</a></blockquote>

## Twitter API Setup

In order to use the `tweet` argument and send tweets directly from this script, you will need to create a twitter application. If this is your first time using Twitter's REST API,  [SlickRemix](https://www.slickremix.com/docs/how-to-get-api-keys-and-tokens-for-twitter/) has a nice walkthrough for creating a twitter app and finding your keys.

## Configuration

Once you have set up your twitter app and located the four keys, you will need to create a file named `_config.yaml` and assign your keys to the appropriate variables (`api_key`, `api_secret`, `access_token`, and `access_token_secret`). This repository includes a [template file](_example_config.yaml) that you can modify with your unique keys. Remember to keep these keys secret to prevent unwanted access to your twitter app!

## Try with a new show

This application is designed to accommodate different shows from the Springfield! Springfield! database as flexibly as possible. Unfortunately, the metadata and actual script text from the database are not necessarily formatted the same as the Battlestar Galactica scripts used here. For example, background effects may be delimited by parentheses rather than square brackets, quotes may not be assigned to a character, and HTML tags for the episode names may differ slightly.

## Automation

This script can easily be run at regular intervals with cron or another job scheduler.
