#--
# Copyright (c) 2009 - 2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  module Test

    module PlatformIndependent

      module Plugins

        module Distributors

          class SourceForge < ::Test::Unit::TestCase

            include RubyPackager::Test::Common

            def testBasicSend
              execTest('Libraries/Basic', [ '-i', 'DummyInstaller1', '-d', 'SourceForge' ], 'ReleaseInfo_SF.rb') do |iReleaseDir, iReleaseInfo|
                checkReleaseInfo(iReleaseDir, iReleaseInfo)
                checkReleaseNotes(iReleaseDir, iReleaseInfo)
                assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
                assert(File.exists?("#{iReleaseDir}/Installer/MainLib.rb.Installer1"))
                assert_equal( [
                  [ 'SSH', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                    :Cmd => 'create' } ],
                  [ 'SSH', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                    :Cmd => 'mkdir -p /home/frs/project/u/un/unixname/UnnamedVersion' } ],
                  [ 'SCP', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                    :FileSrc => "#{iReleaseDir}/Documentation/ReleaseNote.html",
                    :FileDst => '/home/frs/project/u/un/unixname/UnnamedVersion/ReleaseNote.html' } ],
                  [ 'SCP', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                    :FileSrc => "#{iReleaseDir}/Installer/MainLib.rb.Installer1",
                    :FileDst => '/home/frs/project/u/un/unixname/UnnamedVersion/MainLib.rb.Installer1' } ]
                ], $SSHCommands)
              end
            end

            def testBasicSendWithRDoc
              execTest('Libraries/Basic', [ '-i', 'DummyInstaller1', '-d', 'SourceForge' ], 'ReleaseInfo_SF.rb', :IncludeRDoc => true) do |iReleaseDir, iReleaseInfo|
                checkReleaseInfo(iReleaseDir, iReleaseInfo)
                checkReleaseNotes(iReleaseDir, iReleaseInfo)
                checkRDoc(iReleaseDir, iReleaseInfo)
                assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
                assert(File.exists?("#{iReleaseDir}/Installer/MainLib.rb.Installer1"))
                lRDocBaseDir = '/home/groups/u/un/unixname/htdocs/rdoc'
                assert_equal( [
                  [ 'SSH', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                    :Cmd => 'create' } ],
                  [ 'SSH', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                    :Cmd => 'mkdir -p /home/frs/project/u/un/unixname/UnnamedVersion' } ],
                  [ 'SSH', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                    :Cmd => "mkdir -p #{lRDocBaseDir}" } ],
                  [ 'SCP', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                    :FileSrc => "#{iReleaseDir}/Documentation/rdoc.zip",
                    :FileDst => "#{lRDocBaseDir}/rdoc-UnnamedVersion.zip" } ],
                  [ 'SSH', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                    :Cmd => "unzip -o -d #{lRDocBaseDir} #{lRDocBaseDir}/rdoc-UnnamedVersion.zip ; mv #{lRDocBaseDir}/rdoc #{lRDocBaseDir}/UnnamedVersion ; rm #{lRDocBaseDir}/latest ; ln -s #{lRDocBaseDir}/UnnamedVersion #{lRDocBaseDir}/latest ; rm #{lRDocBaseDir}/rdoc-UnnamedVersion.zip" } ],
                  [ 'SCP', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                    :FileSrc => "#{iReleaseDir}/Documentation/ReleaseNote.html",
                    :FileDst => '/home/frs/project/u/un/unixname/UnnamedVersion/ReleaseNote.html' } ],
                  [ 'SCP', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                    :FileSrc => "#{iReleaseDir}/Installer/MainLib.rb.Installer1",
                    :FileDst => '/home/frs/project/u/un/unixname/UnnamedVersion/MainLib.rb.Installer1' } ]
                ], $SSHCommands)
              end
            end

          end

        end

      end

    end

  end

end
