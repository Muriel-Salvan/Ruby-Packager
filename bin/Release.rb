#!env ruby
#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

# Release a distribution of a Ruby program.
# This produces an installable executable that will install a set of files and directories:
# * A binary, including some core Ruby and program files (eventually the whole Ruby distribution if needed - that is if the program is meant to be run on platforms not providing Ruby)
# * A list of files/directories

require 'RubyPackager/Releaser.rb'

module RubyPackager

  # Class giving command line options for the releaser
  class Launcher

    # The options parser
    #   OptionsParser
    attr_reader :OptionsParser

    # Constructor
    def initialize
      # Variables set by the parser
      @IncludeRuby = false

      # The parser
      @OptionsParser = OptionParser.new
      @OptionsParser.banner = 'Release.rb [-r|--ruby] <ReleaseFile>'
      @OptionsParser.on('-r', '--ruby',
        'Include Ruby distribution in the release.') do
        @IncludeRuby = true
      end
    end

    # Run the releaser
    #
    # Parameters:
    # * *iParameters* (<em>list<String></em>): List of arguments, as in command-line
    # Return:
    # * _Boolean_: Success ?
    def run(iParameters)
      rSuccess = true

      begin
        # Parse command line arguments
        lRemainingArgs = @OptionsParser.parse(iParameters)
        if (lRemainingArgs.size != 1)
          puts 'Wrong release file. Please specify 1 release file.'
          puts @OptionsParser
          rSuccess = false
        else
          lReleaseFile = lRemainingArgs[0]
          require lReleaseFile
          if (!defined?($ReleaseInfo))
            puts "Release file #{lReleaseFile} is incorrect. It does not define $ReleaseInfo variable. Please correct it and try again."
            rSuccess = false
          end
        end
      rescue Exception
        puts "Error while parsing arguments: #{$!}"
        puts @OptionsParser
        rSuccess = false
      end
      if (rSuccess)
        rSuccess = Releaser.new.execute($ReleaseInfo, Dir.getwd, "#{Dir.getwd}/Releases", PlatformReleaser.new, @IncludeRuby)
        if (rSuccess)
          puts 'Release successful.'
        else
          puts 'Error while releasing.'
        end
      end

      return rSuccess
    end

  end

end

# Execute everything (take care that paths might differ in bin directories gems)
if (File.basename($0) == File.basename(__FILE__))
  lSuccess = RubyPackager::Launcher.new.run(ARGV)
  if (lSuccess)
    exit 0
  else
    exit 1
  end
end
