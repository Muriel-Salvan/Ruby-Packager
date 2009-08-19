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
    def run
      # Parse command line arguments
      lSuccess = true
      begin
        lRemainingArgs = @OptionsParser.parse(ARGV)
        if (lRemainingArgs.size != 1)
          puts 'Wrong release file. Please specify 1 release file.'
          puts @OptionsParser
          lSuccess = false
        else
          lReleaseFile = lRemainingArgs[0]
          require lReleaseFile
          if (!defined?($ReleaseInfo))
            puts "Release file #{lReleaseFile} is incorrect. It does not define $ReleaseInfo variable. Please correct it and try again."
            lSuccess = false
          end
        end
      rescue Exception
        puts "Error while parsing arguments: #{$!}"
        puts @OptionsParser
        lSuccess = false
      end
      if (lSuccess)
        lSuccess = Releaser.new.execute($ReleaseInfo, Dir.getwd, "#{Dir.getwd}/Releases", ReleaseInfo.new, @IncludeRuby)
        if (lSuccess)
          puts 'Release successful.'
        else
          puts 'Error while releasing.'
        end
      end
    end

  end

end

# Execute everything
if ($0 == __FILE__)
  RubyPackager::Launcher.new.run
end
