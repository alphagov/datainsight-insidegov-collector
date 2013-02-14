require "songkick/transport"
require "datainsight/collector/message_builder"

require_relative "organisation_parser"
require_relative "insidegov_api_client"

class InsideGovCollector

  def initialize(options)
    raise "No base url provided" if options[:base_url].nil?
    @base_url = options[:base_url]
    @message_builder = DataInsight::Collector::MessageBuilder.new("InsideGov")
  end

  def messages
    Enumerator.new do |yielder|
      InsideGovApiClient.new(@base_url).results("policies").each do |policy|
        yielder.yield(build_message(policy))
      end
    end
  end

  private
  def build_message(policy_info)
    @message_builder.build(
      title: policy_info["title"],
      url: policy_info["url"],
      updated_at: policy_info["public_timestamp"],
      organisations: OrganisationParser.parse(policy_info["organisations"])
    )
  end
end
