#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  module Tools

    # Execute some SSH command on a remote host protected with password
    #
    # Parameters::
    # * *iSSHHost* (_String_): The SSH host
    # * *iSSHLogin* (_String_): The SSH login
    # * *iCmd* (_String_): The command to execute
    def ssh_with_password(iSSHHost, iSSHLogin, iCmd)
      require 'net/ssh'
      Net::SSH.start(
        iSSHHost,
        iSSHLogin,
        :password => get_password(iSSHLogin)
      ) do |iSSH|
        puts(iSSH.exec!(iCmd))
      end
    end

    # Copy files through SCP.
    #
    # Parameters::
    # * *iSCPHost* (_String_): Host
    # * *iSCPLogin* (_String_): Login
    # * *iFileSrc* (_String_): Path to local file to copy from
    # * *iFileDst* (_String_): Path to remote file to copy to
    def scp_with_password(iSCPHost, iSCPLogin, iFileSrc, iFileDst)
      require 'net/scp'
      Net::SCP.start(
        iSCPHost,
        iSCPLogin,
        :password => get_password(iSCPLogin)
      ) do |iSCP|
        iSCP.upload!(iFileSrc, iFileDst) do |iChunk, iName, iSent, iTotal|
          printf "#{iName}: #{iSent}/#{iTotal}\015"
          $stdout.flush
        end
        puts ''
      end
    end

    private

    # The map of stored passwords, per login
    @@Passwords = {}

    # Get a needed password.
    # Ask it from the user if we don't know it
    #
    # Parameters::
    # * *iLogin* (_String_): Login for which we want the password
    # Return::
    # * _String_: Password
    def get_password(iLogin)
      if (@@Passwords[iLogin] == nil)
        # Ask for it
        require 'highline/import'
        @@Passwords[iLogin] = ask("Enter password for login #{iLogin}:") do |ioQuestion|
          ioQuestion.echo = false
        end
      end

      return @@Passwords[iLogin]
    end

  end

end