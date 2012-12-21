require "nokogiri"

module OrganisationParser

  def self.parse(some_string)
    return [] if some_string.nil?
    raise "Expected a string, got #{some_string}" unless some_string.is_a?(String)

    organisations = Nokogiri::HTML(some_string)
    abbr_tags = organisations.css("abbr")
    raise "No abbr tag found in: #{some_string}" unless abbr_tags.length > 0 or some_string.empty?
    abbr_tags.map {|abbr| {abbreviation: abbr.content, name: abbr.attr("title")}}
  end

end