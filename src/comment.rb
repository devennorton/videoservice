#require "rubygems"
#require "bundler/setup"

require_relative '../lib/youtube.rb'

#Print out video information in a not totally useless fashion
# @param vids [YouTube::Video]
def printvideos(vids)
  vids.each do |video|
    puts "\n#{video.name} +#{video.rating.up} -#{video.rating.down}\n\t#{video.description}\n\t#{video.uploader}\n\thttp://www.youtube.com/watch?v=#{video.id}"
  end
end

#make a comment on a video
def comment (name, comm, user, pw)
  yt = YouTube::Service.new()
  printvideos vids = yt.search(name,1,1)
  yt.comment(vids[0], comm, YouTube::User.new(user, pw))
end


#just a very boring set of prompts for data.
puts 'What video do you want to comment on?'
name = gets.chomp

puts "what do you think of #{name}"
comm = gets.chomp

puts 'What is your username?'
user = gets.chomp

puts 'What is your password?'
pw = gets.chomp

comment(name, comm, user, pw)

