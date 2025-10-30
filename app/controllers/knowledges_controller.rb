class KnowledgesController < ApplicationController
  before_action :set_knowledge_base
  before_action :set_knowledge, only: %w[show update destroy]

  rescue_from ActiveRecord::StaleObjectError do |e|
    render json: {
      errors: {
        model: @knowledge.model_name.singular,
        params: knowledge_params,
        record: @knowledge.reload,
        attempted_action: e.attempted_action
      }
    }, status: :conflict
  end

  def index
    knowledges = []
    @knowledge_base.knowledges.find_each do |knowledge|
      knowledges << serialize(knowledge)
    end
    render json: knowledges
  end

  def create
    knowledge = Knowledge.new(knowledge_params)
    knowledge.knowledge_base = @knowledge_base
    if knowledge.save
      render json: serialize(knowledge.reload), status: :created
    else
      render json: knowledge.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: serialize(@knowledge)
  end

  def update
    if @knowledge.update(knowledge_params)
      render json: serialize(@knowledge.reload)
    else
      render json: @knowledge.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @knowledge.destroy
    head :no_content
  end

  private

  def serialize(knowledge)
    return unless knowledge

    KnowledgeSerializer.render_as_hash(knowledge)
  end

  def set_knowledge_base
    @knowledge_base = KnowledgeBase.find(params[:knowledge_base_id])
  end

  def set_knowledge
    @knowledge = @knowledge_base.knowledges.find(params[:id])
  end

  def knowledge_params
    data = params.fetch(:knowledge, {}).permit(:name, :slug, :filters, :category, :placeholder, :description, :items, :lock_version)
    data[:items] = JSON.parse(data[:items]) if data[:items].present?
    data
  end
end
