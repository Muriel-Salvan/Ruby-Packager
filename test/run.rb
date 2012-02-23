# To change this template, choose Tools | Templates
# and open the template in the editor.
#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'test/unit'

# Add the path
lRootDir = File.expand_path("#{File.dirname(__FILE__)}/..")
$LOAD_PATH << lRootDir
$LOAD_PATH << "#{lRootDir}/lib"
$LOAD_PATH << "#{lRootDir}/test"

require 'bin/Release'
require 'Common'

# Run the test cases for our platform only
( Dir.glob("#{File.dirname(__FILE__)}/PlatformIndependent/**/*.rb") +
  Dir.glob("#{File.dirname(__FILE__)}/#{RUBY_PLATFORM}/**/*.rb") ).each do |iFileName|
  require iFileName
end
