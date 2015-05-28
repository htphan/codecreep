$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pry'

require 'codecreep/init_db'
require 'codecreep/github'
require 'codecreep/version'
require 'codecreep/user'


module Codecreep

  class App
    def initialize
      @github = Github.new
    end

    def prompt(message, validator)
      puts message
      input = gets.chomp
      until input =~ validator
        puts "I'm sorry, your input was not recognized."
        puts message
        input = gets.chomp
      end
      input
    end

    def create_user(username)
      user = @github.get_user(username)
      Codecreep::User.find_or_create_by(login: user['login']) do |t|
        t.homepage = user['blog']
        t.company = user['company']
        t.follower_count = user['followers']
        t.following_count = user['following']
        t.repo_count = user['public_repos']
      end
    end

    def fetch(user_array)
      user_array.each do |user|
        create_user(user)
        followers = @github.get_followers(user)
        followers.each do |x|
          create_user(x['login'])
          end
        following = @github.get_following(user)
        following.each do |x|
          create_user(x['login'])
        end
      end
    end

    def analyze
      input = prompt("Which category would you like to view?\n"\
                     "1: Most Popular \n2: Most Friendly \n3: Most Networked",
                     /^[123]$/)
      if input == "1"
        puts "Top 10 Most Popular (most followers):"
        puts "Username -> Followers Count"
        Codecreep::User.order("follower_count DESC").take(10).each do |x|
          puts "#{x.login} -> #{x.follower_count}"
        end
      elsif input == "2"
        puts "Top 10 Most Friendly (most users they follow):"
        puts "Username -> Following Count"
        Codecreep::User.order("following_count DESC").take(10).ach do |x|
          puts "#{x.login} -> #{x.following_count}"
        end
      else
        puts "Top 10 Most Networked (friendly + popular):"
        puts "Username -> (Followers Count + Following Count)"
        Codecreep::User.order('following_count + follower_count DESC').take(10).each do |x|
          puts "#{x.login} -> #{x.follower_count + x.following_count}"
        end
      end
    end

    def run
      input = prompt("Would you like to fetch or analyze (input: f/a):", /^[fa]$/)
      if input == "f"
        users = prompt("What are the users you would like to fetch?\n"\
                       " (seperate each user by a comma and a space):", 
                       /^(\w+[,]\s)+\w+$|^\w+$/)
        user_array = users.split(", ")
        self.fetch(user_array)
      else
        self.analyze
      end
    end

  end
end

app = Codecreep::App.new
app.run
