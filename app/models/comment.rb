class Comment < ActiveRecord::Base
  #belongs_to :videoitem
  include PublicActivity::Common
  # tracked except: :update, owner: ->(controller, model) { controller && controller.current_user }

  belongs_to :person
  belongs_to :video_clip

end
