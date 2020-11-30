module Hubspot
  class File
    UPLOAD_FILE_PATH = '/filemanager/api/v3/files/upload'
  
    class << self
      def upload(file, params = {})
        body = {
          file: file,
          options: JSON.generate(file_options(params)),
          folderPath: '/docs'
        }

        ::Hubspot::FilesConnection.post(UPLOAD_FILE_PATH, body: body, params: params)
      end

      protected

      def file_options(params)
        {
          'access' => params['access'] || 'PUBLIC_INDEXABLE',
          'ttl' => params['ttl'] || 'P3M',
          'overwrite' => params['overwrite'] || false,
          'duplicateValidationStrategy' => params['duplicate_validation_strategy'] || 'NONE',
          'duplicateValidationScope' => params['duplicate_validation_scope'] || 'ENTIRE_PORTAL'
        }
      end
    end
  end
end
