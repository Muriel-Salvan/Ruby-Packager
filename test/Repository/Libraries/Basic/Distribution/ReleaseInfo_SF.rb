#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
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
  sourceForge(
    :Login => 'login',
    :ProjectUnixName => 'unixname'
  )
