class SendvideosController < ApplicationController

  def index
    @groups = Group.search(params[:q])
    @people = Person.search(params[:q])
    @video_clips = VideoClip.search(params[:q])
  end


  def create
    mails = Array.new
    videosUrl = Array.new
    subject = params[:subject]
    groups = params[:groups_tokens]
    users = params[:users_tokens]
    videos = params[:videos_tokens]
    message = params[:message_email]
    mails = getMails(groups, users, mails)
    videosUrl = getVideoUrl(videos, videosUrl)
    mails.each do |mail|
      PersonMailer.send_video(subject, mail, videosUrl, message).deliver
    end
  end

  private
    def getVideoUrl(videos, videosUrl)
      videos_list = getElementArray(videos)
      if !(videos_list.nil?)
        videos_list.each do |video|
          videoActiveRecord = VideoClip.find_by_id(video.lstrip.to_i)
          if videoActiveRecord.videoclip_from_url.empty?
            videosUrl << videoActiveRecord.videoitemclip.url
          else
            videosUrl << videoActiveRecord.videoclip_from_url
          end
        end
      end
      return videosUrl
    end

    def getMails(groups, users, mails)
      mails = getGroupsMails(groups, mails)
      mails = getUsersMails(users, mails)
      mails = mails.uniq
      return mails
    end

    def getUsersMails(users, mails)
      users_list = getElementArray(users)
      if !(users_list.nil?)
        users_list.each do |user|
          userActiveRecord = Person.find_by_id(user.lstrip.to_i)
          mails << userActiveRecord.email
        end
      end
      return mails
    end

    def getGroupsMails(groups, mails)
      groups_list = getElementArray(groups)
      if !(groups_list.nil?)
        groups_list.each do |group|
          groupActiveRecord = Group.find_by_id(group.lstrip.to_i)
          groupActiveRecord.people.each do |user|
            userActiveRecord = Person.find(user)
            mails << userActiveRecord.email
          end
        end
      end
      return mails
    end

    def getElementArray(elements)
      if !(elements.empty?)
        return elements.split(',')
      end
      return nil
    end

end
