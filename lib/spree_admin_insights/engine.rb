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
      def connnection_configurations
        configuration_hash = Rails.configuration.database_configuration[Rails.env].to_h
        if configuration_hash['adapter'] == 'sqlite3'
          configuration_hash.merge!({ adapter: 'sqlite' })
        end
        configuration_hash
      end

      # Connect to applications DB using ruby's Sequel wrapper
      ::SpreeAdminInsights::ReportDb = Sequel.connect(connnection_configurations)

    end
  end
end
