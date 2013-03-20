# This file is a dummy gemspec that bundle asks for
# This project is packaged using RubyPackager: http://rubypackager.sourceforge.net

Gem::Specification.new do |s|
  s.name        = 'RubyPackager'
  s.version     = '0.0.1'
  s.add_dependency('rUtilAnts', '>= 1.0')
  s.add_dependency('allinoneruby')
  s.add_dependency('highline')
end
