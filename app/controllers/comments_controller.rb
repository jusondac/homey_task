class CommentsController < ApplicationController
  before_action :set_project

  def create
    @comment = @project.comments.build(comment_params)
    @comment.user = Current.user

    respond_to do |format|
      if @comment.save
        format.turbo_stream
        format.html { redirect_to @project, notice: "Comment added successfully!" }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("comment-form", partial: "comments/form", locals: { comment: @comment, project: @project }) }
        format.html { redirect_to @project, alert: "Failed to add comment." }
      end
    end
  end

  private

  def set_project
    @project = Current.user.accessible_projects.find(params[:project_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
