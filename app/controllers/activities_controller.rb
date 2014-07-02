class ActivitiesController < ApplicationController

  def index
    @activities = PublicActivity::Activity.order('created_at desc')
  end

  def remove_all
    @activities = PublicActivity::Activity.all
    @activities.each do |activity|
      activity.destroy
    end
    flash[:notice] = t('activity.meg_remove_activities')
    redirect_to activities_path
  end

end
