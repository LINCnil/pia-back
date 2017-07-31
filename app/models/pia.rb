class Pia < ApplicationRecord
  has_many :answers, inverse_of: :pia
  has_many :comments, inverse_of: :pia
  has_many :evaluations, inverse_of: :pia
  has_many :measures, inverse_of: :pia
  validates :name, presence: true

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
