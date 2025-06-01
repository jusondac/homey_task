class ProjectsController < ApplicationController
  before_action :set_project, only: [ :show, :update_status ]

  def index
    @projects = Current.user.accessible_projects.includes(:comments, :status_changes, :user, :members)
  end

  def show
    @comment = @project.comments.build
    @conversation_history = @project.conversation_history
    @project_members = @project.all_users
  end

  def update_status
    if @project.update_status!(params[:status], Current.user.display_name)
      redirect_to @project, notice: "Status updated successfully!"
    else
      redirect_to @project, alert: "Failed to update status."
    end
  end

  private

  def set_project
    @project = Current.user.accessible_projects.find(params[:id])
  end
end
