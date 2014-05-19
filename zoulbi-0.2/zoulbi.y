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

%}

/*	

	Union des types reconnus
	par ce fichier bison.

*/

%union {
	struct Node *node;
	char * str;
}

/* délimiteurs */

%token END_OF_FILE EOL
%token LP RP VIRGUL COLON

/* Opérateurs arithmétiques */

%token PLUS MINUS MULT DIV MOD

/* Opérateur de concaténation */

%token CONC

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

/* Return */

%token RETURN

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
%left 	CONC
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
	| ReturnLine  Insts {}
	;

ReturnLine:
	  RETURN EOL {}
	| RETURN Expr EOL {}
	;

DefVarLine:
	  TYPE NAME EOL      	 {}
	| TYPE NAME SET Expr EOL {}	
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
	  IF LP BoolExpr RP EOL {}
	| IF LP Call 	 RP EOL {}
	;

BoolExpr:
	  BOOL 							 						 {}
	| NOT   			BoolExprWirhCall 	  		 		 {}
	| BoolExprWirhCall 	OR    				BoolExprWirhCall {}
	| BoolExprWirhCall 	AND   				BoolExprWirhCall {}
	| BoolExprWirhCall 	EQ    				BoolExprWirhCall {}
	| BoolExprWirhCall 	NE    				BoolExprWirhCall {}
	| BoolExprWirhCall 	GT    				BoolExprWirhCall {}
	| BoolExprWirhCall 	GE    				BoolExprWirhCall {}
	| BoolExprWirhCall 	LT    				BoolExprWirhCall {}
	| BoolExprWirhCall 	LE    				BoolExprWirhCall {}
	;

BoolExprWirhCall:
	  Call {}
	| BoolExpr {}
	| LP BoolExpr RP {}
	;

While:
	Bwhile Insts END {}
	;

Bwhile:
	  WHILE LP BoolExpr RP EOL {}
	| WHILE LP Call 	RP EOL {}
	;


For:
	Bfor Insts END {}
	;

Bfor:
	  FOR LP InstsList COLON BoolExpr COLON InstsList RP EOL {}
	| FOR LP InstsList COLON Call 	  COLON InstsList RP EOL {}
	;

InstsList:
	  {}
	| IList {}
	;

IList:
	  Set VIRGUL IList  {}
	| Call VIRGUL IList {}
	| Set 		  		{}
	| Call 		  		{} 
	;

Expr:
	  ArthExpr  {}
	| BoolExpr  {}
	| Conc 	 	{}
	| Call		{} 
	;

ArthExpr:
    REAL		       											{}
  | NAME 			   											{}
  | ArthExprWithCall 	PLUS 				ArthExprWithCall    {}
  | ArthExprWithCall 	MINUS  				ArthExprWithCall    {}
  | ArthExprWithCall	MULT 				ArthExprWithCall    {}
  | ArthExprWithCall 	DIV  				ArthExprWithCall    {}
  | ArthExprWithCall 	MOD  				ArthExprWithCall    {}
  | MINUS  				ArthExprWithCall 	%prec NEG			{}
  | ArthExprWithCall 	POW  				ArthExprWithCall    {}
  ;

ArthExprWithCall:
	  Call {}
	| ArthExpr {}
	| LP ArthExpr RP {}


Conc:
	STRING 		      			   {}	
  |	ConcWithCall CONC ConcWithCall {}
  ;


ConcWithCall:
	  Call {}
	| Conc {}




%%

void yyerror( char * s ) {
	printf( "%s\n" , s );
}

int main( int argc, char **argv ) {
  	
  	if ( ( argc == 3 ) && ( strcmp( argv[1], "-f" ) == 0 ) ) {
    
      	FILE * fp = fopen( argv[2], "r" );
      	
      	if( !fp ) {
        	printf( "Impossible d'ouvrir le fichier à executer.\n" );
          	exit( 0 );
      	}

      	yyin = fp;

      	if( yyparse() == 1 )
        	printf( "Echec du parsing\n" );
  
    	fclose( fp );
	}
	
	exit( 0 );
}