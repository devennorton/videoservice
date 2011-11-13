require '../lib/youtube.rb'
require 'optparse'

# @param vids [YouTube::Video]
def printvideos(vids)
  vids.each do |video|
    puts "#{video.name} +#{video.rating.up} -#{video.rating.down}\n\t#{video.description}\n\t#{video.uploader}\n\thttp://www.youtube.com/watch?v=#{video.id}"
  end
end

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = 'Usage: yt.rb [options] video'

  options[:count] = 10
  opts.on( '-n', '--number', Integer, 'number of videos to list (default 1)') {|num| options[:count] = num}

  options[:comment] = false
  opts.on('-c', '--comment', String, 'comment on the first video using the supplied term') {|com| options[:comment] = com}

  options[:index] = 1
  opts.on('-i', '--index', Integer, 'the index of the fist video to return') {|index| options[:index] = index}

  options[:name] = ''
  opts.on('-u', '--user', String, 'A username') {|name| option[:name] = name}

  options[:pw] = ''
  opts.on('-p', '--password', String, 'A password') {|pw| optioin[:pw]= pw}

end.parse!

if options[:comment] and options[:name] and options[:pw]
  yt = YouTube::Service.new()
  printvideos vids = yt.search(ARGV.join(' '),1,1)
  yt.comment(vids[0], options[:comment], YouTube::User.new(options[:name], options[:pw]))
else
  puts options[:count]
  printvideos YouTube::Service.new().search(ARGV.join(' '), options[:index], options[:count])
end


