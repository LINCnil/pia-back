class CommentsController < ApplicationController
  before_action :set_comment, only: %i[show update destroy]

  # GET /comments
  def index
    comments = []
    if params[:reference_to]
      Comment.where(pia_id: params[:pia_id], reference_to: params[:reference_to]).find_each do |comment|
        comments << serialize(comment)
      end
    else
      Comment.where(pia_id: params[:pia_id]).find_each do |comment|
        comments << serialize(comment)
      end
    end

    render json: comments
  end

  # GET /comments/1
  def show
    render json: serialize(@comment)
  end

  # POST /comments
  def create
    @comment = Comment.new(comment_params)

    if @comment.save
      render json: serialize(@comment.reload), status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/1
  def update
    if @comment.update(comment_params)
      render json: serialize(@comment.reload)
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /comments/1
  def destroy
    @comment.destroy
  end

  private

  def serialize(comment)
    CommentSerializer.new(comment).serializable_hash.dig(:data, :attributes)
  end

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
