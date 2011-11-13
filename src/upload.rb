require "rubygems"
require "bundler/setup"
require '../lib/youtube.rb'

def upload (name, user, pw)
  YouTube::User.new(user, pw).upload name
end

puts 'What video do you want to upload on?'
name = gets.chomp

puts 'What is your username?'
user = gets.chomp

puts 'What is your password?'
pw = gets.chomp

upload(name, user, pw)

