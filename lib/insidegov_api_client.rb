require "songkick/transport"

class InsideGovApiClient
  def initialize(base_url)
    @base_url = base_url
  end

  def results(path)
    page = 1

    Enumerator.new do |yielder|
      until page.nil?
        url = build_url(path, page)

        logger.debug {"Fetching URL: #{url}"}

        response = client.get(url)

        response.data["results"].each do |item|
          yielder.yield(item)
        end

        page = response.data["next_page"]
      end
    end
  end

  def client
    @client ||= Songkick::Transport::HttParty.new(
      @base_url,
      user_agent: "Datainsight InsideGov Collector",
      timeout: 10
    )
  end

  def build_url(path, page)
    "/government/#{path}.json?direction=alphabetical&page=#{page}"
  end

end