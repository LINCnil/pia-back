require 'test_helper'

class KnowledgesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @knowledge = FactoryBot.create(:knowledge)
  end

  test 'should get index' do
    get knowledge_base_knowledges_url(knowledge_base_id: @knowledge.knowledge_base.id), headers: { 'Authorization' => "Bearer #{doorkeeper_token}" }, as: :json
    assert_response :success
  end

  test 'should create Knowledge' do
    assert_difference('Knowledge.count') do
      post knowledge_base_knowledges_url(knowledge_base_id: @knowledge.knowledge_base.id),
           params: { knowledge: { name: 'Knowledge' } },
           headers: { 'Authorization' => "Bearer #{doorkeeper_token}" },
           as: :json
    end

    assert_response 201
  end

  test 'should show Knowledge' do
    get knowledge_base_knowledge_url(knowledge_base_id: @knowledge.knowledge_base.id, id: @knowledge),
        headers: { 'Authorization' => "Bearer #{doorkeeper_token}" },
        as: :json
    assert_response :success
  end

  test 'should update Knowledge' do
    patch knowledge_base_knowledge_url(knowledge_base_id: @knowledge.knowledge_base.id, id: @knowledge.id),
          params: { knowledge: { name: 'Knowledge 2' } },
          headers: { 'Authorization' => "Bearer #{doorkeeper_token}" },
          as: :json
    assert_response 200
  end

  test 'should destroy Knowledge' do
    assert_difference('Knowledge.count', -1) do
      delete knowledge_base_knowledge_url(knowledge_base_id: @knowledge.knowledge_base.id, id: @knowledge.id),
             headers: { 'Authorization' => "Bearer #{doorkeeper_token}" },
             as: :json
    end

    assert_response 204
  end
end
