class StructuresController < ApplicationController
  before_action :set_structure, only: %i[show update destroy duplicate]

  # GET /structures
  def index
    sorting = sorting_params
    sorting = nil unless Structure.attribute_names.include?(sorting[:column])
    sorting[:direction] = 'asc' if sorting && sorting[:direction] != 'desc'
    @structures = Structure.all
    @structures = @structures.order("#{sorting[:column]} #{sorting[:direction]}") if sorting.present?

    render json: @structures
  end

  # GET /structures/1
  def show
    render json: @structure
  end

  # POST /structures
  def create
    structures_parameters = structure_params
    structures_parameters[:data] = JSON.parse(structures_parameters[:data])
    @structure = Structure.new(structures_parameters)

    if @structure.save
      render json: @structure, status: :created
    else
      render json: @structure.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /structures/1
  def update
    structures_parameters = structure_params
    structures_parameters[:data] = JSON.parse(structures_parameters[:data]) if structures_parameters[:data]

    if @structure.update(structures_parameters)
      render json: @structure
    else
      render json: @structure.errors, status: :unprocessable_entity
    end
  end

  # DELETE /structures/1
  def destroy
    @structure.destroy
  end

  private

  def import_params
    params.fetch(:import, {}).permit(:data)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_structure
    @structure = Structure.find(params[:id])
  end

  # Only allow trusted sorting parameters
  def sorting_params
    params.fetch(:sort, {}).permit(:column, :direction)
  end

  # Only allow a trusted parameter "white list" through.
  def structure_params
    params.fetch(:structure, {}).permit(:name,
                                        :sector_name,
                                        :data)
  end
end
