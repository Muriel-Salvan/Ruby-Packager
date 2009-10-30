#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  module Test

    module PlatformIndependent

      class CommandLine < ::Test::Unit::TestCase

        include RubyPackager::Test::Common

        # Test release a specific version
        def testVersion
          execTest('Libraries/Basic', [ '-v', '0.0.1.20091030' ], 'ReleaseInfo.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo, :Version => '0.0.1.20091030')
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
          end
        end

        # Test release a specific version (long version)
        def testVersionLong
          execTest('Libraries/Basic', [ '--version=0.0.1.20091030' ], 'ReleaseInfo.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo, :Version => '0.0.1.20091030')
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
          end
        end

        # Test release with Tags
        def testTags
          execTest('Libraries/Basic', [ '-t', 'Tag1', '-t', 'Tag2' ], 'ReleaseInfo.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo, :Tags => ['Tag1', 'Tag2'] )
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
          end
        end

        # Test release with Tags (long version)
        def testTagsLong
          execTest('Libraries/Basic', [ '--tag=Tag1', '--tag=Tag2' ], 'ReleaseInfo.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo, :Tags => ['Tag1', 'Tag2'] )
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
          end
        end

        # Test release with Comments
        def testComment
          execTest('Libraries/Basic', [ '-c', 'Comment' ], 'ReleaseInfo.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
          end
        end

        # Test release with Comments (long version)
        def testCommentLong
          execTest('Libraries/Basic', [ '--comment=Comment' ], 'ReleaseInfo.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
          end
        end

        # Test release with Test files
        def testTest
          execTest('Libraries/Basic', [ '-n' ], 'ReleaseInfo_Test.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
            assert(File.exists?("#{iReleaseDir}/Release/Test.rb"))
          end
        end

        # Test release with Test files (long version)
        def testTestLong
          execTest('Libraries/Basic', [ '--includeTest' ], 'ReleaseInfo_Test.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
            assert(File.exists?("#{iReleaseDir}/Release/Test.rb"))
          end
        end

        # Test release with Installers
        def testInstallers
          execTest('Libraries/Basic', [ '-i', 'DummyInstaller1', '-i', 'DummyInstaller2' ], 'ReleaseInfo.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
            assert(File.exists?("#{iReleaseDir}/Installer/MainLib.rb.Installer1"))
            assert(File.exists?("#{iReleaseDir}/Installer/MainLib.rb.Installer2"))
          end
        end

        # Test release with Installers (long version)
        def testInstallersLong
          execTest('Libraries/Basic', [ '--installer=DummyInstaller1', '--installer=DummyInstaller2' ], 'ReleaseInfo.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
            assert(File.exists?("#{iReleaseDir}/Installer/MainLib.rb.Installer1"))
            assert(File.exists?("#{iReleaseDir}/Installer/MainLib.rb.Installer2"))
          end
        end

        # Test release with Distributors
        def testDistributors
          execTest('Libraries/Basic', [ '-i', 'DummyInstaller1', '-i', 'DummyInstaller2', '-d', 'DummyDistributor1', '-d', 'DummyDistributor2' ], 'ReleaseInfo.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
            assert(File.exists?("#{iReleaseDir}/Installer/MainLib.rb.Installer1"))
            assert(File.exists?("#{iReleaseDir}/Installer/MainLib.rb.Installer2"))
            assert($Distributed1 != nil)
            assert_equal(2, $Distributed1.size)
            assert($Distributed1.has_key?('MainLib.rb.Installer1'))
            assert($Distributed1.has_key?('MainLib.rb.Installer2'))
            assert($Distributed2 != nil)
            assert_equal(2, $Distributed2.size)
            assert($Distributed2.has_key?('MainLib.rb.Installer1'))
            assert($Distributed2.has_key?('MainLib.rb.Installer2'))
          end
        end

        # Test release with Distributors (long version)
        def testDistributorsLong
          execTest('Libraries/Basic', [ '-i', 'DummyInstaller1', '-i', 'DummyInstaller2', '--distributor=DummyDistributor1', '--distributor=DummyDistributor2' ], 'ReleaseInfo.rb') do |iReleaseDir, iReleaseInfo|
            checkReleaseInfo(iReleaseDir, iReleaseInfo)
            checkReleaseNotes(iReleaseDir, iReleaseInfo)
            assert(File.exists?("#{iReleaseDir}/Release/MainLib.rb"))
            assert(File.exists?("#{iReleaseDir}/Installer/MainLib.rb.Installer1"))
            assert(File.exists?("#{iReleaseDir}/Installer/MainLib.rb.Installer2"))
            assert($Distributed1 != nil)
            assert_equal(2, $Distributed1.size)
            assert($Distributed1.has_key?('MainLib.rb.Installer1'))
            assert($Distributed1.has_key?('MainLib.rb.Installer2'))
            assert($Distributed2 != nil)
            assert_equal(2, $Distributed2.size)
            assert($Distributed2.has_key?('MainLib.rb.Installer1'))
            assert($Distributed2.has_key?('MainLib.rb.Installer2'))
          end
        end

      end

    end

  end

end
