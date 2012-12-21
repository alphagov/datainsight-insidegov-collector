require "spec_helper"
require_relative "../../lib/insidegov_collector"

describe "insidegov collector" do
  it "should return a list of response messages" do

    policies = {
        count: 1,
        current_page: 1,
        total_pages: 1,
        total_count: 1,
        results: [
            {
                id: 1,
                type: "policy",
                title: "Transport policy",
                url: "/government/policies/transport-policy",
                organisations: "<abbr title=\"Department for Communities and Local Government\">DCLG</abbr>",
                updated_at: "2012-05-28T10:26:49+01:00",
                topics: "anything"
            }
        ]
    }

    FakeWeb.register_uri(:get, "http://www.dev.gov.uk/government/policies.json", body: policies.to_json)

    collector = InsideGovCollector.new

    response = collector.response

    response.should be_a(Array)
    response.should have(1).message

    message = response.first
    message[:envelope][:collector].should == "InsideGov Collector"
    message[:payload][:title].should == "Transport policy"
    message[:payload][:url].should == "/government/policies/transport-policy"
    message[:payload][:updated_at].should == "2012-05-28T10:26:49+01:00"
    message[:payload][:organisations].should have(1).item
    message[:payload][:organisations].first[:name].should == "Department for Communities and Local Government"
    message[:payload][:organisations].first[:abbreviation].should == "DCLG"
  end
end