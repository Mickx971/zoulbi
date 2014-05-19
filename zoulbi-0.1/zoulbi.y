%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <math.h>
	#include "makeTree.h"

	extern int  yyparse();
	extern FILE *yyin;

	void yyerror(char *);
	int yylex();

	int yydebug = 1;

	extern int  yyparse();
	extern FILE *yyin;

%}

/*	
	Union des types reconnus
	par ce fichier bison.*/

%union {
	struct Node *node;
	char * str;
}

/* délimiteurs */

%token END_OF_FILE EOL
%token LP RP VIRGUL COLON

/* Opérateurs arithmétiques */

%token PLUS MINUS MULT DIV MOD

/* Opérateurs d'affectations */

%token SET

/* Opérateurs de comparaison */

%token EQ GT GE LT LE NE

/* Opérateurs logiques */

%token NOT OR AND

/* Structure de bloc */

%token END

/* Types */

%token TYPE

/* Structures de répétition */

%token FOR WHILE

/* Structure de controle */

%token IF ELSE

/* Valeurs typés */

%token BOOL REAL STRING

/* Identificateur */

%token NAME

/* --------------------- */
/* Gestion des priorités */
/* --------------------- */

%left	SET
%left 	OR
%left 	AND
%left 	EQ NE
%left 	GT LT GE LE
%left 	PLUS MINUS
%left 	MULT DIV MOD
%left 	NEG NOT
%right	POW

%start Input
%%

Input:
	  Function END_OF_FILE		{}
	| Function Leol END_OF_FILE {}
	| Function Leol Input 		{}
	;

Leol:
	  EOL Leol 	{} 
	| EOL 	 	{}
	;

Function:
	Prot Insts END 	{}
	;

Prot:
	  TYPE NAME LP RP EOL {}
	| TYPE NAME LP ListArg RP EOL {}
	;

ListArg:
	  Arg {}
	| Arg VIRGUL ListArg {}
	;

Arg:
	TYPE NAME {}
	;

Insts:
	  {}
	| SetLine  	  Insts {}
	| CallLine 	  Insts {}
	| Bloc  	  Insts {}
	| DefVarLine  Insts {}
	;

DefVarLine:
	  TYPE NAME EOL     {}
	| TYPE NAME SetLine {}	
	;

SetLine:
	Set EOL {}
	;

Set:
	NAME SET Expr {}
	;

CallLine:
	Call EOL {}
	;

Call:
	  NAME LP RP {}
	| NAME LP ListParam RP {}
	;

ListParam:
	  NAME VIRGUL ListParam {}
	| NAME
	;

Bloc:
	  If 	EOL {}
	| While EOL {}
	| For 	EOL {}
	;

If:
	  Bif Insts END {}
	| Bif Insts ELSE Insts END {}
	;

Bif:
	IF LP CBool RP EOL {}
	;

CBool:
	| BOOL 				{}
	| NOT   CBool 	  	{}
	| LP    CBool RP  	{}
	| CBool OR    CBool {}
	| CBool AND   CBool {}
	| CBool EQ    CBool {}
	| CBool NE    CBool {}
	| CBool GT    CBool {}
	| CBool GE    CBool {}
	| CBool LT    CBool {}
	| CBool LE    CBool {}
	;

While:
	Bwhile Insts END {}
	;

Bwhile:
	WHILE LP CBool RP EOL {}
	;


For:
	Bfor Insts END {}
	;

Bfor:
	FOR LP InstsList COLON CBool COLON InstsList RP EOL {}
	;

InstsList:
	  {}
	| IList {}
	;

IList:
	  Set VIRGUL IList  {}
	| Call VIRGUL IList {}
	| Set 		  {}
	| Call 		  {} 
	;

Expr:
    TYPE		       			{}
  | NAME 			   			{}
  | Call 			   			{}
  | Expr 	PLUS 	Expr     	{}
  | Expr 	MINUS  	Expr     	{}
  | Expr	MULT 	Expr     	{}
  | Expr 	DIV  	Expr     	{}
  | Expr 	MOD  	Expr     	{}
  | MINUS  	Expr 	%prec NEG	{}
  | Expr 	POW  	Expr     	{}
  | LP   	Expr 	RP 	   		{}
  ;


%%

void yyerror(char * s) {
	
}

int main(int argc, char **argv) {
  	if ((argc == 3) && (strcmp(argv[1], "-f") == 0)) {
    
      	FILE * fp = fopen( argv[2], "r" );
      	if(!fp) {
        	printf("Impossible d'ouvrir le fichier à executer.\n");
          	exit(0);
      	}

      	yyin=fp;

      	if(yyparse() == 1) {
        	printf("Echec du parsing\n");
      	}
  
    	fclose(fp);
	}
	exit(0);
}