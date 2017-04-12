module SpreeAdminInsights
  class Engine < Rails::Engine
    require 'spree/core'
    require 'sequel'
    require 'wicked_pdf'
    require 'csv'

    isolate_namespace Spree
    engine_name 'spree_admin_insights'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc

    config.after_initialize do
      configuration_hash = (ActiveRecord::Base.configurations[Rails.env] ||
        Rails.configuration.database_configuration[Rails.env]
      ).to_h
      configuration_hash.merge!({ 'adapter' => 'sqlite' }) if(configuration_hash['adapter'] == 'sqlite3')

      # Connect to applications DB using ruby's Sequel wrapper
      ::SpreeAdminInsights::ReportDb = Sequel.connect(configuration_hash)
    end
  end
end
