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
	Node *   node ;
	char *   str  ;
	Function func ;
}

/* délimiteurs */

%token EOL
%token LP RP VIRGUL COLON
%token END 	// fin de blocs

/* Opérateurs arithmétiques */

%token <node> PLUS MINUS MULT DIV MOD POW

/* Opérateur de concaténation */

%token <node> CONC

/* Opérateurs d'affectations */

%token <node> SET

/* Opérateurs de comparaison */

%token <node> EQ GT GE LT LE NE

/* Opérateurs logiques */

%token <node> NOT OR AND

/* Types */

%token <node> TYPE

/* Structures de répétition */

%token <node> FOR WHILE

/* Structure de controle */

%token <node> IF ELSE

/* Valeurs typés */

%token <node> BOOL REAL STRING

/* Identificateur */

%token <str> NAME

/* Return */

%token <node> RETURN

/***************************************************/
/* Déclaration des types des noeuds intermédiaires */
/***************************************************/

%type 	<node>		 Input
%type 	<node>	 	 Function
%type 	<node>	 	 Prot
%type 	<node>	 	 ListArg
%type 	<node>	 	 Arg
%type 	<node>	 	 Insts
%type 	<node>	 	 ReturnLine
%type 	<node>	 	 DefVarLine
%type 	<node>	 	 SetLine
%type 	<node>	 	 Set
%type 	<node>	 	 CallLine
%type 	<node>	 	 Call
%type 	<node>	 	 ListParam
%type 	<node>	 	 Bloc
%type 	<node>	 	 If
%type 	<node>	 	 Bif
%type 	<node>	 	 BoolExpr
%type 	<node>	 	 While
%type 	<node>	 	 Bwhile
%type 	<node>	 	 For
%type 	<node>	 	 Bfor
%type 	<node>	 	 InstsList
%type 	<node>	 	 IList
%type 	<node>	 	 Expr
%type 	<node>	 	 ArthExpr
%type 	<node>	 	 ArthExprWithInvoke
%type 	<node>	 	 Conc
%type 	<node>	 	 ConcWithCall

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
							{}	
	| Function 				{}
	| Function Leol Input 	{}
	;

Leol:
	  EOL Leol 	{} 
	| EOL 	 	{}
	;

Function:
	Prot Content END {}
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

Content:
	  LeolOrNull {}
	| LeolOrNull Insts {}
	;

LeolOrNull:
	  {}
	| Leol {}
	;

Insts:
	  Inst LeolOrNull {}
	| Inst LeolOrNull Insts {}
	;
	
Inst:
	  SetLine     {}
	| CallLine 	  {}
	| DefVarLine  {}
	| Bloc 		  {}
	| ReturnLine  {}
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
	  Expr VIRGUL ListParam {}
	| Expr {}
	;

Bloc:
	  If 	EOL {}
	| While EOL {}
	| For 	EOL {}
	;

If:
	  Bif Content END {}
	| Bif Content ELSE Content END {}
	;

Bif:
	  IF LP BoolExpr RP EOL {}
	| IF LP Invoke 	 RP EOL {}
	;

BoolExpr:
	  BoolCondition 				 	  	  {}
	| BoolExprStruct 						  {}
	;

BoolExprStruct:		
	  NOT  	LP		BoolExprMore 		RP    {}
	| NOT   		BoolExprOne 			  {}
	| BoolExprP 	OR    			BoolExprP {}
	| BoolExprP 	AND   			BoolExprP {}
	;

BoolExprMore:
	  BoolExprStruct {}
	| BoolComp 		 {}

BoolExprOne:
	  Invoke {}
	| BOOL 	 {}
	;

BoolExprInvoke:
	  Invoke 	{}
	| BoolExpr 	{}

BoolExprP:
	  LP BoolExpr RP 	{}
	| BoolExprInvoke 	{}
	;

BoolCondition:
	  BOOL 						{}
	| BoolComp 					{}
	;

BoolComp:
	  Expr 		EQ     Expr 	{}
	| Expr 		NE     Expr 	{}
	| ArthExpr 	GT     ArthExpr {}
	| ArthExpr 	GE     ArthExpr {}
	| ArthExpr 	LT     ArthExpr {}
	| ArthExpr 	LE     ArthExpr {}
	;

While:
	Bwhile Content END {}
	;

Bwhile:
	  WHILE LP BoolExpr RP EOL {}
	| WHILE LP Invoke 	RP EOL {}
	;


For:
	Bfor Content END {}
	;

Bfor:
	  FOR LP InstsList COLON BoolExpr COLON InstsList RP EOL {}
	| FOR LP InstsList COLON Invoke   COLON InstsList RP EOL {}
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
	| Invoke 	{}
	;

Invoke:
	  Call	{}
	| NAME 	{}
	;

ArthExpr:
    REAL		       											{}
  | ArthExprWithInvoke 	PLUS 				ArthExprWithInvoke  {}
  | ArthExprWithInvoke 	MINUS  				ArthExprWithInvoke  {}
  | ArthExprWithInvoke	MULT 				ArthExprWithInvoke  {}
  | ArthExprWithInvoke 	DIV  				ArthExprWithInvoke  {}
  | ArthExprWithInvoke 	MOD  				ArthExprWithInvoke  {}
  | MINUS  				ArthExprWithInvoke 	%prec NEG			{}
  | ArthExprWithInvoke 	POW  				ArthExprWithInvoke  {}
  ;

ArthExprWithInvoke:
	  Invoke 		 {}
	| ArthExpr 		 {}
	| LP ArthExpr RP {}


Conc:
	STRING 		      			   {}	
  |	ConcWithCall CONC ConcWithCall {}
  ;


ConcWithCall:
	  Invoke {}
	| Conc {}
	;

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