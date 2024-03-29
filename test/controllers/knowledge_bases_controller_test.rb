require 'test_helper'

class KnowledgeBasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @knowledge_base = FactoryBot.create(:knowledge_base)
  end

  test 'should get index' do
    get knowledge_bases_url, headers: { 'Authorization' => "Bearer #{doorkeeper_token}" }, as: :json
    assert_response :success
  end

  test 'should create KnowledgeBase' do
    assert_difference('KnowledgeBase.count') do
      post knowledge_bases_url,
           params: { knowledge_base: { name: 'Knowledge Base', author: 'Author name', contributors: 'Contributors name' } },
           headers: { 'Authorization' => "Bearer #{doorkeeper_token}" },
           as: :json
    end

    assert_response 201
  end

  test 'should show KnowledgeBase' do
    get knowledge_bases_url(@knowledge_base), headers: { 'Authorization' => "Bearer #{doorkeeper_token}" }, as: :json
    assert_response :success
  end

  test 'should update KnowledgeBase' do
    patch knowledge_base_url(@knowledge_base), params: { knowledge_base: { name: 'Knowledge Base 2' } },
          headers: { 'Authorization' => "Bearer #{doorkeeper_token}" },
          as: :json
    assert_response 200
  end

  test 'should destroy KnowledgeBase' do
    assert_difference('KnowledgeBase.count', -1) do
      delete knowledge_base_url(@knowledge_base), headers: { 'Authorization' => "Bearer #{doorkeeper_token}" }, as: :json
    end

    assert_response 204
  end
end
