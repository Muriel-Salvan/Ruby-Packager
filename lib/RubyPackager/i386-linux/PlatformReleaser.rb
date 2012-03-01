#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

# This file prepares a win32 distribution

# Require needed to generate the temporary ruby file that produces the executable
require 'tmpdir'

module RubyPackager

  class PlatformReleaser

    PLATFORM_DIR = File.dirname(__FILE__)

    # Check if the tools we will use to generate an executable are present
    #
    # Parameters::
    # * *iRootDir* (_String_): Root directory
    # * *iIncludeRuby* (_Boolean_): Do we include Ruby in the release ?
    # * *iNeedBinaryCompilation* (_Boolean_): Do we need to compile RB files into a binary executable ?
    # Return::
    # * _Boolean_: Are tools correctly useable ?
    def check_exe_tools(iRootDir, iIncludeRuby, iNeedBinaryCompilation)
      rSuccess = true

      if (iIncludeRuby)
        # We need allinoneruby
        if (Gem.find_files('allinoneruby').empty?)
          log_err "Need to have allinoneruby gem to release including Ruby.\nPlease install allinoneruby gem (gem install allinoneruby)."
          rSuccess = false
        end
      end

      return rSuccess
    end

    # Create the binary.
    # This is called when the core library has been copied in the release directory.
    #
    # Parameters::
    # * *iRootDir* (_String_): Root directory
    # * *iReleaseDir* (_String_): Release directory
    # * *iIncludeRuby* (_Boolean_): Do we include Ruby in the release ?
    # * *iExecutableInfo* (<em>map<Symbol,Object></em>): The executable information
    # Return::
    # * _Boolean_: Success ?
    def create_binary(iRootDir, iReleaseDir, iIncludeRuby, iExecutableInfo)
      rSuccess = true

      lBinSubDir = "Launch/#{RUBY_PLATFORM}/bin"
      lRubyBaseBinName = 'ruby'
      lBinName = "#{lRubyBaseBinName}-#{RUBY_VERSION}.bin"
      if (iIncludeRuby)
        # First create the binary containing all ruby
        lBinDir = "#{iReleaseDir}/#{lBinSubDir}"
        FileUtils::mkdir_p(lBinDir)
        change_dir(lBinDir) do
          lCmd = "allinoneruby #{lBinName}"
          rSuccess = system(lCmd)
          if (!rSuccess)
            log_err "Error while executing \"#{lCmd}\""
          end
        end
      end
      if (rSuccess)
        # Then create the real executable
        # Generate the Shell file that launches everything for Linux
        File.open("#{iReleaseDir}/#{iExecutableInfo[:ExeName]}", 'w') do |oFile|
          oFile << "\#!/bin/sh
\#--
\# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
\# Licensed under the terms specified in LICENSE file. No warranty is provided.
\#++

\# This file is generated by RubyPackager for Linux.

\# This file has to launch the correct binary. There can be several binaries dependending on the configuration.
\# This is the file that will be created as the executable to launch.

\# Test Ruby's existence
which ruby >/dev/null 2>/dev/null
if [ $? == 1 ]
then
  echo 'Ruby not found on current platform. Use embedded one.'
  if [ ! -d tempruby ]
  then
    echo 'Extracting Ruby distribution...'
    mkdir tempruby
    cd tempruby
    ../#{lBinSubDir}/#{lBinName} --eee-justextract
    cd ..
  fi
  \# Set the environment correctly to execute Ruby from the extracted dir
  export LD_LIBRARY_PATH=`pwd`/tempruby/bin:`pwd`/tempruby/lib:`pwd`/tempruby/lib/lib1:`pwd`/tempruby/lib/lib2:`pwd`/tempruby/lib/lib3:`pwd`/tempruby/lib/lib4:${LD_LIRARY_PATH}
  export RUBYOPT=
  ./tempruby/bin/ruby -w #{iExecutableInfo[:StartupRBFile]}
else
  echo 'Ruby found on current platform. Use it directly.'
  ruby -w #{iExecutableInfo[:StartupRBFile]}
fi
"
        end
        File.chmod(0755, "#{iReleaseDir}/#{iExecutableInfo[:ExeName]}")
      end

      return rSuccess
    end

  end

end
