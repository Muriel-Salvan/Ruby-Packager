#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'RubyPackager/Tools'

module RubyPackager

  module Distributors

    class SourceForge
      
      include RubyPackager::Tools

      # Check that we can use this distributor
      #
      # Return:
      # * _Boolean_: Can we use this distributor ?
      def checkTools
        rSuccess = true

        begin
          require 'net/ssh'
        rescue Exception
          puts '!!! Missing net/ssh library. gem install net-ssh.'
          rSuccess = false
        end
        begin
          require 'net/scp'
        rescue Exception
          puts '!!! Missing net/scp library. gem install net-scp.'
          rSuccess = false
        end
        if (!system('zip -v'))
          puts '!!! Missing zip command-line utility.'
          rSuccess = false
        end

        return rSuccess
      end

      # Distribute what has been generated
      #
      # Parameters:
      # * *iInstallerDir* (_String_): Directory where installers are generated
      # * *iReleaseVersion* (_String_): Release version
      # * *iReleaseInfo* (_ReleaseInfo_): Release info
      # * *iGeneratedFileNames* (<em>list<String></em>): List of files to distribute
      # * *iDocDir* (_String_): Directory where the documentation has been generated
      # Return:
      # * _Boolean_: Success ?
      def distribute(iInstallerDir, iReleaseVersion, iReleaseInfo, iGeneratedFileNames, iDocDir)
        rSuccess = true

        @InstallerDir, @ReleaseVersion, @ReleaseInfo, @GeneratedFileNames, @DocDir = iInstallerDir, iReleaseVersion, iReleaseInfo, iGeneratedFileNames, iDocDir
        @SFProjectSubPath = "#{@ReleaseInfo.SFInfo[:ProjectUnixName][0..0]}/#{@ReleaseInfo.SFInfo[:ProjectUnixName][0..1]}/#{@ReleaseInfo.SFInfo[:ProjectUnixName]}"
        @SFLogin = "#{@ReleaseInfo.SFInfo[:Login]},#{@ReleaseInfo.SFInfo[:ProjectUnixName]}"
        @SFReleaseDir = "/home/frs/project/#{@SFProjectSubPath}/#{@ReleaseVersion}"
        createSFShell
        createReleaseOnSFNET
        uploadRDocOnSFNET
        uploadReleaseNoteOnSFNET
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
        puts 'Uploading RDoc on SF.NET ...'
        # Zip the RDoc
        lOldDir = Dir.getwd
        Dir.chdir(@DocDir)
        system("zip -r rdoc.zip rdoc")
        Dir.chdir(lOldDir)
        # Send it
        lRDocBaseDir = "/home/groups/#{@SFProjectSubPath}/htdocs/rdoc"
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
        puts 'Creating Release on SF.NET ...'
        sshWithPassword(
          'shell.sourceforge.net',
          @SFLogin,
          "mkdir -p #{@SFReleaseDir}"
        )
      end

      # Upload the generated files on SF.NET
      def uploadFilesOnSFNET
        @GeneratedFileNames.each do |iFileName|
          puts "Uploading #{iFileName} on SF.NET ..."
          scpWithPassword(
            'shell.sourceforge.net',
            @SFLogin,
            "#{@InstallerDir}/#{iFileName}",
            "#{@SFReleaseDir}/#{iFileName}"
          )
        end
      end

      # Upload the Release note on SF.NET
      def uploadReleaseNoteOnSFNET
        puts 'Uploading Release Note on SF.NET ...'
        scpWithPassword(
          'shell.sourceforge.net',
          @SFLogin,
          "#{@DocDir}/ReleaseNote.html",
          "#{@SFReleaseDir}/ReleaseNote.html"
        )
        puts '!!! DON\'T FORGET to make association between ReleaseNote and Gem in SF.NET'
      end

    end

  end

end