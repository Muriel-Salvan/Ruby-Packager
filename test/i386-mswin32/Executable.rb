#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
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
            assert(File.exists?("#{iReleaseDir}/Release/ExeName.exe"))
            # Unless the Executable file can contain other rb files (please Crate come faster !), files are still present.
            assert(File.exists?("#{iReleaseDir}/Release/Main.rb"))
          end
        end

      end

    end

  end

end
