class KnowledgesController < ApplicationController
  before_action :get_knowledge_base
  before_action :get_knowledge, only: %w[show update destroy]

  def index
    knowledges = []
    @knowledge_base.knowledges.find_each do |knowledge|
      knowledges << serialize(knowledge)
    end
    render json: knowledges
  end

  def create
    data = knowledge_params
    data["items"] = JSON.parse(data["items"]) if data["items"]
    knowledge = Knowledge.new(data)
    knowledge.knowledge_base = @knowledge_base
    knowledge.save
    render json: serialize(knowledge)
  end

  def show
    render json: serialize(@knowledge)
  end

  def update
    data = knowledge_params
    data["items"] = JSON.parse(data["items"]) if data["items"]
    @knowledge.update(data)
    render json: serialize(@knowledge)
  end

  def destroy
    @knowledge.destroy
    head 204
  end

  private

  def serialize(knowledge)
    KnowledgeSerializer.new(knowledge).serializable_hash.dig(:data, :attributes)
  end

  def get_knowledge_base
    @knowledge_base = KnowledgeBase.find(params[:knowledge_basis_id])
  end

  def get_knowledge
    @knowledge = @knowledge_base.knowledges.find(params[:id])
  end

  def knowledge_params
    params.fetch(:knowledge, {}).permit(:name, :slug, :filters, :category, :placeholder, :description, :items)
  end
end
