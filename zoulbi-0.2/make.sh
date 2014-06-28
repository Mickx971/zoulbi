#!/bin/bash

bison -d zoulbi.y --debug --verbose
mv zoulbi.tab.h zoulbi.h
flex zoulbi.l
gcc -c lex.yy.c -o zoulbi.lex.o
gcc -c zoulbi.tab.c -o zoulbi.y.o
gcc -c makeTree.c -o makeTree.o
gcc -c evalTree.c -o evalTree.o
gcc -c utils.c -o utils.o
gcc -o zoulbi zoulbi.lex.o zoulbi.y.o makeTree.o evalTree.o utils.o

rm lex.yy.c     &>/dev/null
rm zoulbi.lex.o &>/dev/null
rm zoulbi.y.o   &>/dev/null
rm makeTree.o   &>/dev/null
rm zoulbi.h     &>/dev/null
rm zoulbi.tab.c &>/dev/null
rm evalTree.o 	&>/dev/null
rm utils.o 		&>/dev/null
