require '../lib/youtube.rb'

# @param vids [YouTube::Video]
def printvideos(vids)
  vids.each do |video|
    puts "\n#{video.name} +#{video.rating.up} -#{video.rating.down}\n\t#{video.description}\n\t#{video.uploader}\n\thttp://www.youtube.com/watch?v=#{video.id}"
  end
end

puts 'Enter a search term:'
term = gets.chomp

printvideos YouTube::Service.new().search(term)

