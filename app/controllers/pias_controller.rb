class PiasController < ApplicationController
  before_action :set_pia, only: %i[show update destroy duplicate]
  before_action :set_serializer, only: %i[index show]

  # GET /pias
  def index
    sorting = sorting_params
    sorting = nil unless Pia.attribute_names.include?(sorting[:column])
    sorting[:direction] = 'asc' if sorting && sorting[:direction] != 'desc'
    @pias = Pia.all
    @pias = @pias.order("#{sorting[:column]} #{sorting[:direction]}") if sorting.present?

    render json: @pias, each_serializer: @index_serializer
  end

  # GET /pias/1
  def show
    render json: @pia, serializer: @index_serializer
  end

  # POST /pias
  def create
    @pia = Pia.new(pia_params)

    if @pia.save
      render json: @pia, status: :created
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

  def duplicate
    @clone = @pia.duplicate

    render json: @clone
  end

  def import
    @import_params = import_params
    import_data_io = @import_params[:data]
    json_str = import_data_io.read
    Pia.import(json_str)
  end

  private

  def import_params
    params.fetch(:import, {}).permit(:data)
  end

  # Set seralizer for pias index
  def set_serializer
    @index_serializer = params[:export].present? ? ExportPiaSerializer : PiaSerializer
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_pia
    @pia = Pia.find(params[:id])
  end

  # Only allow trusted sorting parameters
  def sorting_params
    params.fetch(:sort, {}).permit(:column, :direction)
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
                                  :dpos_name,
                                  :people_names,
                                  :concerned_people_opinion,
                                  :concerned_people_status,
                                  :rejection_reason,
                                  :applied_adjustments,
                                  :is_example)
  end
end
