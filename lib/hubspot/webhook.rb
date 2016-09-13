module Hubspot
  #
  # HubSpot Webhooks API
  #
  # {http://developers.hubspot.com/docs/methods/webhooks/webhooks-overview}
  #
  class Webhook
    CREATE_SUBSCRIPTION_PATH = '/webhooks/v1/:app_id/subscriptions'

    class << self
      # Create a New Subscription
      # {http://developers.hubspot.com/docs/methods/webhooks/webhooks-overview}
      # @param subscription_type [String]
      # @param property_name [String]
      def create!(user_id, subscription_type, property_name = nil)
        post_data = {
          subscriptionDetails: {
            subscriptionType: subscription_type,
            propertyName: property_name
          },
          enabled: true
        }

        response = Hubspot::Connection.post_json(CREATE_SUBSCRIPTION_PATH, params: { userId: user_id }, body: post_data )
      end
    end
  end
end

# Hubspot::Webhook.create!(Settings.hubspot.user_id, "company.propertyChange", "companyname")
