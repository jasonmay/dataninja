while :
do
    ulimit -v 32768
    echo "resetting"
    rm ~/.fifo.*
    ./bin/fifo.pl
    sleep 5
done
