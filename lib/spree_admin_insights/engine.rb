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
      # Connect to applications DB using ruby's Sequel wrapper
      db_config = Rails.configuration.database_configuration[Rails.env]
      connect_options = db_config.has_key?('url') ? db_config['url'] : db_config
      ::SpreeAdminInsights::ReportDb = Sequel.connect(connect_options)
    end
  end
end
