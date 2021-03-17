class KnowledgeBasesController < ApplicationController
  before_action :set_knowledge_base, only: %w[show update destroy]

  def index
    knowledge_bases = []
    KnowledgeBase.all.find_each do |knowledge_base|
      knowledge_bases << serialize(knowledge_base)
    end
    render json: knowledge_bases
  end

  def create
    knowledge_base = KnowledgeBase.new(knowledge_base_params)

    if knowledge_base.save
      render json: serialize(knowledge_base), status: :created
    else
      render json: knowledge_base.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: serialize(@knowledge_base)
  end

  def update
    if @knowledge_base.update(knowledge_base_params)
      render json: serialize(@knowledge_base)
    else
      render json: @knowledge_base.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @knowledge_base.destroy
    head 204
  end

  private

  def serialize(knowledge_base)
    KnowledgeBaseSerializer.new(knowledge_base).serializable_hash.dig(:data, :attributes)
  end

  def set_knowledge_base
    @knowledge_base = KnowledgeBase.find(params[:id])
  end

  def knowledge_base_params
    params.fetch(:knowledge_base, {}).permit(:name, :author, :contributors)
  end
end
