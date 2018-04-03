# node-podcast-parser

[![build status](https://travis-ci.org/akupila/node-podcast-parser.svg?branch=master)](https://travis-ci.org/akupila/node-podcast-parser)
[![Coverage Status](https://coveralls.io/repos/github/akupila/node-podcast-parser/badge.svg?branch=master)](https://coveralls.io/github/akupila/node-podcast-parser?branch=master)

Parses a podcast RSS feed and returns easy to use object

## Output format

Takes an opinionated view on what should be included so not everything is. The goal is to have the result be as normalized as possible across multiple feeds.

```json
{
  "title":       "<Podcast title>",
  "description": {
    "short":       "<Podcast subtitle>",
    "long":        "<Podcast description>"
  },
  "link":       "<Podcast link (usually website for podcast)>",
  "image":      "<Podcast image>",
  "language":   "<ISO 639 language>",
  "copyright":  "<Podcast copyright>",
  "updated":    "<pubDate or latest episode pubDate>",
  "explicit":   "<Podcast is explicit, true/false>",
  "categories": [
    "Category>Subcategory"
  ],
  "owner": {
    "name":  "<Author name>",
    "email": "<Author email>"
  },
  "episodes": [
    {
      "guid":        "<Unique id>",
      "title":       "<Episode title>",
      "description": "<Episode description>",
      "explicit":    "<Episode is is explicit, true/false>",
      "image":       "<Episode image>",
      "published":   "<date>",
      "duration":    120,
      "categories":  [
        "Category"
      ],
      "enclosure": {
        "filesize": 5650889,
        "type":     "audio/mpeg",
        "url":      "<mp3 file>"
      }
    }
  ]
}
```

## Installation

```
yarn add node-podcast-parser
```

## Usage

```js
const parsePodcast = require('node-podcast-parser');

parsePodcast('<podcast xml>', (err, data) => {
  if (err) {
    console.error(err);
    return;
  }

  // data looks like the format above
  console.log(data);
});
```

## Parsing a remote feed

`node-podcast-parser` only takes care of the parsing itself, you'll need to download the feed first yourself.

Download the feed however you want, for instance using [request](https://github.com/request/request)

Example:

```js
const request = require('request');
const parsePodcast = require('node-podcast-parser');

request('<podcast url>', (err, res, data) => {
  if (err) {
    console.error('Network error', err);
    return;
  }

  parsePodcast(data, (err, data) => {
    if (err) {
      console.error('Parsing error', err);
      return;
    }

    console.log(data);
  });
});
```

## Testing

```js
yarn install
yarn run test
```

## Test coverage

```js
yarn install
yarn run cover
```

## Special notes

### Language

A lot of podcasts have the language set something like `en`. 
The spec requires the language to be [ISO 639](www.loc.gov/standards/iso639-2/php/code_list.php) so it will be convered to `en-us`.
A non-English language will be `lang-lang` such as `de-de`.
The language is always lowercase.

### Cleanup

Most content is left as it is but whitespace at beginning and end of strings is trimmed.

### Missing properties

Unfortunately not all podcasts contain all properties. If so they are simply ommited from the output.

These properties include:

- feed TTL
- episode categories
- episode image
- etc

Episode categories are included as an empty array if the podcast doesn't contain any categories.

### Generic RSS feeds

This module is specifically aimed at parsing RSS feeds and doesn't cater for more generic feeds from blogs etc.

Use [node-feedparser](https://github.com/danmactough/node-feedparser)
