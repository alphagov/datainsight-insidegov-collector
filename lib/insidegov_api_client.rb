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

        response = repeat_if_timeout(3) {
          logger.debug {"Fetching URL: #{url}"}
          client.get(url)
        }

        response.data["results"].each do |item|
          yielder.yield(item)
        end

        page = response.data["next_page"]
      end
    end
  end

  def repeat_if_timeout(repeat_no)
    number_of_timeouts = 0
    seconds_to_sleep = 5

    begin
      begin
        response = yield
      rescue Songkick::Transport::TimeoutError, Songkick::Transport::InvalidJSONError => e
        number_of_timeouts += 1
        if number_of_timeouts >= repeat_no
          raise e
        end
        logger.warn("Connection timed out. Request is going to be retried in #{seconds_to_sleep} seconds.")
        sleep(seconds_to_sleep)
      end
    end while response.nil?

    return response
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