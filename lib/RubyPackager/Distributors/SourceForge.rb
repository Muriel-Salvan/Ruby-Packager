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
        @SFLogin = "#{@ReleaseInfo.sf_info[:login]},#{@ReleaseInfo.sf_info[:project_unix_name]}"
        @SFReleaseDir = "/home/frs/project/#{@ReleaseInfo.sf_info[:project_unix_name][0..0]}/#{@ReleaseInfo.sf_info[:project_unix_name][0..1]}/#{@ReleaseInfo.sf_info[:project_unix_name]}/#{@ReleaseVersion}"
        set_ssh_options('shell.sourceforge.net', @SFLogin, @ReleaseInfo.sf_info)
        ssh('create')
        createReleaseOnSFNET
        # It is possible that the RDoc has not been generated
        if (File.exists?("#{@DocDir}/rdoc"))
          uploadRDocOnSFNET
        end
        uploadFilesOnSFNET

        return rSuccess
      end

      private

      # Upload the RDoc on SF.NET
      def uploadRDocOnSFNET
        log_debug 'Uploading RDoc on SF.NET ...'
        # Zip the RDoc
        change_dir(@DocDir) do
          system("zip -r rdoc.zip rdoc")
        end
        # Send it
        lRDocBaseDir = "/home/project-web/#{@ReleaseInfo.sf_info[:project_unix_name]}/htdocs/rdoc"
        ssh("mkdir -p #{lRDocBaseDir}")
        scp("#{@DocDir}/rdoc.zip", "#{lRDocBaseDir}/rdoc-#{@ReleaseVersion}.zip")
        # Execute its uncompress remotely
        ssh("unzip -o -d #{lRDocBaseDir} #{lRDocBaseDir}/rdoc-#{@ReleaseVersion}.zip ; mv #{lRDocBaseDir}/rdoc #{lRDocBaseDir}/#{@ReleaseVersion} ; rm #{lRDocBaseDir}/latest ; ln -s #{lRDocBaseDir}/#{@ReleaseVersion} #{lRDocBaseDir}/latest ; rm #{lRDocBaseDir}/rdoc-#{@ReleaseVersion}.zip")
        # Remove temporary file
        File.unlink("#{@DocDir}/rdoc.zip")
      end

      # Create the release on SF.NET
      def createReleaseOnSFNET
        log_debug 'Creating Release on SF.NET ...'
        ssh("mkdir -p #{@SFReleaseDir}")
      end

      # Upload the generated files on SF.NET
      def uploadFilesOnSFNET
        @GeneratedFileNames.each do |iFileName|
          log_debug "Uploading #{iFileName} on SF.NET ..."
          scp("#{@InstallerDir}/#{iFileName}", "#{@SFReleaseDir}/#{iFileName}")
        end
      end

    end

  end

end