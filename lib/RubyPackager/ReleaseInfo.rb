#--
# Copyright (c) 2009 - 2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  # This class is the base class of all releases info to be provided by packages.
  class ReleaseInfo

    # Information about the author
    #   map< Symbol, Object >
    attr_reader :AuthorInfo

    # Information about the project
    #   map< Symbol, Object >
    attr_reader :ProjectInfo

    # Information about the executables
    #   list< map< Symbol, Object > >
    attr_reader :ExecutablesInfo

    # Information about the installer
    #   map< Symbol, Object >
    attr_reader :InstallInfo

    # Information about SourceForge
    #   map< Symbol, Object >
    attr_reader :SFInfo

    # Information about RubyForge
    #   map< Symbol, Object >
    attr_reader :RFInfo

    # Information about the Gem
    #   map< Symbol, Object >
    attr_reader :GemInfo

    # List of core files patterns
    #   list< String >
    attr_reader :CoreFiles

    # List of additional files patterns
    #   list< String >
    attr_reader :AdditionalFiles

    # List of test files patterns
    #   list< String >
    attr_reader :TestFiles

    # Constructor
    def initialize
      # This sets also default values
      @AuthorInfo = {}
      @ProjectInfo = {}
      @ExecutablesInfo = []
      @InstallInfo = {}
      @SFInfo = {}
      @RFInfo = {}
      @GemInfo = {}
      # Files patterns list
      @CoreFiles = []
      @AdditionalFiles = []
      @TestFiles = []
    end

    # Add Author properties
    #
    # Parameters:
    # * *iParams* (<em>map<Symbol,Object></em>): The parameters:
    # ** *:Name* (_String_): The author name
    # ** *:EMail* (_String_): The author's email
    # ** *:WebPageURL* (_String_): The author's web page
    # Return:
    # * _ReleaseInfo_: self
    def author(iParams)
      @AuthorInfo.merge!(iParams)

      return self
    end

    # Add Project properties
    #
    # Parameters:
    # * *iParams* (<em>map<Symbol,Object></em>): The parameters:
    # ** *:Name* (_String_): Project name
    # ** *:WebPageURL* (_String_): Project home page
    # ** *:Summary* (_String_): Project Summary
    # ** *:Description* (_String_): Project description
    # ** *:ImageURL* (_String_): URL of the project's image
    # ** *:FaviconURL* (_String_): URL of the project's favicon
    # ** *:SVNBrowseURL* (_String_): URL of the SVN browse
    # ** *:DevStatus* (_String_): Development status
    # Return:
    # * _ReleaseInfo_: self
    def project(iParams)
      @ProjectInfo.merge!(iParams)

      return self
    end

    # Add executable package properties.
    # This method can be called several times to specify several executables.
    #
    # Parameters:
    # * *iParams* (<em>map<Symbol,Object></em>): The parameters:
    # ** *:StartupRBFile* (_String_): Name of RB file to execute as startup file.
    # ** *:ExeName* (_String_): Name of executable file to produce.
    # ** *:IconName* (_String_): Name of the executable icon.
    # ** *:TerminalApplication* (_Boolean_): Does this binary execute in a terminal ?
    # Return:
    # * _ReleaseInfo_: self
    def executable(iParams)
      @ExecutablesInfo << iParams

      return self
    end

    # Add installer properties
    #
    # Parameters:
    # * *iParams* (<em>map<Symbol,Object></em>): The parameters:
    # ** *:NSISFileName* (_String_): Name of the NSI file to use to generate the installer
    # ** *:InstallerName* (_String_): Name of the generated installer
    # Return:
    # * _ReleaseInfo_: self
    def install(iParams)
      @InstallInfo.merge!(iParams)

      return self
    end

    # Add SF.NET properties
    #
    # Parameters:
    # * *iParams* (<em>map<Symbol,Object></em>): The parameters:
    # ** *:Login* (_String_): The releaser's SF.NET login
    # ** *:ProjectUnixName* (_String_): Unix name of the SF project
    # Return:
    # * _ReleaseInfo_: self
    def sourceForge(iParams)
      @SFInfo.merge!(iParams)

      return self
    end

    # Add RubyForge properties
    #
    # Parameters:
    # * *iParams* (<em>map<Symbol,Object></em>): The parameters:
    # ** *:Login* (_String_): The releaser's RubyForge login
    # ** *:ProjectUnixName* (_String_): Unix name of the RubyForge project
    # Return:
    # * _ReleaseInfo_: self
    def rubyForge(iParams)
      @RFInfo.merge!(iParams)

      return self
    end

    # Add Gem properties
    #
    # Parameters:
    # * *iParams* (<em>map<Symbol,Object></em>): The parameters:
    # ** *:GemName* (_String_): The Gem name
    # ** *:GemPlatformClassName* (_String_): The name of the Gem platform class
    # ** *:RequirePath* (_String_): Single path to require
    # ** *:RequirePaths* (<em>list<String></em>): Paths to require
    # ** *:HasRDoc* (_String_): Include RDoc in the Gem ?
    # ** *:ExtraRDocFiles* (<em>list<String></em>): List of file patterns to be included in the RDoc but not in the Gem
    # ** *:TestFile* (_String_): Name of the test file to execute
    # ** *:GemDependencies* (<em>list<[String,String]></em>): List of [ Gem, Version criteria ] this Gem depends on
    # Return:
    # * _ReleaseInfo_: self
    def gem(iParams)
      @GemInfo.merge!(iParams)

      return self
    end

    # Add core files patterns
    #
    # Parameters:
    # * *iFilesPatternsList* (<em>list<String></em>): The list of files patterns to add
    # Return:
    # * _ReleaseInfo_: self
    def addCoreFiles(iFilesPatternsList)
      @CoreFiles.concat(iFilesPatternsList)

      return self
    end

    # Add additional files patterns
    #
    # Parameters:
    # * *iFilesPatternsList* (<em>list<String></em>): The list of files patterns to add
    # Return:
    # * _ReleaseInfo_: self
    def addAdditionalFiles(iFilesPatternsList)
      @AdditionalFiles.concat(iFilesPatternsList)

      return self
    end

    # Add test files patterns
    #
    # Parameters:
    # * *iFilesPatternsList* (<em>list<String></em>): The list of files patterns to add
    # Return:
    # * _ReleaseInfo_: self
    def addTestFiles(iFilesPatternsList)
      @TestFiles.concat(iFilesPatternsList)

      return self
    end

  end

end
