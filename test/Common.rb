#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'fileutils'
require 'tmpdir'
# Require rUtilAnts and RubyPackager now because we will redefine methods and classes in them.
require 'rUtilAnts/Plugins'
require 'RubyPackager/Tools'
# Mute everything except errors if we are not debugging
RUtilAnts::Logging::install_logger_on_object(:lib_root_dir => File.dirname(__FILE__), :bug_tracker_url => 'http://sourceforge.net/tracker/?group_id=274236&atid=1165400', :mute_stdout => !$RBPTest_Debug)

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
        register_new_plugin('Installers', 'DummyInstaller1', nil, nil, 'RubyPackager::Test::Common::DummyInstaller1', nil)
        register_new_plugin('Installers', 'DummyInstaller2', nil, nil, 'RubyPackager::Test::Common::DummyInstaller2', nil)
        register_new_plugin('Distributors', 'DummyDistributor1', nil, nil, 'RubyPackager::Test::Common::DummyDistributor1', nil)
        register_new_plugin('Distributors', 'DummyDistributor2', nil, nil, 'RubyPackager::Test::Common::DummyDistributor2', nil)
      end

    end

  end

end

class Object

  # Check a call was expected, and call a given code if it was both expected and not ignored
  #
  # Parameters::
  # * *iCallType* (_String_): The call type
  # * *iCallParams* (<em>map<Symbol,Object></em>): The call parameters
  # * _CodeBlock_: Code to be called if the expected call is intended to be executed [optional = nil]
  def check_expected_call(iCallType, iCallParams)
    raise "Expecting no further call to be made. Received #{iCallType} with parameters #{iCallParams.inspect}." if $RBPTest_ExpectCalls.empty?
    # Pop the first expected call
    lExpectedCall = $RBPTest_ExpectCalls[0]
    $RBPTest_ExpectCalls = $RBPTest_ExpectCalls[1..-1]
    # Test that we expected this exact call
    lMatchOK = ((lExpectedCall[0] == iCallType) and
                (lExpectedCall[1].size == iCallParams.size))
    if (lMatchOK)
      # Match each parameter, with a special case for regexps
      lExpectedCall[1].each do |iExpectParamName, iExpectParamValue|
        if (iExpectParamValue.is_a?(Regexp))
          if (iCallParams[iExpectParamName].is_a?(String))
            if (iCallParams[iExpectParamName].match(iExpectParamValue) == nil)
              lMatchOK = false
              break
            end
          else
            lMatchOK = false
            break
          end
        elsif (iExpectParamValue != iCallParams[iExpectParamName])
          lMatchOK = false
          break
        end
      end
    end
    raise "Expecting call:\n#{lExpectedCall[0..1].inspect}\nbut received call\n#{[iCallType, iCallParams].inspect}\n." if !lMatchOK
    # Analyze the behaviour to have
    lBehaviourParams = lExpectedCall[2] || {}
    if ((lBehaviourParams[:Execute] == true) and
        block_given?)
      yield
    elsif (lBehaviourParams[:Execute].is_a?(Proc))
      lBehaviourParams[:Execute].call
    end
  end

end

module Kernel

  alias :system_RBTest :system
  def system(iCmd)
    rResult = true

    check_expected_call('system', :Cmd => iCmd, :Dir => Dir.getwd) do
      rResult = system_RBTest(iCmd)
    end

    return rResult
  end

  alias :backquote_RBTest :`
  def `(iCmd)
    rResult = true

    check_expected_call('`', :Cmd => iCmd, :Dir => Dir.getwd) do
      rResult = backquote_RBTest(iCmd)
    end

    return rResult
  end

end

module RubyPackager

  # Redefine some functions used to communicate with external sites
  module Tools

    alias :ssh_RBPTest :ssh
    # Execute some SSH command on a remote host protected with password
    #
    # Parameters::
    # * *iCmd* (_String_): The command to execute
    def ssh(iCmd)
      check_expected_call('SSH', :Host => @SSHHost, :Login => @SSHLogin, :Cmd => iCmd) do
        ssh_RBPTest(iCmd)
      end
    end

    alias :scp_RBPTest :scp
    # Copy files through SCP.
    #
    # Parameters::
    # * *iFileSrc* (_String_): Path to local file to copy from
    # * *iFileDst* (_String_): Path to remote file to copy to
    def scp(iFileSrc, iFileDst)
      check_expected_call('SCP', :Host => @SSHHost, :Login => @SSHLogin, :FileSrc => iFileSrc, :FileDst => iFileDst) do
        scp_RBPTest(iFileSrc, iFileDst)
      end
    end

  end

  module Test

    module Common

      class DummyInstaller1

        # Create the installer with everything in the release directory.
        #
        # Parameters::
        # * *iRootDir* (_String_): The Root directory
        # * *iReleaseDir* (_String_): The release directory (all files to put in the installer are there)
        # * *iInstallerDir* (_String_): The directory where the installer has to be put
        # * *iVersion* (_String_): Release version
        # * *iReleaseInfo* (_ReleaseInfo_): Release info
        # * *iIncludeTest* (_Boolean_): Are test files part of the release ?
        # Return::
        # * _String_: File name to distribute, or nil in case of failure
        def create_installer(iRootDir, iReleaseDir, iInstallerDir, iVersion, iReleaseInfo, iIncludeTest)
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
        # Parameters::
        # * *iRootDir* (_String_): The Root directory
        # * *iReleaseDir* (_String_): The release directory (all files to put in the installer are there)
        # * *iInstallerDir* (_String_): The directory where the installer has to be put
        # * *iVersion* (_String_): Release version
        # * *iReleaseInfo* (_ReleaseInfo_): Release info
        # * *iIncludeTest* (_Boolean_): Are test files part of the release ?
        # Return::
        # * _String_: File name to distribute, or nil in case of failure
        def create_installer(iRootDir, iReleaseDir, iInstallerDir, iVersion, iReleaseInfo, iIncludeTest)
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
        # Parameters::
        # * *iInstallerDir* (_String_): Directory where installers are generated
        # * *iReleaseVersion* (_String_): Release version
        # * *iReleaseInfo* (_ReleaseInfo_): Release info
        # * *iGeneratedFileNames* (<em>list<String></em>): List of files to distribute
        # * *iDocDir* (_String_): Directory where the documentation has been generated
        # Return::
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
        # Parameters::
        # * *iInstallerDir* (_String_): Directory where installers are generated
        # * *iReleaseVersion* (_String_): Release version
        # * *iReleaseInfo* (_ReleaseInfo_): Release info
        # * *iGeneratedFileNames* (<em>list<String></em>): List of files to distribute
        # * *iDocDir* (_String_): Directory where the documentation has been generated
        # Return::
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
      # Parameters::
      # * *iRepositoryName* (_String_): Name of the repository for the test
      # * *iArguments* (<em>list<String></em>): List of arguments to give to RubyPackager (except the release file)
      # * *iReleaseFileName* (_String_): Name of the release file, relatively to the Distribution directory of the application
      # * *iParams* (<em>map<Symbol,Object></em>): Additional parameters. See exec_rbp for details [optional = {}]
      # * _CodeBlock_: The code called once the release has been made
      #   * *iReleaseDir* (_String_): The directory in which the release has been made
      #   * *iReleaseInfo* (<em>RubyPackager::ReleaseInfo</em>): The release info read
      def execTest(iRepositoryName, iArguments, iReleaseInfoFileName, iParams = {})
        setup_repository(iRepositoryName) do |iRepositoryDir|
          exec_rbp(iArguments, iReleaseInfoFileName, iParams) do |iReleaseDir, iReleaseInfo|
            yield(iReleaseDir, iReleaseInfo)
          end
        end
      end

      # Setup a repository by copying one from the tests to a temporary folder.
      # Call some code once the repository has been setup (also set current directory in this repository)
      #
      # Parameters::
      # * *iRepositoryName* (_String_): Name of the repository for the test
      # * _CodeBlock_: The code called once the repository has been setup
      #   * *iRepositoryDir* (_String_): The repository directory
      def setup_repository(iRepositoryName)
        lAppDir = File.expand_path("#{File.dirname(__FILE__)}/Repository/#{iRepositoryName}")
        @@IdxRepo = 0 if (defined?(@@IdxRepo) == nil)
        lRepositoryDir = "#{Dir.tmpdir}/RBPTest/Repository_#{Process.pid}_#{@@IdxRepo}"
        @@IdxRepo += 1
        FileUtils::rm_rf(lRepositoryDir) if (File.exists?(lRepositoryDir))
        FileUtils::mkdir_p(lRepositoryDir)
        FileUtils::cp_r("#{lAppDir}/.", lRepositoryDir)
        change_dir(lRepositoryDir) do
          yield(lRepositoryDir)
        end
        # In case of debug, don't clean up
        if (!$RBPTest_Debug)
          FileUtils::rm_rf(lRepositoryDir)
        end
      end

      # Execute RubyPackager in the current directory, with parameters given.
      #
      # Parameters::
      # * *iArguments* (<em>list<String></em>): List of arguments to give to RubyPackager (except the release file)
      # * *iReleaseFileName* (_String_): Name of the release file, relatively to the Distribution directory of the application
      # * *iParams* (<em>map<Symbol,Object></em>): Additional parameters [optional = {}]
      #   * *:IncludeRDoc* (_Boolean_): Do we generate RDoc ? [optional = false]
      #   * *:ExpectCalls* (<em>list< [CommandType,Params,Behaviour] ></em>): List of expected commands. Each element contains the expected command type (_String_) and parameters (<em>map<Symbol,Object></em>), and an optional behaviour hash (<em>map<Symbol,Object></em>).
      # * _CodeBlock_: The code called once the release has been made
      #   * *iReleaseDir* (_String_): The directory in which the release has been made
      #   * *iReleaseInfo* (<em>RubyPackager::ReleaseInfo</em>): The release info read
      def exec_rbp(iArguments, iReleaseInfoFileName, iParams = {})
        lIncludeRDoc = iParams[:IncludeRDoc] || false
        $RBPTest_ExpectCalls = iParams[:ExpectCalls] || []
        # Reset variables that will be used by dummy Distributors
        lRealReleaseInfoFileName = "Distribution/#{iReleaseInfoFileName}"
        # Launch everything
        lSuccess = RubyPackager::Launcher.new.run(
          iArguments +
          ($RBPTest_Debug ? [ '--debug' ] : []) +
          (!lIncludeRDoc ? [ '--no-rdoc' ] : []) +
          [ lRealReleaseInfoFileName ]
        )
        # Check if everything is ok
        assert(lSuccess)
        # Make sure all expected calls have occurred
        assert $RBPTest_ExpectCalls.empty?, "#{$RBPTest_ExpectCalls.size} calls were not performed: #{$RBPTest_ExpectCalls.inspect}"
        # Get the name of the release directory
        lDirs = Dir.glob("Releases/#{RUBY_PLATFORM}/*/*/*")
        assert_equal(1, lDirs.size)
        lReleaseDir = lDirs[0]
        # Read the release info
        lReleaseInfo = nil
        File.open(lRealReleaseInfoFileName, 'r') do |iFile|
          lReleaseInfo = eval(iFile.read)
        end
        assert(lReleaseInfo.kind_of?(RubyPackager::ReleaseInfo))
        yield(lReleaseDir, lReleaseInfo)
      end

      # Check content of a released ReleaseInfo file
      #
      # Parameters::
      # * *iReleaseDir* (_String_): The directory of the release
      # * *iReleaseInfo* (<em>RubyPackager::ReleaseInfo</em>): The release info used by the release
      # * *iParams* (<em>map<Symbol,Object></em>): Additional parameters:
      #   * *:version* (_String_): The version [optional = 'UnnamedVersion']
      #   * *:tags* (<em>list<String></em>): List of Tags [optional = []]
      def checkReleaseInfo(iReleaseDir, iReleaseInfo, iParams = {})
        lVersion = iParams[:version]
        if (lVersion == nil)
          lVersion = 'UnnamedVersion'
        end
        lTags = iParams[:tags]
        if (lTags == nil)
          lTags = []
        end
        assert(File.exists?("#{iReleaseDir}/Release/ReleaseInfo"))
        lReleasedInfo = nil
        File.open("#{iReleaseDir}/Release/ReleaseInfo", 'r') do |iFile|
          lReleasedInfo = eval(iFile.read)
        end
        assert(lReleasedInfo.kind_of?(Hash))
        assert_equal(lVersion, lReleasedInfo[:version])
        assert_equal(lTags, lReleasedInfo[:tags])
        assert_equal('Project:dev_status', lReleasedInfo[:dev_status])
      end

      # Check generated RDoc
      #
      # Parameters::
      # * *iReleaseDir* (_String_): The directory of the release
      # * *iReleaseInfo* (<em>RubyPackager::ReleaseInfo</em>): The release info used by the release
      def checkRDoc(iReleaseDir, iReleaseInfo)
        assert(File.exists?("#{iReleaseDir}/Documentation/rdoc/index.html"))
      end

      # Check generated release notes
      #
      # Parameters::
      # * *iReleaseDir* (_String_): The directory of the release
      # * *iReleaseInfo* (<em>RubyPackager::ReleaseInfo</em>): The release info used by the release
      def checkReleaseNotes(iReleaseDir, iReleaseInfo)
        assert(File.exists?("#{iReleaseDir}/Documentation/ReleaseNote.html"))
        assert(File.exists?("#{iReleaseDir}/Documentation/ReleaseNote.txt"))
      end

      # Run a generated executable and get its output
      #
      # Parameters::
      # * *iFileName* (_String_): The file name to execute
      # Return::
      # * _String_: The output
      def runExe(lExeFileName)
        rOutput = nil

        change_dir(File.dirname(lExeFileName)) do
          begin
             rOutput = backquote_RBTest("./#{File.basename(lExeFileName)}")
          rescue Exception
            log_err "Exception during executable run \"#{lExeFileName}\": #{$!}\n#{$!.backtrace.join("\n")}"
            assert(false)
          end
        end

        return rOutput
      end

      # Get the gem specification corresponding to a given gem file
      #
      # Parameters::
      # * *iGemFileName* (_String_): Name of the Gem file
      # Return::
      # * <em>Gem::Specification</em>: The corresponding Gem specification
      def getGemSpec(iGemFileName)
        rGemSpec = nil

        change_dir(File.dirname(iGemFileName)) do
          require 'rubygems'
          # TODO: Bug (Ruby): Remove this test when Ruby will be able to deal .bat files correctly.
          require 'rUtilAnts/Platform'
          RUtilAnts::Platform::install_platform_on_object
          if (os == RUtilAnts::Platform::OS_WINDOWS)
            rGemSpec = eval(backquote_RBTest("gem.bat specification #{File.basename(iGemFileName)} --ruby").gsub(/Gem::/,'::Gem::'))
          else
            rGemSpec = eval(backquote_RBTest("gem specification #{File.basename(iGemFileName)} --ruby").gsub(/Gem::/,'::Gem::'))
          end
        end

        return rGemSpec
      end

    end

  end

end
