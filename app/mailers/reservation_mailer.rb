class ReservationMailer < ApplicationMailer
  def send_email_to_guest(guest, car)
    @recipient = guest
    @car = car
    mail(to: @recipient.email, from: "Caritto Team", subject: "Enjoy Your Trip! 😎")
  end
end
