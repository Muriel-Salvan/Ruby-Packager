#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

RubyPackager::ReleaseInfo.new.
  author(
    :name => 'Muriel Salvan',
    :email => 'muriel@x-aeon.com',
    :web_page_url => 'http://murielsalvan.users.sourceforge.net'
  ).
  project(
    :name => 'RubyPackager',
    :web_page_url => 'http://rubypackager.sourceforge.net/',
    :summary => 'Solution to release Ruby programs on any platform.',
    :description => 'Generate installable binary distributions of Ruby programs for many platforms (many OS, with or without Ruby installed on clients...). Fit to distribute extensible (plugins) Ruby programs also. Handles also libraries and uploads on websites (SF.net...).',
    :image_url => 'http://rubypackager.sourceforge.net/wiki/images/c/c9/Logo.png',
    :favicon_url => 'http://rubypackager.sourceforge.net/wiki/images/2/26/Favicon.png',
    :browse_source_url => 'http://github.com/Muriel-Salvan/Ruby-Packager',
    :dev_status => 'Beta'
  ).
  add_core_files( [
    '{lib,bin}/**/*'
  ] ).
  add_test_files( [
    'test/**/*'
  ] ).
  add_additional_files( [
    'README',
    'LICENSE',
    'AUTHORS',
    'Credits',
    'ChangeLog'
  ] ).
  gem(
    :gem_name => 'RubyPackager',
    :gem_platform_class_name => 'Gem::Platform::RUBY',
    :require_path => 'lib',
    :has_rdoc => true,
    :test_file => 'test/run.rb',
    :gem_dependencies => [
      [ 'rUtilAnts', '>= 1.0' ],
      'allinoneruby',
      'highline',
      'net-ssh',
      'net-scp',
      'rdoc'
    ]
  ).
  source_forge(
    :login => 'murielsalvan',
    :project_unix_name => 'rubypackager',
    :ask_for_key_passphrase => true
  ).
  ruby_forge(
    :project_unix_name => 'rubypackager'
  ).
  executable(
    :startup_rb_file => 'bin/Release.rb'
  )

