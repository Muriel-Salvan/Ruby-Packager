#--
# Copyright (c) 2009 - 2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

RubyPackager::ReleaseInfo.new.
  author(
    :Name => 'Author:Name',
    :EMail => 'Author:EMail',
    :WebPageURL => 'Author:WebPageURL'
  ).
  project(
    :Name => 'Project:Name',
    :WebPageURL => 'Project:WebPageURL',
    :Summary => 'Project:Summary',
    :Description => 'Project:Description',
    :ImageURL => 'Project:ImageURL',
    :FaviconURL => 'Project:FaviconURL',
    :SVNBrowseURL => 'Project:SVNBrowseURL',
    :DevStatus => 'Project:DevStatus'
  ).
  addCoreFiles( [
    '*'
  ] ).
  executable(
    :StartupRBFile => 'Main.rb',
    :ExeName => 'ExeName',
    :IconName => "Distribution/#{RUBY_PLATFORM}/Icon.ico",
    :TerminalApplication => true
  ).
  install(
    :NSISFileName => "Distribution/#{RUBY_PLATFORM}/Installer/install.nsi"
  )
