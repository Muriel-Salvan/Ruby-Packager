#--
# Copyright (c) 2009-2010 Muriel Salvan (murielsalvan@users.sourceforge.net)
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
    'MainLib.rb'
  ] ).
  install(
    :NSISFileName => 'Distribution/install.nsi',
    :InstallerName => 'InstallerName'
  )
