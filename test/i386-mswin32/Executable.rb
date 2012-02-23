#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  module Test

    module I386MSWin32

      class Executable < ::Test::Unit::TestCase

        include RubyPackager::Test::Common
        
        # Test the basic usage generating an executable
        def testBasicBinary
          execTest('Applications/Basic', [], 'ReleaseInfo_Exe.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            lExeFileName = "#{iReleaseDir}/Release/ExeName.exe"
            assert(File.exists?(lExeFileName))
            # Unless the Executable file can contain other rb files (please Crate come faster !), files are still present.
            assert(File.exists?("#{iReleaseDir}/Release/Main.rb"))
            # Test it in Ruby's environment
            assert_equal("#{getRubySignature}
Ruby found in environment. Using it directly.
> start rubyw -w \"#{iReleaseDir}/Release/Main.rb\" \n", runExe(lExeFileName))
            # TODO: Test it without Ruby's environment
          end
        end

        # Test the basic usage generating an executable in a terminal
        def testBasicBinaryInTerminal
          execTest('Applications/Basic', [], 'ReleaseInfo_ExeTerm.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            lExeFileName = "#{iReleaseDir}/Release/ExeName.exe"
            assert(File.exists?(lExeFileName))
            # Unless the Executable file can contain other rb files (please Crate come faster !), files are still present.
            assert(File.exists?("#{iReleaseDir}/Release/Main.rb"))
            # Test it in Ruby's environment
            assert_equal("#{getRubySignature}
Ruby found in environment. Using it directly.
> ruby -w \"#{iReleaseDir}/Release/Main.rb\" \nHello World\n", runExe(lExeFileName))
            # TODO: Test it without Ruby's environment
          end
        end

        # Test the basic usage generating an executable, including Ruby
        def testBasicBinaryWithRuby
          execTest('Applications/Basic', [ '-r' ], 'ReleaseInfo_Exe.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            lExeFileName = "#{iReleaseDir}/Release/ExeName.exe"
            assert(File.exists?(lExeFileName))
            # Unless the Executable file can contain other rb files (please Crate come faster !), files are still present.
            assert(File.exists?("#{iReleaseDir}/Release/Main.rb"))
            # Test it in Ruby's environment
            assert_equal("#{getRubySignature}
Ruby found in environment. Using it directly.
> start rubyw -w \"#{iReleaseDir}/Release/Main.rb\" \n", runExe(lExeFileName))
            # TODO: Test it without Ruby's environment
          end
        end

        # Test the basic usage generating an executable, including Ruby launched from a terminal
        def testBasicBinaryWithRubyInTerminal
          execTest('Applications/Basic', [ '-r' ], 'ReleaseInfo_ExeTerm.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            lExeFileName = "#{iReleaseDir}/Release/ExeName.exe"
            assert(File.exists?(lExeFileName))
            # Unless the Executable file can contain other rb files (please Crate come faster !), files are still present.
            assert(File.exists?("#{iReleaseDir}/Release/Main.rb"))
            # Test it in Ruby's environment
            assert_equal("#{getRubySignature}
Ruby found in environment. Using it directly.
> ruby -w \"#{iReleaseDir}/Release/Main.rb\" \nHello World\n", runExe(lExeFileName))
            # TODO: Test it without Ruby's environment
          end
        end

        private

        # Get Ruby's signature when invoked from command line
        #
        # Return::
        # * _String_: Ruby's signature
        def getRubySignature
          lRubyReleaseInfo = nil
          if (defined?(RUBY_PATCHLEVEL))
            lRubyReleaseInfo = "#{RUBY_RELEASE_DATE} patchlevel #{RUBY_PATCHLEVEL}"
          else
            lRubyReleaseInfo = RUBY_RELEASE_DATE
          end

          return "ruby #{RUBY_VERSION} (#{lRubyReleaseInfo}) [#{RUBY_PLATFORM}]"
        end

      end

    end

  end

end
