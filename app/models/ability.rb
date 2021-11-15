class Ability
  include CanCan::Ability

  def initialize user, controller_namespace
    can %i(read, filter), Product, status: "enabled"
    can :read, Category

    case controller_namespace
    when "Admin"
      can :manage, :all if user.role?
    else
      can :manage, Order
      can :manage, Product
    end
  end
end
