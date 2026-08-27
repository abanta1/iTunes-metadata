# Copyright (c) 2000-2026 Anthony Banta - MIT License
#!/bin/bash
# Overwrites podcast, copyright, encoding tool and encoded by m4a tags

IFS=$'\n'

if [ -z $1 ] || [ $1 = "-h" ] || [ ! -d $1 ]
then 
echo
echo "This script removes useless metadata tags from m4a files"
echo
echo "General usage example:" 
echo "    overwriteITTags.sh /path/to/scan"
echo
echo "To print this help, use:"
echo "    overwriteITTags.sh -h"
echo
exit 
fi

if [ -d $1 ]
	then
		for f in `ls -1 $1/*.m4a`;
			do
				AtomicParsley "$f" --podcastURL "" --copyright "" --encodingTool "" --encodedBy "" -overWrite;
			done
		say done
fi
