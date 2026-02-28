require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @user = create(:user, email: 'testuser@example.com', firstname: 'John', lastname: 'Doe')
    @pia = create(:pia, name: 'Test PIA')
    @evaluator = create(:user, email: 'evaluator@example.com', firstname: 'Jane', lastname: 'Evaluator')
    @validator = create(:user, email: 'validator@example.com', firstname: 'Bob', lastname: 'Validator')
  end

  # uuid_created tests
  test "uuid_created sends email to user" do
    email = UserMailer.with(user: @user).uuid_created

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email], email.to
    assert_equal I18n.t('email_new_account_uuid.subject'), email.subject
  end

  test "uuid_created email contains UUID" do
    email = UserMailer.with(user: @user).uuid_created
    assert_match @user.uuid, email.body.encoded
  end

  test "uuid_created uses correct from address" do
    email = UserMailer.with(user: @user).uuid_created
    assert_equal ['noreply@example.com'], email.from
  end

  # uuid_updated tests
  test "uuid_updated sends email to user" do
    email = UserMailer.with(user: @user).uuid_updated

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email], email.to
    assert_equal I18n.t('email_recover_account_uuid.subject'), email.subject
  end

  test "uuid_updated email contains UUID" do
    email = UserMailer.with(user: @user).uuid_updated
    assert_match @user.uuid, email.body.encoded
  end

  test "uuid_updated uses correct from address" do
    email = UserMailer.with(user: @user).uuid_updated
    assert_equal ['noreply@example.com'], email.from
  end

  # section_ready_for_evaluation tests
  test "section_ready_for_evaluation sends email to evaluator" do
    email = UserMailer.with(pia: @pia, evaluator: @evaluator).section_ready_for_evaluation

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@evaluator.email], email.to
    assert_equal I18n.t('section_ready_for_evaluation.subject'), email.subject
  end

  test "section_ready_for_evaluation email contains PIA name" do
    email = UserMailer.with(pia: @pia, evaluator: @evaluator).section_ready_for_evaluation
    assert_match @pia.name, email.body.encoded
  end

  test "section_ready_for_evaluation handles nil PIA" do
    email = UserMailer.with(pia: nil, evaluator: @evaluator).section_ready_for_evaluation
    
    assert_emails 1 do
      email.deliver_now
    end
    
    assert_equal [@evaluator.email], email.to
  end

  # section_ready_for_validation tests
  test "section_ready_for_validation sends email to validator" do
    email = UserMailer.with(pia: @pia, validator: @validator).section_ready_for_validation

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@validator.email], email.to
    assert_equal I18n.t('section_ready_for_validation.subject'), email.subject
  end

  test "section_ready_for_validation email contains PIA name" do
    email = UserMailer.with(pia: @pia, validator: @validator).section_ready_for_validation
    assert_match @pia.name, email.body.encoded
  end

  test "section_ready_for_validation handles nil PIA" do
    email = UserMailer.with(pia: nil, validator: @validator).section_ready_for_validation
    
    assert_emails 1 do
      email.deliver_now
    end
    
    assert_equal [@validator.email], email.to
  end

  # Email delivery tests
  test "all emails are delivered in test mode" do
    ActionMailer::Base.deliveries.clear

    UserMailer.with(user: @user).uuid_created.deliver_now
    UserMailer.with(user: @user).uuid_updated.deliver_now
    UserMailer.with(pia: @pia, evaluator: @evaluator).section_ready_for_evaluation.deliver_now
    UserMailer.with(pia: @pia, validator: @validator).section_ready_for_validation.deliver_now

    assert_equal 4, ActionMailer::Base.deliveries.size
  end
end

