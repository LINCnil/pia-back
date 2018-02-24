class CommentsController < ApplicationController
  before_action :set_comment, only: %i[show update destroy]

  # GET /comments
  def index
    if params[:reference_to]
      @comments = Comment.where(pia_id: params[:pia_id], reference_to: params[:reference_to])
    else
      @comments = Comment.where(pia_id: params[:pia_id])
    end

    render json: @comments
  end

  # GET /comments/1
  def show
    render json: @comment
  end

  # POST /comments
  def create
    @comment = Comment.new(comment_params)

    if @comment.save
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/1
  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /comments/1
  def destroy
    @comment.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = Comment.find_by(id: params[:id], pia_id: params[:pia_id])
  end

  # Only allow a trusted parameter "white list" through.
  def comment_params
    params.fetch(:comment, {}).permit(
      :description,
      :reference_to,
      :for_measure
    ).merge(params.permit(:pia_id))
  end
end
