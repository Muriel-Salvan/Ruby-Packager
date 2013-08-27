module RubyPackager

  module Test

    module Windows

      module Plugins

        module Installers

          class NSIS < ::Test::Unit::TestCase

            include RubyPackager::Test::Common

            def testNSISCall
              execTest('Libraries/Basic', [ '-v', '0.0.1.20091030', '-i', 'NSIS' ], 'ReleaseInfo_NSIS.rb', :ExpectCalls => [
                [ 'system',
                  {
                    :Dir => /^.*$/,
                    :Cmd => /^makensis \/VERSION$/
                  },
                  { :Execute => $RBPTest_ExternalTools ? true : Proc.new { true } }
                ],
                [ 'system',
                  {
                    :Dir => /^.*$/,
                    :Cmd => /^makensis \/DVERSION=0\.0\.1\.20091030 "\/DRELEASEDIR=.*\\Releases\\#{RUBY_PLATFORM}\\0\.0\.1\.20091030\\Normal\\\d\d\d\d_\d\d_\d\d_\d\d_\d\d_\d\d\\Release" ".*\\Distribution\\install\.nsi\"$/
                  },
                  { :Execute => $RBPTest_ExternalTools ? true : Proc.new {
                    FileUtils::touch 'Distribution/setup.exe'
                    true
                  } }
                ]
              ]) do |iReleaseDir, iReleaseInfo|
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
