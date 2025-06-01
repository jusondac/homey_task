require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
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
    let(:user) { create(:user, email_address: 'test@example.com') }

    context 'with existing user email' do
      it 'delivers password reset email' do
        expect(PasswordsMailer).to receive(:reset).with(user).and_return(
          double('mailer', deliver_later: true)
        )

        post :create, params: { email_address: 'test@example.com' }
      end

      it 'redirects to new session path with notice' do
        allow(PasswordsMailer).to receive(:reset).and_return(
          double('mailer', deliver_later: true)
        )

        post :create, params: { email_address: 'test@example.com' }
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq('Password reset instructions sent (if user with that email address exists).')
      end
    end

    context 'with non-existent user email' do
      it 'does not deliver email' do
        expect(PasswordsMailer).not_to receive(:reset)
        post :create, params: { email_address: 'nonexistent@example.com' }
      end

      it 'redirects to new session path with the same notice (security)' do
        post :create, params: { email_address: 'nonexistent@example.com' }
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq('Password reset instructions sent (if user with that email address exists).')
      end
    end

    it 'does not require authentication' do
      post :create, params: { email_address: 'test@example.com' }
      expect(response).not_to have_http_status(:unauthorized)
    end
  end

  describe 'GET #edit' do
    let(:user) { create(:user) }
    let(:valid_token) { 'valid_token_123' }

    context 'with valid token' do
      before do
        allow(User).to receive(:find_by_password_reset_token!).with(valid_token).and_return(user)
      end

      it 'assigns the user to @user' do
        get :edit, params: { id: valid_token }
        expect(assigns(:user)).to eq(user)
      end

      it 'renders the edit template' do
        get :edit, params: { id: valid_token }
        expect(response).to render_template(:edit)
      end

      it 'returns successful response' do
        get :edit, params: { id: valid_token }
        expect(response).to have_http_status(:success)
      end
    end

    context 'with invalid token' do
      before do
        allow(User).to receive(:find_by_password_reset_token!).with('invalid_token').and_raise(
          ActiveSupport::MessageVerifier::InvalidSignature
        )
      end

      it 'redirects to new password path with alert' do
        get :edit, params: { id: 'invalid_token' }
        expect(response).to redirect_to(new_password_path)
        expect(flash[:alert]).to eq('Password reset link is invalid or has expired.')
      end
    end

    it 'does not require authentication' do
      allow(User).to receive(:find_by_password_reset_token!).and_return(user)
      get :edit, params: { id: valid_token }
      expect(response).not_to redirect_to(new_session_path)
    end
  end

  describe 'PATCH #update' do
    let(:user) { create(:user) }
    let(:valid_token) { 'valid_token_123' }

    before do
      allow(User).to receive(:find_by_password_reset_token!).with(valid_token).and_return(user)
    end

    context 'with valid password parameters' do
      let(:valid_params) do
        {
          id: valid_token,
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
      end

      it 'updates the user password' do
        patch :update, params: valid_params
        expect(user.reload.authenticate('newpassword123')).to be_truthy
      end

      it 'redirects to new session path with notice' do
        patch :update, params: valid_params
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq('Password has been reset.')
      end
    end

    context 'with invalid password parameters' do
      let(:invalid_params) do
        {
          id: valid_token,
          password: 'newpassword123',
          password_confirmation: 'different_password'
        }
      end

      before do
        allow(user).to receive(:update).and_return(false)
      end

      it 'does not update the user password' do
        original_password_digest = user.password_digest
        patch :update, params: invalid_params
        expect(user.reload.password_digest).to eq(original_password_digest)
      end

      it 'redirects to edit password path with alert' do
        patch :update, params: invalid_params
        expect(response).to redirect_to(edit_password_path(valid_token))
        expect(flash[:alert]).to eq('Passwords did not match.')
      end
    end

    context 'with invalid token' do
      before do
        allow(User).to receive(:find_by_password_reset_token!).with('invalid_token').and_raise(
          ActiveSupport::MessageVerifier::InvalidSignature
        )
      end

      it 'redirects to new password path with alert' do
        patch :update, params: {
          id: 'invalid_token',
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
        expect(response).to redirect_to(new_password_path)
        expect(flash[:alert]).to eq('Password reset link is invalid or has expired.')
      end
    end

    it 'does not require authentication' do
      patch :update, params: {
        id: valid_token,
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }
      expect(response).not_to have_http_status(:unauthorized)
    end
  end

  describe 'before_actions' do
    let(:user) { create(:user) }
    let(:valid_token) { 'valid_token_123' }

    before do
      allow(User).to receive(:find_by_password_reset_token!).with(valid_token).and_return(user)
    end

    it 'sets user by token for edit action' do
      get :edit, params: { id: valid_token }
      expect(assigns(:user)).to eq(user)
    end

    it 'sets user by token for update action' do
      patch :update, params: {
        id: valid_token,
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'authentication requirements' do
    it 'allows unauthenticated access to all actions' do
      get :new
      expect(response).not_to redirect_to(new_session_path)

      post :create, params: { email_address: 'test@example.com' }
      expect(response).not_to have_http_status(:unauthorized)
    end
  end
end
