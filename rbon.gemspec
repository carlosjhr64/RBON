Gem::Specification.new do |s|

  s.name     = 'rbon'
  s.version  = '0.0.210120'

  s.homepage = 'https://github.com/carlosjhr64/rbon'

  s.author   = 'carlosjhr64'
  s.email    = 'carlosjhr64@gmail.com'

  s.date     = '2021-01-20'
  s.licenses = ['MIT']

  s.description = <<DESCRIPTION
RBON is not JSON!

Use RBON to store your configration "Items",
if by "Items" you mean that:
`Key = (Symbol=~/^\w+[?!]?$/)`
and
`Item = (Key | String | Integer | Float | nil | bool)`
and
`Items = (Item | Array[Items] | Hash[Key, Items])`.
DESCRIPTION

  s.summary = <<SUMMARY
RBON is not JSON!
SUMMARY

  s.require_paths = ['lib']
  s.files = %w(
README.md
lib/rbon.rb
lib/rbon/dump.rb
lib/rbon/load.rb
  )

  s.requirements << 'ruby: ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-linux]'

end
