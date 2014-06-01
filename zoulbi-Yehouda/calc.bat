
del lex.yy.c
del zoulbi.lex.o
del zoulbi.y.o
del makeTree.o  
del zoulbi.h  
del zoulbi.tab.c

pause

bison -d zoulbi.y --debug --verbose

rename zoulbi.tab.h zoulbi.h

flex zoulbi.l


gcc -c lex.yy.c -o zoulbi.lex.o
gcc -c zoulbi.tab.c -o zoulbi.y.o
gcc -c makeTree.c -o makeTree.o
gcc -o zoulbi zoulbi.lex.o zoulbi.y.o makeTree.o

minipseud -f in.txt

pause
