require "songkick/transport"

class InsideGovCollector
  def response
    client = Songkick::Transport::HttParty.new("http://www.dev.gov.uk/", user_agent: "Datainsight InsideGov Collector", timeout: 10)
    [build_message(client.get("/government/policies.json").data["results"].first)]
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
