class Pseudonym < ActiveRecord::Base
  belongs_to :pseudonymable, :polymorphic => true

  def url
    pseudonymable.url
  end

  def published?
    pseudonymable.published?
  end

end
