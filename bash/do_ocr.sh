for k in T01_*.png
do 
    echo $k
    ttext=${k}_text.txt
    tpng=${k}_text.png
    convert $k -threshold 70% +repage $tpng
    convert -crop 50x50+80+180 $tpng $tpng
    gocr -i $tpng -o $ttext
    cat $ttext | grep -v "_" > ${k/png/txt}
done
