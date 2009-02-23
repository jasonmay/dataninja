while :
do
    ulimit -v 32768
    echo "resetting"
    rm ~/.fifo.* 2>/dev/null
    ./bin/fifo.pl
    sleep 5
done
