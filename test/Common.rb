#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'fileutils'

module RubyPackager

  module Test

    # Execute a test
    #
    # Parameters:
    # * *iApplicationName* (_String_): Name of the application for the test
    # * *iReleaseInfoName* (_String_): Name of release info file
    # * *iIncludeRuby* (_Boolean_): Do we include Ruby in the release ?
    def execTest(iApplicationName, iReleaseInfoName, iIncludeRuby)
      # Go to the application directory
      lOldDir = Dir.getwd
      lAppDir = File.expand_path("#{File.dirname(__FILE__)}/Applications/#{iApplicationName}")
      Dir.chdir(lAppDir)
      # Clean the Releases dir if it exists already
      FileUtils::rm_rf("#{lAppDir}/Releases")
      # Launch everything
      lArgs = []
      if (iIncludeRuby)
        lArgs << '-r'
      end
      lArgs << "Distribution/#{iReleaseInfoName}"
      lSuccess = RubyPackager::Launcher.new.run(lArgs)
      Dir.chdir(lOldDir)
      # Check if everything is ok
      assert(lSuccess)
      # Get the name of the directory
      lDirs = Dir.glob("#{lAppDir}/Releases/#{RUBY_PLATFORM}/*")
      assert_equal(1, lDirs.size)
      lReleaseDir = lDirs[0]
      # Read the release info ourselves
      require "#{lAppDir}/Distribution/#{iReleaseInfoName}"
      # TODO: OS independent. Don't test .exe anymore here.
      assert(File.exists?("#{lReleaseDir}/Installer/#{$ReleaseInfo.ExeName}_#{$ReleaseInfo.Version}_setup.exe"))
      assert(File.exists?("#{lReleaseDir}/Release/#{$ReleaseInfo.ExeName}.exe"))
      # Clean the Releases dir
      FileUtils::rm_rf("#{lAppDir}/Releases")
    end

  end

end
