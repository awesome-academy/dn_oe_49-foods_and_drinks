# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize user
    can %i(read filter), [Product, Category]
    return unless user

    can :read, User, id: user.id
    can %i(create read), Order, user_id: user.id
    can :cancel, Order, user_id: user.id, status: :open
  end
end
