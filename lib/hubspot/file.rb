require 'hubspot/utils'
require 'base64'
require 'pp'

module Hubspot
  #
  # HubSpot Files API
  #
  # {https://developers.hubspot.com/docs/methods/files/post_files}
  #
  class File
    GET_FILE_PATH    = "/filemanager/api/v2/files/:file_id"
    DELETE_FILE_PATH = "/filemanager/api/v2/files/:file_id/full-delete" 
    LIST_FILE_PATH   = "/filemanager/api/v2/files"

    attr_reader :id
    attr_reader :properties

    def initialize(response_hash)
      @id = response_hash["id"]
      @properties = response_hash
    end

    class << self
      def find_by_id(file_id)
        response = Hubspot::Connection.get_json(GET_FILE_PATH, { file_id: file_id })
	new(response)
      end
    end

    # Permanently delete a file and all related data and thumbnails from file manager.
    # {https://developers.hubspot.com/docs/methods/files/hard_delete_file_and_associated_objects}
    def destroy!
      Hubspot::Connection.post_json(DELETE_FILE_PATH, params: {file_id: id})
    end

  end
end
