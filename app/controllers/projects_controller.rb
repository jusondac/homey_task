class ProjectsController < ApplicationController
  before_action :set_project, only: [ :show, :update_status ]

  def index
    @projects = Current.user.projects.includes(:comments, :status_changes)
  end

  def show
    @comment = Comment.new
    @conversation_history = @project.conversation_history
  end

  def update_status
    if @project.update_status!(params[:status], Current.user.email_address)
      redirect_to @project, notice: "Status updated successfully!"
    else
      redirect_to @project, alert: "Failed to update status."
    end
  end

  private

  def set_project
    @project = Current.user.projects.find(params[:id])
  end
end
