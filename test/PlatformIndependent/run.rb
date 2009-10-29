#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  module Test

    module PlatformIndependent

      class LibraryTest < ::Test::Unit::TestCase

        include RubyPackager::Test::Common

        # Test the basic usage without embedded Ruby
        def testBasicLib
          execTest('Libraries/Basic', [], 'ReleaseInfo.rb') do |iReleaseDir, iReleaseInfo|
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
            assert(File.exists?("#{iReleaseDir}/Documentation/rdoc/index.html"))
            assert(File.exists?("#{iReleaseDir}/Documentation/ReleaseNote.html"))
            assert(File.exists?("#{iReleaseDir}/Documentation/ReleaseNote.txt"))
          end
        end

      end

    end

  end

end
