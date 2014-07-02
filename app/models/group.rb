class Group < ActiveRecord::Base

    include PublicActivity::Model
    tracked except: :update, owner: ->(controller, model) { controller && controller.current_person }

    has_and_belongs_to_many :rights, :join_table => 'groups_rights'
    has_and_belongs_to_many :people, :join_table => 'groups_people'

    validates :name, presence: true

    #Add right to group
    def add_right(right)
        rights << right
    end

  private

    def self.search(search_group)
      if search_group
        where('name LIKE ?', "%#{search_group}%")
      else
        self.all
      end
    end
end
