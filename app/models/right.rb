class Right < ActiveRecord::Base

  include PublicActivity::Model
  tracked except: :update, owner: ->(controller, model) { controller && controller.current_person }

  has_and_belongs_to_many :groups, :join_table => 'groups_rights'
    has_and_belongs_to_many :personalgroups, :join_table => 'personal_groupsrights'

    validates :name, presence: true
end
