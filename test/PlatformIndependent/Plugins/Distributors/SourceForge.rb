#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
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
              lFRSBaseDir = '/home/frs/project/u/un/unixname/UnnamedVersion'
              lReleaseBaseDir = Regexp.escape("Releases/#{RUBY_PLATFORM}/UnnamedVersion/Normal/") + '\\d\\d\\d\\d_\\d\\d_\\d\\d_\\d\\d_\\d\\d_\\d\\d'
              execTest('Libraries/Basic', [ '-i', 'DummyInstaller1', '-d', 'SourceForge' ], 'ReleaseInfo_SF.rb', :ExpectCalls => [
                [ 'system', { :Cmd => 'zip -v', :Dir => /.*/ }, { :Execute => true } ],
                [ 'SSH', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                  :Cmd => 'create' } ],
                [ 'SSH', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                  :Cmd => "mkdir -p #{lFRSBaseDir}" } ],
                [ 'SCP', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                  :FileSrc => /^.*\/#{lReleaseBaseDir}\/Installer\/MainLib\.rb\.Installer1$/,
                  :FileDst => "#{lFRSBaseDir}/MainLib.rb.Installer1" } ]
              ]) do |iReleaseDir, iReleaseInfo|
                checkReleaseInfo(iReleaseDir, iReleaseInfo)
                checkReleaseNotes(iReleaseDir, iReleaseInfo)
                assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
                assert(File.exists?("#{iReleaseDir}/Installer/MainLib.rb.Installer1"))
              end
            end

            def testBasicSendWithRDoc
              lRDocBaseDir = '/home/project-web/unixname/htdocs/rdoc'
              lFRSBaseDir = '/home/frs/project/u/un/unixname/UnnamedVersion'
              lReleaseBaseDir = Regexp.escape("Releases/#{RUBY_PLATFORM}/UnnamedVersion/Normal/") + '\\d\\d\\d\\d_\\d\\d_\\d\\d_\\d\\d_\\d\\d_\\d\\d'
              execTest('Libraries/Basic', [ '-i', 'DummyInstaller1', '-d', 'SourceForge' ], 'ReleaseInfo_SF.rb', :IncludeRDoc => true, :ExpectCalls => [
                [ 'system', { :Cmd => 'zip -v', :Dir => /.*/ }, { :Execute => true } ],
                [ 'SSH', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                  :Cmd => 'create' } ],
                [ 'SSH', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                  :Cmd => "mkdir -p #{lFRSBaseDir}" } ],
                [ 'system', { :Cmd => 'zip -r rdoc.zip rdoc', :Dir => /^.*\/#{lReleaseBaseDir}\/Documentation$/ }, { :Execute => true } ],
                [ 'SSH', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                  :Cmd => "mkdir -p #{lRDocBaseDir}" } ],
                [ 'SCP', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                  :FileSrc => /^.*\/#{lReleaseBaseDir}\/Documentation\/rdoc\.zip$/,
                  :FileDst => "#{lRDocBaseDir}/rdoc-UnnamedVersion.zip" } ],
                [ 'SSH', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                  :Cmd => "unzip -o -d #{lRDocBaseDir} #{lRDocBaseDir}/rdoc-UnnamedVersion.zip ; mv #{lRDocBaseDir}/rdoc #{lRDocBaseDir}/UnnamedVersion ; rm #{lRDocBaseDir}/latest ; ln -s #{lRDocBaseDir}/UnnamedVersion #{lRDocBaseDir}/latest ; rm #{lRDocBaseDir}/rdoc-UnnamedVersion.zip" } ],
                [ 'SCP', { :Host => 'shell.sourceforge.net', :Login => 'login,unixname',
                  :FileSrc => /^.*\/#{lReleaseBaseDir}\/Installer\/MainLib\.rb\.Installer1$/,
                  :FileDst => "#{lFRSBaseDir}/MainLib.rb.Installer1" } ]
              ]) do |iReleaseDir, iReleaseInfo|
                checkReleaseInfo(iReleaseDir, iReleaseInfo)
                checkReleaseNotes(iReleaseDir, iReleaseInfo)
                checkRDoc(iReleaseDir, iReleaseInfo)
                assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
                assert(File.exists?("#{iReleaseDir}/Installer/MainLib.rb.Installer1"))
              end
            end

          end

        end

      end

    end

  end

end
