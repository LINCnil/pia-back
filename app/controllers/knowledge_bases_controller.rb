class KnowledgeBasesController < ApplicationController
  before_action :get_knowledge_base, only: %w[show update destroy]

  def index
    knowledge_bases = []
    KnowledgeBase.all.find_each do |knowledge_base|
      knowledge_bases << serialize(knowledge_base)
    end
    render json: knowledge_bases
  end

  def create
    knowledge_base = KnowledgeBase.create(knowledge_base_params)
    render json: serialize(knowledge_base)
  end

  def show
    render json: serialize(@knowledge_base)
  end

  def update
    @knowledge_base.update(knowledge_base_params)
    render json: serialize(@knowledge_base)
  end

  def destroy
    @knowledge_base.destroy
    head 204
  end

  private

  def serialize(knowledge_base)
    KnowledgeBaseSerializer.new(knowledge_base).serializable_hash.dig(:data, :attributes)
  end

  def get_knowledge_base
    @knowledge_base = KnowledgeBase.find(params[:id])
  end

  def knowledge_base_params
    params.fetch(:knowledge_base, {}).permit(:name, :author, :contributors)
  end
end
