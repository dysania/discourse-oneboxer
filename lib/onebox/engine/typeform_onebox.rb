module Onebox
  module Engine
    class TypeformOnebox
      include Engine

      matches_regexp(/^https?:\/\/[a-z0-9]+\.typeform\.com\/to\/[a-zA-Z0-9]+/)
      always_https

      def to_html
        typeform_src = build_typeform_src

        <<-HTML
          <iframe src="#{typeform_src}"
                  width="100%"
                  height="600px"
                  scrolling="no"
                  frameborder="0">
          </iframe>
        HTML
      end
      alias placeholder_html to_html

      private

      def build_typeform_src
        escaped_src = ::Onebox::Helpers.normalize_url_for_output(@url)
        query_params = CGI::parse(URI::parse(escaped_src).query || '')

        return escaped_src if query_params.has_key?('typeform-embed')

        escaped_src.tap do |src|
          if query_params.empty?
            src << '?' unless src.end_with?('?')
          else
            src << '&'
          end

          src << 'typeform-embed=embed-widget'
        end
      end
    end
  end
end