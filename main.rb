require 'coinbase/wallet'
require 'yaml'
require 'certified'
require 'vcr'
require 'webmock'

VCR.configure do |config|
  config.cassette_library_dir = 'casettes'
  config.hook_into :webmock
end

# Load config
config = YAML.load_file('config.yml')

username = config['username']
api_key = config['api_key']
api_secret = config['api_secret']

puts "Using configuration for #{username}, with API key #{api_key} and secret #{api_secret}"

# Create a new client
coinbaseClient = Coinbase::Wallet::Client.new(api_key: api_key, api_secret:api_secret)


# Use VCR to record/replay API calls to Coinbase
VCR.use_cassette('coinbase_accounts') do
  begin
    account = coinbaseClient.accounts
    account.each do |account|
      puts "Balance: #{account.balance.amount} #{account.balance.currency}"
    end

  rescue Coinbase::Wallet::APIError  => e
    puts "Coinbase wallet error: #{e.message}"

  rescue OpenSSL::SSL::SSLError => ssl_error
    puts "SSL error: #{ssl_error.message}"
  end

end