cd "/Users/jonathan/Dropbox/DropSync Uploads"

# Confirm directory to avoid disasters
echo -e "\nCurrent directory is $PWD.\n\nWARNING: This program does not make any backups of the source material. Using this script in an improperly structured folder can lead to catastrophic results.\n"
read -p "Are you sure you want to continue (y/n)? " choice
case "$choice" in 
  y|Y ) echo -e "\nContinuing execution..."
  ;;
  n|N ) echo -e "\nAborting..."
  exit
  ;;
  * ) echo -e "\nInvalid input. Aborting..."
  exit
  ;;
esac

# Move everything to root folder and delete the sub folders
for dir in */ ; do
  cd "$dir"
  for file in * ; do
    mv "$file" ..
  done
  cd ..
  rmdir "$dir" > /dev/null 2>&1
done

# Rename JPG to jpg
for i in $(ls *.JPG 2> /dev/null) ; do
  mv -f $i ${i%.JPG}.jpg
done

# Rename DNG to dng
for i in $(ls *.DNG 2> /dev/null) ; do
  mv -f $i ${i%.DNG}.dng
done

# Rename IMG_ format images from Google Camera
for i in $(ls *.jpg 2> /dev/null) ; do
  first=`echo ${i:0:4}`
  if [ $first = 'IMG_' ]
  then
    new=`echo ${i:4:4}-${i:8:2}-${i:10:2}-${i:13:2}-${i:15:2}-${i:17:2}.jpg`
    mv "$i" "$new"
  fi
done

# Rename PANO_ format images from Google Camera
for i in $(ls *.jpg 2> /dev/null) ; do
  first=`echo ${i:0:5}`
  if [ $first = 'PANO_' ]
  then
    new=`echo ${i:5:4}-${i:9:2}-${i:11:2}-${i:14:2}-${i:16:2}-${i:18:2}.jpg`
    mv "$i" "$new"
  fi
done

# Set timestamps from file name
for i in $(ls *.jpg 2> /dev/null) ; do
  year=`echo ${i:0:4}`
  month=`echo ${i:5:2}`
  date=`echo ${i:8:2}`
  hour=`echo ${i:11:2}`
  minute=`echo ${i:14:2}`
  second=`echo ${i:17:2}`
  full_date=`echo $month/$date/$year $hour:$minute:$second`
  SetFile -d "$full_date" $i
  SetFile -m "$full_date" $i
done

# Sort files into 2015-XX-XX folders
for i in $(ls *.jpg *.dng *.mp4 2> /dev/null) ; do
  dir=`echo ${i:0:8}XX Daily Life`
  mkdir "$dir" > /dev/null 2>&1
  mv "$i" "$dir"
done

# Move files to proper location
for dir in */ ; do
  cd "$dir"
  dest="/Users/jonathan/Pictures/Memories/2015/$dir"
  mkdir "$dest" > /dev/null 2>&1
  for file in * ; do
    mv "$file" "$dest$file"
    echo "Created new file $dest$file"
  done
  cd ..
  rmdir "$dir"
done

# Finish Stage 1
echo "Finished with moving files to Pictures folder!"

# Confirm to proceed to compression stage
echo -e "\nNow is the time to organize your files in the Pictures folder.\n"
read -p "Are you ready to continue to the compression stage (y/n)? " choice
case "$choice" in 
  y|Y ) echo -e "\nContinuing execution..."
  ;;
  n|N ) echo -e "\nAborting..."
  exit
  ;;
  * ) echo -e "\nInvalid input. Aborting..."
  exit
  ;;
esac

# Move to the Memories folder to simplify paths
cd ~/Pictures/Memories/

# Set output directory
output_f="/Users/jonathan/Dropbox/Compressed Memories"

# Recreate directory structure under 2015
for dir in 2015/*/
do
  mkdir "$output_f/$dir" > /dev/null 2>&1
done

# Recreate sub-directory structure in 2015 folders
for dir in 2015/**/*/
do
  if [[ "$dir" == *"Facebook"* ]] # Skip if Facebook in name.
  then
    continue
  fi
  mkdir "$output_f/$dir" > /dev/null 2>&1
done

# Compress files that haven't been compressed yet
start_time=$(date +%s)

for f in 2015/* 2015/**/* 2015/**/**/*
do
  ext=${f: -4}
  if [[ $ext != '.jpg' && $ext != '.JPG' ]]
  then
    continue # Skip if the extension is not a JPG.
  fi

  output_path="$output_f/$f"
  if [ ! -f "$output_path" ] # Skip if image is already compressed.
  then
    if [ -d "$output_path" ] # Skip if working with a folder.
    then
      continue
    fi
    if [[ "$output_path" == *"Facebook"* ]] # Skip if Facebook in name.
    then
      continue
    fi
    convert "$f" -resize "1080^>" -quality 60% "$output_path" & > /dev/null 2>&1
    echo "Created new file $output_path"
  fi
done

wait
end_time=$(date +%s)

echo "Compression operations took $(($end_time - $start_time)) seconds."

echo "Finished!"
