require "songkick/transport"

require_relative "organisation_parser"

class InsideGovCollector

  def initialize(options)
    @base_url = options[:base_url]
  end

  def messages
    PolicyIterator.new(@base_url)
  end

  private

  class PolicyIterator
    include Enumerable

    def initialize(base_url)
      @base_url = base_url
    end

    def each
      next_page = 1

      until next_page.nil?
        response = client.get(build_url(next_page))

        response.data["results"].each do |policy|
          yield build_message(policy)
        end

        next_page = response.data["next_page"]
      end
    end

    def client
      @client ||= Songkick::Transport::HttParty.new(
        @base_url,
        user_agent: "Datainsight InsideGov Collector",
        timeout: 10
      )
    end

    def build_url(page)
      "/government/policies.json?direction=alphabetical&page=#{page}"
    end

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

end
