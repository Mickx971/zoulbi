#!/bin/bash

bison -d zoulbi.y --debug --verbose
mv zoulbi.tab.h zoulbi.h
mv zoulbi.tab.c zoulbi.y.c
flex zoulbi.l
mv  lex.yy.c zoulbi.lex.c
gcc -c zoulbi.lex.c -o zoulbi.lex.o
gcc -c zoulbi.y.c -o zoulbi.y.o
gcc -o zoulbi zoulbi.lex.o zoulbi.y.o

rm zoulbi.lex.c	&>/dev/null
rm zoulbi.lex.o	&>/dev/null
rm zoulbi.h		&>/dev/null
rm zoulbi.y.c	&>/dev/null
rm zoulbi.y.o	&>/dev/null
