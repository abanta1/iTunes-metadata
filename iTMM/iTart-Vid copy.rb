#!/usr/bin/env ruby
#
# install the required gems with the following commands
# sudo gem install json
# sudo gem install similar_text
# then run the script with "ruby iTArt-Vid.rb"
require 'json'
require 'open-uri'
require 'similar_text'

home = Dir.home
Dir.chdir("/Volumes/Media/Movies/untitled folder")
curdir = Dir.pwd

vids = []

vidfilesv = File.join("**","*.m4v")
vidfilesp = File.join("**","*.mp4")

vidsp = Dir.glob(vidfilesp)
vidsv = Dir.glob(vidfilesv)


vidsp.each do | vidp |
  begin
    vids << vidp
  end
end

vidsv.each do | vidv |
  begin
    vids << vidv
  end
end
  

#puts vids
print "Processing "
print vids.count
puts " files"
#puts "----------"

vids.each do | vid |
  begin

#	print vid
#	puts " + vid"
# Full file path
    f=curdir + "/" + vid.to_s.gsub(/["\[\]]/, '')
#    puts f
    
# Filename with extension
    fileext=f.gsub(/.*\//, '')
#    print fileext
#	 puts " + ext"
    
# Filename without extension    
    filenoext=fileext.gsub(/\.m4v/, '').gsub(/\.mp4/, '')
#    print filenoext
#    puts " + noext"
    
# File path only    
    filepat=f.gsub(/#{fileext}/, '')
#	 print filepat
#	 puts " + path"
	
# Filename without parentheses	
	noparent=filenoext.gsub(/[\(\)]/, '')
#	 print noparent
#	 puts " + noparenth"

# Set year and epsid before removing	
	epsid=noparent[/\.(s?[0-9]{0,2}\.?e[0-9]{1,3})/i, 1]	
	year=noparent[/[12][0-9]{3}/]
	
#	 print epsid
#	 puts " + epsid"
#	 print year
#	 puts " + year"

# Filename without episode ID
	noepsid=noparent
	unless epsid.nil?
	  noepsid=noparent.gsub(/\.#{epsid}.*/i, '')
	end
#	 print noepsid
#	puts " + noeid"

	
# Filename without year
	noyear=noepsid
	unless year.nil?
	  noyear=noepsid.gsub(/\.[12][0-9]{3}.*/, '')
	end
#	 print noyear
#	 puts " + ny"

	
# Is it tv or movie
	entityv="movie"
	opfile="#{home}/Desktop/pics/#{noyear}.jpg"

# Set to TV show, set episode ID and ssn num
	unless epsid.nil?
	  ssnnum=epsid[/s?([0-9]{0,2})/i, 1]
	  if ssnnum.to_i < 10
		ssnnum=ssnnum[/\d(\d)/i, 1]
	  end
	  entityv="tvSeason"
	  opfile="#{home}/Desktop/pics/#{noyear}.#{ssnnum}.jpg"
#	  puts ssnnum + " ssn"
	end
	
#	 puts opfile
	
	fileshowname=noyear.gsub(/[ \.]/, '+')
#	puts fileshowname
	
	iTunesHash = JSON.parse(open("http://itunes.apple.com/search?entity=#{entityv}&term=#{fileshowname}").read)
#	 puts iTunesHash
	if iTunesHash['resultCount'] == 0
		puts "Zero results for #{fileshowname.gsub(/[+]/, ' ')} in US Store"
		next
	end
	
	iTunesHash['results'].each do | result |
      
      unless epsid.nil?
      	unless result['artistName'].similar(fileshowname.gsub(/[+]/, ' ')) < 80
      	  if result['collectionName'].include? "Season #{ssnnum}"
      	  	arturl=result['artworkUrl100'].sub(/100x100/, '600x600')
      	  	print "Downloading art for #{fileshowname.gsub(/[+]/, ' ')}, "
      	  	open(opfile, 'w+') do |file|
			  file << open(arturl).read
			end
			puts " Done"
      	  	break
      	  end
      	else
      	  next
      	end
      
      else
#      puts result['trackName']
#      puts fileshowname
#      puts 'a'
      fileshownamet=fileshowname.gsub(/[+]/, ' ')

      	if (result['trackName'].similar(fileshownamet) > 80) || ((result['trackName'].include? fileshownamet) == true)
      	  resyear=result['releaseDate'][/[12][0-9]{3}/].to_i
      	  resyrhi = resyear + 2
      	  resyrlo = resyear - 2
      	  if (resyrlo..resyrhi) === resyear
      	  	arturl=result['artworkUrl100'].sub(/100x100/, '600x600')
      	  	print "Downloading art for #{fileshownamet} - #{resyear}, "
      	  	#open(opfile, 'w+') do |file|
			#  file << open(arturl).read
			#end
			puts " Done"
      	  	break
      	  end 	  
        else
		  next
        end
      end
	end
       
  rescue StandardError => e
    puts e
  end
end





















