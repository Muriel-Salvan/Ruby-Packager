#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'fileutils'
require 'rUtilAnts/Plugins'

# Bypass the creation of any PluginsManager to include our dummy plugins automatically
module RUtilAnts

  module Plugins

    PluginsManager_ORG = PluginsManager
    remove_const :PluginsManager

    class PluginsManager < PluginsManager_ORG

      def initialize
        super
        # Add dummy Installers and Distributors
        registerNewPlugin('Installers', 'DummyInstaller1', nil, nil, 'RubyPackager::Test::Common::DummyInstaller1', nil)
        registerNewPlugin('Installers', 'DummyInstaller2', nil, nil, 'RubyPackager::Test::Common::DummyInstaller2', nil)
        registerNewPlugin('Distributors', 'DummyDistributor1', nil, nil, 'RubyPackager::Test::Common::DummyDistributor1', nil)
        registerNewPlugin('Distributors', 'DummyDistributor2', nil, nil, 'RubyPackager::Test::Common::DummyDistributor2', nil)
      end

    end

  end

end

module RubyPackager

  module Test

    module Common

      class DummyInstaller1
        # Create the installer with everything in the release directory.
        #
        # Parameters:
        # * *iRootDir* (_String_): The Root directory
        # * *iReleaseDir* (_String_): The release directory (all files to put in the installer are there)
        # * *iInstallerDir* (_String_): The directory where the installer has to be put
        # * *iVersion* (_String_): Release version
        # * *iReleaseInfo* (_ReleaseInfo_): Release info
        # Return:
        # * _String_: File name to distribute, or nil in case of failure
        def createInstaller(iRootDir, iReleaseDir, iInstallerDir, iVersion, iReleaseInfo)
          rFileName = nil

          Dir.glob("#{iReleaseDir}/*").each do |iFileName|
            rFileName = "#{File.basename(iFileName)}.Installer1"
            require 'fileutils'
            FileUtils::cp(iFileName, "#{iInstallerDir}/#{rFileName}")
            break
          end

          return rFileName
        end

      end

      class DummyInstaller2
        # Create the installer with everything in the release directory.
        #
        # Parameters:
        # * *iRootDir* (_String_): The Root directory
        # * *iReleaseDir* (_String_): The release directory (all files to put in the installer are there)
        # * *iInstallerDir* (_String_): The directory where the installer has to be put
        # * *iVersion* (_String_): Release version
        # * *iReleaseInfo* (_ReleaseInfo_): Release info
        # Return:
        # * _String_: File name to distribute, or nil in case of failure
        def createInstaller(iRootDir, iReleaseDir, iInstallerDir, iVersion, iReleaseInfo)
          rFileName = nil

          Dir.glob("#{iReleaseDir}/*").each do |iFileName|
            rFileName = "#{File.basename(iFileName)}.Installer2"
            require 'fileutils'
            FileUtils::cp(iFileName, "#{iInstallerDir}/#{rFileName}")
            break
          end

          return rFileName
        end

      end

      class DummyDistributor1

        def initialize
          $Distributed1 = {}
        end

        # Distribute what has been generated
        #
        # Parameters:
        # * *iInstallerDir* (_String_): Directory where installers are generated
        # * *iReleaseVersion* (_String_): Release version
        # * *iReleaseInfo* (_ReleaseInfo_): Release info
        # * *iGeneratedFileNames* (<em>list<String></em>): List of files to distribute
        # * *iDocDir* (_String_): Directory where the documentation has been generated
        # Return:
        # * _Boolean_: Success ?
        def distribute(iInstallerDir, iReleaseVersion, iReleaseInfo, iGeneratedFileNames, iDocDir)
          rSuccess = true

          iGeneratedFileNames.each do |iFileName|
            $Distributed1[File.basename(iFileName)] = nil
          end

          return rSuccess
        end

      end

      class DummyDistributor2

        def initialize
          $Distributed2 = {}
        end

        # Distribute what has been generated
        #
        # Parameters:
        # * *iInstallerDir* (_String_): Directory where installers are generated
        # * *iReleaseVersion* (_String_): Release version
        # * *iReleaseInfo* (_ReleaseInfo_): Release info
        # * *iGeneratedFileNames* (<em>list<String></em>): List of files to distribute
        # * *iDocDir* (_String_): Directory where the documentation has been generated
        # Return:
        # * _Boolean_: Success ?
        def distribute(iInstallerDir, iReleaseVersion, iReleaseInfo, iGeneratedFileNames, iDocDir)
          rSuccess = true

          iGeneratedFileNames.each do |iFileName|
            $Distributed2[File.basename(iFileName)] = nil
          end

          return rSuccess
        end

      end

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

      # Check content of a released ReleaseInfo file
      #
      # Parameters:
      # * *iReleaseDir* (_String_): The directory of the release
      # * *iReleaseInfo* (<em>RubyPackager::ReleaseInfo</em>): The release info used by the release
      # * *iParams* (<em>map<Symbol,Object></em>): Additional parameters:
      # ** *:Version* (_String_): The version [optional = 'UnnamedVersion']
      # ** *:Tags* (<em>list<String></em>): List of Tags [optional = []]
      def checkReleaseInfo(iReleaseDir, iReleaseInfo, iParams = {})
        lVersion = iParams[:Version]
        if (lVersion == nil)
          lVersion = 'UnnamedVersion'
        end
        lTags = iParams[:Tags]
        if (lTags == nil)
          lTags = []
        end
        assert(File.exists?("#{iReleaseDir}/Release/ReleaseInfo"))
        lReleasedInfo = nil
        File.open("#{iReleaseDir}/Release/ReleaseInfo", 'r') do |iFile|
          lReleasedInfo = eval(iFile.read)
        end
        assert(lReleasedInfo.kind_of?(Hash))
        assert_equal(lVersion, lReleasedInfo[:Version])
        assert_equal(lTags, lReleasedInfo[:Tags])
        assert_equal('Project:DevStatus', lReleasedInfo[:DevStatus])
      end

      # Check generated documentation (Release notes, RDoc...)
      #
      # Parameters:
      # * *iReleaseDir* (_String_): The directory of the release
      # * *iReleaseInfo* (<em>RubyPackager::ReleaseInfo</em>): The release info used by the release
      def checkDoc(iReleaseDir, iReleaseInfo)
        assert(File.exists?("#{iReleaseDir}/Documentation/rdoc/index.html"))
        assert(File.exists?("#{iReleaseDir}/Documentation/ReleaseNote.html"))
        assert(File.exists?("#{iReleaseDir}/Documentation/ReleaseNote.txt"))
      end

    end

  end

end
