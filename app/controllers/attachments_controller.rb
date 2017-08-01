class AttachmentsController < ApplicationController
  before_action :set_attachment, only: [:show, :update, :destroy]

  # GET /attachments
  def index
    @attachments = Attachment.all

    render json: @attachments
  end

  # GET /attachments/1
  def show
    render json: @attachment
  end

  # POST /attachments
  def create
    @attachment = Attachment.new(attachment_params)

    if @attachment.save
      render json: @attachment, status: :created, location: @attachment
    else
      render json: @attachment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /attachments/1
  def update
    if @attachment.update(attachment_params)
      render json: @attachment
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
    @attachment = Attachment.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def attachment_params
    params.fetch(:attachment, {}).permit(:attached_file, :pia_signed, :pia_id)
  end
end
