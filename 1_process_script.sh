# Confirmation dialogue to avoid disasters.
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

# Move everything to root folder and delete the sub folders.
for dir in */ ; do
  cd "$dir"
  for file in * ; do
    mv "$file" ..
  done
  cd ..
  rmdir "$dir"
done

# Rename everything from JPG to jpg.
for i in $(ls *.JPG 2> /dev/null) ; do
  mv -f $i ${i%.JPG}.jpg
done

# Rename IMG_ format images from Google Camera.
for i in $(ls *.jpg 2> /dev/null) ; do
  first=`echo ${i:0:4}`
  if [ $first = 'IMG_' ]
  then
    new=`echo ${i:4:4}-${i:8:2}-${i:10:2}-${i:13:2}-${i:15:2}-${i:17:2}.jpg`
    mv "$i" "$new"
  fi
done

# Sorts files into 2015-XX-XX folders.
for i in $(ls *.jpg 2> /dev/null) ; do
  dir=`echo ${i:0:8}XX Daily Life`
  mkdir "$dir" > /dev/null 2>&1
  mv "$i" "$dir"
done

# Move files to proper CRUZER location.
for dir in */ ; do
  cd "$dir"
  dest="/Users/jonathan/Pictures/Memories/2015/$dir"
  for file in * ; do
    mv "$file" "$dest$file"
    echo "Created new file $dest$file"
  done
  cd ..
  rmdir "$dir"
done

# open "/Users/jonathan/Pictures/Memories/2015/"

echo "Finished!"
