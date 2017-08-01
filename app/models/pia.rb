class Pia < ApplicationRecord
  has_many :answers, inverse_of: :pia
  has_many :comments, inverse_of: :pia
  has_many :evaluations, inverse_of: :pia
  has_many :measures, inverse_of: :pia
  has_many :attachments, inverse_of: :pia
  validates :name, presence: true

  def self.import(json_string)
    json = JSON.parse(json_string)
    json.each do |pia_in|
      current_pia = Pia.new
      current_pia.status = pia_in['status']
      current_pia.name = pia_in['name']
      current_pia.author_name = pia_in['author_name']
      current_pia.evaluator_name = pia_in['evaluator_name']
      current_pia.validator_name = pia_in['validator_name']
      current_pia.dpo_status = pia_in['dpo_status']
      current_pia.dpo_opinion = pia_in['dpo_opinion']
      current_pia.concerned_people_opinion = pia_in['concerned_people_opinion']
      current_pia.concerned_people_status = pia_in['concerned_people_status']
      current_pia.rejection_reason = pia_in['rejection_reason']
      current_pia.applied_adjustments = pia_in['applied_adjustments']
      current_pia.created_at = pia_in['created_at']
      current_pia.updated_at = pia_in['updated_at']

      %w[answers evaluations comments measures].each do |assoc|
        values = pia_in[assoc]
        values.each do |value|
          current_pia.send(assoc).build(value.except('id'))
        end
      end
      current_pia.save
      p current_pia
    end
  end

  def duplicate
    duplicate_self
    duplicate_answers
    duplicate_comments
    duplicate_evaluations
    duplicate_measures
    @clone
  end

  private

  def duplicate_self
    @clone = self.dup
    @clone.save
  end

  %w(answers evaluations comments measures).each do |association|
    define_method("duplicate_#{association}") do
      send(association).each do |value|
        @clone.send(association) << value.dup
      end
    end
  end
end
