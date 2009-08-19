#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  module Test

    # Execute a test
    #
    # Parameters:
    # * *iApplicationName* (_String_): Name of the application for the test
    # * *iReleaseInfoName* (_String_): Name of release info file
    # * *iIncludeRuby* (_Boolean_): Do we include Ruby in the release ?
    def execTest(iApplicationName, iReleaseInfoName, iIncludeRuby)
      # Go to the application directory
      lOldDir = Dir.getwd
      lAppDir = "#{File.dirname(__FILE__)}/Applications/#{iApplicationName}"
      Dir.chdir(lAppDir)
      # Launch everything
      lArgs = []
      if (iIncludeRuby)
        lArgs << '-r'
      end
      lArgs << "Distribution/#{iReleaseInfoName}"
      lSuccess = RubyPackager::Launcher.new.run(lArgs)
      Dir.chdir(lOldDir)
      # Check if everything is ok
      assert(lSuccess)
    end

  end

end
