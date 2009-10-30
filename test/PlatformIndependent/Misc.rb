#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  module Test

    module PlatformIndependent

      class Misc < ::Test::Unit::TestCase

        include RubyPackager::Test::Common

        # Test release without Test files
        def testWithoutTest
          execTest('Libraries/Basic', [], 'ReleaseInfo_Test.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
            assert(!File.exists?("#{iReleaseDir}/Release/Test.rb"))
          end
        end

        # Test release with Test files
        def testWithTest
          execTest('Libraries/Basic', [ '-n' ], 'ReleaseInfo_Test.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
            assert(File.exists?("#{iReleaseDir}/Release/Test.rb"))
          end
        end

        # Test release with Additional files
        def testWithAdditional
          execTest('Libraries/Basic', [], 'ReleaseInfo_Additional.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
            assert(File.exists?("#{iReleaseDir}/Release/Add.rb"))
          end
        end

        # Test release with RDoc
        def testWithRDoc
          execTest('Libraries/Basic', [], 'ReleaseInfo.rb', :IncludeRDoc => true) do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            checkRDoc(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
          end
        end

      end

    end

  end

end
