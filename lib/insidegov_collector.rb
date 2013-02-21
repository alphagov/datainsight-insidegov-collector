require "songkick/transport"
require "datainsight/collector/message_builder"

require_relative "organisation_parser"
require_relative "insidegov_api_client"

class InsideGovCollector

  def initialize(options)
    raise "No base url provided" if options[:base_url].nil?
    @client = InsideGovApiClient.new(options[:base_url])
    @message_builder = DataInsight::Collector::MessageBuilder.new("InsideGov")
  end

  def messages
    Enumerator.new do |yielder|
      @client.results("policies").each do |policy|
        policy["type"] = "policy"
        yielder.yield(build_message(policy))
      end
      @client.results("announcements").each do |announcement|
        yielder.yield(build_message(announcement))
      end
    end
  end

  private
  def build_message(artefact)
    @message_builder.build(
      title: artefact["title"],
      type: artefact["type"],
      url: artefact["url"],
      updated_at: artefact["public_timestamp"],
      organisations: organisations(artefact)
    )
  end

  def organisations(artefact)
    begin
      OrganisationParser.parse(artefact["organisations"])
    rescue Exception => e
      logger.error(e)
      ""
    end
  end
end
