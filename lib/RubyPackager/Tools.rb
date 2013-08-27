module RubyPackager

  module Tools

    # Set options that will be used by SSH calls
    #
    # Parameters::
    # * *iSSHHost* (_String_): The SSH host
    # * *iSSHLogin* (_String_): The SSH login
    # * *iOptions* (<em>map<Symbol,Object></em>): Additional options [optional = {}]:
    #   * *:ask_for_password* (_Boolean_): Do we ask for the user password to give to SSH ?
    #   * *:ask_for_key_passphrase* (_Boolean_): Do we ask for the key passphrase to give to SSH ?
    def set_ssh_options(iSSHHost, iSSHLogin, iOptions = {})
      @SSHHost, @SSHLogin, @SSHOptions = iSSHHost, iSSHLogin, iOptions
    end

    # Execute some SSH command on a remote host protected with password
    #
    # Parameters::
    # * *iCmd* (_String_): The command to execute
    def ssh(iCmd)
      require 'net/ssh'
      Net::SSH.start(
        @SSHHost,
        @SSHLogin,
        get_net_ssh_options
      ) do |iSSH|
        puts(iSSH.exec!(iCmd))
      end
    end

    # Copy files through SCP.
    #
    # Parameters::
    # * *iFileSrc* (_String_): Path to local file to copy from
    # * *iFileDst* (_String_): Path to remote file to copy to
    def scp(iFileSrc, iFileDst)
      require 'net/scp'
      Net::SCP.start(
        @SSHHost,
        @SSHLogin,
        get_net_ssh_options
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
    # * *iLogin* (_String_): String for which we want the password
    # Return::
    # * _String_: Password
    def get_password(iLogin)
      if (@@Passwords[iLogin] == nil)
        # Ask for it
        require 'highline/import'
        @@Passwords[iLogin] = ask("Enter password for #{iLogin}:") do |ioQuestion|
          ioQuestion.echo = false
        end
      end

      return @@Passwords[iLogin]
    end

    # Get the real SSH options that will be given to the Net::SSH library
    # These are based on the way SSH options are set by set_ssh_options
    #
    # Return::
    # * <em>map<Symbol,Object></em>: The Net::SSH options
    def get_net_ssh_options
      rOptions = {}

      if (@SSHOptions[:ask_for_password])
        rOptions[:password] = get_password("login #{@SSHLogin}")
      end
      if (@SSHOptions[:ask_for_key_passphrase])
        rOptions[:passphrase] = get_password("key passphrase of #{@SSHLogin}")
      end

      return rOptions
    end

  end

end
