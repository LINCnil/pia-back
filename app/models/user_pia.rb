class UserPia < ApplicationRecord
  self.table_name = 'users_pias'
  belongs_to :user
  belongs_to :pia

  enum role: { guest: 0, author: 1, evaluator: 2, validator: 3 }
end
