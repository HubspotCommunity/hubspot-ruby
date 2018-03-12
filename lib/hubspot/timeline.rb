module Hubspot
	class Timeline
		CREATE_EVENT_PATH = '/integrations/v1/:application‐id/timeline/event'

		class << self
			def create_event(app_id, token, params = {})
				Hubspot::Connection.put_json_with_token(CREATE_EVENT_PATH, token, params: {'application‐id': app_id}, body: params)
			end
		end
	end
end
