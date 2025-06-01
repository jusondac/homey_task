class CommentsController < ApplicationController
  before_action :set_project

  def create
    @comment = @project.comments.build(comment_params)
    @comment.user = Current.user

    if @comment.save
      redirect_to @project, notice: "Comment added successfully!"
    else
      redirect_to @project, alert: "Failed to add comment."
    end
  end

  private

  def set_project
    @project = Current.user.projects.find(params[:project_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
