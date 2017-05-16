require 'spree_core'
require 'spree_admin_insights/engine'

class SpreeAdminInsights
  def self.configure
    yield configuration if block_given?
  end

  def self.configuration
    @config ||= Spree::Report::Configuration.new
  end
end
