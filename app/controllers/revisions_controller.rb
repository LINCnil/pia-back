class RevisionsController < ApplicationController
  before_action :set_revision, only: %i[show update destroy]

  # GET /revisions
  def index
    revisions = []
    Revision.where(pia_id: params[:pia_id]).order(created_at: :desc).find_each do |revision|
      revisions << serialize(revision)
    end

    render json: revisions
  end

  # GET /revisions/1
  def show
    render json: serialize(@revision)
  end

  # POST /revisions
  def create
    @revision = Revision.new(revision_params)

    if @revision.save
      render json: serialize(@revision), status: :created
    else
      render json: @revision.errors, status: :unprocessable_entity
    end
  end

  # DELETE /revisions/1
  def destroy
    @revision.destroy
  end

  private

  def serialize(revision)
    RevisionSerializer.new(revision).serializable_hash.dig(:data, :attributes)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_revision
    @revision = Revision.find_by(id: params[:id], pia_id: params[:pia_id])
  end

  # Only allow a trusted parameter "white list" through.
  def revision_params
    params.fetch(:revision, {}).permit(:export).merge(params.permit(:pia_id))
  end
end
