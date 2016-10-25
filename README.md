# lua-tui

A library for doing things with terminals

## Status

This was a weekend project. You probably shouldn't use it in any projects.


## Components

### tui.filters

Tells you how long a potentially unread escape sequence will be.

Filters get a `peek` function that they use to lookahead on an input stream.


### tui.terminfo

Parser for terminfo files


### tui.tput

`init` and `reset` functions


## Useful links

  - http://invisible-island.net/xterm/ctlseqs/ctlseqs.html
