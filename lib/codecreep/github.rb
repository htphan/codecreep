require 'httparty'
require 'pry'

module Codecreep
  class Github
    include HTTParty
    base_uri 'https://api.github.com'
    basic_auth ENV['GH_USER'], ENV['GH_PASS']

    def get_user(username)
      self.class.get("/users/#{username}")
    end

    def follows(username, page)
      self.class.get("/users/#{username}/followers?page=#{page}&per_page=100")  
    end

    def get_followers(username)
      # self.class.get("/users/#{username}/followers?per_page=100")
      page = 1
      followers = []
      followers = followers + self.follows(username, page)
      until followers.length % 100 != 0
        if self.follows(username, page)[0] != nil
          page += 1
          followers = followers + self.follows(username, page)
          puts "#{page}"
        end
      end
      followers

      # response.headers['link'].split(', ')[1].match(/page=(\d+)/)[1].to_i (takes the first one)

    end

    def get_following(username)
      self.class.get("/users/#{username}/following?per_page=100")      
    end
  end
end
