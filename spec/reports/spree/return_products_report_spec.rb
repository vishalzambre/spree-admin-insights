require 'spec_helper'

describe Spree::ReturnedProductsReport do

  let(:start_date) { (Date.today - 10.days).to_s }
  let(:end_date) { Date.today.to_s }
  let(:search_params) { { search: { start_date: start_date, end_date: end_date } } }
  let(:report) { Spree::ReturnedProductsReport.new(search_params) }

  describe '#initialize' do
    it { expect(report.instance_variable_get(:@start_date)).to be_an_instance_of(Date) }
    it { expect(report.instance_variable_get(:@end_date)).to be_an_instance_of(Date) }
    it { expect(report.instance_variable_get(:@sortable_type)).to eq(:asc) }
    it { expect(report.sortable_attribute).to eq(:product_name) }
  end

  describe '#generate' do
    it { expect(report.generate).to be_an_instance_of(Sequel::Mysql2::Dataset)}
  end

  describe '#select_columns' do
    let(:dataset) { report.generate }
    it { expect(report.select_columns(dataset)).to be_an_instance_of(Sequel::Mysql2::Dataset) }
  end

end
