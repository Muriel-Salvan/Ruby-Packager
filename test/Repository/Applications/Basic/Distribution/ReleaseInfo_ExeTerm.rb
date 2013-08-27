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
    '*'
  ] ).
  executable(
    :startup_rb_file => 'Main.rb',
    :exe_name => 'ExeName',
    :icon_name => "Distribution/#{PLATFORM_ID}/Icon.ico",
    :terminal_application => true
  ).
  install(
    :nsis_file_name => "Distribution/#{PLATFORM_ID}/Installer/install.nsi"
  )
