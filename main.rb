#require 'net/http'
require 'open-uri'
require 'json'

serverBase = 'http://staging.cms.xxxx.com/umbraco/api/PowerPointMigration/'

def is_number? string
  true if Float(string) rescue false
end

def get_isvalid? id
    return open(serverBase + 'GetPowerPointHasValidLocalFile/?id=' + id).read
end

def get_slidepaths id
  return open(serverBase + 'GetPowerPointSlideMediaPathsForMediaItem/?id=' + id).read
end

def do_convertmedia id
  return open(serverBase + 'GetConvertPowerPointToInteractivePowerPoint/?id=' + id).read
end

def do_deletemedia id
  return open(serverBase + 'GetDeletePowerPointMediaItem/?id=' + id).read
end

def get_powerpointIds
  return open(serverBase + 'GetAllPowerPointIds').read
end

def convertSingleMedia nextMediaId

  if is_number?(nextMediaId) && nextMediaId.to_i > -1
    if get_isvalid?(nextMediaId)
      #find local paths which we'll use later on
      fileNames = JSON.parse(get_slidepaths(nextMediaId))
      #puts fileNames;
      fileNames.each do |key, value|
        open('filesToDelete.txt', 'a') { |f|
          f.puts value
        }
      end

      puts "Beginning conversion on item " + nextMediaId

      #convert the media
      convertResult = do_convertmedia(nextMediaId)

      puts "Finished converting " + nextMediaId

      if is_number?(convertResult) && convertResult.to_i > -1
        #everything seemed to go ok, let's delete the original item
        do_deletemedia(nextMediaId)

        #and finally, log out
        open('conversionLog.txt', 'a') { |f|
          f.puts "Conversion complete - created " + convertResult + " and deleted " + nextMediaId
        }

        puts "Converted item " + nextMediaId
      else
        open('conversionLog.txt', 'a') { |f|
          f.puts "Conversion failed for item " + nextMediaId + " - not deleted. Does the file exist?"
          puts "Conversion failed for item " + nextMediaId + " - not deleted. Does the file exist?"
        }

      end
    end
  end
end

ids = JSON.parse(get_powerpointIds)

ids.each do |key|
  convertSingleMedia(key.to_s)
end
