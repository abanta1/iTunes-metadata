# Copyright (c) 2000-2026 Anthony Banta - MIT License
#!/usr/bin/env ruby
# original by @tapbot_paul, this by @abanta
# Don't blame me if this nukes your metadata, formats your drive, kills your kids
# This script goes through any iCloud Matched songs in your iTunes library and tries to update the 
# metadata from the iTunes Store
# Will run against selected tracks or if nothing selected entire library
#
# install the required gems with the following commands
# sudo gem install json
# sudo gem install rb-appscript
# sudo gem install similar_text
# then run the script with "ruby iTunesMetadataMatch.rb"
#
require 'rubygems'
#require 'appscript'
require 'rb-scpt'
require 'json'
require 'open-uri'
require 'similar_text'
require("~/Library/iTunes/tunes.rb")

#	  @iTunes_track.--itunes program--.set('--iTunesAPI--')
class Track
	  attr_reader :iTunes_id
	  attr_reader :iTunes_track
	  
	def initialize(iTunes_track)
	  @iTunes_track = iTunes_track
	  path = @iTunes_track.location.get.path
	  $iTunes_path = @iTunes_track.location.get.path
	  
	  
	  file_string = File.open(path, 'r').read(1024) # song ID usually around 600-700 bytes in
	  index = file_string.index('song')
	  if index
		@iTunes_id = file_string[index+4,4].unpack('N')[0]
	  else
		print "Couldn't find Id for #{@iTunes_track.name.get} in first KB\n trying entire song..."
		file_string = File.open(path, 'r').read
	    index = file_string.index('song')
		if index
			@iTunes_id = file_string[index+4,4].unpack('N')[0]
			puts "Found!"
		else
			puts "Couldn't find Id for #{@iTunes_track.name.get} at all, try to redownload?"
		end
	  end
	  
	end

	def valid?
	  @iTunes_id.nil?
	end
	
end



#iTunes API sets limit to 200 results per query.
appleid = "appleid@domain.com"
WORK_SIZE = 1
STDOUT.sync = true
tracks = []
tracks.clear
links = []
links.clear
plinks =[]
plinks.clear
res_tname = []
res_tname.clear
res_album = []
res_album.clear
res_can = []
res_can.clear
res_oan = []
res_oan.clear
res_artist = []
res_artist.clear

res_tn = []
res_tn.clear
res_tc = []
res_tc.clear
res_genre = []
res_genre.clear
res_dc = []
res_dc.clear
res_dn  = []
res_dn.clear

res_rating = []
res_rating.clear

res_aid = []
res_aid.clear
res_cid = []
res_cid.clear
res_year = []
res_year.clear



result = []
result.clear
j=0

app = Appscript.app.by_name("iTunes", Tunes)

iTunes_tracks = app.selection.get
if iTunes_tracks.count == 0
	abort('Select some tracks')
	
#  iTunes_tracks = app.library_playlists[1].tracks.get
end

puts "Reading #{iTunes_tracks.count} tracks "

iTunes_tracks.each do | iTunes_track |
  begin
    if iTunes_track.kind.get == 'Matched AAC audio file'
    if iTunes_track.grouping.get != '~Disney Vault'
    	puts 'Track already processed through iTMM'
    	next
    end
#    unless iTunes_track.artworks.get.count == 0
#    	print iTunes_track.name.get
#    	puts ' already has artwork'
#    	next
#    end
      track = Track.new(iTunes_track) 
	  unless track.valid?
        tracks << track
        puts '----------------------------------------------------------------------------'
		puts
		puts '----------------------------------------------------------------------------'
		puts
		puts '----------------------------------------------------------------------------'

		trackname = iTunes_track.name.get.gsub(/['."]/,'').gsub(/(Ft.*)/i,'').gsub(/(feat.*)/i,'').gsub(/(\(.*\))/,'').gsub(' ','+')		
		
		puts trackname
		album = iTunes_track.album.get
		artist = iTunes_track.artist.get
		i=0
		
		url = "http://itunes.apple.com/search?entity=song&limit=200&term=#{trackname}&country=us"
		encoded_url = URI.encode(url)
		puts encoded_url
		
		iTunesHash = JSON.parse(open(encoded_url).read)
#		puts iTunesHash
		if iTunesHash['resultCount'] == 0
			puts "\nNone found, wrong name?"
			next
		end
		iTunesHash['results'].each do | result |
			result_name = result['trackCensoredName']
			result_album = result['collectionCensoredName']
			result_can = result['collectionArtistName']
			result_oan = result_artist = result['artistName']
			unless result['collectionArtistName'].nil?
	  			result_artist = result['collectionArtistName']
	 		else
	 			result_artist = result['artistName']
	  		end
	  		result_tc = result['trackCount']
	  		result_tn = result['trackNumber']
	  		result_genre = result['primaryGenreName']
	  		result_dc = result['discCount']
	  		result_dn = result['discNumber']
	  		result_rating = result['trackExplicitness']
	  		
	  		result_aid = result['artistId']
			result_cid = result['collectionId']
			result_year = result['releaseDate']
			result_time = result['trackTimeMillis']
	  		
			result_link = result['artworkUrl100']
			result_prev = result['previewUrl']

#			puts 'ra'			
#			puts result_artist
#			puts artist
#			unless result_artist != artist
#			unless result_artist.similar(artist) < 50
			unless result_oan.similar(artist) < 50
			puts
			i += 1
			puts "#{i})"
			
			print 'Album Artist: '
	  		puts result_can
			print 'Song Artist: '
			puts result_oan
			print 'Album Name: '
			puts result_album
			print 'Track Name: '
			puts result_name
			print 'Track: '
			print result_tn
			print '/'
			puts result_tc
			print 'Genre: '
			puts result_genre
			print 'Disc: '
			print result_dn
			print '/'
			puts result_dc
			print 'Released: '
			puts result_year
			print 'Time: '
			x = result_time / 1000
			seconds = x % 60
			x /= 60
			minutes = x % 60
			print minutes
			print ':'
			if seconds < 10 
			print '0'
			end
			puts seconds
			puts result_rating
			
#			puts result_link

			res_tname << result_name
			res_album << result_album
			res_can << result_can
			res_oan << result_oan
			res_artist << result_artist
			res_tn << result_tn
			res_tc << result_tc
			res_genre << result_genre
			res_dc << result_dc
			res_dn << result_dn
			res_rating << result_rating
			res_aid << result_aid
			res_cid << result_cid
			res_year << result_year
			
			links << result_link
			plinks << result_prev
			j += 1
			else
			next
			end

			
		end
		if j == 0
		puts "\nNone found, wrong name?"
		next
		end
		puts
		print "Enter choice (0 to skip): "
		inp = gets.chomp.to_i
		if inp == 0
		next
		end
		inp -= 1


		begin
			print "Is that correct (y/n/s/p) (s to show art, p to preview): "
			yesno = gets.chomp
			
			case yesno
			when 'y'

#				puts res_tname[inp]
#				puts res_album[inp]
#				puts res_can[inp]
#				puts res_oan[inp]
#				puts res_tc[inp]
#				puts res_tn[inp]
#				puts res_genre[inp]
#				puts res_dc[inp]
#				puts res_dn[inp]
#				puts res_rating[inp]
#				puts res_aid[inp]
#				puts res_cid[inp]
#				puts res_year[inp]

				trackpath = $iTunes_path
				escapepath = Regexp.escape(trackpath).gsub(/([',;=&@!`"])/, '\\\\\1').gsub('\.' , '.')
				open('.image.png', 'wb') do |file|
				  file << open(links[inp].gsub('100x100','600x600')).read
				end
				`AtomicParsley #{escapepath} --artwork REMOVE_ALL --artwork .image.png -W`
#				`mp4art --add .image.png #{escapepath}`
				`rm .image.png`
				
				case res_rating[inp] # Updates explicit tag	  
					when 'explicit'
			  			`AtomicParsley #{escapepath} --artistID #{res_aid[inp]} --albumID #{res_cid[inp]} \
						--appleID "#{appleid}" --year #{res_year[inp]} --advisory explicit -W`
					when 'cleaned'
	  					`AtomicParsley #{escapepath} --artistID #{res_aid[inp]} --albumID #{res_cid[inp]} \
						--appleID "#{appleid}" --year #{res_year[inp]} --advisory clean -W`
					when 'notExplicit'
			  			`AtomicParsley #{escapepath} --artistID #{res_aid[inp]} --albumID #{res_cid[inp]} \
						--appleID "#{appleid}" --year #{res_year[inp]} --advisory remove -W`
					else
				end

				print "Changing"

				iTunes_track.track_count.set(res_tc[inp])
				print "."
				iTunes_track.track_number.set(res_tn[inp])
				print "."
				iTunes_track.genre.set(res_genre[inp])
				print "."
				iTunes_track.disc_count.set(res_dc[inp])
				print "."
				iTunes_track.disc_number.set(res_dn[inp])
				print "."
				iTunes_track.album_artist.set(res_artist[inp])
				print "."
				iTunes_track.artist.set(res_oan[inp])
				print "."
				iTunes_track.album.set(res_album[inp])
				print "."
				iTunes_track.name.set(res_tname[inp])
								
			
			when 'n'
				break
			
			when 's'
				system('open',links[inp].gsub('100x100','600x600'))
				
			when 'p'
				system('open',plinks[inp])
			
			else
				puts "Behave asshole"
			end
		end until yesno == 'y'
		

		
		links.clear
		plinks.clear
		
		res_tname.clear
		res_album.clear
		res_can.clear
		res_oan.clear
		res_artist.clear
		res_tn.clear
		res_tc.clear
		res_genre.clear
		res_dc.clear
		res_dn.clear
		res_rating.clear
		res_aid.clear
		res_cid.clear
		res_year.clear
      end
    end

  rescue StandardError => e
    puts e
  end
end
    
    
    

  
print "\n"
