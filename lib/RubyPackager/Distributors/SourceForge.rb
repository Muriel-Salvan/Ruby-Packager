#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'RubyPackager/Tools'

module RubyPackager

  module Distributors

    class SourceForge
      
      include RubyPackager::Tools

      # Check that we can use this distributor
      #
      # Return::
      # * _Boolean_: Can we use this distributor ?
      def check_tools
        rSuccess = true

        begin
          require 'net/ssh'
        rescue Exception
          log_err 'Missing net/ssh library. gem install net-ssh.'
          rSuccess = false
        end
        begin
          require 'net/scp'
        rescue Exception
          log_err 'Missing net/scp library. gem install net-scp.'
          rSuccess = false
        end
        if (!system('zip -v'))
          log_err 'Missing zip command-line utility.'
          rSuccess = false
        end

        return rSuccess
      end

      # Distribute what has been generated
      #
      # Parameters::
      # * *iInstallerDir* (_String_): Directory where installers are generated
      # * *iReleaseVersion* (_String_): Release version
      # * *iReleaseInfo* (_ReleaseInfo_): Release info
      # * *iGeneratedFileNames* (<em>list<String></em>): List of files to distribute
      # * *iDocDir* (_String_): Directory where the documentation has been generated
      # Return::
      # * _Boolean_: Success ?
      def distribute(iInstallerDir, iReleaseVersion, iReleaseInfo, iGeneratedFileNames, iDocDir)
        rSuccess = true

        @InstallerDir, @ReleaseVersion, @ReleaseInfo, @GeneratedFileNames, @DocDir = iInstallerDir, iReleaseVersion, iReleaseInfo, iGeneratedFileNames, iDocDir
        @SFLogin = "#{@ReleaseInfo.SFInfo[:Login]},#{@ReleaseInfo.SFInfo[:ProjectUnixName]}"
        @SFReleaseDir = "/home/frs/project/#{@ReleaseInfo.SFInfo[:ProjectUnixName][0..0]}/#{@ReleaseInfo.SFInfo[:ProjectUnixName][0..1]}/#{@ReleaseInfo.SFInfo[:ProjectUnixName]}/#{@ReleaseVersion}"
        createSFShell
        createReleaseOnSFNET
        # It is possible that the RDoc has not been generated
        if (File.exists?("#{@DocDir}/rdoc"))
          uploadRDocOnSFNET
        end
        uploadFilesOnSFNET

        return rSuccess
      end

      private

      # Create a Shell for SF.NET
      def createSFShell
        sshWithPassword(
          'shell.sourceforge.net',
          @SFLogin,
          'create'
        )
      end

      # Shutdown a Shell for SF.NET
      def shutdownSFShell
        sshWithPassword(
          'shell.sourceforge.net',
          @SFLogin,
          'shutdown'
        )
      end

      # Upload the RDoc on SF.NET
      def uploadRDocOnSFNET
        log_debug 'Uploading RDoc on SF.NET ...'
        # Zip the RDoc
        change_dir(@DocDir) do
          system("zip -r rdoc.zip rdoc")
        end
        # Send it
        lRDocBaseDir = "/home/project-web/#{@ReleaseInfo.SFInfo[:ProjectUnixName]}/htdocs/rdoc"
        sshWithPassword(
          'shell.sourceforge.net',
          @SFLogin,
          "mkdir -p #{lRDocBaseDir}"
        )
        scpWithPassword(
          'shell.sourceforge.net',
          @SFLogin,
          "#{@DocDir}/rdoc.zip",
          "#{lRDocBaseDir}/rdoc-#{@ReleaseVersion}.zip"
        )
        # Execute its uncompress remotely
        sshWithPassword(
          'shell.sourceforge.net',
          @SFLogin,
          "unzip -o -d #{lRDocBaseDir} #{lRDocBaseDir}/rdoc-#{@ReleaseVersion}.zip ; mv #{lRDocBaseDir}/rdoc #{lRDocBaseDir}/#{@ReleaseVersion} ; rm #{lRDocBaseDir}/latest ; ln -s #{lRDocBaseDir}/#{@ReleaseVersion} #{lRDocBaseDir}/latest ; rm #{lRDocBaseDir}/rdoc-#{@ReleaseVersion}.zip"
        )
        # Remove temporary file
        File.unlink("#{@DocDir}/rdoc.zip")
      end

      # Create the release on SF.NET
      def createReleaseOnSFNET
        log_debug 'Creating Release on SF.NET ...'
        sshWithPassword(
          'shell.sourceforge.net',
          @SFLogin,
          "mkdir -p #{@SFReleaseDir}"
        )
      end

      # Upload the generated files on SF.NET
      def uploadFilesOnSFNET
        @GeneratedFileNames.each do |iFileName|
          log_debug "Uploading #{iFileName} on SF.NET ..."
          scpWithPassword(
            'shell.sourceforge.net',
            @SFLogin,
            "#{@InstallerDir}/#{iFileName}",
            "#{@SFReleaseDir}/#{iFileName}"
          )
        end
      end

    end

  end

end