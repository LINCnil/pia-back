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
    pia_parameters.delete(:guest_name)
    pia_parameters[:structure_data] = JSON.parse(pia_parameters[:structure_data]) if pia_parameters[:structure_data]
    @pia = Pia.new(pia_parameters)
    
    # Update pia user fields and UserPia relations
    update_pia_user_field(:author_name, 1) {|user| @pia.user_pias << UserPia.new(user_id: user.id, role: 1) }
    update_pia_user_field(:evaluator_name, 2) {|user| @pia.user_pias << UserPia.new(user_id: user.id, role: 2) }
    update_pia_user_field(:validator_name, 3) {|user| @pia.user_pias << UserPia.new(user_id: user.id, role: 3) }
    

    # Guest in userPia
    if pia_params[:guest_name]
      byebug
      pia_params[:guest_name].split(',').each do |user_id|
        @pia.user_pias << UserPia.new(user_id: user_id, role: 0)
      end
    end

    if @pia.save
      byebug
      render json: serialize(@pia), status: :created
    else
      render json: @pia.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pias/1
  def update
    pia_parameters = pia_params
    pia_parameters.delete(:guest_name)
    pia_parameters[:structure_data] = JSON.parse(pia_parameters[:structure_data]) if pia_parameters[:structure_data]
    
    if @pia.update(pia_parameters)

      # Update pia user fields and UserPia relations
      update_pia_user_field(:author_name, 1) { |user| update_user_pias(user, 1) }
      update_pia_user_field(:evaluator_name, 1) { |user| update_user_pias(user, 2) }
      update_pia_user_field(:validator_name, 1) { |user| update_user_pias(user, 3) }
      
      # Guest in userPia
      if pia_params[:guest_name]
        @pia.user_pias = []
        pia_params[:guest_name].split(',').each do |user_id|
          @pia.user_pias << UserPia.new(user_id: user_id, role: 0)
        end
      end

      @pia.save
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
  def check_user_id(user_id)
    if user_id.to_i.positive?
      User.find(user_id.to_i)
    else
      user_id
    end
  end

  def update_pia_user_field(field, role)
    user = check_user_id(pia_params[field])
    return unless user.is_a?(User)
    @pia.send("#{field}=", "#{user.firstname} #{user.lastname}")
    yield(user)
  end

  def update_user_pias(user, role)
      relation = @pia.user_pias.find_by(role: role)
      return unless relation.present?
      relation.user_id = user.id
      relation.save
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
                                  :guest_name,
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
