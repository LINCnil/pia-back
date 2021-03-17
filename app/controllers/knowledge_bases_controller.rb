class KnowledgeBasesController < ApplicationController
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
    knowledge_base = KnowledgeBase.find(params[:id])
    render json: serialize(knowledge_base)
  end

  def update
    knowledge_base = KnowledgeBase.find(params[:id])
    knowledge_base.update(knowledge_base_params)
    render json: serialize(knowledge_base)
  end

  def destroy
    knowledge_base = KnowledgeBase.find(params[:id])
    knowledge_base.destroy
    head 204
  end

  private

  def serialize(knowledge_base)
    KnowledgeBaseSerializer.new(knowledge_base).serializable_hash.dig(:data, :attributes)
  end

  def knowledge_base_params
    params.fetch(:knowledge_base, {}).permit(:name, :author, :contributors)
  end
end
