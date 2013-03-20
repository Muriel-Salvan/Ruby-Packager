#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  module Installers

    class NSIS

      # Check that we can use this installer
      #
      # Return::
      # * _Boolean_: Can we use this installer ?
      def check_tools
        rSuccess = true

        # Check that makensis is present
        if (!system('makensis /VERSION'))
          log_err "Need to have MakeNSIS installed in the system PATH to create installer.\nPlease download and install MakeNSIS in the PATH from http://nsis.sourceforge.net/Main_Page"
          rSuccess = false
        end

        return rSuccess
      end

      # Create the installer with everything in the release directory.
      #
      # Parameters::
      # * *iRootDir* (_String_): The Root directory
      # * *iReleaseDir* (_String_): The release directory (all files to put in the installer are there)
      # * *iInstallerDir* (_String_): The directory where the installer has to be put
      # * *iVersion* (_String_): Release version
      # * *iReleaseInfo* (_ReleaseInfo_): Release info
      # * *iIncludeTest* (_Boolean_): Are test files part of the release ?
      # Return::
      # * _String_: File name to distribute, or nil in case of failure
      def create_installer(iRootDir, iReleaseDir, iInstallerDir, iVersion, iReleaseInfo, iIncludeTest)
        rFileName = nil

        if (iReleaseInfo.install_info[:nsis_file_name] == nil)
          log_err 'No NSISFileName specified among the Install description.'
        else
          lNSISOK = system("makensis /DVERSION=#{iVersion} \"/DRELEASEDIR=#{iReleaseDir.gsub(/\//,'\\')}\" \"#{iRootDir.gsub(/\//,'\\')}\\#{iReleaseInfo.install_info[:nsis_file_name].gsub(/\//,'\\')}\"")
          if (lNSISOK)
            lInstallerDir = File.dirname("#{iRootDir}/#{iReleaseInfo.install_info[:nsis_file_name]}")
            rFileName = "#{iReleaseInfo.install_info[:installer_name]}_#{iVersion}_setup.exe"
            FileUtils.mv("#{lInstallerDir}/setup.exe", "#{iInstallerDir}/#{rFileName}")
          end
        end

        return rFileName
      end

    end

  end

end
