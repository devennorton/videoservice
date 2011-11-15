require_relative '../lib/youtube.rb'
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
  opts.on( '-n', '--number NUMBER', 'number of videos to list (default 1)') {|num| options[:count] = num}

  options[:comment] = false
  opts.on('-c', '--comment COMMENT', 'comment on the first video using the supplied term') {|com| options[:comment] = com}

  options[:index] = 1
  opts.on('-i', '--index INDEX', 'the index of the fist video to return') {|index| options[:index] = index}

  options[:name] = ''
  opts.on('-u', '--user NAME', 'A username') {|name| options[:name] = name}

  options[:pw] = ''
  opts.on('-p', '--password PASSWORD', 'A password') {|pw| options[:pw] = pw}

  options[:up] = ''
  opts.on('-u', '--upload FILE', 'A file to be uploaded') {|up| options[:up] = up}
  
  ots.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end

end.parse!

if options[:comment]
  unless options[:name]
    p "Input a username:"
    options[:name] = gets.chomp
  end
  unless options[:pw]
    p "Input a password:"
    options[:pw] = gets.chomp
  end

  yt = YouTube::Service.new
  printvideos vids = yt.search(ARGV.join(' '),1,1)
  begin
    yt.comment(vids[0], options[:comment], YouTube::User.new(options[:name], options[:pw]))
  rescue YouTube::BadPasswordError => e
    p e.message
  end

elsif options[:up]
  unless options[:name]
    p "Input a username:"
    options[:name] = gets.chomp
  end

  unless options[:pw]
    p "Input a password:"
    options[:pw] = gets.chomp
  end

  yt = YouTube::Service.new
  printvideos vids = yt.search(ARGV.join(' '),1,1)
  begin
    yt.upload(options[:up], YouTube::User.new(options[:name], options[:pw]))
  rescue YouTube::BadPasswordError => e
    p e.message
  end
else
  puts options[:count]
  printvideos YouTube::Service.new.search(ARGV.join(' '), options[:index], options[:count])
end


