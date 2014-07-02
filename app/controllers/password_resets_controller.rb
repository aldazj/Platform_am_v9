class PasswordResetsController < ApplicationController

  def new
  end

  def create
    person = Person.find_by_email(params[:email])
    person.send_password_reset if person
    redirect_to root_url, :notice => "Email sent with password reset instructions."
  end

  def edit
    @person = Person.find_by_password_reset_token!(params[:id])
  end

  def update
    @person = Person.find_by_password_reset_token!(params[:id])
    if @person.password_reset_sent_at < 2.hours.ago
      a = 1
      raise a.inspect
      redirect_to new_password_reset_path, :alert => "Password reset has expired."
    elsif @person.update_attributes(person_params)
      redirect_to root_url, :notice => "Password has been reset."
    else
      render :edit
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def person_params
    if params[:admin] != nil
      params.require(:admin).permit(:lastname, :firstname, :email, :dateofbirth, :private_phone, :professional_phone, :password, :password_confirmation,:type,
                                    videoitems_attributes: [:id, :title, :description, :is_available, :date, :views, :pathvideo, :_destroy])
    elsif params[:user] != nil
      params.require(:user).permit(:lastname, :firstname, :email, :dateofbirth, :private_phone, :professional_phone, :password, :password_confirmation, :type,
                                   videoitems_attributes: [:id, :title, :description, :is_available, :date, :views, :pathvideo, :_destroy])
    elsif params[:person] != nil
      params.require(:person).permit(:lastname, :firstname, :email, :dateofbirth, :private_phone, :professional_phone, :password, :password_confirmation, :type,
                                     videoitems_attributes: [:id, :title, :description, :is_available, :date, :views, :pathvideo, :_destroy])
    end
  end
end
