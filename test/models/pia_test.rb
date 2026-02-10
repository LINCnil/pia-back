require 'test_helper'

class PiaTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "should be valid with valid attributes" do
    pia = build(:pia)
    assert pia.valid?
  end

  test "should require name" do
    pia = build(:pia, name: nil)
    assert_not pia.valid?
    assert_includes pia.errors[:name], "can't be blank"
  end

  test "should belong to structure optionally" do
    pia = create(:pia, structure: nil)
    assert pia.valid?
    assert_nil pia.structure
  end

  test "should have many answers" do
    pia = create(:pia)
    create(:answer, pia: pia)
    create(:answer, pia: pia)
    assert_equal 2, pia.answers.count
  end

  test "should have many comments" do
    pia = create(:pia)
    create(:comment, pia: pia)
    create(:comment, pia: pia)
    assert_equal 2, pia.comments.count
  end

  test "should have many evaluations" do
    pia = create(:pia)
    create(:evaluation, pia: pia)
    create(:evaluation, pia: pia)
    assert_equal 2, pia.evaluations.count
  end

  test "should have many measures" do
    pia = create(:pia)
    create(:measure, pia: pia)
    create(:measure, pia: pia)
    assert_equal 2, pia.measures.count
  end

  test "should have many attachments" do
    pia = create(:pia)
    create(:attachment, pia: pia)
    create(:attachment, pia: pia)
    assert_equal 2, pia.attachments.count
  end

  test "should have many revisions" do
    pia = create(:pia)
    create(:revision, pia: pia)
    create(:revision, pia: pia)
    assert_equal 2, pia.revisions.count
  end

  test "should have many user_pias" do
    pia = create(:pia)
    create(:user_pia, pia: pia)
    create(:user_pia, pia: pia)
    assert_equal 2, pia.user_pias.count
  end

  test "should destroy dependent answers" do
    pia = create(:pia)
    create(:answer, pia: pia)
    create(:answer, pia: pia)

    assert_difference 'Answer.count', -2 do
      pia.destroy
    end
  end

  test "should destroy dependent comments" do
    pia = create(:pia)
    create(:comment, pia: pia)
    create(:comment, pia: pia)

    assert_difference 'Comment.count', -2 do
      pia.destroy
    end
  end

  test "should destroy dependent evaluations" do
    pia = create(:pia)
    create(:evaluation, pia: pia)
    create(:evaluation, pia: pia)

    assert_difference 'Evaluation.count', -2 do
      pia.destroy
    end
  end

  test "should destroy dependent measures" do
    pia = create(:pia)
    create(:measure, pia: pia)
    create(:measure, pia: pia)

    assert_difference 'Measure.count', -2 do
      pia.destroy
    end
  end

  test "should destroy dependent attachments" do
    pia = create(:pia)
    create(:attachment, pia: pia)
    create(:attachment, pia: pia)

    assert_difference 'Attachment.count', -2 do
      pia.destroy
    end
  end

  test "should destroy dependent revisions" do
    pia = create(:pia)
    create(:revision, pia: pia)
    create(:revision, pia: pia)

    assert_difference 'Revision.count', -2 do
      pia.destroy
    end
  end

  test "should destroy dependent user_pias" do
    pia = create(:pia)
    create(:user_pia, pia: pia)
    create(:user_pia, pia: pia)

    assert_difference 'UserPia.count', -2 do
      pia.destroy
    end
  end

  test "should sanitize name after initialize" do
    pia = Pia.new(name: '<script>alert("xss")</script>Hello')
    assert_not_includes pia.name, '<script>'
  end

  test "should sanitize author_name after initialize" do
    pia = Pia.new(author_name: '<script>alert("xss")</script>Hello')
    assert_not_includes pia.author_name, '<script>'
  end

  test "should sanitize evaluator_name after initialize" do
    pia = Pia.new(evaluator_name: '<script>alert("xss")</script>Hello')
    assert_not_includes pia.evaluator_name, '<script>'
  end

  test "should sanitize validator_name after initialize" do
    pia = Pia.new(validator_name: '<script>alert("xss")</script>Hello')
    assert_not_includes pia.validator_name, '<script>'
  end

  test "should sanitize category after initialize" do
    pia = Pia.new(category: '<script>alert("xss")</script>Hello')
    assert_not_includes pia.category, '<script>'
  end

  test "import should save a new PIA" do
    data = [{
      name: "PIA #{SecureRandom.uuid}",
      answers: [],
      evaluations: [],
      comments: [],
      measures: []
    }]

    assert Pia.import(data.to_json)
    assert Pia.find_by(name: data.first[:name])
  end

  test "import should save PIA with answers" do
    data = [{
      name: "PIA #{SecureRandom.uuid}",
      answers: [{ reference_to: 'test.ref', data: {} }],
      evaluations: [],
      comments: [],
      measures: []
    }]

    Pia.import(data.to_json)
    pia = Pia.find_by(name: data.first[:name])

    assert_equal 1, pia.answers.count
  end

  test "import should save PIA with evaluations" do
    data = [{
      name: "PIA #{SecureRandom.uuid}",
      answers: [],
      evaluations: [{ reference_to: 'test.ref' }],
      comments: [],
      measures: []
    }]

    Pia.import(data.to_json)
    pia = Pia.find_by(name: data.first[:name])

    assert_equal 1, pia.evaluations.count
  end

  test "import should save PIA with comments" do
    data = [{
      name: "PIA #{SecureRandom.uuid}",
      answers: [],
      evaluations: [],
      comments: [{ reference_to: 'test.ref' }],
      measures: []
    }]

    Pia.import(data.to_json)
    pia = Pia.find_by(name: data.first[:name])

    assert_equal 1, pia.comments.count
  end

  test "import should save PIA with measures" do
    data = [{
      name: "PIA #{SecureRandom.uuid}",
      answers: [],
      evaluations: [],
      comments: [],
      measures: [{ title: 'Test measure' }]
    }]

    Pia.import(data.to_json)
    pia = Pia.find_by(name: data.first[:name])

    assert_equal 1, pia.measures.count
  end

  test 'duplicate a PIA' do
    pia = FactoryBot.create(:pia)
    pia.duplicate

    assert_equal pia.name, Pia.last.name
    assert_not_equal pia.id, Pia.last.id
  end

  test 'duplicate should copy answers' do
    pia = create(:pia)
    create(:answer, pia: pia)
    create(:answer, pia: pia)

    duplicate = pia.duplicate

    assert_equal 2, duplicate.answers.count
    assert_not_equal pia.answers.first.id, duplicate.answers.first.id
  end

  test 'duplicate should copy evaluations' do
    pia = create(:pia)
    create(:evaluation, pia: pia)
    create(:evaluation, pia: pia)

    duplicate = pia.duplicate

    assert_equal 2, duplicate.evaluations.count
    assert_not_equal pia.evaluations.first.id, duplicate.evaluations.first.id
  end

  test 'duplicate should copy comments' do
    pia = create(:pia)
    create(:comment, pia: pia)
    create(:comment, pia: pia)

    duplicate = pia.duplicate

    assert_equal 2, duplicate.comments.count
    assert_not_equal pia.comments.first.id, duplicate.comments.first.id
  end

  test 'duplicate should copy measures' do
    pia = create(:pia)
    create(:measure, pia: pia)
    create(:measure, pia: pia)

    duplicate = pia.duplicate

    assert_equal 2, duplicate.measures.count
    assert_not_equal pia.measures.first.id, duplicate.measures.first.id
  end
end
