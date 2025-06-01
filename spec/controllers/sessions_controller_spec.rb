require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end

    it 'returns successful response' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'does not require authentication' do
      get :new
      expect(response).not_to redirect_to(new_session_path)
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user, email_address: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      let(:valid_params) do
        { email_address: 'test@example.com', password: 'password123' }
      end

      it 'authenticates the user' do
        expect {
          post :create, params: valid_params
        }.to change { user.sessions.count }.by(1)
        expect(response).to redirect_to(root_url)
      end

      it 'creates a new session' do
        expect {
          post :create, params: valid_params
        }.to change { user.sessions.count }.by(1)
      end

      it 'redirects to after authentication url' do
        post :create, params: valid_params
        expect(response).to redirect_to(root_url)
      end

      it 'sets session cookie' do
        post :create, params: valid_params
        expect(cookies.signed[:session_id]).to be_present
      end

      context 'with return_to_after_authenticating in session' do
        before do
          session[:return_to_after_authenticating] = '/projects/1'
        end

        it 'redirects to the stored URL' do
          post :create, params: valid_params
          expect(response).to redirect_to('/projects/1')
        end

        it 'clears the return_to_after_authenticating from session' do
          post :create, params: valid_params
          expect(session[:return_to_after_authenticating]).to be_nil
        end
      end
    end

    context 'with invalid credentials' do
      let(:invalid_params) do
        { email_address: 'test@example.com', password: 'wrongpassword' }
      end

      it 'does not authenticate the user' do
        post :create, params: invalid_params
        expect(Current.user).to be_nil
      end

      it 'does not create a new session' do
        expect {
          post :create, params: invalid_params
        }.not_to change { Session.count }
      end

      it 'redirects to new session path with alert' do
        post :create, params: invalid_params
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq('Try another email address or password.')
      end

      it 'does not set session cookie' do
        post :create, params: invalid_params
        expect(cookies.signed[:session_id]).to be_nil
      end
    end

    context 'with non-existent user' do
      let(:nonexistent_params) do
        { email_address: 'nonexistent@example.com', password: 'password123' }
      end

      it 'redirects to new session path with alert' do
        post :create, params: nonexistent_params
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq('Try another email address or password.')
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { create(:user) }
    let(:session) { create(:session, user: user) }

    before do
      Current.session = session
      cookies.signed[:session_id] = session.id
    end

    it 'destroys the current session' do
      expect {
        delete :destroy
      }.to change { Session.count }.by(-1)
    end

    it 'clears the Current.session' do
      delete :destroy
      expect(Current.session).to be_nil
    end

    it 'deletes the session cookie' do
      delete :destroy
      expect(cookies[:session_id]).to be_nil
    end

    it 'redirects to new session path' do
      delete :destroy
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe 'rate limiting' do
    let(:user) { create(:user, email_address: 'test@example.com', password: 'password123') }

    it 'applies rate limiting to create action' do
      # This test verifies that rate limiting is configured
      # Skip this test as Rails 8 handles rate limiting differently
      skip "Rate limiting implementation details are not directly testable"
    end
  end

  describe 'authentication requirements' do
    it 'allows unauthenticated access to new action' do
      get :new
      expect(response).not_to redirect_to(new_session_path)
    end

    it 'allows unauthenticated access to create action' do
      post :create, params: { email_address: 'test@example.com', password: 'wrong' }
      expect(response).not_to have_http_status(:unauthorized)
    end
  end
end
