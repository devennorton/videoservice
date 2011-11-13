require '..\lib\youtube.rb'


#not a real unit test just some functional tests for debugging

def test()
  me = YouTube::User.new('deven.norton', 'javadoc')
  yt = YouTube::Service.new()
  ret = yt.search('PON PON PON')
  puts me.token
  ret.each {|video| puts "\n#{video.name} +#{video.rating.up} -#{video.rating.down}\n\t#{video.description}\n\t#{video.uploader}\n\thttp://www.youtube.com/watch?v=#{video.id}"}

  begin
    puts me.comment(ret[0], "killroy was here!!!!!!")
    puts me.upload(YouTube::Uploadable.new("../src/test"))
  rescue YouTube::BadPasswordError => e
    p e.message
  end


end

test