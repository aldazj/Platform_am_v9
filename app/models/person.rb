class Person < ActiveRecord::Base

  #has_many :videoitems, :dependent => :destroy
  #accepts_nested_attributes_for :videoitems, :reject_if => lambda { |attribute| attribute[:pathvideo].blank?}, :allow_destroy => true

    include PublicActivity::Model
    tracked except: :update, owner: ->(controller, model) { controller && controller.current_person }

    has_and_belongs_to_many :groups, :join_table => 'groups_people'

    has_many :video_clips, :dependent => :destroy
    accepts_nested_attributes_for :video_clips, :allow_destroy => true

    has_one :personalgroup, :dependent => :destroy

    has_many :comments

    has_secure_password

    TYPES = %w( Admin User )

    before_save :set_type
    validates :type, presence: true, :inclusion => { :in => TYPES }

    before_save { |person| person.email = email.downcase }
    validates :lastname, presence: true, length: { maximum: 50 }
    validates :firstname, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true,
              format: { with: VALID_EMAIL_REGEX }
              #TODO CORRIGER UNIQUENESS -- UPDATE
              #uniqueness: { case_sensitive: false }
    validates :password_digest, presence: true, length: { minimum: 4 }, :on => :create
    validates :password_confirmation, presence: true, :on => :create
    before_save :create_remember_token


    #Add group to person
    def add_group(group)
        groups << group
    end

    def set_type
        raiser "override method  in each model inheriting from Person!"
    end

    def send_password_reset
      generate_token(:password_reset_token)
      self.password_reset_sent_at = Time.zone.now
      save!
      PersonMailer.password_reset(self).deliver
    end


    private

        def create_remember_token
            self.remember_token = SecureRandom.urlsafe_base64
        end

        def generate_token(column)
          begin
            self[column] = SecureRandom.urlsafe_base64
          end while Person.exists?(column => self[column])
        end

        def self.search(search)
          if search
            where('name LIKE ?', "%#{search}%")
          else
            self.all
          end
        end

end
