#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

# Release a distribution of a Ruby program.
# This produces an installable executable that will install a set of files and directories:
# * A binary, including some core Ruby and program files (eventually the whole Ruby distribution if needed - that is if the program is meant to be run on platforms not providing Ruby)
# * A list of files/directories

require 'fileutils'
require 'optparse'

# Require the platform specific distribution file
require "RubyPackager/#{RUBY_PLATFORM}/PlatformReleaser.rb"

module RubyPackager

  # Class that describes a release
  class ReleaseInfo

    # The name of the release
    #   String
    attr_reader :Name

    # The version of the release
    #   String
    attr_reader :Version

    # List of files patterns to include in the core executable
    #   list<String>
    attr_reader :CoreFiles

    # List of files patterns to add in the release
    #   list<String>
    attr_reader :AdditionalFiles

    # Startup RB file
    #   String
    attr_reader :StartupRBFile

    # Executable name
    #   String
    attr_reader :ExeName

    # Icon name
    #   String
    attr_reader :IconName

    # NSI file name
    #   String
    attr_reader :NSIFileName

    # Default constructor
    #
    # Paramters:
    # * *iName* (_String_): The name of the release
    # * *iVersion* (_String_): The version of the release
    # * *iCoreFiles* (<em>list<String></em>): List of files patterns to include in the core executable
    # * *iAdditionalFiles* (<em>list<String></em>): List of files patterns to add in the release
    # * *iStartupRBFile* (_String_): Name of the RB file to execute (relative to the root dir)
    # * *iExeName* (_String_): Name of the executable to produce
    # * *iIconName* (_String_): Name of the icon file (relative to the root dir)
    # * *iNSIFileName* (_String_): Name of the NSI installation file (relative to the root dir)
    def initialize(iName, iVersion, iCoreFiles, iAdditionalFiles, iStartupRBFile, iExeName, iIconName, iNSIFileName)
      @Name, @Version, @CoreFiles, @AdditionalFiles, @StartupRBFile, @ExeName, @IconName, @NSIFileName = iName, iVersion, iCoreFiles, iAdditionalFiles, iStartupRBFile, iExeName, iIconName, iNSIFileName
    end

    # Check if the tools needed for the release are ok
    # This is meant to be overriden if needed
    #
    # Parameters:
    # * *iRootDir* (_String_): Root directory from where the release is happening
    # Return:
    # * _Boolean_: Success ?
    def checkTools(iRootDir)
      return true
    end

  end

  # Class that makes a release
  class Releaser

    # Log an operation, and call some code inside
    #
    # Parameters:
    # * *iOperationName* (_String_): Operation name
    # * *CodeBlock*: Code to call in this operation
    def logOp(iOperationName)
      puts "===== #{iOperationName} ..."
      yield
      puts "===== ... #{iOperationName}"
    end

    # Copy a list of files patterns to the release directory
    #
    # Parameters:
    # * *iRootDir* (_String_): The root dir
    # * *iReleaseDir* (_String_): The release dir
    # * *iFilesPatterns* (<em>list<String></em>): The list of files patterns
    def copyFiles(iRootDir, iReleaseDir, iFilesPatterns)
      iFilesPatterns.each do |iFilePattern|
        Dir.glob(iFilePattern).each do |iFileName|
          if (iFileName.match(/\.svn/) == nil)
            lRelativeName = nil
            # Extract the relative file name
            lMatch = iFileName.match(/^#{iRootDir}\/(.*)$/)
            if (lMatch == nil)
              # The path is already relative
              lRelativeName = iFileName
            else
              lRelativeName = lMatch[1]
            end
            lDestFileName = "#{iReleaseDir}/#{lRelativeName}"
            FileUtils::mkdir_p(File.dirname(lDestFileName))
            if (File.directory?(iFileName))
              puts "Create directory #{lRelativeName}"
            else
              puts "Copy file #{lRelativeName}"
              FileUtils::cp(iFileName, lDestFileName)
            end
          end
        end
      end
    end

    # Release
    #
    # Parameters:
    # * *iReleaseInfo* (_ReleaseInfo_): The release information
    # * *iRootDir* (_String_): The root directory, containing files to ship in the distribution
    # * *iReleaseBaseDir* (_String_): The release directory, where files will be copied and generated for distribution
    # * *iPlatformReleaseInfo* (_Object_): The platform dependent release info
    # * *iIncludeRuby* (_Boolean_): Do we include Ruby in the release ?
    # Return:
    # * _Boolean_: Success ?
    def execute(iReleaseInfo, iRootDir, iReleaseBaseDir, iPlatformReleaseInfo, iIncludeRuby)
      rSuccess = true

      # Compute the release directory name
      lReleaseDir = "#{iReleaseBaseDir}/#{RUBY_PLATFORM}/#{Time.now.strftime('%Y_%m_%d_%H_%M_%S')}"
      lReleaseVersion = iReleaseInfo.Version.clone
      # Add options to the directory name
      if (iIncludeRuby)
        lReleaseDir += '_Ruby'
        lReleaseVersion += 'R'
      end
      lInstallerDir = "#{lReleaseDir}/Installer"
      lReleaseDir += '/Release'
      logOp('Check installed tools') do
        # Check that the tools we need to release are indeed here
        iReleaseInfo.checkTools(iRootDir)
        # Check tools for platform dependent considerations
        lPlatformSuccess = iPlatformReleaseInfo.checkTools(iRootDir, iIncludeRuby)
        if (!lPlatformSuccess)
          rSuccess = false
        end
      end
      if (rSuccess)
        logOp('Copy core files') do
          copyFiles(iRootDir, lReleaseDir, iReleaseInfo.CoreFiles)
        end
        logOp('Create binary') do
          # Application core is copied
          # TODO (crate): When crate will work correctly under Windows, use it here to pack everything
          # For now the executable creation is platform dependent
          rSuccess = iPlatformReleaseInfo.createBinary(iRootDir, lReleaseDir, iIncludeRuby, iReleaseInfo.StartupRBFile, iReleaseInfo.ExeName, iReleaseInfo.IconName)
        end
        if (rSuccess)
          logOp('Copy additional files') do
            copyFiles(iRootDir, lReleaseDir, iReleaseInfo.AdditionalFiles)
          end
          logOp('Create installer') do
            FileUtils::mkdir_p(lInstallerDir)
            # Create the installer for this distribution
            rSuccess = iPlatformReleaseInfo.createInstaller(iRootDir, lReleaseDir, lInstallerDir, lReleaseVersion, iReleaseInfo.NSIFileName, iReleaseInfo.ExeName)
            if (!rSuccess)
              puts "!!! Unable to create the installer"
            end
          end
        else
          puts "!!! Unable to create the platform dependent binary."
        end
      else
        puts "!!! Some tools needed to release are missing."
      end

      return rSuccess
    end

  end

  # Get command line parameters
  #
  # Return:
  # * _OptionParser_: The options parser
  def self.getOptions
    rOptions = OptionParser.new

    rOptions.banner = 'Release.rb [-r|--ruby] [-g|--rubygems] [-w|--wxruby] [-e|--ext]'
    rOptions.on('-r', '--ruby',
      'Include Ruby distribution in the release.') do
      $PBS_Distribution_Ruby = true
    end
    rOptions.on('-g', '--rubygems',
      'Include Ruby Gems in the release.') do
      $PBS_Distribution_RubyGems = true
    end
    rOptions.on('-w', '--wxruby',
      'Include WxRuby in the release.') do
      $PBS_Distribution_WxRuby = true
    end
    rOptions.on('-e', '--ext',
      'Include all ext directory in the release.') do
      $PBS_Distribution_Ext = true
    end

    return rOptions
  end

  # Run Release
  def self.run
    # Default constants that are modified by command line options
    $PBS_Distribution_Ruby = false
    $PBS_Distribution_RubyGems = false
    $PBS_Distribution_WxRuby = false
    $PBS_Distribution_Ext = false
    # Parse command line arguments
    lOptions = self.getOptions
    lSuccess = true
    begin
      lOptions.parse(ARGV)
    rescue Exception
      puts "Error while parsing arguments: #{$!}"
      puts lOptions
      lSuccess = false
    end
    if (lSuccess)
      lSuccess = Releaser.new(Dir.getwd, "#{Dir.getwd}/Releases", PlatformReleaser.new).execute(
        $PBS_Distribution_Ruby,
        $PBS_Distribution_RubyGems,
        $PBS_Distribution_WxRuby,
        $PBS_Distribution_Ext)
      if (lSuccess)
        puts 'Release successful.'
      else
        puts 'Error while releasing.'
      end
    end
  end

end

# Execute everything
if ($0 == __FILE__)
  PBS::Distribution::run
end