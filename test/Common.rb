#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'fileutils'
# Require rUtilAnts and RubyPackager now because we will redefine methods and classes in them.
require 'rUtilAnts/Plugins'
require 'RubyPackager/Tools'
# Mute everything except errors
RUtilAnts::Logging::initializeLogging(File.dirname(__FILE__), 'http://sourceforge.net/tracker/?group_id=274236&atid=1165400', true)

# Bypass the creation of any PluginsManager to include our dummy plugins automatically
module RUtilAnts

  module Plugins

    PluginsManager_ORG = PluginsManager
    remove_const :PluginsManager

    class PluginsManager < PluginsManager_ORG

      # Constructor
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

  # Redefine some functions used to communicate with external sites
  module Tools

    remove_method :sshWithPassword

    # Execute some SSH command on a remote host protected with password
    #
    # Parameters:
    # * *iSSHHost* (_String_): The SSH host
    # * *iSSHLogin* (_String_): The SSH login
    # * *iCmd* (_String_): The command to execute
    def sshWithPassword(iSSHHost, iSSHLogin, iCmd)
      $SSHCommands << [ 'SSH', {
        :Host => iSSHHost,
        :Login => iSSHLogin,
        :Cmd => iCmd
      } ]
    end

    remove_method :scpWithPassword

    # Copy files through SCP.
    #
    # Parameters:
    # * *iSCPHost* (_String_): Host
    # * *iSCPLogin* (_String_): Login
    # * *iFileSrc* (_String_): Path to local file to copy from
    # * *iFileDst* (_String_): Path to remote file to copy to
    def scpWithPassword(iSCPHost, iSCPLogin, iFileSrc, iFileDst)
      $SSHCommands << [ 'SCP', {
        :Host => iSCPHost,
        :Login => iSCPLogin,
        :FileSrc => iFileSrc,
        :FileDst => iFileDst
      } ]
    end

  end

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
      # * *iParams* (<em>map<Symbol,Object></em>): Additional parameters [optional = {}]
      # ** *:IncludeRDoc* (_Boolean_): Do we generate RDoc ? [optional = false]
      # * _CodeBlock_: The code called once the released has been made
      # ** *iReleaseDir* (_String_): The directory in which the release has been made
      # ** *iReleaseInfo* (<em>RubyPackager::ReleaseInfo</em>): The release info read
      def execTest(iRepositoryName, iArguments, iReleaseInfoFileName, iParams = {})
        lIncludeRDoc = iParams[:IncludeRDoc]
        if (lIncludeRDoc == nil)
          lIncludeRDoc = false
        end
        # Reset variables that will be used by dummy Distributors
        # The list of commands SSH/SCP issued, along with their parameters
        # list< [ String,      map< Symbol,        Object > ] >
        # list< [ CommandName, map< AttributeName, Value  > ] >
        $SSHCommands = []
        # Go to the application directory
        lOldDir = Dir.getwd
        lAppDir = File.expand_path("#{File.dirname(__FILE__)}/Repository/#{iRepositoryName}")
        Dir.chdir(lAppDir)
        # Clean the Releases dir if it exists already
        FileUtils::rm_rf("#{lAppDir}/Releases")
        # Launch everything
        lRealReleaseInfoFileName = "Distribution/#{iReleaseInfoFileName}"
        lSuccess = nil
        if (lIncludeRDoc)
          lSuccess = RubyPackager::Launcher.new.run(iArguments + [ lRealReleaseInfoFileName ])
        else
          lSuccess = RubyPackager::Launcher.new.run(iArguments + [ '--no-rdoc', lRealReleaseInfoFileName ])
        end
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

      # Check generated RDoc
      #
      # Parameters:
      # * *iReleaseDir* (_String_): The directory of the release
      # * *iReleaseInfo* (<em>RubyPackager::ReleaseInfo</em>): The release info used by the release
      def checkRDoc(iReleaseDir, iReleaseInfo)
        assert(File.exists?("#{iReleaseDir}/Documentation/rdoc/index.html"))
      end

      # Check generated release notes
      #
      # Parameters:
      # * *iReleaseDir* (_String_): The directory of the release
      # * *iReleaseInfo* (<em>RubyPackager::ReleaseInfo</em>): The release info used by the release
      def checkReleaseNotes(iReleaseDir, iReleaseInfo)
        assert(File.exists?("#{iReleaseDir}/Documentation/ReleaseNote.html"))
        assert(File.exists?("#{iReleaseDir}/Documentation/ReleaseNote.txt"))
      end

      # Run a generated executable and get its output
      #
      # Parameters:
      # * *iFileName* (_String_): The file name to execute
      # Return:
      # * _String_: The output
      def runExe(lExeFileName)
        rOutput = nil

        lOldDir = Dir.getwd
        Dir.chdir(File.dirname(lExeFileName))
        begin
          begin
            rOutput = `#{File.basename(lExeFileName)}`
          rescue Exception
            assert(false)
          end
        rescue Exception
          Dir.chdir(lOldDir)
          raise
        end
        Dir.chdir(lOldDir)

        return rOutput
      end

      # Get the gem specification corresponding to a given gem file
      #
      # Parameters:
      # * *iGemFileName* (_String_): Name of the Gem file
      # Return:
      # * <em>Gem::Specification</em>: The corresponding Gem specification
      def getGemSpec(iGemFileName)
        rGemSpec = nil

        lOldDir = Dir.getwd
        Dir.chdir(File.dirname(iGemFileName))
        require 'rubygems'
        # TODO: Bug (Ruby): Remove this test when Ruby will be able to deal .bat files correctly.
        if (RUBY_PLATFORM == 'i386-mswin32')
          rGemSpec = eval(`gem.bat specification #{File.basename(iGemFileName)} --ruby`.gsub(/Gem::/,'::Gem::'))
        else
          rGemSpec = eval(`gem specification #{File.basename(iGemFileName)} --ruby`.gsub(/Gem::/,'::Gem::'))
        end
        Dir.chdir(lOldDir)

        return rGemSpec
      end
      
    end

  end

end
