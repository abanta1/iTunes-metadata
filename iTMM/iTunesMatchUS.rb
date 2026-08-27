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
# then run the script with "ruby iTunesMetadataMatch.rb"
#
require 'rubygems'
require 'appscript'
require 'json'
require 'open-uri'
require("~/Library/iTunes/tunes.rb")

#	  @iTunes_track.--itunes program--.set('--iTunesAPI--')
class Track
	  attr_reader :iTunes_id
	  attr_reader :iTunes_track
	  
	def initialize(iTunes_track)
	  @iTunes_track = iTunes_track
	  path = @iTunes_track.location.get.path
	  file_string = File.open(path, 'r').read(1024) # song ID usually around 600-700 bytes in
	  index = file_string.index('song')
	  if index
		@iTunes_id = file_string[index+4,4].unpack('N')[0]
		@iTunes_track.comment.set("iTunes ID: #{@iTunes_id}")
	  else
		print "Couldn't find Id for #{@iTunes_track.name.get} in first KB\n trying entire song..."
		file_string = File.open(path, 'r').read
	    index = file_string.index('song')
		if index
			@iTunes_id = file_string[index+4,4].unpack('N')[0]
			@iTunes_track.comment.set("iTunes ID: #{@iTunes_id}")
			puts "Found!"
			`echo "#{path}" >> ~/Desktop/path.txt`
		else
			puts "Couldn't find Id for #{@iTunes_track.name.get} at all, try to redownload?"
		end
	  end
	end

	def valid?
	  @iTunes_id.nil?
	end
	
	def sterilize()
	  trackpath = "#{@iTunes_track.location.get.path}"
	  escapepath = Regexp.escape(trackpath).gsub(/([',;=&@!`])/, '\\\\\1')
	  `AtomicParsley #{escapepath} -PW`
	end
	
	def notfound()
	  @iTunes_track.grouping.set('~Disney Vault')
	end

	def update_track(result, cname) # Updates settable iTunes tags
	  cnName = Regexp.escape(cname).gsub(/([',;=&@!`])/, '\\\\\1')
	
	  @iTunes_track.grouping.set(cnName.gsub('\\',''))	  
	  unless result['primaryGenreName'].nil?
	  	@iTunes_track.genre.set(result['primaryGenreName'])
	  else @iTunes_track.genre.set("")
	  end
	  @iTunes_track.disc_count.set(result['discCount'])
	  @iTunes_track.track_count.set(result['trackCount'])	  
	  
	  @iTunes_track.artist.set(result['artistName'])
	  @iTunes_track.track_number.set(result['trackNumber'])
	  @iTunes_track.disc_number.set(result['discNumber'])
	  @iTunes_track.name.set(result['trackCensoredName'])
	  
	  unless result ['collectionCensoredName'].nil?
	  	@iTunes_track.album.set(result['collectionCensoredName'])
	  else @iTunes_track.album.set(result['collectionName'])
	  end
	  unless result['collectionArtistName'].nil?
	  	@iTunes_track.album_artist.set(result['collectionArtistName'])
	  else @iTunes_track.album_artist.set(result['artistName'])
	  end
	  
	end

	def update_parsley(result, sfcountry) # Updates unsettable iTunes tags
	  trackpath = "#{@iTunes_track.location.get.path}"
	  escapepath = Regexp.escape(trackpath).gsub(/([',;=&@!`"])/, '\\\\\1')
	  

#	  `AtomicParsley #{escapepath} --artistID #{result['artistId']} --albumID #{result['collectionId']} \
#		--appleID "#{appleid}" --storeID #{sfcountry} --year #{result['releaseDate']} -W`

#	  `AtomicParsley #{escapepath} --genreID result['-----Id'] --overWrite`			--dont have geIDs
#	  `AtomicParsley #{escapepath} --composerID result['collectionId'] --overWrite`	--dont have cmIDs
#	  `AtomicParsley #{escapepath} --xID result['collectionId'] --overWrite`		--dont have xIDs
#  	  `AtomicParsley #{escapepath} --purd #{result['purchaseDate']} --overWrite`    --psuedo

	case result['trackExplicitness'] # Updates explicit tag	  
		when 'explicit'
			`AtomicParsley #{escapepath} --artistID #{result['artistId']} --albumID #{result['collectionId']} \
			--appleID "#{appleid}" --storeID #{sfcountry} --year #{result['releaseDate']} --advisory explicit -W`
		when 'cleaned'
			`AtomicParsley #{escapepath} --artistID #{result['artistId']} --albumID #{result['collectionId']} \
			--appleID "#{appleid}" --storeID #{sfcountry} --year #{result['releaseDate']} --advisory clean -W`
		when 'notExplicit'
			`AtomicParsley #{escapepath} --artistID #{result['artistId']} --albumID #{result['collectionId']} \
			--appleID "#{appleid}" --storeID #{sfcountry} --year #{result['releaseDate']} --advisory remove -W`
		else
	end

	end #def updateParsley
	
	def update_artwork(result)
		trackpath = "#{@iTunes_track.location.get.path}"
		escapepath = Regexp.escape(trackpath).gsub(/([',;=&@!`"])/, '\\\\\1').gsub('\.' , '.')
	    trackfold =  trackpath.gsub(/[^\/]*?\.m4a/, '')
		artlink = result['artworkUrl100'].gsub('100', '600')
		Dir.chdir(trackfold)
		begin	

		  open(".image.png", 'w+') do | file |
		    file << open(artlink).read
		    file.close
		  end

		`AtomicParsley #{escapepath} --artwork REMOVE_ALL --artwork .image.png -W`
#		  `mp4art -z --add image.png #{escapepath}`
		`rm .image.png`
		rescue OpenURI::HTTPError => ex
		  print "Download art failed: "
		  print ex
		  puts trackpath
		end
	end
	
	def get_sfid(country)
		case country
		
		when "AE"
		   sfID = "143481"
		   cname = "United Arab Emirates" 

		when "AG"
		   sfID = "143540"
		   cname = "Antigua & Barbuda" 

		when "AI"
		   sfID = "143538"
		   cname = "Anguilla" 

		when "AL"
		   sfID = "143575"
		   cname = "Albania"

		when "AM"
		   sfID = "143524"
		   cname = "Armenia" 

		when "AO"
		   sfID = "143564"
		   cname = "Angola" 

		when "AR"
		   sfID = "143505"
		   cname = "Argentina" 

		when "AT"
		   sfID = "143445"
		   cname = "Austria" 

		when "AU"
		   sfID = "143460"
		   cname = "Australia" 

		when "AZ"
		   sfID = "143568"
		   cname = "Azerbaijan" 

		when "BB"
		   sfID = "143541"
		   cname = "Barbados" 

		when "BD"
		   sfID = "143490"
		   cname = "Bangladesh" 

		when "BE"
		   sfID = "143446"
		   cname = "Belgium" 

		when "BF"
		   sfID = "143578"
		   cname = "Burkina Faso"

		when "BG"
		   sfID = "143526"
		   cname = "Bulgaria" 

		when "BH"
		   sfID = "143559"
		   cname = "Bahrain" 

		when "BJ"
		   sfID = "143576"
		   cname = "Benin"

		when "BM"
		   sfID = "143542"
		   cname = "Bermuda" 

		when "BN"
		   sfID = "143560"
		   cname = "Brunei" 

		when "BO"
		   sfID = "143556"
		   cname = "Bolivia" 

		when "BR"
		   sfID = "143503"
		   cname = "Brazil" 

		when "BS"
		   sfID = "143539"
		   cname = "The Bahamas" 

		when "BT"
		   sfID = "143577"
		   cname = "Bhutan"

		when "BW"
		   sfID = "143525"
		   cname = "Botswana" 

		when "BY"
		   sfID = "143565"
		   cname = "Belarus" 

		when "BZ"
		   sfID = "143555"
		   cname = "Belize" 

		when "CA"
		   sfID = "143455"
		   cname = "Canada" 

		when "CG"
		   sfID = "143582"
		   cname = "Republic of Congo"

		when "CH"
		   sfID = "143459"
		   cname = "Switzerland" 

		when "CI"
		   sfID = "143527"
		   cname = "Cote D'Ivoire" 

		when "CL"
		   sfID = "143483"
		   cname = "Chile" 

		when "CN"
		   sfID = "143465"
		   cname = "China" 

		when "CO"
		   sfID = "143501"
		   cname = "Colombia" 

		when "CR"
		   sfID = "143495"
		   cname = "Costa Rica" 

		when "CV"
		   sfID = "143580"
		   cname = "Cape Verde"

		when "CY"
		   sfID = "143557"
		   cname = "Cyprus" 

		when "CZ"
		   sfID = "143489"
		   cname = "Czech Republic" 

		when "DE"
		   sfID = "143443"
		   cname = "Germany" 

		when "DK"
		   sfID = "143458"
		   cname = "Denmark" 

		when "DM"
		   sfID = "143545"
		   cname = "Dominica" 

		when "DO"
		   sfID = "143508"
		   cname = "Dominican Republic" 

		when "DZ"
		   sfID = "143563"
		   cname = "Algeria" 

		when "EC"
		   sfID = "143509"
		   cname = "Ecuador" 

		when "EE"
		   sfID = "143518"
		   cname = "Estonia" 

		when "EG"
		   sfID = "143516"
		   cname = "Egypt" 

		when "ES"
		   sfID = "143454"
		   cname = "Spain" 

		when "FI"
		   sfID = "143447"
		   cname = "Finland" 

		when "FJ"
		   sfID = "143583"
		   cname = "Fiji"

		when "FM"
		   sfID = "143591"
		   cname = "Federated States of Micronesia"

		when "FR"
		   sfID = "143442"
		   cname = "France" 

		when "GB"
		   sfID = "143444"
		   cname = "United Kingdom"

		when "GD"
		   sfID = "143546"
		   cname = "Grenada" 

		when "GH"
		   sfID = "143573"
		   cname = "Ghana" 

		when "GM"
		   sfID = "143584"
		   cname = "Gambia"

		when "GR"
		   sfID = "143448"
		   cname = "Greece" 

		when "GT"
		   sfID = "143504"
		   cname = "Guatemala" 

		when "GW"
		   sfID = "143585"
		   cname = "Guinea-Bissau"

		when "GY"
		   sfID = "143553"
		   cname = "Guyana" 

		when "HK"
		   sfID = "143463"
		   cname = "Hong Kong" 

		when "HN"
		   sfID = "143510"
		   cname = "Honduras" 

		when "HR"
		   sfID = "143494"
		   cname = "Croatia" 

		when "HU"
		   sfID = "143482"
		   cname = "Hungary" 

		when "ID"
		   sfID = "143476"
		   cname = "Indonesia" 

		when "IE"
		   sfID = "143449"
		   cname = "Ireland" 

		when "IL"
		   sfID = "143491"
		   cname = "Israel" 

		when "IN"
		   sfID = "143467"
		   cname = "India" 

		when "IS"
		   sfID = "143558"
		   cname = "Iceland" 

		when "IT"
		   sfID = "143450"
		   cname = "Italy" 

		when "JM"
		   sfID = "143511"
		   cname = "Jamaica" 

		when "JO"
		   sfID = "143528"
		   cname = "Jordan" 

		when "JP"
		   sfID = "143462"
		   cname = "Japan" 

		when "KE"
		   sfID = "143529"
		   cname = "Kenya" 

		when "KG"
		   sfID = "143586"
		   cname = "Kyrgyzstan"

		when "KH"
		   sfID = "143579"
		   cname = "Cambodia"

		when "KN"
		   sfID = "143548"
		   cname = "St. Kitts & Nevis" 

		when "KR"
		   sfID = "143466"
		   cname = "Korea" 

		when "KW"
		   sfID = "143493"
		   cname = "Kuwait" 

		when "KY"
		   sfID = "143544"
		   cname = "Cayman Islands" 

		when "KZ"
		   sfID = "143517"
		   cname = "Kazakstan" 

		when "LA"
		   sfID = "143587"
		   cname = "Lao People's Democratic Republic"

		when "LB"
		   sfID = "143497"
		   cname = "Lebanon" 

		when "LC"
		   sfID = "143549"
		   cname = "St. Lucia" 

		when "LI"
		   sfID = "143522"
		   cname = "Liechtenstein" 

		when "LK"
		   sfID = "143486"
		   cname = "Sri Lanka" 

		when "LR"
		   sfID = "143588"
		   cname = "Liberia"

		when "LT"
		   sfID = "143520"
		   cname = "Lithuania" 

		when "LU"
		   sfID = "143451"
		   cname = "Luxembourg" 

		when "LV"
		   sfID = "143519"
		   cname = "Latvia" 

		when "MD"
		   sfID = "143523"
		   cname = "Moldova" 

		when "MG"
		   sfID = "143531"
		   cname = "Madagascar" 

		when "MK"
		   sfID = "143530"
		   cname = "Macedonia" 

		when "ML"
		   sfID = "143532"
		   cname = "Mali" 

		when "MN"
		   sfID = "143592"
		   cname = "Mongolia"

		when "MO"
		   sfID = "143515"
		   cname = "Macau" 

		when "MR"
		   sfID = "143590"
		   cname = "Mauritania"

		when "MS"
		   sfID = "143547"
		   cname = "Montserrat" 

		when "MT"
		   sfID = "143521"
		   cname = "Malta" 

		when "MU"
		   sfID = "143533"
		   cname = "Mauritius" 

		when "MV"
		   sfID = "143488"
		   cname = "Maldives" 

		when "MW"
		   sfID = "143589"
		   cname = "Malawi"

		when "MX"
		   sfID = "143468"
		   cname = "Mexico" 

		when "MY"
		   sfID = "143473"
		   cname = "Malaysia" 

		when "MZ"
		   sfID = "143593"
		   cname = "Mozambique"

		when "NA"
		   sfID = "143594"
		   cname = "Namibia"

		when "NE"
		   sfID = "143534"
		   cname = "Niger" 

		when "NG"
		   sfID = "143561"
		   cname = "Nigeria" 

		when "NI"
		   sfID = "143512"
		   cname = "Nicaragua" 

		when "NL"
		   sfID = "143452"
		   cname = "Netherlands" 

		when "NO"
		   sfID = "143457"
		   cname = "Norway" 

		when "NP"
		   sfID = "143484"
		   cname = "Nepal" 

		when "NZ"
		   sfID = "143461"
		   cname = "New Zealand" 

		when "OM"
		   sfID = "143562"
		   cname = "Oman" 

		when "PA"
		   sfID = "143485"
		   cname = "Panama" 

		when "PE"
		   sfID = "143507"
		   cname = "Peru" 

		when "PG"
		   sfID = "143597"
		   cname = "Papua New Guinea"

		when "PH"
		   sfID = "143474"
		   cname = "Philippines" 

		when "PK"
		   sfID = "143477"
		   cname = "Pakistan" 

		when "PL"
		   sfID = "143478"
		   cname = "Poland" 

		when "PT"
		   sfID = "143453"
		   cname = "Portugal" 

		when "PW"
		   sfID = "143595"
		   cname = "Palau"

		when "PY"
		   sfID = "143513"
		   cname = "Paraguay" 

		when "QA"
		   sfID = "143498"
		   cname = "Qatar" 

		when "RO"
		   sfID = "143487"
		   cname = "Romania" 

		when "RS"
		   sfID = "143500"
		   cname = "Serbia" 

		when "RU"
		   sfID = "143469"
		   cname = "Russia" 

		when "SA"
		   sfID = "143479"
		   cname = "Saudi Arabia" 

		when "SB"
		   sfID = "143601"
		   cname = "Solomon Islands"

		when "SC"
		   sfID = "143599"
		   cname = "Seychelles"

		when "SE"
		   sfID = "143456"
		   cname = "Sweden" 

		when "SG"
		   sfID = "143464"
		   cname = "Singapore" 

		when "SI"
		   sfID = "143499"
		   cname = "Slovenia" 

		when "SK"
		   sfID = "143496"
		   cname = "Slovakia" 

		when "SL"
		   sfID = "143600"
		   cname = "Sierra Leone"

		when "SN"
		   sfID = "143535"
		   cname = "Senegal" 

		when "SR"
		   sfID = "143554"
		   cname = "Suriname" 

		when "ST"
		   sfID = "143598"
		   cname = "Sao Tome and Principe"

		when "SV"
		   sfID = "143506"
		   cname = "El Salvador" 

		when "SZ"
		   sfID = "143602"
		   cname = "Swaziland"

		when "TC"
		   sfID = "143552"
		   cname = "Turks & Caicos" 

		when "TD"
		   sfID = "143581"
		   cname = "Chad"

		when "TH"
		   sfID = "143475"
		   cname = "Thailand" 

		when "TJ"
		   sfID = "143603"
		   cname = "Tajikistan"

		when "TM"
		   sfID = "143604"
		   cname = "Turkmenistan"

		when "TN"
		   sfID = "143536"
		   cname = "Tunisia" 

		when "TR"
		   sfID = "143480"
		   cname = "Turkey" 

		when "TT"
		   sfID = "143551"
		   cname = "Trinidad & Tobago" 

		when "TW"
		   sfID = "143470"
		   cname = "Taiwan" 

		when "TZ"
		   sfID = "143572"
		   cname = "Tanzania" 

		when "UA"
		   sfID = "143492"
		   cname = "Ukraine" 

		when "UG"
		   sfID = "143537"
		   cname = "Uganda"  

		when "US"
		   sfID = "143441"
		   cname = "USA" 

		when "UY"
		   sfID = "143514"
		   cname = "Uruguay" 

		when "UZ"
		   sfID = "143566"
		   cname = "Uzbekistan" 

		when "VC"
		   sfID = "143550"
		   cname = "St. Vincent & The Grenadines" 

		when "VE"
		   sfID = "143502"
		   cname = "Venezuela" 

		when "VG"
		   sfID = "143543"
		   cname = "British Virgin Islands" 

		when "VN"
		   sfID = "143471"
		   cname = "Vietnam" 

		when "YE"
		   sfID = "143571"
		   cname = "Yemen" 

		when "ZA"
		   sfID = "143472"
		   cname = "South Africa" 

		when "ZW"
		   sfID = "143605"
		   cname = "Zimbabwe"
		   
		else
		   sfID = "0"
		   cname = "The North Pole"
		end
		return sfID, cname
	end #def get_sfid
end

##########################################################################################
################################					######################################
################################ Script Starts Here ######################################
################################					######################################
##########################################################################################

#iTunes API sets limit to 200 results per query.
WORK_SIZE = 100
STDOUT.sync = true
tracks = []
tracks.clear
appleid = "appleid@domain.com"

app = Appscript.app.by_name("iTunes", Tunes)

iTunes_tracks = app.selection.get
if iTunes_tracks.count == 0
  iTunes_tracks = app.library_playlists[1].tracks.get
end

print "Reading #{iTunes_tracks.count} tracks "

iTunes_tracks.each do | iTunes_track |
  begin
    if iTunes_track.kind.get == 'Matched AAC audio file' && iTunes_track.grouping.get != 'USA'
      track = Track.new(iTunes_track) 
	  unless track.valid?
        tracks << track
        print '*' if ((tracks.count % WORK_SIZE) == 0)
      end
    end
	
	
#	if iTunes_track.kind.get == 'Purchased AAC audio file'
#      track = Track.new(iTunes_track) 
#	  unless track.valid?
#        tracks << track
#        print '*' if ((tracks.count % WORK_SIZE) == 0)
#      end
#    end
    
    
  rescue StandardError => e
    puts e
  end
end
puts ''

# All 2 char country codes. Lots currently not valid %w(AF AX AL DZ AS AD AO AI AQ AG AR \
#AM AW AU AT AZ BS BH BD BB BY BE BZ BJ BM BT BO BQ BA BW BV BR IO BN BG BF BI KH CM CA CV \
#KY CF TD CL CN CX CC CO KM CG CD CK CR CI HR CU CW CY CZ DK DJ DM DO EC EG SV GQ ER EE ET \
#FK FO FJ FI FR GF PF TF GA GM GE DE GH GI GR GL GD GP GU GT GG GN GW GY HT HM VA HN HK HU \
#IS IN ID IR IQ IE IM IL IT JM JP JE JO KZ KE KI KP KR KW KG LA LV LB LS LR LY LI LT LU MO \
#MK MG MW MY MV ML MT MH MQ MR MU YT MX FM MD MC MN ME MS MA MZ MM NA NR NP NL NC NZ NI NE \
#NG NU NF MP NO OM PK PW PS PA PG PY PE PH PN PL PT PR QA RE RO RU RW BL SH KN LC MF PM VC \
#WS SM ST SA SN RS SC SL SG SX SK SI SB SO ZA GS SS ES LK SD SR SJ SZ SE CH SY TW TJ TZ TH \
#TL TG TK TO TT TN TR TM TC TV UG UA AE GB US UM UY UZ VU VE VN VG VI WF EH YE ZM ZW)

countries = %w(US)
# GB CA AU IT DE FR JP CN CH MX AE AG AI AL AM AO AR AT AZ BB BE BF BG BH BJ BM BN BO BR BS BT BW BY BZ CG CL CO CR CV CY CZ DK DM DO DZ EC EE EG ES FI FJ FM GD GH GM GR GT GW GY HK HN HR HU ID IE IL IN IS JM JO KE KG KH KN KR KW KY KZ LA LB LC LK LR LT LU LV MD MG MK ML MN MO MR MS MT MU MW MY MZ NA NE NG NI NL NO NP NZ OM PA PE PG PH PK PL PT PW PY QA RO RU SA SB SC SE SG SI SK SL SN SR ST SV SZ TC TD TH TJ TM TN TR TT TW TZ UA UG UY UZ VC VE VG VN YE ZA ZW)

if tracks.count == 0
	puts "Didn't find any non US matched tracks"
	exit
else
	puts "Found #{tracks.count} matched tracks"
end

countries.each do | country |

#	printf "%79s\r" ""
#	printf "%.75s\n" "     `if [ "$collectionArtName" == "" ]; then echo $artistName; else echo $collectionArtName; fi` - $trackName"
#	printf "%*s\r" 0 "     $((trkIter++)) out of $trkCnt"
#	printf "\e[A"

#	printf("%s, the sale price is $%f.\n", name, sale_price)
#	printf("|%-15s|%7.2f|\n", "Cathy", 13.5)


  printf( "Querying %s store for %i tracks ", country, tracks.count)
  
  counter = 0
  found = 0


  tracks.dup.each.each_slice(WORK_SIZE) do | subtracks |
    ids = subtracks.map { | track | track.iTunes_id }
    iTunesHash = JSON.parse(open("http://itunes.apple.com/lookup?id=#{ids.join(',')}&country=#{country}").read)
    print '*'   
    iTunesHash['results'].each do | result |
      result_id = result['trackId']
      subtracks.each do | track |
        if result_id == track.iTunes_id
          found += 1
#            track.sterilize()
            sfcountry, cname = track.get_sfid(country)
            track.update_artwork(result)
            track.update_parsley(result, sfcountry)
            track.update_track(result, cname)
            tracks.delete(track)
#            `rm .image.png`
            counter += 1
        end
        subtracks.delete(track)
      end
    end
    
  end
  print " #{found} track(s) found"
  if counter > 0
	printf " %d updated\n", counter
  else
    printf " %d updated\r", counter  
  end
  break if tracks.empty?
end

if tracks.count > 0
	print "\n"
	puts "Couldn't find meatadata for #{tracks.count} tracks"
	tracks.each do | track |
#		track.notfound()
		print '*'
	end
end
print "\n"

