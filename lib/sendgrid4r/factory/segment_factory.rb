# -*- encoding: utf-8 -*-

module SendGrid4r
  module Factory
    #
    # SendGrid Web API v3 Segment Factory Class implementation
    #
    class SegmentFactory
      def create(name: nil, list_id: nil, conditions:)
        segment = REST::MarketingCampaigns::Contacts::Segments::Segment.new(
          nil,
          name,
          list_id,
          conditions,
          nil
        )
        segment.to_h.reject { |_key, value| value.nil? }
      end
    end
  end
end
