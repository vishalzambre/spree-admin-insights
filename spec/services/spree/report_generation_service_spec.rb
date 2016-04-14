require 'spec_helper'

describe Spree::ReportGenerationService do

  let(:klass) { Spree::ReportGenerationService }
  let(:report_service) { Spree::ReportGenerationService.new }
  let(:start_date) { (Date.today - 10.days).to_s }
  let(:end_date) { Date.today.to_s }
  let(:search_params) { { search: { start_date: start_date, end_date: end_date }, 'no_pagination' => 'true' } }
  let(:resource) { Spree::CartAdditionsReport.new(search_params) }
  let(:search_attributes) { { start_date: 'Product added from', end_date: 'Product added to' } }
  let(:report_name) { :cart_additions }
  let (:csv_data) { "Product,Variant,Additions,Cart Addition(Qty)\nRuby Baseball Jersey,RUB-00001,1,1\nRuby on Rails Bag,ROR-00012,2,3\n" }
  let(:csv_stats) do
    [
      { product_name: "Ruby Baseball Jersey", sku: "RUB-00001", additions: 1, quantity_change: 1 },
      { product_name: "Ruby on Rails Bag", sku: "ROR-00012", additions: 2, quantity_change: 3 }
    ]
  end
  let(:headers_result) do
    [
      {name: "Product", value: :product_name, sorted: "asc", type: :string, sortable: true},
      {name: "Variant", value: :sku, sorted: nil, type: :string, sortable: true},
      {name: "Additions", value: :additions, sorted: nil, type: :integer, sortable: true},
      {name: "Cart Addition(Qty)", value: :quantity_change, sorted: nil, type: :integer, sortable: true}
    ]
  end

  describe '.generate_report' do
    it  { expect(klass.generate_report(report_name, search_params)).to be_an_instance_of(Array) }
  end

  describe '.search_attributes' do
    it { expect(klass.search_attributes(Spree::CartAdditionsReport)).to eq(search_attributes) }
  end

  describe '.total_pages' do
    context 'when pagination is required' do
      describe 'when total_records % records_per_page is 0' do
        it { expect(klass.total_pages(6, 3, 'false')).to eq(1) }
      end

      describe 'when total_records % records_per_page is not 0' do
        it { expect(klass.total_pages(6, 4, 'false')).to eq(1) }
      end
    end

    context 'when pagination is not required' do
      it { expect(klass.total_pages(6, 3, 'true')).to be nil }
    end
  end

  describe '.headers' do
    it { expect(klass.headers(Spree::CartAdditionsReport, resource, report_name)).to eq(headers_result) }
  end

  describe '.download' do
    it { expect(klass.download(headers_result, csv_stats)).to eq(csv_data) }
  end
end
