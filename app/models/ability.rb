class Ability
  include CanCan::Ability

  def initialize(user = nil)
    user ||= User.new
    if user.superadmin?
        can :manage, User
        can :manage, Unit
        can :manage, UserLog
        can :manage, Role
        can :role, :unitadmin
        can :role, :user
        can :manage, ImportInfo

        # cannot :role, :superadmin
        cannot [:role, :create, :destroy, :update], User, role: 'superadmin'
        can :update, User, id: user.id

        
    elsif user.unitadmin?
    #can :manage, :all
        

        can :manage, Unit, id: user.unit_id

        can :read, UserLog, user: {unit_id: user.unit_id}
        can :destroy, UserLog, operation: '订单导入'

        can :manage, User, unit_id: user.unit_id

        can :manage, Role
        cannot :role, User, role: 'superadmin'
        can :role, :unitadmin
        can :role, :user
        
        # cannot :role, User, role: 'unitadmin'
        cannot [:create, :destroy, :update], User, role: ['unitadmin', 'superadmin']
        can :update, User, id: user.id

        can :manage, ImportInfo

        # can :manage,BusinessRelationship
        
    elsif user.user?
        can :update, User, id: user.id
        can :read, UserLog, user: {id: user.id}

        can :read, Unit, id: user.unit_id

    else
        cannot :manage, :all
        #can :update, User, id: user.id
        cannot :read, User
        
    end


    end
end




# if user.admin?(storage)


# Define abilities for the passed in user here. For example:
#
#   user ||= User.new # guest user (not logged in)
#   if user.admin?
#     can :manage, :all
#   else
#     can :read, :all
#   end
#
# The first argument to `can` is the action you are giving the user 
# permission to do.
# If you pass :manage it will apply to every action. Other common actions
# here are :read, :create, :update and :destroy.
#
# The second argument is the resource the user can perform the action on. 
# If you pass :all it will apply to every resource. Otherwise pass a Ruby
# class of the resource.
#
# The third argument is an optional hash of conditions to further filter the
# objects.
# For example, here the user can only update published articles.
#
#   can :update, Article, :published => true
#
# See the wiki for details:
# https://github.com/ryanb/cancan/wiki/Defining-Abilities
