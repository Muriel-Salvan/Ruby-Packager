#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  # This class is the base class of all releases info to be provided by packages.
  class ReleaseInfo

    # Information about the author
    #   map< Symbol, Object >
    attr_reader :author_info

    # Information about the project
    #   map< Symbol, Object >
    attr_reader :project_info

    # Information about the executables
    #   list< map< Symbol, Object > >
    attr_reader :executables_info

    # Information about the installer
    #   map< Symbol, Object >
    attr_reader :install_info

    # Information about SourceForge
    #   map< Symbol, Object >
    attr_reader :sf_info

    # Information about RubyForge
    #   map< Symbol, Object >
    attr_reader :rf_info

    # Information about the Gem
    #   map< Symbol, Object >
    attr_reader :gem_info

    # List of core files patterns
    #   list< String >
    attr_reader :core_files

    # List of additional files patterns
    #   list< String >
    attr_reader :additional_files

    # List of test files patterns
    #   list< String >
    attr_reader :test_files

    # Constructor
    def initialize
      # This sets also default values
      @author_info = {}
      @project_info = {}
      @executables_info = []
      @install_info = {}
      @sf_info = {}
      @rf_info = {}
      @gem_info = {}
      # Files patterns list
      @core_files = []
      @additional_files = []
      @test_files = []
    end

    # Add Author properties
    #
    # Parameters::
    # * *iParams* (<em>map<Symbol,Object></em>): The parameters:
    #   * *:name* (_String_): The author name
    #   * *:email* (_String_): The author's email
    #   * *:web_page_url* (_String_): The author's web page
    # Return::
    # * _ReleaseInfo_: self
    def author(iParams)
      @author_info.merge!(iParams)

      return self
    end

    # Add Project properties
    #
    # Parameters::
    # * *iParams* (<em>map<Symbol,Object></em>): The parameters:
    #   * *:name* (_String_): Project name
    #   * *:web_page_url* (_String_): Project home page
    #   * *:summary* (_String_): Project Summary
    #   * *:description* (_String_): Project description
    #   * *:image_url* (_String_): URL of the project's image
    #   * *:favicon_url* (_String_): URL of the project's favicon
    #   * *:browse_source_url* (_String_): URL to browse the source code
    #   * *:dev_status* (_String_): Development status
    # Return::
    # * _ReleaseInfo_: self
    def project(iParams)
      @project_info.merge!(iParams)

      return self
    end

    # Add executable package properties.
    # This method can be called several times to specify several executables.
    #
    # Parameters::
    # * *iParams* (<em>map<Symbol,Object></em>): The parameters:
    #   * *:startup_rb_file* (_String_): Name of RB file to execute as startup file.
    #   * *:exe_name* (_String_): Name of executable file to produce.
    #   * *:icon_name* (_String_): Name of the executable icon.
    #   * *:terminal_application* (_Boolean_): Does this binary execute in a terminal ?
    # Return::
    # * _ReleaseInfo_: self
    def executable(iParams)
      @executables_info << iParams

      return self
    end

    # Add installer properties
    #
    # Parameters::
    # * *iParams* (<em>map<Symbol,Object></em>): The parameters:
    #   * *:nsis_file_name* (_String_): Name of the NSI file to use to generate the installer
    #   * *:installer_name* (_String_): Name of the generated installer
    # Return::
    # * _ReleaseInfo_: self
    def install(iParams)
      @install_info.merge!(iParams)

      return self
    end

    # Add SF.NET properties
    #
    # Parameters::
    # * *iParams* (<em>map<Symbol,Object></em>): The parameters:
    #   * *:login* (_String_): The releaser's SF.NET login
    #   * *:project_unix_name* (_String_): Unix name of the SF project
    #   * *:ask_for_password* (_Boolean_): Do we ask for the user password to give to SSH ?
    #   * *:ask_for_key_passphrase* (_Boolean_): Do we ask for the key passphrase to give to SSH ?
    # Return::
    # * _ReleaseInfo_: self
    def source_forge(iParams)
      @sf_info.merge!(iParams)

      return self
    end

    # Add RubyForge properties
    #
    # Parameters::
    # * *iParams* (<em>map<Symbol,Object></em>): The parameters:
    #   * *:login* (_String_): The releaser's RubyForge login
    #   * *:project_unix_name* (_String_): Unix name of the RubyForge project
    # Return::
    # * _ReleaseInfo_: self
    def ruby_forge(iParams)
      @rf_info.merge!(iParams)

      return self
    end

    # Add Gem properties
    #
    # Parameters::
    # * *iParams* (<em>map<Symbol,Object></em>): The parameters:
    #   * *:gem_name* (_String_): The Gem name
    #   * *:gem_platform_class_name* (_String_): The name of the Gem platform class
    #   * *:require_path* (_String_): Single path to require
    #   * *:require_paths* (<em>list<String></em>): Paths to require
    #   * *:has_rdoc* (_String_): Include RDoc in the Gem ?
    #   * *:extra_rdoc_files* (<em>list<String></em>): List of file patterns to be included in the RDoc but not in the Gem
    #   * *:test_file* (_String_): Name of the test file to execute
    #   * *:gem_dependencies* (<em>list< [String,String] ></em>): List of [ Gem, Version criteria ] this Gem depends on
    #   * *:extensions* (<em>list<String></em>): List of paths to extconf.rb files to include as native C extensions
    # Return::
    # * _ReleaseInfo_: self
    def gem(iParams)
      @gem_info.merge!(iParams)

      return self
    end

    # Add core files patterns
    #
    # Parameters::
    # * *iFilesPatternsList* (<em>list<String></em>): The list of files patterns to add
    # Return::
    # * _ReleaseInfo_: self
    def add_core_files(iFilesPatternsList)
      @core_files.concat(iFilesPatternsList)

      return self
    end

    # Add additional files patterns
    #
    # Parameters::
    # * *iFilesPatternsList* (<em>list<String></em>): The list of files patterns to add
    # Return::
    # * _ReleaseInfo_: self
    def add_additional_files(iFilesPatternsList)
      @additional_files.concat(iFilesPatternsList)

      return self
    end

    # Add test files patterns
    #
    # Parameters::
    # * *iFilesPatternsList* (<em>list<String></em>): The list of files patterns to add
    # Return::
    # * _ReleaseInfo_: self
    def add_test_files(iFilesPatternsList)
      @test_files.concat(iFilesPatternsList)

      return self
    end

  end

end
