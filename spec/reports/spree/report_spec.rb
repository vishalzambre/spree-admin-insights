require 'spec_helper'

describe Spree::Report do

  let(:start_date) { (Date.today - 10.days).to_s }
  let(:end_date) { Date.today.to_s }
  let(:search_params) { { search: { start_date: start_date, end_date: end_date } } }
  let(:report) { Spree::Report.new(search_params) }

  describe '#initialize' do
    it { expect(report.instance_variable_get(:@start_date)).to be_an_instance_of(Date) }
    it { expect(report.instance_variable_get(:@end_date)).to be_an_instance_of(Date) }
  end

  describe '#generate' do
    it 'raise exception' do
      expect{ report.generate }.to raise_error('Please define this method in inherited class')
    end
  end

  describe '#header_sorted?' do
    before { report.sortable_attribute = :product_name }
    context 'when sortable_attribute is equal to header' do
      it { expect(report.header_sorted?(:product_name)).to be true }
    end
    context 'when sortable_attribute is equal to header' do
      it { expect(report.header_sorted?(:production)).to be false }
    end
  end

  describe '#set_sortable_attribute' do
    before { report.set_sortable_attributes({ sort: { type: 'asc', attribute: 'test_attribute' } }, :default_sortable_attribute) }
    it { expect(report.sortable_type).to eq(:asc) }
    it { expect(report.sortable_attribute).to eq(:test_attribute) }
  end

  describe '#chart_json' do
    it { expect(report.chart_json).to be_an_instance_of(Hash) }
  end

  describe '#sortable_sequel_expression' do
    context 'when sortable_type is desc' do
      before { report.sortable_type = :desc }
      it { expect(report.sortable_sequel_expression).to be_an_instance_of(Sequel::SQL::OrderedExpression) }
    end

    context 'when sortable_type is asc' do
      before { report.sortable_type = :asc }
      it { expect(report.sortable_sequel_expression).to be_an_instance_of(Sequel::SQL::OrderedExpression) }
    end
  end

  describe '#initialize_months_table' do
    context 'when table already exists' do
      before { allow(SpreeReportify::ReportDb).to receive(:table_exists?).and_return(true) }
      it { expect(report.initialize_months_table).to be nil }
    end

    context 'when table doesnt exists' do
      before { allow(SpreeReportify::ReportDb).to receive(:table_exists?).and_return(false) }
      it { expect(report.initialize_months_table).to be_an_instance_of(Array) }
    end
  end

end
