#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  module Installers

    class Gem

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

        change_dir(iReleaseDir) do
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
          if ((iIncludeTest) and
              (iReleaseInfo.GemInfo[:TestFile] != nil))
            lStrTestFile = "iSpec.test_file = '#{iReleaseInfo.GemInfo[:TestFile]}'"
          end
          # Compute the list of executable files and the executable directory
          lBinError = false
          lExecutablesDir = nil
          lExecutablesBase = []
          iReleaseInfo.ExecutablesInfo.each do |iExecutableInfo|
            if (lExecutablesDir == nil)
              lExecutablesDir = File.dirname(iExecutableInfo[:StartupRBFile])
            elsif (lExecutablesDir != File.dirname(iExecutableInfo[:StartupRBFile]))
              # Error
              log_err "Executables should be all in the same directory. \"#{lExecutablesDir}\" and \"#{File.dirname(iExecutableInfo[:StartupRBFile])}\" are different directories."
              lBinError = true
            end
            lExecutablesBase << File.basename(iExecutableInfo[:StartupRBFile])
          end
          if (!lBinError)
            lStrBinDir = ''
            lStrExecutables = ''
            if (lExecutablesDir != nil)
              lStrBinDir = "iSpec.bindir = '#{lExecutablesDir}'"
              lStrExecutables = "iSpec.executables = #{lExecutablesBase.inspect}"
            end
            # Compute require paths
            lRequirePaths = []
            if (iReleaseInfo.GemInfo[:RequirePath] != nil)
              lRequirePaths = [ iReleaseInfo.GemInfo[:RequirePath] ]
            end
            if (iReleaseInfo.GemInfo[:RequirePaths] != nil)
              lRequirePaths.concat(iReleaseInfo.GemInfo[:RequirePaths])
            end
            lStrRequirePaths = 'iSpec.require_path = \'\''
            if (!lRequirePaths.empty?)
              lStrRequirePaths = "iSpec.require_paths = #{lRequirePaths.inspect}"
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
  #{lStrRequirePaths}
  iSpec.has_rdoc = #{lStrHasRDoc}
  #{lStrExtraRDocFiles}
  iSpec.rubyforge_project = '#{iReleaseInfo.RFInfo[:ProjectUnixName]}'
  #{lStrTestFile}
  #{lStrBinDir}
  #{lStrExecutables}
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
                log_err "RubyGems returned error #{$!.exit_code}."
                lGemOK = false
              end
            end
            File.unlink(lGemSpecFileName)
            if (lGemOK)
              # Move the Gem to the destination directory
              require 'fileutils'
              # Find the name of the Gem: it can differ depending on the platform
              rFileName = Dir.glob("#{iReleaseInfo.GemInfo[:GemName]}-#{iVersion}*.gem")[0]
              if (rFileName == nil)
                log_err "Unable to find generated gem \"#{iReleaseInfo.GemInfo[:GemName]}-#{iVersion}*.gem\""
              else
                FileUtils::mv(rFileName, "#{iInstallerDir}/#{rFileName}")
              end
            end
          end
        end

        return rFileName
      end

    end

  end

end