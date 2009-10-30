#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  module Installers

    class NSIS

      # Check that we can use this installer
      #
      # Return:
      # * _Boolean_: Can we use this installer ?
      def checkTools
        rSuccess = true

        # Check that makensis is present
        if (!system('makensis /VERSION'))
          puts "!!! Need to have MakeNSIS installed in the system PATH to create installer."
          puts "!!! Please download and install MakeNSIS in the PATH from http://nsis.sourceforge.net/Main_Page"
          rSuccess = false
        end

        return rSuccess
      end

      # Create the installer with everything in the release directory.
      #
      # Parameters:
      # * *iRootDir* (_String_): The Root directory
      # * *iReleaseDir* (_String_): The release directory (all files to put in the installer are there)
      # * *iInstallerDir* (_String_): The directory where the installer has to be put
      # * *iVersion* (_String_): Release version
      # * *iReleaseInfo* (_ReleaseInfo_): Release info
      # Return:
      # * _String_: File name to distribute, or nil in case of failure
      def createInstaller(iRootDir, iReleaseDir, iInstallerDir, iVersion, iReleaseInfo)
        rFileName = nil

        if (iReleaseInfo.InstallInfo[:NSISFileName] == nil)
          puts '!!! No NSISFileName specified among the Install description.'
        else
          lNSISOK = system("makensis /DVERSION=#{iVersion} \"/DRELEASEDIR=#{iReleaseDir.gsub(/\//,'\\')}\" \"#{iRootDir.gsub(/\//,'\\')}\\#{iReleaseInfo.InstallInfo[:NSISFileName].gsub(/\//,'\\')}\"")
          if (lNSISOK)
            lInstallerDir = File.dirname("#{iRootDir}/#{iReleaseInfo.InstallInfo[:NSISFileName]}")
            rFileName = "#{iReleaseInfo.InstallInfo[:InstallerName]}_#{iVersion}_setup.exe"
            FileUtils.mv("#{lInstallerDir}/setup.exe", "#{iInstallerDir}/#{rFileName}")
          end
        end

        return rFileName
      end

    end

  end

end