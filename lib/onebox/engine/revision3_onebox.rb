module Onebox
  module Engine
    class Revision3Onebox
      include Engine
      include OpenGraph

      matches do
        # /^http\:\/\/(.*\.)?revision3\.com\/.*$/
        find "revision3.com"
      end

      private

      def extracted_data
        {
          url: @url,
          title: @body.title,
          image: @body.images.first,
        }
      end
    end
  end
end
