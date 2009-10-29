#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'fileutils'

module RubyPackager

  module Test

    module Common

      # Execute a test
      #
      # Parameters:
      # * *iRepositoryName* (_String_): Name of the repository for the test
      # * *iArguments* (<em>list<String></em>): List of arguments to give to RubyPackager (except the release file)
      # * *iReleaseFileName* (_String_): Name of the release file, relatively to the Distribution directory of the application
      # * _CodeBlock_: The code called once the released has been made
      # ** *iReleaseDir* (_String_): The directory in which the release has been made
      # ** *iReleaseInfo* (<em>RubyPackager::ReleaseInfo</em>): The release info read
      def execTest(iRepositoryName, iArguments, iReleaseInfoFileName)
        # Go to the application directory
        lOldDir = Dir.getwd
        lAppDir = File.expand_path("#{File.dirname(__FILE__)}/Repository/#{iRepositoryName}")
        Dir.chdir(lAppDir)
        # Clean the Releases dir if it exists already
        FileUtils::rm_rf("#{lAppDir}/Releases")
        # Launch everything
        lRealReleaseInfoFileName = "Distribution/#{iReleaseInfoFileName}"
        lSuccess = RubyPackager::Launcher.new.run(iArguments + [ lRealReleaseInfoFileName ])
        Dir.chdir(lOldDir)
        # Check if everything is ok
        assert(lSuccess)
        # Get the name of the directory
        lDirs = Dir.glob("#{lAppDir}/Releases/#{RUBY_PLATFORM}/*/*/*")
        assert_equal(1, lDirs.size)
        lReleaseDir = lDirs[0]
        # Read the release info
        lReleaseInfo = nil
        File.open("#{lAppDir}/#{lRealReleaseInfoFileName}", 'r') do |iFile|
          lReleaseInfo = eval(iFile.read)
        end
        assert(lReleaseInfo.kind_of?(RubyPackager::ReleaseInfo))
        yield(lReleaseDir, lReleaseInfo)
        # Clean the Releases dir
        FileUtils::rm_rf("#{lAppDir}/Releases")
      end

    end

  end

end
