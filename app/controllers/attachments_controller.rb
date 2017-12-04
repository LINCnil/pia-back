class AttachmentsController < ApplicationController
  before_action :set_attachment, only: [:show, :update, :destroy]

  # GET /attachments
  def index
    @attachments = Attachment.where(pia_id: params[:pia_id])
    render json: @attachments
  end

  # GET /attachments/1
  def show
    render json: @attachment
  end

  def show_signed
    @attachment = Attachment.where(pia_signed: true, pia_id: params[:pia_id]).first
    render json: @attachment
  end

  # POST /attachments
  def create
    file = params[:attachment][:file]
    @attachment = Attachment.new(attachment_params)

    filename = params[:attachment][:name]
    @attachment.name = filename.chomp(File.extname(filename))

    file = file.gsub('data:;base64', "data:#{@attachment.mime_type};base64")
    @attachment.attached_file = file

    if @attachment.save
      render json: @attachment, status: :created
    else
      render json: @attachment.errors, status: :unprocessable_entity
    end
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

  # Only allow a trusted parameter "white list" through.
  def attachment_params
    params.fetch(:attachment, {})
          .permit(:pia_signed, :mime_type)
          .merge(params.permit(:pia_id))
  end
end
