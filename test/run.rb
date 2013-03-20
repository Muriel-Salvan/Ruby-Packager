# To change this template, choose Tools | Templates
# and open the template in the editor.
#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'test/unit'

# Set to true to activate log debugs
$RBPTest_Debug = false

# Set to true to test using external tools (NSIS, exerb)
$RBPTest_ExternalTools = false

# Add the path
lRootDir = File.expand_path("#{File.dirname(__FILE__)}/..")
$LOAD_PATH << lRootDir
$LOAD_PATH << "#{lRootDir}/lib"
$LOAD_PATH << "#{lRootDir}/test"

require 'bin/Release'
require 'Common'
activate_log_debug($RBPTest_Debug)

# Run the test cases for our platform only
require 'rUtilAnts/Platform'
RUtilAnts::Platform.install_platform_on_object
PLATFORM_ID = (
  case os
  when RUtilAnts::Platform::OS_WINDOWS
    'windows'
  when RUtilAnts::Platform::OS_LINUX, RUtilAnts::Platform::OS_UNIX, RUtilAnts::Platform::OS_MACOSX
    'linux'
  when RUtilAnts::Platform::OS_CYGWIN
    'cygwin'
  else
    raise RuntimeError, "Non supported OS code: #{os}"
  end
)
( Dir.glob("#{File.dirname(__FILE__)}/PlatformIndependent/**/*.rb") +
  Dir.glob("#{File.dirname(__FILE__)}/#{PLATFORM_ID}/**/*.rb") ).each do |iFileName|
  require iFileName
end
