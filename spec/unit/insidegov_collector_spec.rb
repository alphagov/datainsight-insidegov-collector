require "spec_helper"
require_relative "../../lib/insidegov_collector"

describe "insidegov collector" do
  it "should return a single page of policy messages" do

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

    url = "http://insidegov/government/policies.json?direction=alphabetical&page=1"
    FakeWeb.register_uri(:get, url, body: policies.to_json)

    collector = InsideGovCollector.new({base_url: "http://insidegov/"})

    policy_iterator = collector.messages
    policy_iterator.should be_a(InsideGovCollector::PolicyIterator)


    messages = policy_iterator.to_a

    messages.should have(2).messages

    message = messages.first
    message[:envelope][:collector].should == "InsideGov"
    message[:payload][:title].should == "Transport policy"
    message[:payload][:url].should == "/government/policies/transport-policy"
    message[:payload][:updated_at].should == "2012-05-28T10:26:49+01:00"
    message[:payload][:organisations].should have(1).item
    message[:payload][:organisations].first[:name].should == "Department for Communities and Local Government"
    message[:payload][:organisations].first[:abbreviation].should == "DCLG"

    second_message = messages[1]
    second_message[:envelope][:collector].should == "InsideGov"
    second_message[:payload][:title].should == "Another policy"
    second_message[:payload][:url].should == "/government/policies/another-policy"
    second_message[:payload][:updated_at].should == "2012-12-21T23:59:59+00:00"
    second_message[:payload][:organisations].should have(1).item
    second_message[:payload][:organisations].first[:name].should == "Department for Random Stuff"
    second_message[:payload][:organisations].first[:abbreviation].should == "DRS"
  end

  it "should return two pages of policy messages" do
    policies = {
      count: 2,
      current_page: 1,
      total_pages: 2,
      total_count: 4,
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
      ],
      next_page: 2
    }

    url = "http://insidegov/government/policies.json?direction=alphabetical&page=1"
    FakeWeb.register_uri(:get, url, body: policies.to_json)

    policies[:current_page] = 2
    policies.delete(:next_page)
    policies[:previous_page] = 1

    url = "http://insidegov/government/policies.json?direction=alphabetical&page=2"
    FakeWeb.register_uri(:get, url, body: policies.to_json)

    collector = InsideGovCollector.new(base_url: "http://insidegov/")

    policy_iterator = collector.messages
    policy_iterator.should be_a(InsideGovCollector::PolicyIterator)

    messages = policy_iterator.to_a

    messages.should have(4).messages
  end
end