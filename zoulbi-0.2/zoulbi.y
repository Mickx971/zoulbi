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
	  BOOL 				 	   {}
	| BoolExprMore 			   {}
	;

BoolExprMore:  
	  BoolCondition 		   					{}
	| NOT		BoolExprInvoke       			{}
	| BoolExprInvoke 	OR    BoolExprInvoke 	{}
	| BoolExprInvoke 	AND   BoolExprInvoke 	{}
	;

BoolExprInvoke:
	  Invoke 	{}
	| BoolExpr 	{}
	;

BoolCondition:
	  EqualCondition 	{}
	| ArthExpr 	GT    ArthExpr {}
	| ArthExpr 	GE    ArthExpr {}
	| ArthExpr 	LT    ArthExpr {}
	| ArthExpr 	LE    ArthExpr {}
	;

EqualCondition:
	 	Operand EQ Operand 	{}
	| 	Operand NE Operand 	{}
	;

Operand:
	  	ArthExpr 			{}
	| 	Conc 	 			{}
	| 	Invoke 			 	{}
	| 	LP BoolExprMore RP 	{}
	| 	BOOL 				{}
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
  		REAL		{}			
  	|	ArthExpr1 	{}
  	|	ArthExpr2 	{}
  	|	ArthExpr3 	{}
  	|	ArthExpr4 	{}
  	;

ArthExpr1:
		ArthExpr5	PLUS	ArthExpr5 {}
	|	ArthExpr5	MINUS	ArthExpr5 {}
	;

ArthExpr2:
		ArthExpr6	MULT	ArthExpr6 {}
	|	ArthExpr6	MOD		ArthExpr6 {}
	|	ArthExpr6	DIV		ArthExpr6 {}
	;

ArthExpr3:
		MINUS ArthExpr7 %prec NEG {}
	;

ArthExpr4:
		ArthExpr8 POW ArthExpr9	{}
	;

ArthExpr5:
		ArthExpr	{}
	|	Invoke		{}
	;

ArthExpr6:
		ArthExpr2	{}
	|	ArthExpr3	{}
	|	ArthExpr10 	{}
	;

ArthExpr7:
		LP ArthExpr3 RP	{}
	|	ArthExpr10		{}
	;

ArthExpr8:
		ArthExpr11		{}
	|	LP ArthExpr3 RP	{}
	;

ArthExpr9:
		ArthExpr11	{}
	|	ArthExpr3	{}
	;

ArthExpr10:
		ArthExpr12 		{}
	| 	ArthExpr4 		{}
	;

ArthExpr11:
		ArthExpr12		{}
	|	LP ArthExpr4 RP	{}
	;

ArthExpr12:
		Invoke			{}
	|	REAL			{}
	|	LP ArthExpr1 RP	{}
	|	LP ArthExpr2 RP	{}
	;

Conc:
		STRING 		      			   		{}	
	|	ConcWithInvoke CONC ConcWithInvoke 	{}
  	;


ConcWithInvoke:
		Invoke {}
	| 	Conc {}
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