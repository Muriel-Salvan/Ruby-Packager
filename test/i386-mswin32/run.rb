# To change this template, choose Tools | Templates
# and open the template in the editor.
#--
# Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module RubyPackager

  class BasicTest < ::Test::Unit::TestCase

    include RubyPackager::Test

    # Test the basic usage without embedded Ruby
    def testBasicWithoutRuby
      execTest('Basic', 'ReleaseInfo.rb', false)
    end

  end

end
