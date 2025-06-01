require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'test'
    end
  end

  describe 'authentication' do
    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        get :index
        expect(response).to redirect_to(new_session_path)
      end
    end

    context 'when user is authenticated' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it 'allows access to the action' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'browser compatibility' do
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    it 'allows modern browsers' do
      request.user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
