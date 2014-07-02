class PersonMailer < ActionMailer::Base
  #default from: "platform4am@gmail.com"

  def registration_mail(person)
    @person = person
    mail(
      :to =>  person.email,
      :from    => "platform4am@gmail.com",
      :subject => "Registration Platform 4AM",
    )
  end

  def password_reset(person)
    @person = person
    mail(
      :to =>  person.email,
      :from    => "platform4am@gmail.com",
      :subject => "Password Reset"
    )
  end

  def send_video(subject, mail, videosUrl, message)
    @person = Person.find_by_email(mail)
    @videosUrl = videosUrl
    @message = message
    mail(
        :to =>  @person.email,
        :from    => "platform4am@gmail.com",
        :subject => subject
    )
  end



end
