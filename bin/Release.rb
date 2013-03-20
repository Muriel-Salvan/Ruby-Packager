#!env ruby
#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

# Release a distribution of a Ruby program or library.
# Here is the behaviour:
# 1. Gather all files meant to be released in a separate directory (Core, Additional and Test if specified)
# 2. In the case of an executable release, generate the executable with Core files and Ruby distribution if specified
# 3. In the case of specified installers, generate the needed installers including the Core files (or the executable), the Additional files and Test if specified)
# 4. In the case of specified distributors, ship the generated installers to those distributors

require 'rUtilAnts/Logging'
RUtilAnts::Logging::install_logger_on_object(:lib_root_dir => "#{File.dirname(__FILE__)}/..", :bug_tracker_url => 'http://sourceforge.net/tracker/?group_id=274236&atid=1165400')
require 'rUtilAnts/Misc'
RUtilAnts::Misc.install_misc_on_object
require 'rUtilAnts/Platform'
RUtilAnts::Platform.install_platform_on_object

module RubyPackager

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

  # Class giving command line options for the releaser
  class Launcher

    FILE_PATH = File.expand_path(__FILE__)

    # Run the releaser
    #
    # Parameters::
    # * *iParameters* (<em>list<String></em>): List of arguments, as in command-line
    # Return::
    # * _Boolean_: Success ?
    def run(iParameters)
      rSuccess = true

      # Get the RubyPackager version we are running on
      lRPReleaseInfo = {
        :version => 'Development',
        :tags => [],
        :dev_status => 'Unofficial'
      }
      lReleaseInfoFileName = "#{File.dirname(FILE_PATH)}/../ReleaseInfo"
      if (File.exists?(lReleaseInfoFileName))
        File.open(lReleaseInfoFileName, 'r') do |iFile|
          lRPReleaseInfo = eval(iFile.read)
        end
      end

      # Parse for plugins
      require 'rUtilAnts/Plugins'
      lPluginsManager = RUtilAnts::Plugins::PluginsManager.new
      lPluginsManager.parse_plugins_from_dir('Installers', "#{File.dirname(FILE_PATH)}/../lib/RubyPackager/Installers", 'RubyPackager::Installers')
      lPluginsManager.parse_plugins_from_dir('Installers', "#{File.dirname(FILE_PATH)}/../lib/RubyPackager/#{PLATFORM_ID}/Installers", 'RubyPackager::Installers')
      lPluginsManager.parse_plugins_from_dir('Distributors', "#{File.dirname(FILE_PATH)}/../lib/RubyPackager/Distributors", 'RubyPackager::Distributors')
      lPluginsManager.parse_plugins_from_dir('Distributors', "#{File.dirname(FILE_PATH)}/../lib/RubyPackager/#{PLATFORM_ID}/Distributors", 'RubyPackager::Distributors')

      # Parse command line arguments
      # Variables set by the parser
      lDisplayUsage = false
      lReleaseVersion = 'UnnamedVersion'
      lReleaseTags = []
      lReleaseComment = nil
      lIncludeRuby = false
      lIncludeTest = false
      lIncludeRDoc = true
      lInstallers = []
      lDistributors = []
      # The parser
      require 'optparse'
      lOptionsParser = OptionParser.new
      lOptionsParser.banner = 'Release.rb [-h|--help] [-e|--debug] [-v|--version <Version>] [-t|--tag <TagName>]* [-c|--comment <Comment>] [-r|--ruby] [-n|--includeTest] [-o|--no-rdoc] [-i|--installer <InstallerName>]* [-d|--distributor <DistributorName>]* <ReleaseFile>'
      lOptionsParser.on('-h', '--help',
        'Display help usage.') do
        lDisplayUsage = true
      end
      lOptionsParser.on('-e', '--debug',
        'Activate debugging logs.') do
        activate_log_debug(true)
      end
      lOptionsParser.on('-v', '--version <Version>', String,
        '<Version>: Version string of the release.',
        'Set the version to display for this release.') do |iArg|
        lReleaseVersion = iArg
      end
      lOptionsParser.on('-t', '--tag <TagName>', String,
        '<TagName>: Tag to apply to this version.',
        'Set a Tag to this version. A Tag is a way to categorize the version (i.e. UltimateEdition, Alpha...).') do |iArg|
        lReleaseTags << iArg
      end
      lOptionsParser.on('-c', '--comment <Comment>', String,
        '<Comment>: Comment to add to the release note.',
        'Set the release comment to display for this release.') do |iArg|
        lReleaseComment = iArg
      end
      lOptionsParser.on('-r', '--ruby',
        'Include Ruby distribution in the release (only applicable for executable releases).') do
        lIncludeRuby = true
      end
      lOptionsParser.on('-n', '--includeTest',
        'Include Test files in the release.') do
        lIncludeTest = true
      end
      lOptionsParser.on('-o', '--no-rdoc',
        'Do NOT generate RDoc.') do
        lIncludeRDoc = false
      end
      lOptionsParser.on('-i', '--installer <InstallerName>', String,
        '<InstallerName>: Name of an Installer to use.',
        "Generate an installer. Can be specified multiple times. Available Installers are: #{lPluginsManager.get_plugins_names('Installers').join(', ')}") do |iArg|
        lInstallers << iArg
      end
      lOptionsParser.on('-d', '--distributor <DistributorName>', String,
        '<DistributorName>: Name of a Distributor to use.',
        "Ship generated installers to a distributor. Can be specified multiple times. Available Distributors are: #{lPluginsManager.get_plugins_names('Distributors').join(', ')}") do |iArg|
        lDistributors << iArg
      end
      lReleaseInfo = nil
      begin
        lRemainingArgs = lOptionsParser.parse(iParameters)
        if (lRemainingArgs.size != 1)
          if (!lDisplayUsage)
            puts 'Wrong release file. Please specify 1 release file.'
            puts lOptionsParser
            rSuccess = false
          end
        else
          # Check the Release file
          lReleaseFile = lRemainingArgs[0]
          require 'RubyPackager/ReleaseInfo'
          File.open(lReleaseFile, 'r') do |iFile|
            lReleaseInfo = eval(iFile.read)
          end
          if (!lReleaseInfo.kind_of?(RubyPackager::ReleaseInfo))
            puts "Release file #{lReleaseFile} is incorrect. It does not define RubyPackager::ReleaseInfo variable. Please correct it and try again."
            rSuccess = false
          end
        end
        # Check the installers
        lAvailableInstallers = lPluginsManager.get_plugins_names('Installers')
        lInstallers.each do |iInstallerName|
          if (!lAvailableInstallers.include?(iInstallerName))
            puts "Unknown specified installer: #{iInstallerName}."
            puts lOptionsParser
            rSuccess = false
          end
        end
        # Check the distributors
        lAvailableDistributors = lPluginsManager.get_plugins_names('Distributors')
        lDistributors.each do |iDistributorName|
          if (!lAvailableDistributors.include?(iDistributorName))
            puts "Unknown specified distributor: #{iDistributorName}."
            puts lOptionsParser
            rSuccess = false
          end
        end
      rescue Exception
        puts "Error while parsing arguments: #{$!}"
        puts lOptionsParser
        rSuccess = false
      end
      if (rSuccess)
        if (lDisplayUsage)
          puts "RubyPackager v. #{lRPReleaseInfo[:version]} - #{lRPReleaseInfo[:dev_status]}"
          puts ''
          puts lOptionsParser
        else
          # All is ok, call the library with parameters
          require 'RubyPackager/Releaser'
          # Require the platform specific distribution file
          require "RubyPackager/#{PLATFORM_ID}/PlatformReleaser"
          rSuccess = Releaser.new(
            lPluginsManager,
            lReleaseInfo,
            Dir.getwd,
            "#{Dir.getwd}/Releases",
            PlatformReleaser.new,
            lReleaseVersion,
            lReleaseTags,
            lReleaseComment,
            lIncludeRuby,
            lIncludeTest,
            lIncludeRDoc,
            lInstallers,
            lDistributors
          ).execute
          if (rSuccess)
            log_info 'Release successful.'
          else
            log_err 'Error while releasing.'
          end
        end
      end

      return rSuccess
    end

  end

end

# Execute everything (take care that paths might differ in bin directories gems)
if (File.basename($0) == File.basename(__FILE__))
  lSuccess = RubyPackager::Launcher.new.run(ARGV)
  if (lSuccess)
    exit 0
  else
    exit 1
  end
end
