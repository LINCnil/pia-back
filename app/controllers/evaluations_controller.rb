class EvaluationsController < ApplicationController
  before_action :set_evaluation, only: [:show, :update, :destroy]

  # GET /evaluations
  def index
    @evaluations = Evaluation.where(pia_id: params[:pia_id])

    render json: @evaluations
  end

  # GET /evaluations/1
  def show
    render json: @evaluation
  end

  # POST /evaluations
  def create
    @evaluation = Evaluation.new(evaluation_params)

    if @evaluation.save
      render json: @evaluation, status: :created, location: @evaluation
    else
      render json: @evaluation.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /evaluations/1
  def update
    if @evaluation.update(evaluation_params)
      render json: @evaluation
    else
      render json: @evaluation.errors, status: :unprocessable_entity
    end
  end

  # DELETE /evaluations/1
  def destroy
    @evaluation.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_evaluation
      @evaluation = Evaluation.where(id: params[:id], pia_id: params[:pia_id])
    end

    # Only allow a trusted parameter "white list" through.
    def evaluation_params
      params.fetch(:evaluation, {}).permit(
        :status,
        :reference_to,
        :action_plan_comment,
        :evaluation_comment,
        :evaluation_date,
        :gauges,
        :estimated_implementation_date,
        :person_in_charge,
        :pia_id
      )
    end
end
