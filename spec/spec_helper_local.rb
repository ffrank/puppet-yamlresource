require 'puppet/face'

RSpec.configure do |config|
  config.mock_with :mocha
end

require 'puppetlabs_spec_helper/puppet_spec_helper'

RSpec.configure do |config|
  Puppet::Test::TestHelper.initialize

  config.before :all do
    Puppet::Test::TestHelper.before_all_tests()
  end

  config.after :all do
    Puppet::Test::TestHelper.after_all_tests()
  end

  config.before :each do
    Puppet::Test::TestHelper.before_each_test()
    # silly hack to make sure we have a temporary vardir, although the
    # location is in the environment path, which is bonkers
    Puppet[:vardir] = Puppet[:environmentpath] + "/vardir"
  end

  config.after :each do
    Puppet::Test::TestHelper.after_each_test()
  end
end
