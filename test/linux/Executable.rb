module RubyPackager

  module Test

    module Linux

      class Executable < ::Test::Unit::TestCase

        include RubyPackager::Test::Common

        # Test the basic usage generating an executable
        def testBasicBinary
          execTest('Applications/Basic', [], 'ReleaseInfo_Exe.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            lExeFileName = "#{iReleaseDir}/Release/ExeName"
            assert(File.exists?(lExeFileName))
            # Unless the Executable file can contain other rb files (please Crate come faster !), files are still present.
            assert(File.exists?("#{iReleaseDir}/Release/Main.rb"))
            # Test it in Ruby's environment
            assert_equal("Ruby found on current platform. Use it directly.
Hello World\n", runExe(lExeFileName))
            # TODO: Test it without Ruby's environment
          end
        end

        # Test the basic usage generating an executable in a terminal
        def testBasicBinaryInTerminal
          execTest('Applications/Basic', [], 'ReleaseInfo_ExeTerm.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            lExeFileName = "#{iReleaseDir}/Release/ExeName"
            assert(File.exists?(lExeFileName))
            # Unless the Executable file can contain other rb files (please Crate come faster !), files are still present.
            assert(File.exists?("#{iReleaseDir}/Release/Main.rb"))
            # Test it in Ruby's environment
            assert_equal("Ruby found on current platform. Use it directly.
Hello World\n", runExe(lExeFileName))
            # TODO: Test it without Ruby's environment
          end
        end

        # Test the basic usage generating an executable, including Ruby
        def testBasicBinaryWithRuby
          execTest('Applications/Basic', [ '-r' ], 'ReleaseInfo_Exe.rb', :ExpectCalls => [
            [ 'system',
              {
                :Dir => /^.*\/Releases\/#{RUBY_PLATFORM}\/UnnamedVersion\/IncludeRuby\/\d\d\d\d_\d\d_\d\d_\d\d_\d\d_\d\d\/Release\/Launch\/linux\/bin$/,
                :Cmd => /^allinoneruby ruby\-#{RUBY_VERSION}\.bin$/
              },
              { :Execute => $RBPTest_ExternalTools ? true : Proc.new { true } }
            ]
          ]) do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            lExeFileName = "#{iReleaseDir}/Release/ExeName"
            assert(File.exists?(lExeFileName))
            # Unless the Executable file can contain other rb files (please Crate come faster !), files are still present.
            assert(File.exists?("#{iReleaseDir}/Release/Main.rb"))
            # Test it in Ruby's environment
            assert_equal("Ruby found on current platform. Use it directly.
Hello World\n", runExe(lExeFileName))
            # TODO: Test it without Ruby's environment
          end
        end

        # Test the basic usage generating an executable, including Ruby launched from a terminal
        def testBasicBinaryWithRubyInTerminal
          execTest('Applications/Basic', [ '-r' ], 'ReleaseInfo_ExeTerm.rb', :ExpectCalls => [
            [ 'system',
              {
                :Dir => /^.*\/Releases\/#{RUBY_PLATFORM}\/UnnamedVersion\/IncludeRuby\/\d\d\d\d_\d\d_\d\d_\d\d_\d\d_\d\d\/Release\/Launch\/linux\/bin$/,
                :Cmd => /^allinoneruby ruby\-#{RUBY_VERSION}\.bin$/
              },
              { :Execute => $RBPTest_ExternalTools ? true : Proc.new { true } }
            ]
          ]) do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            lExeFileName = "#{iReleaseDir}/Release/ExeName"
            assert(File.exists?(lExeFileName))
            # Unless the Executable file can contain other rb files (please Crate come faster !), files are still present.
            assert(File.exists?("#{iReleaseDir}/Release/Main.rb"))
            # Test it in Ruby's environment
            assert_equal("Ruby found on current platform. Use it directly.
Hello World\n", runExe(lExeFileName))
            # TODO: Test it without Ruby's environment
          end
        end

      end

    end

  end

end
