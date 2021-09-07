class UserPia < ApplicationRecord
  belongs_to :user
  belongs_to :pia

  enum role: { guest: 0, author: 1, evaluator: 2, validator: 3 }
end
