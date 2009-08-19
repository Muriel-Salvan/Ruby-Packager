# RubyPackager Gem specification
#
#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'rubygems'

# Return the Gem specification
#
# Return:
# * <em>Gem::Specification</em>: The Gem specification
Gem::Specification.new do |iSpec|
  iSpec.name = 'RubyPackager'
  iSpec.version = '0.0.1.20090819'
  iSpec.author = 'Muriel Salvan'
  iSpec.email = 'murielsalvan@users.sourceforge.net'
  iSpec.homepage = 'http://rubypackager.sourceforge.net/'
  iSpec.platform = Gem::Platform::RUBY
  iSpec.summary = 'A program that ships easily Ruby applications to any platform.'
  iSpec.description = 'Use RubyPackager to easily package your application to any OS, with or without Ruby installed on the client\'s platform.'
  iSpec.files = Dir.glob('{test,lib,bin}/**/*').delete_if do |iFileName|
    ((iFileName == 'CVS') or
     (iFileName == '.svn'))
  end
  iSpec.bindir = 'bin'
  iSpec.executables = [ 'Release.rb' ]
  iSpec.require_path = 'lib'
  iSpec.test_file = 'test/run.rb'
  iSpec.has_rdoc = true
  iSpec.extra_rdoc_files = ['README',
                            'TODO',
                            'ChangeLog',
                            'LICENSE',
                            'AUTHORS',
                            'Credits']
end
