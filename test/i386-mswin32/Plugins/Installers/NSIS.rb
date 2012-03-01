#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  module Test

    module PlatformIndependent

      module Plugins

        module Installers

          class NSIS < ::Test::Unit::TestCase

            include RubyPackager::Test::Common

            def testNSISCall
              execTest('Libraries/Basic', [ '-v', '0.0.1.20091030', '-i', 'NSIS' ], 'ReleaseInfo_NSIS.rb') do |iReleaseDir, iReleaseInfo|
                checkReleaseInfo(iReleaseDir, iReleaseInfo, :version => '0.0.1.20091030' )
                checkReleaseNotes(iReleaseDir, iReleaseInfo)
                assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
                assert(File.exists?("#{iReleaseDir}/Installer/InstallerName_0.0.1.20091030_setup.exe"))
              end
            end

          end

        end

      end

    end

  end

end
