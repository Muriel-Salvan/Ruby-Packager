#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  module Test

    module PlatformIndependent

      module Plugins

        module Installers

          class Gem < ::Test::Unit::TestCase

            include RubyPackager::Test::Common

            def testGemLibrary
              execTest('Libraries/Basic', [ '-v', '0.0.1.20091030', '-i', 'Gem' ], 'ReleaseInfo_Gem.rb') do |iReleaseDir, iReleaseInfo|
                checkReleaseInfo(iReleaseDir, iReleaseInfo, :Version => '0.0.1.20091030' )
                checkReleaseNotes(iReleaseDir, iReleaseInfo)
                assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
                lGemName = "#{iReleaseDir}/Installer/GemName-0.0.1.20091030.gem"
                assert(File.exists?(lGemName))
                # Get back the specification to check it
                lOldDir = Dir.getwd
                Dir.chdir(File.dirname(lGemName))
                require 'rubygems'
                lGemSpec = eval(`gem.bat specification #{File.basename(lGemName)} --ruby`.gsub(/Gem::/,'::Gem::'))
                Dir.chdir(lOldDir)
                assert_equal('GemName', lGemSpec.name)
                assert_equal(::Gem::Version.new('0.0.1.20091030'), lGemSpec.version)
                assert_equal(['Author:Name'], lGemSpec.authors)
                assert_equal('Project:Description', lGemSpec.description)
                assert_equal('Author:EMail', lGemSpec.email)
                assert_equal(2, lGemSpec.files.size)
                assert(lGemSpec.files.include?('MainLib.rb'))
                assert(lGemSpec.files.include?('ReleaseInfo'))
                assert_equal(true, lGemSpec.has_rdoc)
                assert_equal('Project:WebPageURL', lGemSpec.homepage)
                assert_equal('Project:Summary', lGemSpec.summary)
              end
            end

            def testGemLibraryWithTest
              execTest('Libraries/Basic', [ '-v', '0.0.1.20091030', '-n', '-i', 'Gem' ], 'ReleaseInfo_TestGem.rb') do |iReleaseDir, iReleaseInfo|
                checkReleaseInfo(iReleaseDir, iReleaseInfo, :Version => '0.0.1.20091030' )
                checkReleaseNotes(iReleaseDir, iReleaseInfo)
                assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
                assert(File.exists?("#{iReleaseDir}/Release/Test.rb"))
                lGemName = "#{iReleaseDir}/Installer/GemName-0.0.1.20091030.gem"
                assert(File.exists?(lGemName))
                # Get back the specification to check it
                lOldDir = Dir.getwd
                Dir.chdir(File.dirname(lGemName))
                require 'rubygems'
                # TODO: Bug (Ruby): gem.bat instead of gem for Windows only. Make .bat files calleable without their extension.
                if (RUBY_PLATFORM == 'i386-mswin32')
                  lGemSpec = eval(`gem.bat specification #{File.basename(lGemName)} --ruby`.gsub(/Gem::/,'::Gem::'))
                else
                  lGemSpec = eval(`gem specification #{File.basename(lGemName)} --ruby`.gsub(/Gem::/,'::Gem::'))
                end
                Dir.chdir(lOldDir)
                assert_equal('GemName', lGemSpec.name)
                assert_equal(::Gem::Version.new('0.0.1.20091030'), lGemSpec.version)
                assert_equal(['Author:Name'], lGemSpec.authors)
                assert_equal('Project:Description', lGemSpec.description)
                assert_equal('Author:EMail', lGemSpec.email)
                assert_equal('Test.rb', lGemSpec.test_file)
                assert_equal(3, lGemSpec.files.size)
                assert(lGemSpec.files.include?('MainLib.rb'))
                assert(lGemSpec.files.include?('Test.rb'))
                assert(lGemSpec.files.include?('ReleaseInfo'))
                assert_equal(true, lGemSpec.has_rdoc)
                assert_equal('Project:WebPageURL', lGemSpec.homepage)
                assert_equal('Project:Summary', lGemSpec.summary)
              end
            end

            def testGemExecutable
              execTest('Applications/Basic', [ '-v', '0.0.1.20091030', '-i', 'Gem' ], 'ReleaseInfo_Gem.rb') do |iReleaseDir, iReleaseInfo|
                checkReleaseInfo(iReleaseDir, iReleaseInfo, :Version => '0.0.1.20091030' )
                checkReleaseNotes(iReleaseDir, iReleaseInfo)
                assert(File.exists?("#{iReleaseDir}/Release/Main.rb"))
                lGemName = "#{iReleaseDir}/Installer/GemName-0.0.1.20091030.gem"
                assert(File.exists?(lGemName))
                # Get back the specification to check it
                lOldDir = Dir.getwd
                Dir.chdir(File.dirname(lGemName))
                require 'rubygems'
                lGemSpec = eval(`gem.bat specification #{File.basename(lGemName)} --ruby`.gsub(/Gem::/,'::Gem::'))
                Dir.chdir(lOldDir)
                assert_equal('GemName', lGemSpec.name)
                assert_equal(::Gem::Version.new('0.0.1.20091030'), lGemSpec.version)
                assert_equal(['Author:Name'], lGemSpec.authors)
                assert_equal('.', lGemSpec.bindir)
                assert_equal('Main.rb', lGemSpec.default_executable)
                assert_equal(['Main.rb'], lGemSpec.executables)
                assert_equal('Project:Description', lGemSpec.description)
                assert_equal('Author:EMail', lGemSpec.email)
                assert_equal(3, lGemSpec.files.size)
                assert(lGemSpec.files.include?('Main.rb'))
                assert(lGemSpec.files.include?('ReleaseInfo'))
                # This one is added by RubyGems itself because of the binary
                assert(lGemSpec.files.include?('./Main.rb'))
                assert_equal(true, lGemSpec.has_rdoc)
                assert_equal('Project:WebPageURL', lGemSpec.homepage)
                assert_equal('Project:Summary', lGemSpec.summary)
              end
            end

            def testGemDependency
              execTest('Libraries/Basic', [ '-v', '0.0.1.20091030', '-i', 'Gem' ], 'ReleaseInfo_GemDep.rb') do |iReleaseDir, iReleaseInfo|
                checkReleaseInfo(iReleaseDir, iReleaseInfo, :Version => '0.0.1.20091030' )
                checkReleaseNotes(iReleaseDir, iReleaseInfo)
                assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
                lGemName = "#{iReleaseDir}/Installer/GemName-0.0.1.20091030.gem"
                assert(File.exists?(lGemName))
                # Get back the specification to check it
                lOldDir = Dir.getwd
                Dir.chdir(File.dirname(lGemName))
                require 'rubygems'
                lGemSpec = eval(`gem.bat specification #{File.basename(lGemName)} --ruby`.gsub(/Gem::/,'::Gem::'))
                Dir.chdir(lOldDir)
                assert_equal('GemName', lGemSpec.name)
                assert_equal(::Gem::Version.new('0.0.1.20091030'), lGemSpec.version)
                assert_equal(['Author:Name'], lGemSpec.authors)
                assert_equal('Project:Description', lGemSpec.description)
                assert_equal('Author:EMail', lGemSpec.email)
                assert_equal(2, lGemSpec.files.size)
                assert(lGemSpec.files.include?('MainLib.rb'))
                assert(lGemSpec.files.include?('ReleaseInfo'))
                assert_equal(true, lGemSpec.has_rdoc)
                assert_equal('Project:WebPageURL', lGemSpec.homepage)
                assert_equal('Project:Summary', lGemSpec.summary)
                assert_equal(1, lGemSpec.dependencies.size)
                assert_equal('GemDepName', lGemSpec.dependencies[0].name)
                assert_equal([ [ '>=', ::Gem::Version.new('0.1') ] ], lGemSpec.dependencies[0].version_requirements.requirements)
              end
            end

          end

        end

      end

    end

  end

end
