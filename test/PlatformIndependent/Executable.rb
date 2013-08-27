module RubyPackager

  module Test

    module PlatformIndependent

      class Executable < ::Test::Unit::TestCase

        include RubyPackager::Test::Common

        # Test the basic usage
        def testBasicExecutable
          execTest('Applications/Basic', [], 'ReleaseInfo.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/Main.rb"))
          end
        end

      end

    end

  end

end
