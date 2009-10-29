#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

RubyPackager::ReleaseInfo.new.
  author(
    :Name => 'Muriel Salvan',
    :EMail => 'murielsalvan@users.sourceforge.net',
    :WebPageURL => 'http://murielsalvan.users.sourceforge.net'
  ).
  project(
    :Name => 'RubyPackager',
    :WebPageURL => 'http://rubypackager.sourceforge.net/',
    :Summary => 'Solution to release Ruby programs on any platform.',
    :Description => 'Generate installable binary distributions of Ruby programs for many platforms (many OS, with or without Ruby installed on clients...). Fit to distribute extensible (plugins) Ruby programs also. Handles also libraries and uploads on websites (SF.net...).',
    :ImageURL => 'http://rubypackager.sourceforge.net/wiki/images/c/c9/Logo.png',
    :FaviconURL => 'http://rubypackager.sourceforge.net/wiki/images/2/26/Favicon.png',
    :SVNBrowseURL => 'http://rubypackager.svn.sourceforge.net/viewvc/rubypackager/',
    :DevStatus => 'Alpha'
  ).
  addCoreFiles( [
    '{lib,bin}/**/*'
  ] ).
  addTestFiles( [
    'test/**/*'
  ] ).
  addAdditionalFiles( [
    'README',
    'LICENSE',
    'AUTHORS',
    'Credits',
    'TODO',
    'ChangeLog'
  ] ).
  gem(
    :GemName => 'RubyPackager',
    :GemPlatformClassName => 'Gem::Platform::RUBY',
    :RequirePath => 'lib',
    :HasRDoc => true,
    :TestFile => 'test/run.rb',
    :GemDependencies => [
      [ 'rUtilAnts', '>= 0.1' ]
    ]
  ).
  sourceForge(
    :Login => 'murielsalvan',
    :ProjectUnixName => 'rubypackager'
  ).
  rubyForge(
    :ProjectUnixName => 'rubypackager'
  ).
  executable(
    :StartupRBFile => 'bin/Release.rb'
  )

