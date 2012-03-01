#--
# Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

RubyPackager::ReleaseInfo.new.
  author(
    :name => 'Author:name',
    :email => 'Author:email',
    :web_page_url => 'Author:web_page_url'
  ).
  project(
    :name => 'Project:name',
    :web_page_url => 'Project:web_page_url',
    :summary => 'Project:summary',
    :description => 'Project:description',
    :image_url => 'Project:image_url',
    :favicon_url => 'Project:favicon_url',
    :browse_source_url => 'Project:browse_source_url',
    :dev_status => 'Project:dev_status'
  ).
  add_core_files( [
    'MainLib.rb'
  ] )
