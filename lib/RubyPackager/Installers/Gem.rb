#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  module Installers

    class Gem

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

        changeDir(iReleaseDir) do
          # 1. Generate the gemspec that will build the gem
          lStrHasRDoc = nil
          if (iReleaseInfo.GemInfo[:HasRDoc])
            lStrHasRDoc = 'true'
          else
            lStrHasRDoc = 'false'
          end
          # !!! Don't use absolute paths here, otherwise they will be stored in the Gem
          lStrFiles = "iSpec.files = [ '#{Dir.glob('**/*').join('\', \'')}' ]"
          lStrExtraRDocFiles = ''
          if ((iReleaseInfo.GemInfo[:ExtraRDocFiles] != nil) and
              (!iReleaseInfo.GemInfo[:ExtraRDocFiles].empty?))
            lStrExtraRDocFiles = "iSpec.extra_rdoc_files = [ '#{iReleaseInfo.GemInfo[:ExtraRDocFiles].join('\', \'')}' ]"
            RubyPackager::copyFiles(iRootDir, iReleaseDir, iReleaseInfo.GemInfo[:ExtraRDocFiles])
          end
          lGemDepsStrList = []
          if (iReleaseInfo.GemInfo[:GemDependencies] != nil)
            iReleaseInfo.GemInfo[:GemDependencies].each do |iGemDepInfo|
              iGemName, iGemVersion = iGemDepInfo
              if (iGemVersion != nil)
                lGemDepsStrList << "iSpec.add_dependency('#{iGemName}', '#{iGemVersion}')"
              else
                lGemDepsStrList << "iSpec.add_dependency('#{iGemName}')"
              end
            end
          end
          lStrTestFile = ''
          if (iReleaseInfo.GemInfo[:TestFile] != nil)
            lStrTestFile = "iSpec.test_file = '#{iReleaseInfo.GemInfo[:TestFile]}'"
          end
          lStrBinDir = ''
          lStrDefaultExecutable = ''
          if (iReleaseInfo.ExecutableInfo[:StartupRBFile] != nil)
            lStrBinDir = "iSpec.bindir = '#{File.dirname(iReleaseInfo.ExecutableInfo[:StartupRBFile])}'"
            lStrDefaultExecutable = "iSpec.executables = [ '#{File.basename(iReleaseInfo.ExecutableInfo[:StartupRBFile])}' ]"
          end
          lGemSpecFileName = 'release.gemspec.rb'
          File.open(lGemSpecFileName, 'w') do |oFile|
            oFile << "
Gem::Specification.new do |iSpec|
  iSpec.name = '#{iReleaseInfo.GemInfo[:GemName]}'
  iSpec.version = '#{iVersion}'
  iSpec.author = '#{iReleaseInfo.AuthorInfo[:Name].gsub(/'/,'\\\\\'')}'
  iSpec.email = '#{iReleaseInfo.AuthorInfo[:EMail]}'
  iSpec.homepage = '#{iReleaseInfo.ProjectInfo[:WebPageURL]}'
  iSpec.platform = #{iReleaseInfo.GemInfo[:GemPlatformClassName]}
  iSpec.summary = '#{iReleaseInfo.ProjectInfo[:Summary].gsub(/'/,'\\\\\'')}'
  iSpec.description = '#{iReleaseInfo.ProjectInfo[:Description].gsub(/'/,'\\\\\'')}'
  #{lStrFiles}
  iSpec.require_path = '#{iReleaseInfo.GemInfo[:RequirePath]}'
  iSpec.has_rdoc = #{lStrHasRDoc}
  #{lStrExtraRDocFiles}
  iSpec.rubyforge_project = '#{iReleaseInfo.RFInfo[:ProjectUnixName]}'
  #{lStrTestFile}
  #{lStrBinDir}
  #{lStrDefaultExecutable}
  #{lGemDepsStrList.join("\n")}
end
"
          end
          # 2. Call gem build with this gemspec
          # Load RubyGems
          require 'rubygems/command_manager'
          # Build gem
          lGemOK = true
          begin
            ::Gem::CommandManager.instance.find_command('build').invoke(lGemSpecFileName)
          rescue ::Gem::SystemExitException
            # For RubyGems, this is normal behaviour: success results in an exception thrown with exit_code 0.
            if ($!.exit_code != 0)
              logErr "RubyGems returned error #{$!.exit_code}."
              lGemOK = false
            end
          end
          File.unlink(lGemSpecFileName)
          if (lGemOK)
            # Move the Gem to the destination directory
            require 'fileutils'
            rFileName = "#{iReleaseInfo.GemInfo[:GemName]}-#{iVersion}.gem"
            FileUtils::mv(rFileName, "#{iInstallerDir}/#{rFileName}")
          end
        end

        return rFileName
      end

    end

  end

end