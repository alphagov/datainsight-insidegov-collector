require "songkick/transport"

require_relative "organisation_parser"

class InsideGovCollector

  def initialize(options)
    @base_url = options[:base_url]
  end

  def response
    client = Songkick::Transport::HttParty.new(@base_url, user_agent: "Datainsight InsideGov Collector", timeout: 10)
    client.get("/government/policies.json").data["results"].map {|policy| build_message(policy)}
  end

  private


  def build_message(policy_info)
    {
        envelope: {collector: "InsideGov Collector"},
        payload: {
            title: policy_info["title"],
            url: policy_info["url"],
            updated_at: policy_info["updated_at"],
            organisations: OrganisationParser.parse(policy_info["organisations"])
        }
    }
  end
end
