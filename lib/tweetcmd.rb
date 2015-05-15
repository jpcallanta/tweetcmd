# Main TweetCmd class
require 'twitter'
require 'colorize'

class TweetCmd
  def initialize(consumer_key, consumer_key_secret, access_token, access_token_secret, user)
    @username = user
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = consumer_key
      config.consumer_secret = consumer_key_secret
      config.access_token = access_token
      config.access_token_secret = access_token_secret
    end
  end

  def trap_int(signal)
    Signal.trap(signal) {
      puts ''
      exit 0
    }
  end

  def repeater(char, repeat_num)
    return (char * repeat_num)
  end

  def show_usage
    puts 'Usage:'
    puts 'tweetcmd <command> [arguments]'.colorize(:light_gray)
    puts ''
    puts 'Commands:'.colorize(:light_gray)
    puts 'home-timeline|user-timeline'.colorize(:light_gray)
  end

  def display_tweets(streams)
    streams.each do |stream|
      tweet = "#{stream[:user]}: #{stream[:tweet]}".colorize(:blue)

      puts tweet
      puts ''
    end
  end

  def stream_user(user, delay = 120)
    self.trap_int('INT')

    begin
      user_timeline = @client.user_timeline(user, count: 10)
    rescue => e
      puts e.message.colorize(:red)
      exit 1
    end

    while true
      streams = []
      header = "#{user} timeline"

      system('clear')
      puts header.colorize(color: :yellow, background: :gray)
      puts self.repeater('=', header.length).colorize(:gray)
      puts ''

      user_timeline.each do |tweet|
        streams << {
          id: tweet.id,
          user: tweet.user.name,
          tweet: tweet.full_text
        }
      end

      self.display_tweets(streams)
      sleep(delay)
    end
  end

  def stream_home(delay = 120)
    self.trap_int('INT')

    begin
      home_timeline = @client.home_timeline(count: 10)
    rescue => e
      puts e.message.colorize(:red)
      exit 1
    end

    while true
      streams = []
      header = "My Home Timeline (#{@username})"

      system('clear')
      puts header.colorize(:yellow)
      puts self.repeater('=', header.length).colorize(:gray)
      puts ''

      home_timeline.each do |tweet|
        streams << {
          id: tweet.id,
          user: tweet.user.name,
          tweet: tweet.full_text
        }
      end

      self.display_tweets(streams)
      sleep(delay)
    end
  end
end
