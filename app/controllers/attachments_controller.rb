class AttachmentsController < ApplicationController
  before_action :set_attachment, only: %i[show update destroy]

  # GET /attachments
  def index
    attachments = []
    Attachment.where(pia_id: params[:pia_id]).find_each do |attachment|
      attachments << serialize(attachment)
    end
    render json: attachments
  end

  # GET /attachments/1
  def show
    render json: serialize(@attachment)
  end

  def show_signed
    render json: serialize(Attachment.find_by(pia_signed: true, pia_id: params[:pia_id]))
  end

  # POST /attachments
  def create
    @attachment = Attachment.new(attachment_params)
    if @attachment.save
      render json: serialize(@attachment), status: :created
    else
      render json: @attachment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /attachments/1
  def update
    @attachment = Attachment.find params[:id]
    @attachment.comment = attachment_params[:comment]
    @attachment.file.purge
    @attachment.save
  end

  # DELETE /attachments/1
  def destroy
    @attachment.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_attachment
    @attachment = Attachment.find_by(id: params[:id], pia_id: params[:pia_id])
  end

  def serialize(attachment)
    return unless attachment

    AttachmentSerializer.render_as_hash(attachment)
  end

  # Only allow a trusted parameter "white list" through.
  def attachment_params
    params.fetch(:attachment, {}).permit(:pia_signed, :comment, :file)
          .merge(params.permit(:pia_id))
  end
end
