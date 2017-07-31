class PiasController < ApplicationController
  before_action :set_pia, only: [:show, :update, :destroy]

  # GET /pias
  def index
    @pias = Pia.all

    render json: @pias
  end

  # GET /pias/1
  def show
    render json: @pia
  end

  # POST /pias
  def create
    @pia = Pia.new(pia_params)

    if @pia.save
      render json: @pia, status: :created, location: @pia
    else
      render json: @pia.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pias/1
  def update
    if @pia.update(pia_params)
      render json: @pia
    else
      render json: @pia.errors, status: :unprocessable_entity
    end
  end

  # DELETE /pias/1
  def destroy
    @pia.destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_pia
    @pia = Pia.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def pia_params
    params.fetch(:pia, {}).permit(:status,
                                  :name,
                                  :author_name,
                                  :evaluator_name,
                                  :validator_name,
                                  :dpo_status,
                                  :dpo_opinion,
                                  :concerned_people_opinion,
                                  :concerned_people_status,
                                  :rejection_reason,
                                  :applied_adjustments)
  end
end
