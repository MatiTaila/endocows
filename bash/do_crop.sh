for k in 130520-1*.jpg
do 
    convert -crop 224x384+320+48 $k _${k/jpg/png}
done
