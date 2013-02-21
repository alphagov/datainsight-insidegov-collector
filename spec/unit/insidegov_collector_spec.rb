require "spec_helper"
require_relative "../../lib/insidegov_collector"

describe "insidegov collector" do
  before(:each) do
    @empty_result = {:results => []}
    @artefact = {
      "title" => "Example title",
      "type" => "mytype",
      "url" => "http://example/",
      "public_timestamp" => "2012-12-12T12:12:12",
      "organisations" => "<abbr title=\"Department for Communities and Local Government\">DCLG</abbr>"
    }
  end

  it "should return policies" do
    InsideGovApiClient.any_instance
      .should_receive(:results)
      .with("policies")
      .and_return([@artefact, @artefact])
    InsideGovApiClient.any_instance
      .should_receive(:results)
      .with("announcements")
      .and_return([])

    collector = InsideGovCollector.new({base_url: "http://insidegov/"})

    messages = collector.messages.to_a

    messages.should have(2).items

    message = messages.first
    message[:envelope][:collector].should == "InsideGov"
    message[:payload][:title].should == "Example title"
    message[:payload][:url].should == "http://example/"
    message[:payload][:type].should == "policy"
    message[:payload][:updated_at].should == "2012-12-12T12:12:12"
    message[:payload][:organisations].should have(1).item
    message[:payload][:organisations].first[:name].should == "Department for Communities and Local Government"
    message[:payload][:organisations].first[:abbreviation].should == "DCLG"
  end

  it "should return announcements" do
    InsideGovApiClient.any_instance
    .should_receive(:results)
    .with("policies")
    .and_return([])
    InsideGovApiClient.any_instance
    .should_receive(:results)
    .with("announcements")
    .and_return([@artefact, @artefact])

    collector = InsideGovCollector.new({base_url: "http://insidegov/"})

    messages = collector.messages.to_a

    messages.should have(2).items

    message = messages.first
    message[:envelope][:collector].should == "InsideGov"
    message[:payload][:title].should == "Example title"
    message[:payload][:url].should == "http://example/"
    message[:payload][:type].should == "mytype"
    message[:payload][:updated_at].should == "2012-12-12T12:12:12"
    message[:payload][:organisations].should have(1).item
    message[:payload][:organisations].first[:name].should == "Department for Communities and Local Government"
    message[:payload][:organisations].first[:abbreviation].should == "DCLG"
  end

  it "should not fail if there are no organisations" do
    @artefact["organisations"] = ""

    InsideGovApiClient.any_instance
    .should_receive(:results)
    .with("policies")
    .and_return([@artefact])
    InsideGovApiClient.any_instance
    .should_receive(:results)
    .with("announcements")
    .and_return([])

    collector = InsideGovCollector.new({base_url: "http://insidegov/"})

    lambda { collector.messages.to_a }.should_not raise_error
  end
end