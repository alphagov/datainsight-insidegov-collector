namespace :collect do
  desc "Initially collect InsideGov data"
  task :init => [:init_policies]

  task :init_policies do
    rack_env = ENV.fetch('RACK_ENV', 'development')
    root_path = File.expand_path(File.dirname(__FILE__) + "/../../")
    sh %{cd #{root_path} && RACK_ENV=#{rack_env} bundle exec collector --base_url=https://www.gov.uk broadcast}
  end
end
