require "spec_helper"
require_relative "../../lib/insidegov_collector"

describe "insidegov collector" do
  it "should return a list of response messages" do

    policies = {
        count: 2,
        current_page: 1,
        total_pages: 1,
        total_count: 2,
        results: [
            {
                id: 1,
                type: "policy",
                title: "Transport policy",
                url: "/government/policies/transport-policy",
                organisations: "<abbr title=\"Department for Communities and Local Government\">DCLG</abbr>",
                updated_at: "2012-05-28T10:26:49+01:00",
                topics: "anything"
            },
            {
                id: 2,
                type: "policy",
                title: "Another policy",
                url: "/government/policies/another-policy",
                organisations: "<abbr title=\"Department for Random Stuff\">DRS</abbr>",
                updated_at: "2012-12-21T23:59:59+00:00",
                topics: "anything"
            },
        ]
    }

    FakeWeb.register_uri(:get, "http://www.dev.gov.uk/government/policies.json", body: policies.to_json)

    collector = InsideGovCollector.new

    response = collector.response

    response.should be_a(Array)
    response.should have(2).messages

    message = response.first
    message[:envelope][:collector].should == "InsideGov Collector"
    message[:payload][:title].should == "Transport policy"
    message[:payload][:url].should == "/government/policies/transport-policy"
    message[:payload][:updated_at].should == "2012-05-28T10:26:49+01:00"
    message[:payload][:organisations].should have(1).item
    message[:payload][:organisations].first[:name].should == "Department for Communities and Local Government"
    message[:payload][:organisations].first[:abbreviation].should == "DCLG"

    second_message = response[1]
    second_message[:envelope][:collector].should == "InsideGov Collector"
    second_message[:payload][:title].should == "Another policy"
    second_message[:payload][:url].should == "/government/policies/another-policy"
    second_message[:payload][:updated_at].should == "2012-12-21T23:59:59+00:00"
    second_message[:payload][:organisations].should have(1).item
    second_message[:payload][:organisations].first[:name].should == "Department for Random Stuff"
    second_message[:payload][:organisations].first[:abbreviation].should == "DRS"
  end
end