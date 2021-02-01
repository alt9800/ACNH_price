# twitter自動リプライbot用

require "twitter"
require 'yaml'
require "csv"


def mentionTimeline
  just_time = Time.now
  search_span = 60.0
  @client.mentions_timeline.each do |tweet|
    if tweet.is_a?(Twitter::Tweet)
      word = tweet.text.split(" ")[1]
      CSV.foreach("./list.csv") do |row|
        if row[1] == word && tweet_id2time(tweet.id) >= just_time -  search_span
          comment = "#{row[1]}の出現時期は#{row[2]}、#{row[3]}で#{row[4]}にみられます。\n#{row[5]}ベルで売れます。"
          @client.update("@#{tweet.user.screen_name}\n#{comment}", options = {:in_reply_to_status_id => tweet.id})
        end 
      end
    end
  end
end

# yamlから自分のキーを読み込んでくる
CONFIG = YAML.load_file('config.yaml')

user_id = CONFIG["user_id"]
consumer_key = CONFIG["consumer_key"]
consumer_secret = CONFIG["consumer_secret"]
access_token = CONFIG["access_token"]
access_token_secret = CONFIG["access_token_secret"]
# count = CONFIG["count"]


@client = Twitter::REST::Client.new do |config|
  config.consumer_key    = consumer_key
  config.consumer_secret   = consumer_secret
  config.access_token    = access_token
  config.access_token_secret = access_token_secret
end

=begin
# いつかストリームをうまく使ってタイムライン監視をしたい
stream_client = Twitter::Streaming::Client.new do |config|
  config.consumer_key    = consumer_key
  config.consumer_secret   = consumer_secret
  config.access_token    = access_token
  config.access_token_secret = access_token_secret
end
=end

mentionTimeline
