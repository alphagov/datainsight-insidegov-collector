require "spec_helper"
require_relative "../../lib/organisation_parser"

describe OrganisationParser do

  it "should parse an empty string as empty list" do
    OrganisationParser.parse("").should == []
  end

  it "should parse an abbr element to an organisation" do
    OrganisationParser.parse("<abbr title=\"foo bar zap\">FBZ</abbr>")
      .should == [{name: "foo bar zap", abbreviation: "FBZ"}]
  end

  it "should parse multiple abbr element to organisations" do
    string = %{<abbr title="Ministry of Silly Walks">MoSW</abbr>, <abbr title="Ministry of Magic">MoM</abbr> and <abbr title="Department of Coffee">DoC</abbr>"}
    OrganisationParser.parse(string).should == [
        {name: "Ministry of Silly Walks", abbreviation: "MoSW"},
        {name: "Ministry of Magic", abbreviation: "MoM"},
        {name: "Department of Coffee", abbreviation: "DoC"}
    ]
  end

  it "should parse nil as empty list" do
    OrganisationParser.parse(nil).should == []
  end

  it "should raise an error if not given a string" do
    lambda{ OrganisationParser.parse({}) }.should raise_error
  end

  it "should raise an error if given string contains unexpected content" do
    lambda{ OrganisationParser.parse("a string with no abbr") }.should raise_error
  end

end