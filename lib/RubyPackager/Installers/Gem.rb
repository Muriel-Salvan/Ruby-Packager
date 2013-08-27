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

          # has_rdoc
          lStrHasRDoc = (iReleaseInfo.gem_info[:has_rdoc]) ? 'true' : 'false'

          # files
          # !!! Don't use absolute paths here, otherwise they will be stored in the Gem
          lStrFiles = "iSpec.files = [ '#{Dir.glob('**/*').join('\', \'')}' ]"

          # extra_rdoc_files
          lStrExtraRDocFiles = ''
          if ((iReleaseInfo.gem_info[:extra_rdoc_files] != nil) and
              (!iReleaseInfo.gem_info[:extra_rdoc_files].empty?))
            lStrExtraRDocFiles = "iSpec.extra_rdoc_files = [ '#{iReleaseInfo.gem_info[:extra_rdoc_files].join('\', \'')}' ]"
            RubyPackager::copyFiles(iRootDir, iReleaseDir, iReleaseInfo.gem_info[:extra_rdoc_files])
          end

          # add_dependency
          lGemDepsStrList = []
          if (iReleaseInfo.gem_info[:gem_dependencies] != nil)
            iReleaseInfo.gem_info[:gem_dependencies].each do |iGemDepInfo|
              iGemName, iGemVersion = iGemDepInfo
              if (iGemVersion != nil)
                lGemDepsStrList << "iSpec.add_dependency('#{iGemName}', '#{iGemVersion}')"
              else
                lGemDepsStrList << "iSpec.add_dependency('#{iGemName}')"
              end
            end
          end

          # test_file
          lStrTestFile = ''
          if ((iIncludeTest) and
              (iReleaseInfo.gem_info[:test_file] != nil))
            lStrTestFile = "iSpec.test_file = '#{iReleaseInfo.gem_info[:test_file]}'"
          end

          # bind_dir and executables
          # Compute the list of executable files and the executable directory
          lBinError = false
          lExecutablesDir = nil
          lExecutablesBase = []
          iReleaseInfo.executables_info.each do |iExecutableInfo|
            if (lExecutablesDir == nil)
              lExecutablesDir = File.dirname(iExecutableInfo[:startup_rb_file])
            elsif (lExecutablesDir != File.dirname(iExecutableInfo[:startup_rb_file]))
              # Error
              log_err "Executables should be all in the same directory. \"#{lExecutablesDir}\" and \"#{File.dirname(iExecutableInfo[:startup_rb_file])}\" are different directories."
              lBinError = true
            end
            lExecutablesBase << File.basename(iExecutableInfo[:startup_rb_file])
          end
          if (!lBinError)
            lStrBinDir = ''
            lStrExecutables = ''
            if (lExecutablesDir != nil)
              lStrBinDir = "iSpec.bindir = '#{lExecutablesDir}'"
              lStrExecutables = "iSpec.executables = #{lExecutablesBase.inspect}"
            end

            # require_path and require_paths
            # Compute require paths
            lRequirePaths = []
            if (iReleaseInfo.gem_info[:require_path] != nil)
              lRequirePaths = [ iReleaseInfo.gem_info[:require_path] ]
            end
            if (iReleaseInfo.gem_info[:require_paths] != nil)
              lRequirePaths.concat(iReleaseInfo.gem_info[:require_paths])
            end
            lStrRequirePaths = (lRequirePaths.empty?) ? 'iSpec.require_path = \'\'' : "iSpec.require_paths = #{lRequirePaths.inspect}"

            # extensions
            lStrExtensions = ''
            if ((iReleaseInfo.gem_info[:extensions] != nil) and
                (!iReleaseInfo.gem_info[:extensions].empty?))
              lStrExtensions = "iSpec.extensions = [ '#{iReleaseInfo.gem_info[:extensions].join('\', \'')}' ]"
            end

            # Generate the GemSpec file
            lGemSpecFileName = 'release.gemspec.rb'
            File.open(lGemSpecFileName, 'w') do |oFile|
              oFile << "
Gem::Specification.new do |iSpec|
  iSpec.name = '#{iReleaseInfo.gem_info[:gem_name]}'
  iSpec.version = '#{iVersion}'
  iSpec.author = '#{iReleaseInfo.author_info[:name].gsub(/'/,'\\\\\'')}'
  iSpec.email = '#{iReleaseInfo.author_info[:email]}'
  iSpec.homepage = '#{iReleaseInfo.project_info[:web_page_url]}'
  iSpec.platform = #{iReleaseInfo.gem_info[:gem_platform_class_name]}
  iSpec.summary = '#{iReleaseInfo.project_info[:summary].gsub(/'/,'\\\\\'')}'
  iSpec.description = '#{iReleaseInfo.project_info[:description].gsub(/'/,'\\\\\'')}'
  #{lStrFiles}
  #{lStrRequirePaths}
  iSpec.has_rdoc = #{lStrHasRDoc}
  #{lStrExtraRDocFiles}
  iSpec.rubyforge_project = '#{iReleaseInfo.rf_info[:project_unix_name]}'
  #{lStrTestFile}
  #{lStrBinDir}
  #{lStrExecutables}
  #{lGemDepsStrList.join("\n")}
  #{lStrExtensions}
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
              rFileName = Dir.glob("#{iReleaseInfo.gem_info[:gem_name]}-#{iVersion}*.gem")[0]
              if (rFileName == nil)
                log_err "Unable to find generated gem \"#{iReleaseInfo.gem_info[:gem_name]}-#{iVersion}*.gem\""
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
