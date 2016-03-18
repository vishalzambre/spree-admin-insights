require 'spec_helper'

describe Spree::CheckoutController do

  let(:order) { mock_model(Spree::Order, remaining_total: 1000, state: 'cart') }
  let(:user) { mock_model(Spree::User, store_credits_total: 500) }
  let(:checkout_event) { mock_model(Spree::CheckoutEvent) }

  before(:each) do
    allow(user).to receive(:orders).and_return(Spree::Order.all)
    allow(controller).to receive(:track_activity).and_return(checkout_event)
    allow(controller).to receive(:ensure_order_not_completed).and_return(true)
    allow(controller).to receive(:ensure_checkout_allowed).and_return(true)
    allow(controller).to receive(:ensure_sufficient_stock_lines).and_return(true)
    allow(controller).to receive(:ensure_valid_state).and_return(true)
    allow(controller).to receive(:associate_user).and_return(true)
    allow(controller).to receive(:check_authorization).and_return(true)
    allow(controller).to receive(:current_order).and_return(order)
    allow(controller).to receive(:setup_for_current_state).and_return(true)
    allow(controller).to receive(:spree_current_user).and_return(user)
    allow(order).to receive(:can_go_to_state?).and_return(false)
  end

  describe '#edit' do

    def send_request(state)
      get :edit, state: state
    end

    before(:each) do
      allow(order).to receive(:state=).and_return("address")
    end

    context 'when previous state is different than next state' do
      before { send_request('address') }
      it 'expect response to be have status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'create a checkout event record' do
        expect(controller.track_activity).to be_instance_of(Spree::CheckoutEvent)
      end
    end

    context 'when previous state is same as next state' do
      before do
        request.env['HTTP_REFERER'] = 'test/cart'
        send_request('cart')
      end

      it 'create a checkout event record' do
        expect(controller).not_to receive(:track_activity)
      end

      it 'expect response to have status code 200' do
        expect(response).to have_http_status(200)
      end
    end

  end

  describe '#update' do

    def send_request
      patch :update, state: order.state
    end

    before(:each) do
      allow(order).to receive(:update_from_params).and_return(true)
      allow(order).to receive(:temporary_address=).and_return(true)
      allow(order).to receive(:state=).and_return("complete")
      allow(order).to receive(:next).and_return(true)
      allow(order).to receive(:completed?).and_return(true)
      request.env['HTTP_REFERER'] = 'test/confirm'
      send_request
    end

    describe 'when user confirm the order' do
      it 'should create an instance of checkout_event' do
        expect(controller.track_activity).to be_instance_of(Spree::CheckoutEvent)
      end

      it 'expect response to have status code 302' do
        expect(response).to have_http_status(302)
      end
    end

  end

end
