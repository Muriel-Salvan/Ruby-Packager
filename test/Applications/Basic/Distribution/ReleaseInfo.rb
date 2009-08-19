#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

$ReleaseInfo = RubyPackager::ReleaseInfo.new(
  'BasicTest_HelloWorld',
  '0.0.1',
  ['Main.rb'],
  [],
  'Main.rb',
  'BasicTest',
  "Distribution/#{RUBY_PLATFORM}/Icon.ico",
  "Distribution/#{RUBY_PLATFORM}/Installer/install.nsi",
  true
)
