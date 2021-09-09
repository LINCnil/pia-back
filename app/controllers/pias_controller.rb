class PiasController < ApplicationController
  before_action :set_pia, only: %i[show update destroy duplicate]

  # GET /pias
  def index
    pias = []
    Pia.where(is_archive: params[:is_archive].present?)
        .order(query_order)
        .find_each do |pia|
      pias << serialize(pia)
    end
    render json: pias
  end

  # GET /pias/example
  def example
    pia = Pia.find_by(is_example: 1)
    render json: serialize(pia)
  end

  # GET /pias/1
  def show
    render json: serialize(@pia)
  end

  # POST /pias
  def create
    pia_parameters = pia_params
    pia_parameters[:structure_data] = JSON.parse(pia_parameters[:structure_data]) if pia_parameters[:structure_data]
    @pia = Pia.new(pia_parameters)

    # Replace author, evaluator and validator value by user info if is user_id

    if testUserId(pia_parameters[:author_name]).is_a?(User)
      validator = testUserId(pia_parameters[:author_name])
      @pia.author_name = validator.firstname + " " + validator.lastname
    end

    if testUserId(pia_parameters[:evaluator_name]).is_a?(User)
      validator = testUserId(pia_parameters[:evaluator_name])
      @pia.evaluator_name = validator.firstname + " " + validator.lastname
    end

    if testUserId(pia_parameters[:validator_name]).is_a?(User)
      validator = testUserId(pia_parameters[:validator_name])
      @pia.validator_name = validator.firstname + " " + validator.lastname
    end

    
    if @pia.save
      render json: serialize(@pia), status: :created
    else
      render json: @pia.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pias/1
  def update
    pia_parameters = pia_params
    pia_parameters[:structure_data] = JSON.parse(pia_parameters[:structure_data]) if pia_parameters[:structure_data]
    if @pia.update(pia_parameters)
      render json: serialize(@pia)
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
    render json: serialize(@clone)
  end

  def import
    @import_params = import_params
    import_data_io = @import_params[:data]
    json_str = import_data_io.read
    Pia.import(json_str)
  end

  private

  # return the params if it's not a user
  def testUserId(user_id)
    user_id unless Float(user_id)
    User.find(user_id.to_i)
  end

  def import_params
    params.fetch(:import, {}).permit(:data)
  end

  def serialize(pia)
    if params[:export].present?
      ExportPiaSerializer.new(pia).serializable_hash.dig(:data, :attributes)
    else
      PiaSerializer.new(pia).serializable_hash.dig(:data, :attributes)
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_pia
    @pia = Pia.find(params[:id])
  end

  def query_order
    sorting = sorting_params
    sorting = nil unless Pia.attribute_names.include?(sorting[:column])
    sorting[:direction] = 'asc' if sorting && sorting[:direction] != 'desc'
    sorting.present? ? "#{sorting[:column]} #{sorting[:direction]}" : nil
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
                                  :dpos_names,
                                  :people_names,
                                  :concerned_people_opinion,
                                  :concerned_people_status,
                                  :concerned_people_searched_content,
                                  :concerned_people_searched_opinion,
                                  :rejection_reason,
                                  :applied_adjustments,
                                  :is_example,
                                  :structure_id,
                                  :structure_name,
                                  :structure_sector_name,
                                  :structure_data,
                                  :is_archive,
                                  :category)
  end
end
