class EvaluationsController < ApplicationController
  before_action :set_evaluation, only: %i[show update destroy]

  # GET /evaluations
  def index
    if params[:reference_to]
      evaluations = serialize Evaluation.find_by(pia_id: params[:pia_id], reference_to: params[:reference_to])
    else
      evaluations = []
      Evaluation.where(pia_id: params[:pia_id]).find_each do |evaluation|
        evaluations << serialize(evaluation)
      end
    end

    render json: evaluations
  end

  # GET /evaluations/1
  def show
    render json: serialize(@evaluation)
  end

  # POST /evaluations
  def create
    @evaluation = Evaluation.new(evaluation_params)

    if @evaluation.save
      render json: serialize(@evaluation), status: :created
    else
      render json: @evaluation.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /evaluations/1
  def update
    if @evaluation.update(evaluation_params)
      @evaluation.global_status = 0 if @evaluation.status == 1 && evaluation_params["global_status"].blank?
      @evaluation.save
      render json: serialize(@evaluation)
    else
      render json: @evaluation.errors, status: :unprocessable_entity
    end
  end

  # DELETE /evaluations/1
  def destroy
    @evaluation.destroy
  end

  private

  def serialize(evaluation)
    EvaluationSerializer.new(evaluation).serializable_hash.dig(:data, :attributes)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_evaluation
    @evaluation = Evaluation.find_by(id: params[:id], pia_id: params[:pia_id])
  end

  # Only allow a trusted parameter "white list" through.
  def evaluation_params
    params.fetch(:evaluation, {}).permit(
      :status,
      :reference_to,
      :action_plan_comment,
      :evaluation_comment,
      :evaluation_date,
      :estimated_implementation_date,
      :person_in_charge,
      :global_status,
      gauges: %i[x y]
    ).merge(params.permit(:pia_id))
  end
end
