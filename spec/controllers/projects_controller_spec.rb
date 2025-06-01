require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'GET #index' do
    let!(:owned_project) { create(:project, user: user) }
    let!(:member_project) { create(:project, user: other_user) }
    let!(:inaccessible_project) { create(:project, user: other_user) }

    before do
      create(:project_membership, user: user, project: member_project)
    end

    it 'assigns accessible projects to @projects' do
      get :index
      expect(assigns(:projects)).to include(owned_project)
      expect(assigns(:projects)).to include(member_project)
      expect(assigns(:projects)).not_to include(inaccessible_project)
    end

    it 'includes associated records to avoid N+1 queries' do
      expect(user).to receive(:accessible_projects).and_return(
        double('relation', includes: Project.none)
      )
      get :index
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'returns successful response' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    let(:project) { create(:project, user: user) }

    context 'when user has access to the project' do
      it 'assigns the project to @project' do
        get :show, params: { id: project.id }
        expect(assigns(:project)).to eq(project)
      end

      it 'builds a new comment' do
        get :show, params: { id: project.id }
        expect(assigns(:comment)).to be_a_new(Comment)
        expect(assigns(:comment).project).to eq(project)
      end

      it 'assigns conversation history' do
        comment = create(:comment, project: project, user: user)
        status_change = create(:status_change, project: project)

        get :show, params: { id: project.id }
        expect(assigns(:conversation_history)).to include(comment)
        expect(assigns(:conversation_history)).to include(status_change)
      end

      it 'assigns project members' do
        member = create(:user)
        create(:project_membership, user: member, project: project)

        get :show, params: { id: project.id }
        expect(assigns(:project_members)).to include(user)
        expect(assigns(:project_members)).to include(member)
      end

      it 'renders the show template' do
        get :show, params: { id: project.id }
        expect(response).to render_template(:show)
      end

      it 'returns successful response' do
        get :show, params: { id: project.id }
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user does not have access to the project' do
      let(:inaccessible_project) { create(:project, user: other_user) }

      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          get :show, params: { id: inaccessible_project.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'PATCH #update_status' do
    let(:project) { create(:project, user: user, status: 'pending') }

    context 'when user has access to the project' do
      context 'when status update is successful' do
        it 'updates the project status' do
          patch :update_status, params: { id: project.id, status: 'in_progress' }
          expect(project.reload.status).to eq('in_progress')
        end

        it 'creates a status change record' do
          expect {
            patch :update_status, params: { id: project.id, status: 'in_progress' }
          }.to change { project.status_changes.count }.by(1)

          status_change = project.status_changes.last
          expect(status_change.from_status).to eq('pending')
          expect(status_change.to_status).to eq('in_progress')
          expect(status_change.changed_by).to eq(user.display_name)
        end

        it 'redirects to project with success notice' do
          patch :update_status, params: { id: project.id, status: 'in_progress' }
          expect(response).to redirect_to(project)
          expect(flash[:notice]).to eq('Status updated successfully!')
        end
      end

      context 'when status update fails' do
        before do
          allow_any_instance_of(Project).to receive(:update_status!).and_return(false)
        end

        it 'redirects to project with error alert' do
          patch :update_status, params: { id: project.id, status: 'in_progress' }
          expect(response).to redirect_to(project)
          expect(flash[:alert]).to eq('Failed to update status.')
        end
      end
    end

    context 'when user does not have access to the project' do
      let(:inaccessible_project) { create(:project, user: other_user) }

      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          patch :update_status, params: { id: inaccessible_project.id, status: 'in_progress' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'before_actions' do
    let(:project) { create(:project, user: user) }

    it 'sets project for show action' do
      get :show, params: { id: project.id }
      expect(assigns(:project)).to eq(project)
    end

    it 'sets project for update_status action' do
      patch :update_status, params: { id: project.id, status: 'in_progress' }
      expect(assigns(:project)).to eq(project)
    end
  end
end
