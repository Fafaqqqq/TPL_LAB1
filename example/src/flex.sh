#!/bin/bash

NAME=lexer

[ ! -z "$1" ] && NAME=$1 

flex --outfile=$NAME.c --header-file=$NAME.h $NAME.l 