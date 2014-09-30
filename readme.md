Piratebay desktop
=================

Copy from [piratebay-downloader](https://github.com/angel-git/piratebay-downloader) using Grunt to create a desktop port.

![Image](image1.png?raw=true)

## dependencies
- grunt
- ruby
- npm sass
- npm xml2js
- npm request
- npm mustache

## building
- do `npm install` to get dependencies under the project folder
- grunt build --platforms=linux32,linux64,mac,win

## issues
- does not run behind a proxy
- can't change month