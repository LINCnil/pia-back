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
    file = params[:attachment][:file]
    @attachment = Attachment.new(attachment_params)

    filename = params[:attachment][:name]
    @attachment.name = filename.chomp(File.extname(filename))

    file = file.gsub('data:application/octet-stream;base64', "data:#{@attachment.mime_type};base64")
    @attachment.attached_file = file

    if @attachment.save
      render json: serialize(@attachment), status: :created
    else
      render json: @attachment.errors, status: :unprocessable_entity
    end
  end

  def update
    @attachment = Attachment.find params[:id]
    @attachment.comment = attachment_params[:comment]
    @attachment.remove_attached_file!
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
    AttachmentSerializer.new(attachment).serializable_hash.dig(:data, :attributes)
  end

  # Only allow a trusted parameter "white list" through.
  def attachment_params
    params.fetch(:attachment, {})
          .permit(:pia_signed, :mime_type, :comment)
          .merge(params.permit(:pia_id))
  end
end
