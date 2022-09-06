class PiasController < ApplicationController
  before_action :set_pia, only: %i[show update destroy duplicate]
  before_action :authorize_pia if ENV['ENABLE_AUTHENTICATION'].present?

  # GET /pias
  def index
    res = []
    # check if user is technical else his pias
    pias = if ENV['ENABLE_AUTHENTICATION'].blank? || current_user.is_technical_admin
             Pia.all
           else
             policy_scope(Pia)
           end

    pias.where(is_archive: params[:is_archive].present?)
        .order(query_order)
        .find_each do |pia|
      res << serialize(pia)
    end
    render json: res
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
    # do not add this to pia
    pia_parameters.delete(:guests)
    pia_parameters.delete(:authors)
    pia_parameters.delete(:evaluators)
    pia_parameters.delete(:validators)

    pia_parameters[:structure_data] = JSON.parse(pia_parameters[:structure_data]) if pia_parameters[:structure_data]
    @pia = Pia.new(pia_parameters)

    if @pia.save
      if ENV['ENABLE_AUTHENTICATION'].present?
        # Update pia user fields and UserPia relations
        check_pia_user_field(:authors, pia_params["authors"], "author_name", 1) if pia_params.key?("authors")
        check_pia_user_field(:evaluators, pia_params["evaluators"], "evaluator_name", 2) if pia_params.key?("evaluators")
        check_pia_user_field(:validators, pia_params["validators"], "validator_name", 3) if pia_params.key?("validators")
        check_pia_user_field(:guests, pia_params["guests"]) if pia_params.key?("guests")
        @pia.save
      end
      render json: serialize(@pia.reload), status: :created
    else
      render json: @pia.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pias/1
  def update
    pia_parameters = pia_params

    # do not add this to pia
    pia_parameters.delete(:guests)
    pia_parameters.delete(:authors)
    pia_parameters.delete(:evaluators)
    pia_parameters.delete(:validators)

    pia_parameters[:structure_data] = JSON.parse(pia_parameters[:structure_data]) if pia_parameters[:structure_data]

    if @pia.update(pia_parameters)

      if ENV['ENABLE_AUTHENTICATION'].present?
        # Update pia user fields and UserPia relations
        check_pia_user_field(:authors, pia_params["authors"], "author_name", 1) if pia_params.key?("authors")
        check_pia_user_field(:evaluators, pia_params["evaluators"], "evaluator_name", 2) if pia_params.key?("evaluators")
        check_pia_user_field(:validators, pia_params["validators"], "validator_name", 3) if pia_params.key?("validators")
        check_pia_user_field(:guests, pia_params["guests"]) if pia_params.key?("guests")
        @pia.save
      end
      render json: serialize(@pia.reload), status: :ok
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

  def authorize_pia
    authorize @pia || Pia
  end

  # return the params if it's not a user
  def check_user_id(user_id)
    if user_id.to_i.positive?
      User.find(user_id.to_i)
    else
      user_id
    end
  end

  def check_pia_user_field(field, value, dump_field = nil, role = 0)
    user_fullnames = []
    @pia.user_pias.where(role: role).delete_all
    return unless value.present?

    # update relations
    value.split(',').each do |id|
      user = check_user_id(id)
      # return unless user.present?
      if user.is_a?(User)
        if field != :guests
          user_fullnames << "#{user.firstname} #{user.lastname}"
        end

        # save for auth mode
        relation = @pia.user_pias.find_by(role: role, user_id: user.id)
        if relation.blank?
          relation = UserPia.new(user_id: user.id, role: role, pia_id: @pia.id)
        end
        relation.save
      else
        user_fullnames << user
      end
    end

    # update dump_field_value with user fullnames
    @pia.send("#{dump_field}=", user_fullnames.join(',')) if field != :guests && dump_field.present?
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
                                  :guests,
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
                                  :progress,
                                  :category,
                                  :authors,
                                  :validators,
                                  :evaluators)
  end
end
