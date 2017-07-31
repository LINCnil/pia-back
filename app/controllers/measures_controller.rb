class MeasuresController < ApplicationController
  before_action :set_measure, only: [:show, :update, :destroy]

  # GET /measures
  def index
    @measures = Measure.all

    render json: @measures
  end

  # GET /measures/1
  def show
    render json: @measure
  end

  # POST /measures
  def create
    @measure = Measure.new(measure_params)

    if @measure.save
      render json: @measure, status: :created, location: @measure
    else
      render json: @measure.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /measures/1
  def update
    if @measure.update(measure_params)
      render json: @measure
    else
      render json: @measure.errors, status: :unprocessable_entity
    end
  end

  # DELETE /measures/1
  def destroy
    @measure.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_measure
    @measure = Measure.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def measure_params
    params.fetch(:measure, {}).permit(
      :title,
      :content,
      :placeholder,
      :pia_id
    )
  end
end
