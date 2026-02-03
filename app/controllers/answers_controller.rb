class AnswersController < ApplicationController
  before_action :set_answer, only: %i[show update destroy]

  rescue_from ActiveRecord::StaleObjectError do |e|
    render json: {
      errors: {
        model: @answer.model_name.singular,
        params: answer_params,
        record: @answer.reload,
        attempted_action: e.attempted_action
      }
    }, status: :conflict
  end

  # GET /answers
  def index
    if params[:reference_to]
      answers = serialize Answer.find_by(pia_id: params[:pia_id], reference_to: params[:reference_to])
    else
      answers = []
      Answer.where(pia_id: params[:pia_id]).find_each do |answer|
        answers << serialize(answer)
      end
    end

    render json: answers
  end

  # GET /answers/1
  def show
    render json: serialize(@answer)
  end

  # POST /answers
  def create
    @answer = Answer.new(processed_answer_params)

    if @answer.save
      render json: serialize(@answer.reload), status: :created
    else
      render json: @answer.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /answers/1
  def update
    if @answer.update(processed_answer_params)
      render json: serialize(@answer.reload)
    else
      render json: @answer.errors, status: :unprocessable_entity
    end
  end

  # DELETE /answers/1
  def destroy
    @answer.destroy
  end

  private

  def serialize(answer)
    return unless answer

    AnswerSerializer.render_as_hash(answer)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_answer
    @answer = Answer.find_by(id: params[:id], pia_id: params[:pia_id])
  end

  # Only allow a trusted parameter "white list" through.
  def answer_params
    params.permit(:pia_id, :id, answer: [:reference_to, :lock_version, :data])
    params.require(:answer).permit(
      :reference_to, :lock_version, :data
    ).merge(pia_id: params[:pia_id])
  end

  def processed_answer_params
    answer_parameters = answer_params
    answer_parameters[:data] = JSON.parse(answer_parameters[:data]) if answer_parameters[:data].is_a?(String)
    answer_parameters
  end
end
