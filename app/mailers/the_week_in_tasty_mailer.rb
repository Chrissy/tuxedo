require 'sendgrid-ruby'
require 'rack/utils'

# Configured to send through the SendGrid marketing API when in production,
# and action mailer when in development. If you would like to test out SendGrid, 
# you can change the Rails.env logic.
#
# To send an email, try: 
# > rake mailer:send_weekly
#
# Lots of Rails magic in here. Check out:
# * weekly_email.html.erb
# * mailer.html.erb
# * mailer.text.erb
# * application_mailer.rb

class TheWeekInTastyMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  default from: 'editors@tuxedono2.com'

  def weekly_email
    return unless (Date.today.strftime("%A") == "Friday")

    @featured_recipes = Recipe.week_in_tasty_recipes

    return if (@featured_recipes.count == 0)

    @recommends = @featured_recipes[0].recommends(3)
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_TOKEN'])

    if (Rails.env == "production")
      data = JSON.parse('{
        "name": "The Week In Tasty' + Time.now.to_s + '",
        "send_to": {
          "list_ids": [
            "95add883-6f02-476a-b500-d6ead3f5f1d2"
          ]
        },
        "email_config": {
          "id": 986724,
          "title": "The Week In Tasty",
          "subject": "The Week In Tasty",
          "sender_id": 3008071,
          "suppression_group_id": 26635,
          "plain_content": "<<content>>",
          "html_content": "<<content>>"
        } 
      }')
  
      template = render_to_string
      plain_template = render_to_string("weekly_email.text.erb")
      
      data['email_config']['html_content'] = template
      data['email_config']['plain_content'] = plain_template
  
      begin
        response = sg.client.marketing.singlesends.post(request_body: data)
      rescue Exception => e
        puts e.message
      end
  
      id = JSON.parse(response.body)["id"]
      data = JSON.parse('{"send_at": "' + (Time.now + 10.minutes).iso8601 + '"}')
  
      response = sg.client.marketing.singlesends._(id).schedule.put(request_body: data)
    else 
      mail(to: "bar@example.com", subject: 'The Week In Tasty')
    end
  end
end
