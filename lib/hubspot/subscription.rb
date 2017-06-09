module Hubspot
  class Subscription
	SUBSCRIPTIONS_PATH = '/email/public/v1/subscriptions'
	TIMELINE_PATH 	   = '/email/public/v1/subscriptions/timeline'
	SUBSCRIPTION_PATH  = '/email/public/v1/subscriptions/:email_address'

	attr_reader :subscribed
	attr_reader :marked_as_spam
	attr_reader :bounced
	attr_reader :status
	attr_reader :subscription_statuses

	def initialize(response_hash)
      @subscribed			 = response_hash['subscribed']
      @marked_as_spam 		 = response_hash['markedAsSpam']
      @bounced	    		 = response_hash['bounced']
      @status      		   	 = response_hash['status']
      @subscription_statuses = response_hash['SubscriptionStatuses']
    end

	class << self 
	  def status(email)
	  	response = Hubspot::Connection.get_json(SUBSCRIPTION_PATH, {email_address: email})
	  	new(response)
	  end 
	end 

  end 
end 