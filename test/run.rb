# To change this template, choose Tools | Templates
# and open the template in the editor.
#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'test/unit'

# Add the path
lRootDir = File.expand_path("#{File.dirname(__FILE__)}/..")
$LOAD_PATH << lRootDir
$LOAD_PATH << "#{lRootDir}/lib"

require 'bin/Release'
require 'Common'

# Run the test cases for our platform
require "#{File.dirname(__FILE__)}/#{RUBY_PLATFORM}/run"
