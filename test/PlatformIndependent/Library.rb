#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  module Test

    module PlatformIndependent

      class Library < ::Test::Unit::TestCase

        include RubyPackager::Test::Common

        # Test the basic usage
        def testBasicLib
          execTest('Libraries/Basic', [], 'ReleaseInfo.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
          end
        end

      end

    end

  end

end
