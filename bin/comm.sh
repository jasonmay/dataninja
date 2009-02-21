#!/bin/sh

while :
do
    read foo
    echo "$foo" > $HOME/.fifo.out
    cat - < $HOME/.fifo.in
done
