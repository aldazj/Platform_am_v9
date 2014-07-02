#http://thewebfellas.com/blog/2009/8/29/protecting-your-paperclip-downloads
class VideoClip < ActiveRecord::Base

  include PublicActivity::Model
  tracked except: :update, owner: ->(controller, model) { controller && controller.current_person }

  require 'digest/md5'

  belongs_to :person

  has_many :thumbnails, :dependent => :destroy
  accepts_nested_attributes_for :thumbnails, :allow_destroy => true

  has_many :formatvideos, :dependent => :destroy
  accepts_nested_attributes_for :formatvideos, :allow_destroy => true

  has_many :comments, :dependent => :destroy
  accepts_nested_attributes_for :comments, :reject_if => lambda { |attribute| attribute[:message].blank?}, :allow_destroy => true

  has_attached_file :videoitemclip,
                    #:preserve_files => true,
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :bucket => '*************',
                    :s3_host_name => 's3-us-west-2.amazonaws.com',
                    #:default_url => ':class/:attachment/:id/:content_type/:basename.:extension',
                    #:url =>':s3_domain_url',
                    #:s3_protocol => 'http',
                    #:path => ':class/:attachment/:id/:style/:basename.:extension' NORMAL
                    :path => ':class/:attachment/:token/:style/:basename.:extension'

  #acts_as_paranoid

  #validates_attachment_presence :videoitemclip
  #validates_attachment_size :mp3, :less_than => 10.megabytes

  validates :title, presence: true
  validates_presence_of :token


  after_initialize :init, :before_validation_on_create

  validates_attachment_content_type :videoitemclip,
                                    :content_type =>
                                        [ "application/x-mp4",
                                          "video/mpeg",
                                          "video/quicktime",
                                          "video/x-la-asf",
                                          "video/x-ms-asf",
                                          "video/x-msvideo",
                                          "video/x-sgi-movie",
                                          "video/x-flv",
                                          "flv-application/octet-stream",
                                          "video/3gpp",
                                          "video/3gpp2",
                                          "video/3gpp-tt",
                                          "video/BMPEG",
                                          "video/BT656",
                                          "video/CelB",
                                          "video/DV",
                                          "video/H261",
                                          "video/H263",
                                          "video/H263-1998",
                                          "video/H263-2000",
                                          "video/H264",
                                          "video/JPEG",
                                          "video/MJ2",
                                          "video/MP1S",
                                          "video/MP2P",
                                          "video/MP2T",
                                          "video/mp4",
                                          "video/MP4V-ES",
                                          "video/MPV",
                                          "video/mpeg4",
                                          "video/mpeg4-generic",
                                          "video/nv",
                                          "video/parityfec",
                                          "video/pointer",
                                          "video/raw",
                                          "video/rtx"]


  def to_param
    token
  end

  protected

  def before_validation_on_create
    self.token = Digest::MD5.hexdigest(Time.now.strftime("%Y-%d-%m %H:%M:%S %Z").to_s+" "+rand(36**10).to_s(36)) if self.new_record? and self.token.nil?
  end

  private
    #Proteger l'access et mettre la notion du token
    def downloadable?(person)
      person != :person
    end

    def init
      if self.new_record? && self.videoclip_from_url.nil?
        self.is_available = true
      end
    end

    def self.search_video(search_video, current_person)
      if search_video
        where('title LIKE ?', "%#{search_video}%")
      else
        if current_person.type == 'Admin'
          self.all
        else
          where('is_available LIKE ? OR person_id = ?', true, current_person.id)
        end
      end
    end

    def self.search_video_unavailable(search_video_unavailable, current_person)
      if search_video_unavailable
        where('title LIKE ?', "%#{search_video_unavailable}%")
      else
        if current_person.type == 'Admin'
          where('is_available LIKE ?', false)
        end
      end
    end

    def self.search(search_video)
      if search_video
        where('title LIKE ?', "%#{search_video}%")
      else
        self.all
      end
    end

=begin

    def fast_asset=(files)
      if files &&  files.respond_to?('[]')
        files.each do |item|
          self.tmp_upload_dir = "#{item['filepath']}_1"
          tmp_file_path = "#{self.tmp_upload_dir}/#{item['original_name']}"
          FileUtils.mkdir_p(self.tmp_upload_dir)
          FileUtils.mv(item['filepath'], tmp_file_path)

          self.videoitemclip = File.open(tmp_file_path)

          if file.index(item) == 0
            self.video = File.open(tmp_file_path)
          else
            self.image = File.open(tmp_file_path)
          end
        end
      end
    end
=end

end
