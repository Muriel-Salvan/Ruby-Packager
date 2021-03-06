module RubyPackager

  module Test

    module PlatformIndependent

      module Plugins

        module Distributors

          class RubyGems < ::Test::Unit::TestCase

            include RubyPackager::Test::Common

            def testSend
              lReleaseBaseDir = Regexp.escape("Releases/#{RUBY_PLATFORM}/0.0.1.20120228/Normal/") + '\\d\\d\\d\\d_\\d\\d_\\d\\d_\\d\\d_\\d\\d_\\d\\d'
              execTest('Libraries/Basic', [ '-v', '0.0.1.20120228', '-i', 'Gem', '-d', 'RubyGems' ], 'ReleaseInfo_Gem.rb', :ExpectCalls => [
                [ 'system', {
                  :Cmd => 'gem push --help',
                  :Dir => /^.*$/
                }, { :Execute => true } ],
                [ 'system', {
                  :Cmd => 'gem push GemName-0.0.1.20120228.gem',
                  :Dir => /^.*\/#{lReleaseBaseDir}\/Installer$/
                }, { :Execute => Proc.new { true } } ]
              ]) do |iReleaseDir, iReleaseInfo|
                checkReleaseInfo(iReleaseDir, iReleaseInfo, :version => '0.0.1.20120228')
                checkReleaseNotes(iReleaseDir, iReleaseInfo)
                assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
                lGemFileName = "#{iReleaseDir}/Installer/"
                assert(File.exists?(lGemFileName))
              end
            end

          end

        end

      end

    end

  end

end
