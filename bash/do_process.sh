rm -f tempfile01
for k in *.png
do 
    echo $k | awk 'BEGIN { FS = "_" } ; { print $3 }' >> tempfile01
done

awk '{count[$1]++}END{for(j in count) print j, ""count[j]""}' FS="_" tempfile01 > resumen_animales.txt

