require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end

    it 'returns successful response' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new user to @user' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    it 'does not require authentication' do
      get :new
      expect(response).not_to redirect_to(new_session_path)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          user: {
            email_address: 'newuser@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'creates a new user' do
        expect {
          post :create, params: valid_params
        }.to change { User.count }.by(1)
      end

      it 'assigns the user to @user' do
        post :create, params: valid_params
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user)).to be_persisted
      end

      it 'signs in the user automatically' do
        post :create, params: valid_params
        expect(Current.user).to eq(assigns(:user))
      end

      it 'creates a session for the user' do
        expect {
          post :create, params: valid_params
        }.to change { Session.count }.by(1)

        session = Session.last
        expect(session.user).to eq(assigns(:user))
      end

      it 'redirects to after authentication url with notice' do
        post :create, params: valid_params
        expect(response).to redirect_to(root_url)
        expect(flash[:notice]).to eq('Welcome! You have signed up successfully.')
      end

      it 'sets session cookie' do
        post :create, params: valid_params
        expect(cookies.signed[:session_id]).to be_present
      end

      context 'with return_to_after_authenticating in session' do
        before do
          session[:return_to_after_authenticating] = '/projects'
        end

        it 'redirects to the stored URL' do
          post :create, params: valid_params
          expect(response).to redirect_to('/projects')
        end
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          user: {
            email_address: 'invalid_email',
            password: 'short',
            password_confirmation: 'different'
          }
        }
      end

      it 'does not create a user' do
        expect {
          post :create, params: invalid_params
        }.not_to change { User.count }
      end

      it 'assigns the user to @user with errors' do
        post :create, params: invalid_params
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user)).not_to be_persisted
        expect(assigns(:user).errors).to be_present
      end

      it 'does not sign in the user' do
        post :create, params: invalid_params
        expect(Current.user).to be_nil
      end

      it 'does not create a session' do
        expect {
          post :create, params: invalid_params
        }.not_to change { Session.count }
      end

      it 'renders new template with unprocessable entity status' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not set session cookie' do
        post :create, params: invalid_params
        expect(cookies.signed[:session_id]).to be_nil
      end
    end

    context 'with missing parameters' do
      let(:missing_params) do
        {
          user: {
            email_address: '',
            password: '',
            password_confirmation: ''
          }
        }
      end

      it 'does not create a user' do
        expect {
          post :create, params: missing_params
        }.not_to change { User.count }
      end

      it 'renders new template with validation errors' do
        post :create, params: missing_params
        expect(response).to render_template(:new)
        expect(assigns(:user).errors[:email_address]).to be_present
        expect(assigns(:user).errors[:password]).to be_present
      end
    end
  end

  describe 'private methods' do
    describe '#registration_params' do
      let(:controller_instance) { described_class.new }
      let(:params) do
        ActionController::Parameters.new(
          user: {
            email_address: 'test@example.com',
            password: 'password123',
            password_confirmation: 'password123',
            admin: true,  # This should be filtered out
            id: 123  # This should be filtered out
          }
        )
      end

      before do
        allow(controller_instance).to receive(:params).and_return(params)
      end

      it 'permits only allowed parameters' do
        registration_params = controller_instance.send(:registration_params)
        expected_params = {
          'email_address' => 'test@example.com',
          'password' => 'password123',
          'password_confirmation' => 'password123'
        }
        expect(registration_params).to eq(expected_params)
      end

      it 'does not permit admin parameter' do
        registration_params = controller_instance.send(:registration_params)
        expect(registration_params).not_to have_key('admin')
      end

      it 'does not permit id parameter' do
        registration_params = controller_instance.send(:registration_params)
        expect(registration_params).not_to have_key('id')
      end
    end
  end

  describe 'authentication requirements' do
    it 'allows unauthenticated access to all actions' do
      get :new
      expect(response).not_to redirect_to(new_session_path)

      post :create, params: { user: { email_address: 'test@test.com' } }
      expect(response).not_to have_http_status(:unauthorized)
    end
  end
end
