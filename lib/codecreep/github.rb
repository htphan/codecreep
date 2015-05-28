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

    def get_followers(username)
      self.class.get("/users/#{username}/followers?page=1&per_page=100")
      # page = 1
      # get_follows = self.class.get("/users/#{username}/followers?page=#{page}&per_page=100")
      # followers = {}
      # followers.merge!(get_follows) 
      # until followers.length % 100 != 0
      #   page += 1
      #   followers.merge!(get_follows)
      # end
      # followers
    end

    def get_following(username)
      self.class.get("users/#{username}/following?page=1&per_page=100")      
    end
  end
end
