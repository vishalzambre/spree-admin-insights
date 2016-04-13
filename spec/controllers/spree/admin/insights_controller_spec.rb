require 'spec_helper'

describe Spree::Admin::InsightsController do

  let(:user) { mock_model(Spree.user_class, :generate_spree_api_key! => false) }
  let(:reports_array) { double(Array) }

  before do
    allow(controller).to receive(:authorize_admin).and_return(true)
    allow(controller).to receive(:spree_current_user).and_return(user)
    allow(Spree::ReportGenerationService::REPORTS).to receive(:[]).and_return(reports_array)
  end

  describe '#index' do

    def send_request(report_type = nil)
      xhr :get, :index, type: report_type
    end

    describe 'expects to receive' do
      it { expect(controller).to receive(:authorize_admin).and_return(true) }
      it { expect(controller).to receive(:spree_current_user).and_return(user) }
      it{ expect(Spree::ReportGenerationService::REPORTS).to receive(:[]).and_return(reports_array) }
      after { send_request }
    end

    describe 'response' do
      before { send_request('product_analysis') }
      it { expect(response).to have_http_status(200) }
    end

    describe 'assigns' do
      before { send_request('product_analysis') }
      it { expect(assigns(:reports)).to eq(reports_array) }
    end
  end

  describe '#show' do
    def send_request(no_pagination = "true")
      xhr :get, :show, type: 'product_analysis', id: "product_views", no_pagination: no_pagination
    end

    context 'when report doesnt exist' do
      before do
        allow(reports_array).to receive(:include?).and_return(false)
      end

      describe 'expects to receive' do
        it{ expect(Spree::ReportGenerationService::REPORTS).to receive(:[]).and_return(reports_array) }
        it { expect(reports_array).to receive(:include?).and_return(false) }
        after { send_request }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to(admin_insights_path) }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:report_name)).to eq(:product_views)}
      end
    end

    context 'when report exist' do

      let(:result_array) { ['test_headers', 'test_stats', 'test_total_pages', 'test_search_attributes', 'test_chart_json'] }

      before do
        allow(reports_array).to receive(:include?).and_return(true)
        allow(Spree::ReportGenerationService).to receive(:generate_report).and_return(result_array)
      end

      describe 'expects to receive' do
        it { expect(Spree::ReportGenerationService).to receive(:generate_report).and_return(result_array) }
        it { expect(Spree::ReportGenerationService::REPORTS).to receive(:[]).and_return(reports_array) }
        it { expect(reports_array).to receive(:include?).and_return(true) }
        after { send_request(false) }
      end

      describe 'response' do
        before { send_request(false) }
        it { expect(response).to have_http_status(200) }
      end

      describe 'assigns' do
        before { send_request(false) }
        it { expect(assigns(:report_name)).to eq(:product_views) }
        it { expect(assigns(:headers)).to eq(result_array[0]) }
        it { expect(assigns(:stats)).to eq(result_array[1]) }
        it { expect(assigns(:total_pages)).to eq(result_array[2]) }
        it { expect(assigns(:search_attributes)).to eq(result_array[3]) }
        it { expect(assigns(:chart_json)).to eq(result_array[4]) }
        it { expect(assigns(:report_data_json)).to be_an_instance_of(Hash) }
      end
    end
  end

  describe '#download' do
    def send_request(format)
      xhr :get, :download, type: 'product_analysis', id: 'product_views', no_pagination: 'true', format: format
    end

    let(:result_array) { ['test_headers', 'test_stats'] }
    let(:download_data) { double('download_data') }

    before do
      allow(reports_array).to receive(:include?).and_return(true)
      allow(Spree::ReportGenerationService).to receive(:generate_report).and_return(result_array)
      allow(Spree::ReportGenerationService).to receive(:download).and_return(download_data)
    end

    context 'when format is csv' do
      describe 'expects to receive' do
        it { expect(Spree::ReportGenerationService).to receive(:generate_report).and_return(result_array) }
        it { expect(Spree::ReportGenerationService::REPORTS).to receive(:[]).and_return(reports_array) }
        it { expect(reports_array).to receive(:include?).and_return(true) }
        it { expect(Spree::ReportGenerationService).to receive(:download).and_return(download_data) }
        after { send_request('csv') }
      end

      describe 'response' do
        before { send_request('csv') }
        it { expect(response.headers['Content-Type']).to eq('text/csv') }
        it { expect(response).to render_template(nil) }
      end

      describe 'assigns' do
        before { send_request('csv') }
        it { expect(assigns(:report_name)).to eq(:product_views) }
        it { expect(assigns(:headers)).to eq(result_array[0]) }
        it { expect(assigns(:stats)).to eq(result_array[1]) }
      end
    end

    context 'when format is xls' do
      describe 'expects to receive' do
        it { expect(Spree::ReportGenerationService).to receive(:generate_report).and_return(result_array) }
        it { expect(Spree::ReportGenerationService::REPORTS).to receive(:[]).and_return(reports_array) }
        it { expect(reports_array).to receive(:include?).and_return(true) }
        it { expect(Spree::ReportGenerationService).to receive(:download).and_return(download_data) }
        after { send_request('xls') }
      end

      describe 'response' do
        before { send_request('xls') }
        it { expect(response.headers['Content-Type']).to eq('application/xls') }
        it { expect(response).to render_template(nil) }
      end

      describe 'assigns' do
        before { send_request('xls') }
        it { expect(assigns(:report_name)).to eq(:product_views) }
        it { expect(assigns(:headers)).to eq(result_array[0]) }
        it { expect(assigns(:stats)).to eq(result_array[1]) }
      end
    end

    context 'when format is text' do
      describe 'expects to receive' do
        it { expect(Spree::ReportGenerationService).to receive(:generate_report).and_return(result_array) }
        it { expect(Spree::ReportGenerationService::REPORTS).to receive(:[]).and_return(reports_array) }
        it { expect(reports_array).to receive(:include?).and_return(true) }
        it { expect(Spree::ReportGenerationService).to receive(:download).and_return(download_data) }
        after { send_request('text') }
      end

      describe 'response' do
        before { send_request('text') }
        it { expect(response.headers['Content-Type']).to eq('text/plain') }
        it { expect(response).to render_template(nil) }
      end

      describe 'assigns' do
        before { send_request('text') }
        it { expect(assigns(:report_name)).to eq(:product_views) }
        it { expect(assigns(:headers)).to eq(result_array[0]) }
        it { expect(assigns(:stats)).to eq(result_array[1]) }
      end
    end

    context 'when format is pdf' do
      describe 'expects to receive' do
        it { expect(Spree::ReportGenerationService).to receive(:generate_report).and_return(result_array) }
        it { expect(Spree::ReportGenerationService::REPORTS).to receive(:[]).and_return(reports_array) }
        it { expect(reports_array).to receive(:include?).and_return(true) }
        after { send_request('pdf') }
      end

      describe 'response' do
        before { send_request('pdf') }
        it { expect(response.headers['Content-Type']).to eq('application/pdf') }
      end

      describe 'assigns' do
        before { send_request('pdf') }
        it { expect(assigns(:report_name)).to eq(:product_views) }
        it { expect(assigns(:headers)).to eq(result_array[0]) }
        it { expect(assigns(:stats)).to eq(result_array[1]) }
      end
    end
  end
end
