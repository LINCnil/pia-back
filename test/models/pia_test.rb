require 'test_helper'

class PiaTest < ActiveSupport::TestCase
  test "import should save a new PIA" do
    data = [{
      name: "PIA #{SecureRandom.uuid}",
      answers: [],
      evaluations: [],
      comments: [],
      measures: [],
    }]

    assert Pia.import(data.to_json)
    assert Pia.find_by(name: data.first[:name])
  end

  test 'duplicate a PIA' do
    pia = FactoryBot.create(:pia)
    pia.duplicate

    assert_equal pia.name, Pia.last.name
    assert_not_equal pia.id, Pia.last.id
  end
end
