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
%token END  // fin de blocs

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

%type <node> Function
%type <node> Prot
%type <node> ListArgOrEmpty
%type <node> ListArg
%type <node> Arg
%type <node> Content
%type <node> LeolOrNull
%type <node> Insts
%type <node> Inst
%type <node> ReturnLine
%type <node> DefVarLine
%type <node> SetLine
%type <node> Set
%type <node> CallLine
%type <node> Call
%type <node> ListParamOrEmpty
%type <node> ListParam
%type <node> Bloc
%type <node> If
%type <node> Bif
%type <node> BoolExpr
%type <node> BoolExprMore 
%type <node> BoolExprInvoke
%type <node> BoolCondition
%type <node> EqualCondition
%type <node> Operand
%type <node> While
%type <node> Bwhile
%type <node> For
%type <node> Bfor
%type <node> InstsList
%type <node> IList
%type <node> Expr
%type <node> Invoke
%type <node> ArthExpr
%type <node> ArthExpr1
%type <node> ArthExpr2
%type <node> ArthExpr3
%type <node> ArthExpr4
%type <node> ArthExprInvoke
%type <node> ArthExpr6
%type <node> ArthExpr7
%type <node> ArthExpr8
%type <node> ArthExpr9
%type <node> ArthExpr10
%type <node> ArthExpr11
%type <node> ArthExpr12
%type <node> Conc
%type <node> ConcWithInvoke

/* --------------------- */
/* Gestion des priorités */
/* --------------------- */

%left   SET
%left   OR
%left   AND
%left   EQ NE
%left   GT LT GE LE
%left   PLUS MINUS
%left   MULT DIV MOD
%left   NEG NOT
%left   CONC
%right  POW

%start Input
%%

Input:
                            {}  
    |   Function            {}
    |   Function Leol Input {}
    ;

Leol:
        EOL Leol    {} 
    |   EOL         {}
    ;

Function:
        Prot Content END {}
    ;

Prot:
        TYPE NAME LP ListArgOrEmpty RP EOL {}
    ;

ListArgOrEmpty:
        {}
    |   ListArg {}
    ;

ListArg:
        Arg {}
    |   Arg VIRGUL ListArg {}
    ;

Arg:
        TYPE NAME {}
    ;

Content:
        LeolOrNull {}
    |   LeolOrNull Insts {}
    ;

LeolOrNull:
        {}
    |   Leol {}
    ;

Insts:
        Inst LeolOrNull {}
    |   Inst LeolOrNull Insts {}
    ;
    
Inst:
        SetLine     {}
    |   CallLine    {}
    |   DefVarLine  {}
    |   Bloc        {}
    |   ReturnLine  {}
    ;

ReturnLine:
        RETURN EOL {}
    |   RETURN Expr EOL {}
    ;

DefVarLine:
        TYPE NAME EOL           {

            /* Ajout du nom de la variable au noeud Déclaration */

            $1->name = $2 ;

            $$ = $1 ;

            /* Notification de déclaration */

            

            /* ! Discuter du type void pour les variables ! */

        }

    |   TYPE NAME SET Expr EOL  {

        }  
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
        NAME LP ListParamOrEmpty RP {

        }
    ;

ListParamOrEmpty:
        {}
    |   ListParam {}
    ;

ListParam:
        Expr VIRGUL ListParam {}
    |   Expr {}
    ;

Bloc:
        If      EOL {}
    |   While   EOL {}
    |   For     EOL {}
    ;

If:
        Bif Content END {}
    |   Bif Content ELSE Content END {}
    ;

Bif:
        IF LP BoolExprInvoke RP EOL {}
    ;

BoolExpr:
        BOOL            {}
    |   BoolExprMore    {}
    ;

BoolExprMore:  
        BoolCondition                           {}
    |   NOT     BoolExprInvoke                  {}
    |   BoolExprInvoke  OR    BoolExprInvoke    {}
    |   BoolExprInvoke  AND   BoolExprInvoke    {}
    ;

BoolExprInvoke:
        Invoke      {}
    |   BoolExpr    {}
    ;

BoolCondition:
        EqualCondition             {}
    |   ArthExpr    GT    ArthExpr {}
    |   ArthExpr    GE    ArthExpr {}
    |   ArthExpr    LT    ArthExpr {}
    |   ArthExpr    LE    ArthExpr {}
    ;

EqualCondition:
        Operand EQ Operand  {}
    |   Operand NE Operand  {}
    ;

Operand:
        ArthExpr            {}
    |   Conc                {}
    |   Invoke              {}
    |   LP BoolExprMore RP  {}
    |   BOOL                {}
    ;

While:
        Bwhile Content END {}
    ;

Bwhile:
        WHILE LP BoolExprInvoke RP EOL {}
    ;


For:
        Bfor Content END {}
    ;

Bfor:
        FOR LP InstsList COLON BoolExprInvoke COLON InstsList RP EOL {}
    ;

InstsList:
        {}
    |   IList {}
    ;

IList:
        Set VIRGUL IList    {}
    |   Call VIRGUL IList   {}
    |   Set                 {}
    |   Call                {} 
    ;

Expr:
        ArthExpr    {}
    |   BoolExpr    {}
    |   Conc        {}
    |   Invoke      {}
    ;

Invoke:
        Call    { $$ = $1 ; }

    |   NAME    { 

            if( 1 /* searchVariable( $1 ) */ )
                ;
            else {

                printf( "Undefined variable: %s\n", $1 ) ;
                return 1;
            
            }  
        }
    ;

ArthExpr:
        REAL        {}          
    |   ArthExpr1   {}
    |   ArthExpr2   {}
    |   ArthExpr3   {}
    |   ArthExpr4   {}
    ;

ArthExpr1:
        ArthExprInvoke  PLUS    ArthExprInvoke {}
    |   ArthExprInvoke  MINUS   ArthExprInvoke {}
    ;

ArthExpr2:
        ArthExpr6   MULT    ArthExpr6 {}
    |   ArthExpr6   MOD     ArthExpr6 {}
    |   ArthExpr6   DIV     ArthExpr6 {}
    ;

ArthExpr3:
        MINUS ArthExpr7 %prec NEG {}
    ;

ArthExpr4:
        ArthExpr8 POW ArthExpr9 {}
    ;

ArthExprInvoke:
        ArthExpr    {}
    |   Invoke      {}
    ;

ArthExpr6:
        ArthExpr2   {}
    |   ArthExpr3   {}
    |   ArthExpr10  {}
    ;

ArthExpr7:
        LP ArthExpr3 RP {}
    |   ArthExpr10      {}
    ;

ArthExpr8:
        ArthExpr11      {}
    |   LP ArthExpr3 RP {}
    ;

ArthExpr9:
        ArthExpr11  {}
    |   ArthExpr3   {}
    ;

ArthExpr10:
        ArthExpr12  { $$ = $1 ; }
    |   ArthExpr4   { $$ = $1 ; }
    ;

ArthExpr11:
        ArthExpr12      { $$ = $1 ; }
    |   LP ArthExpr4 RP { $$ = $2 ; }
    ;

ArthExpr12:
        Invoke          { $$ = $1 ; }
    |   REAL            { $$ = $1 ; }
    |   LP ArthExpr1 RP { $$ = $2 ; }
    |   LP ArthExpr2 RP { $$ = $2 ; }
    ;

Conc:
        STRING                              {

            /* Création du noeud string */

            $$ = createNode( NT_STRING ) ;

            $$->string = $1->string ;

        }

    |   ConcWithInvoke CONC ConcWithInvoke  {
            
            Children * c  = ( Children * ) malloc( sizeof( Children ) ) ;
            c->child      = ( Node ** )    malloc( sizeof( Node * ) * 2 ) ;
            c->number     =  2 ;

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c );

            free( c ) ;
        }
    ;


ConcWithInvoke:
        Invoke  { $$ = $1 ; } //ici vérifier si la fonction ou variable appelée est de type string
    |   Conc    { $$ = $1 ; }
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
            return EXIT_FAILURE ;
        }

        yyin = fp;

        if( yyparse() == 1 ){
            printf( "Echec du parsing\n" );
            fclose( fp );
            return EXIT_FAILURE ;
        }
        else
            printf( "Fichier correct\n" );
  
        fclose( fp );
    }
    
    return EXIT_SUCCESS ;
}