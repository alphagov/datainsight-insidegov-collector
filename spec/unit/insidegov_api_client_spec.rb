require_relative "../spec_helper"
require_relative "../../lib/insidegov_api_client"

describe InsideGovApiClient do
  it "should return a single page of items" do
    payload = {
      count: 2,
      current_page: 1,
      total_pages: 1,
      total_count: 2,
      results: [
        {
          "id" => 1,
          "name" => "item one"
        },
        {
          "id" => 2,
          "name" => "item two"
        },
      ]
    }
    url = "http://insidegov/government/items.json?direction=alphabetical&page=1"
    FakeWeb.register_uri(:get, url, body: payload.to_json)

    client = InsideGovApiClient.new("http://insidegov/")

    iterator = client.results("items")

    items = iterator.to_a

    items.should have(2).items

    items[0].should == payload[:results][0]
    items[1].should == payload[:results][1]
  end

  it "should return two pages of items" do
    payload = {
      count: 2,
      current_page: 1,
      total_pages: 2,
      total_count: 4,
      results: [
        {
          "id" => 1,
          "name" => "item one"
        },
        {
          "id" => 2,
          "name" => "item two"
        },
      ],
      next_page: 2
    }

    url = "http://insidegov/government/items.json?direction=alphabetical&page=1"
    FakeWeb.register_uri(:get, url, body: payload.to_json)

    payload[:current_page] = 2
    payload.delete(:next_page)
    payload[:previous_page] = 1

    url = "http://insidegov/government/items.json?direction=alphabetical&page=2"
    FakeWeb.register_uri(:get, url, body: payload.to_json)

    client = InsideGovApiClient.new("http://insidegov/")

    iterator = client.results("items")

    items = iterator.to_a

    items.should have(4).items

    items[0].should == payload[:results][0]
    items[1].should == payload[:results][1]
    items[2].should == payload[:results][0]
    items[3].should == payload[:results][1]
  end

  it "should repeat the request after a timeout" do
    url = "http://insidegov/government/items.json?direction=alphabetical&page=1"
    FakeWeb.register_uri(:get, url, [{:exception => Songkick::Transport::TimeoutError}, {:body => {results: []}.to_json}])

    client = InsideGovApiClientNoSleep.new("http://insidegov/")

    expect { client.results("items").to_a }.to_not raise_error
  end

  it "should fail after 3 retries" do
    url = "http://insidegov/government/items.json?direction=alphabetical&page=1"
    FakeWeb.register_uri(:get, url,
                         [{:exception => Songkick::Transport::TimeoutError},
                          {:exception => Songkick::Transport::TimeoutError},
                          {:exception => Songkick::Transport::TimeoutError},
                          {:body => {results: []}.to_json}])

    client = InsideGovApiClientNoSleep.new("http://insidegov/")

    expect { client.results("items").to_a }.to raise_error(Songkick::Transport::TimeoutError)
  end

  class InsideGovApiClientNoSleep < InsideGovApiClient
    def initialize(url)
      super(url)
    end

    def sleep(no_of_seconds)
    end
  end
end