class AnswersController < ApplicationController
  before_action :set_answer, only: [:show, :update, :destroy]

  # GET /answers
  def index
    if params[:reference_to]
      @answers = Answer.find_by({ pia_id: params[:pia_id], reference_to: params[:reference_to] })
    else
      @answers = Answer.where(pia_id: params[:pia_id])
    end

    render json: @answers
  end

  # GET /answers/1
  def show
    render json: @answer
  end

  # POST /answers
  def create
    @answer = Answer.new(answer_params)

    if @answer.save
      render json: @answer, status: :created
    else
      render json: @answer.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /answers/1
  def update
    if @answer.update(answer_params)
      render json: @answer
    else
      render json: @answer.errors, status: :unprocessable_entity
    end
  end

  # DELETE /answers/1
  def destroy
    @answer.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_answer
    @answer = Answer.find_by(id: params[:id], pia_id: params[:pia_id])
  end

  # Only allow a trusted parameter "white list" through.
  def answer_params
    params.fetch(:answer, {}).permit(
      :reference_to,
      :pia_id,
      data: [:text, :gauge, :list]
    ).merge(params.permit(:pia_id))
    #params.permit(:pia_id, answer: [:reference_to, { data: [:text, :gauge, :list] }])
  end
end
