require 'spec_helper'

describe Spree::TrendingSearchReport do

  let(:start_date) { (Date.today - 10.days).to_s }
  let(:end_date) { Date.today.to_s }
  let(:search_params) { { search: { start_date: start_date, end_date: end_date, keywords_cont: 'ruby' } } }
  let(:report) { Spree::TrendingSearchReport.new(search_params) }

  describe '#initialize' do
    it { expect(report.instance_variable_get(:@start_date)).to be_an_instance_of(Date) }
    it { expect(report.instance_variable_get(:@end_date)).to be_an_instance_of(Date) }
    it { expect(report.instance_variable_get(:@search_keywords_cont)).to eq('%ruby%') }
    it { expect(report.instance_variable_get(:@sortable_type)).to eq(:desc) }
    it { expect(report.sortable_attribute).to eq(:occurrences) }
  end

  describe '#generate' do
    it { expect(report.generate).to be_an_instance_of(Sequel::Mysql2::Dataset)}
  end

  describe '#select_columns' do
    let(:dataset) { report.generate }
    it { expect(report.select_columns(dataset)).to be_an_instance_of(Sequel::Mysql2::Dataset) }
  end

  describe '#chart_data' do
    it { expect(report.chart_data).to be_an_instance_of(Array) }
  end

  describe '#chart_json' do
    it { expect(report.chart_json).to be_an_instance_of(Hash) }
  end

end
