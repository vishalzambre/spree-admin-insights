require 'spec_helper'

describe Spree::PaymentMethodTransactionsConversionRateReport do

  let(:start_date) { (Date.today - 10.days).to_s }
  let(:end_date) { Date.today.to_s }
  let(:search_params) { { search: { start_date: start_date, end_date: end_date } } }
  let(:report) { Spree::PaymentMethodTransactionsConversionRateReport.new(search_params) }

  describe '#initialize' do
    it { expect(report.instance_variable_get(:@start_date)).to be_an_instance_of(Date) }
    it { expect(report.instance_variable_get(:@end_date)).to be_an_instance_of(Date) }
    it { expect(report.instance_variable_get(:@sortable_type)).to eq(:asc) }
    it { expect(report.sortable_attribute).to eq(:payment_method_name) }
  end

  describe '#generate' do
    it { expect(report.generate).to be_an_instance_of(Sequel::Mysql2::Dataset)}
  end

  describe '#select_columns' do
    before { @dataset = report.generate }
    it { expect(report.select_columns(@dataset)).to be_an_instance_of(Sequel::Mysql2::Dataset) }
  end

end
