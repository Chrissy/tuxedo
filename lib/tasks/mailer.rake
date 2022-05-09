namespace :mailer do
  desc "Send Weekly Tasty Mail"
  task send_weekly: :environment do
    TheWeekInTastyMailer.weekly_email.deliver_now
  end
end
