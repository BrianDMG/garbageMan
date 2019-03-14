#!/bin/bash

#This script will search through a base media directory and
#delete media files that meet user-specified age criteria
#in both a specified "churn" movies directory (for deleting
#older releases, as well as any path (recursively) within $tv_dir

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo $script_dir

#Directory vars
base_dir="/path/to/all/media"
movie_dir="$base_dir/movies"
churn_dir="$movie_dir/churn"
tv_dir="$base_dir/tv"
music_dir="$base_dir/music"

#File containing the list of media to delete
	#Must contain #maxBegin,#maxEnd, etc.
garbage_list=DIR="$script_dir/garbageMan.list"

#Various threshold (number of days)
max_threshold=30
high_threshold=14
mid_threshold=7
low_threshold=3

#--------------------------------------------------------------------
# Basic cleanup operations
#--------------------------------------------------------------------
#Uncomment to delete all Thumbs.db in $base_dir
#find $base_dir -name "Thumbs.db" -print0 | xargs -0 rm -rf

#Uncomment to delete all .jpg in $music_dir
#find $music_dir -name "*.jpg" -print0 | xargs -0 rm -rf

#--------------------------------------------------------------------
# Remove old movies in $base_dir/$movie_dir/$churn_dir
#--------------------------------------------------------------------
find $churn_dir -type f -mtime +$max_threshold -exec rm {} \;

#--------------------------------------------------------------------
# Remove TV shows based on how often they air
#--------------------------------------------------------------------
thresholdArray=(max high mid low)
for threshold in ${thresholdArray[@]}; do
	IFS=$'\n'
	begin="#${threshold}Begin"
	end="#${threshold}End"
	current_threshold_array=($(awk "/$begin/{flag=1;next}/$end/{flag=0}flag" $garbage_list))
	for show in "${current_threshold_array[@]}"; do
		current_threshold_number="${threshold}_threshold"
		find $tv_dir/"$show" -type f -mtime +${!current_threshold_number} -exec rm {} \;
	done
done

#Delete empty dirs in $base_dir
find $base_dir -type d -empty -print0 -delete