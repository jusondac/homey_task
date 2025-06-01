require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }

  before do
    sign_in(user)
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        project_id: project.id,
        comment: { content: 'This is a test comment' }
      }
    end

    let(:invalid_params) do
      {
        project_id: project.id,
        comment: { content: '' }
      }
    end

    context 'when user has access to the project' do
      context 'with valid parameters' do
        it 'creates a new comment' do
          expect {
            post :create, params: valid_params
          }.to change { project.comments.count }.by(1)
        end

        it 'assigns the current user to the comment' do
          post :create, params: valid_params
          comment = project.comments.last
          expect(comment.user).to eq(user)
        end

        it 'assigns the project to the comment' do
          post :create, params: valid_params
          comment = project.comments.last
          expect(comment.project).to eq(project)
        end

        context 'HTML format' do
          it 'redirects to the project with success notice' do
            post :create, params: valid_params
            expect(response).to redirect_to(project)
            expect(flash[:notice]).to eq('Comment added successfully!')
          end
        end

        context 'Turbo Stream format' do
          it 'responds with turbo_stream format' do
            post :create, params: valid_params, format: :turbo_stream
            expect(response.media_type).to eq('text/vnd.turbo-stream.html')
          end
        end
      end

      context 'with invalid parameters' do
        context 'HTML format' do
          it 'does not create a comment' do
            expect {
              post :create, params: invalid_params
            }.not_to change { project.comments.count }
          end

          it 'redirects to the project with error alert' do
            post :create, params: invalid_params
            expect(response).to redirect_to(project)
            expect(flash[:alert]).to eq('Failed to add comment.')
          end
        end

        context 'Turbo Stream format' do
          it 'renders turbo_stream with form replacement' do
            post :create, params: invalid_params, format: :turbo_stream
            expect(response.media_type).to eq('text/vnd.turbo-stream.html')
          end

          it 'does not create a comment' do
            expect {
              post :create, params: invalid_params, format: :turbo_stream
            }.not_to change { project.comments.count }
          end
        end
      end
    end

    context 'when user does not have access to the project' do
      let(:other_user) { create(:user) }
      let(:inaccessible_project) { create(:project, user: other_user) }
      let(:unauthorized_params) do
        {
          project_id: inaccessible_project.id,
          comment: { content: 'This is a test comment' }
        }
      end

      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          post :create, params: unauthorized_params
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'before_actions' do
    it 'sets project from accessible projects' do
      post :create, params: {
        project_id: project.id,
        comment: { content: 'Test comment' }
      }
      expect(assigns(:project)).to eq(project)
    end
  end

  describe 'private methods' do
    describe '#comment_params' do
      let(:controller_instance) { described_class.new }
      let(:params) do
        ActionController::Parameters.new(
          comment: {
            content: 'Test content',
            user_id: 123,  # This should be filtered out
            project_id: 456  # This should be filtered out
          }
        )
      end

      before do
        allow(controller_instance).to receive(:params).and_return(params)
      end

      it 'permits only content parameter' do
        comment_params = controller_instance.send(:comment_params)
        expect(comment_params).to eq({ 'content' => 'Test content' })
      end

      it 'does not permit user_id' do
        comment_params = controller_instance.send(:comment_params)
        expect(comment_params).not_to have_key('user_id')
      end

      it 'does not permit project_id' do
        comment_params = controller_instance.send(:comment_params)
        expect(comment_params).not_to have_key('project_id')
      end
    end
  end
end
