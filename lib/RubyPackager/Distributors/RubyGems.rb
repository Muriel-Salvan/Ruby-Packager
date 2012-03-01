#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'RubyPackager/Tools'

module RubyPackager

  module Distributors

    class RubyGems
      
      include RubyPackager::Tools

      # Check that we can use this distributor
      #
      # Return::
      # * _Boolean_: Can we use this distributor ?
      def check_tools
        rSuccess = true

        begin
          rSuccess = system('gem push --help')
        rescue Exception
          log_err "Error while testing \"gem push\": #{$!}. Please update your RubyGems library."
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

        # Take only the Gem files
        iGeneratedFileNames.each do |iFileName|
          if (iFileName[-4..-1].upcase == '.GEM')
            change_dir(iInstallerDir) do
              if ((!system("gem push #{iFileName}")) or
                  (($? != nil) and
                   ($? != 0)))
                rSuccess = false
                log_err "Error while pushing #{iFileName}: #{$?}."
              end
            end
          end
        end

        return rSuccess
      end

    end

  end

end