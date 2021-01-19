# RBON

* [VERSION 0.0.210119](https://github.com/carlosjhr64/rbon/releases)
* [github](https://www.github.com/carlosjhr64/rbon)
* [rubygems](https://rubygems.org/gems/rbon)

## INSTALL:

```shell
$ gem install rbon
```

## DESCRIPTION:

RBON is not JSON!

Use RBON to store your configration "Items",
if by "Items" you mean that:
`Key = (Symbol=~/^\w+[?!]?$/)`
and
`Item = (Key | String | Integer | Float | nil | bool)`
and
`Items = (Item | Array[Items] | Hash[Key, Items])`.

## SYNOPSIS:

```ruby
require 'rbon'

CONFIG = {
  author: "CarlosJHR64",
  year: 2021,
  Key_List: [
    :yes!,
    :wut?,
    :no
  ],
}

# RBON.new(String newline:$/, String tab:'  ')
rbon = RBON.new

# Key   = (Symbol=~/^\w+[?!]?$/)
# Item  = (Key | String | Integer | Float | nil | bool)
# Items = (Item | Array[Items] | Hash[Key, Items])
# RBON#dump(Items item, IO io: StringIO.new)
dump = rbon.dump CONFIG

dump.class #=> String
dump       #~> ^\{\s*author: "CarlosJHR64"

# The dump is just a very restricted strict ruby code for Items:
unsafe = eval dump
CONFIG == unsafe #=> true

# But don't eval an untrusted RBON dump, load it in RBON instead:
safe = RBON.load dump
CONFIG == safe # TODO
```

## LICENSE:

Copyright 2021 CarlosJHR64

Permission is hereby granted, free of charge,
to any person obtaining a copy of this software and
associated documentation files (the "Software"),
to deal in the Software without restriction,
including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and
to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice
shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS",
WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
