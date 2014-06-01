%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>
    #include "makeTree.h"

    extern int  yyparse() ;
    extern FILE *yyin ;

    void    yyerror(char *) ;
    int     yylex()         ;
    int     yydebug = 1     ;

    Stack * memory ;

%}

/*  

    Union des types reconnus
    par ce fichier bison.

*/

%union {
   
    Node      *   node    ;
    char      *   str     ;
    Content   *   content ;

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

%type <node>    Function
%type <node>    Prot
%type <node>    ListArgOrEmpty
%type <node>    ListArg
%type <node>    Arg
%type <content> Content
%type <content> FreeMemoryBloc
%type <node>    LeolOrNull
%type <node>    Insts
%type <node>    Inst
%type <node>    ReturnLine
%type <node>    DefVarLine
%type <node>    SetLine
%type <node>    Set
%type <node>    CallLine
%type <node>    Call
%type <node>    ListParamOrEmpty
%type <node>    ListParam
%type <node>    Bloc
%type <node>    If
%type <node>    Bif
%type <node>    BoolExpr
%type <node>    BoolExprMore 
%type <node>    BoolExprInvoke
%type <node>    BoolCondition
%type <node>    EqualCondition
%type <node>    Operand
%type <node>    While
%type <node>    Bwhile
%type <node>    For
%type <node>    Bfor
%type <node>    InstsList
%type <node>    IList
%type <node>    Expr
%type <node>    Invoke
%type <node>    ArthExpr
%type <node>    ArthExpr1
%type <node>    ArthExpr2
%type <node>    ArthExpr3
%type <node>    ArthExpr4
%type <node>    ArthExprInvoke
%type <node>    ArthExpr6
%type <node>    ArthExpr7
%type <node>    ArthExpr8
%type <node>    ArthExpr9
%type <node>    ArthExpr10
%type <node>    ArthExpr11
%type <node>    ArthExpr12
%type <node>    Conc
%type <node>    ConcWithInvoke

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
    |   AddMemoryBloc Insts FreeMemoryBloc {

            $3->n = $2 ;
            $$    = $3 ;

        }
    ;

FreeMemoryBloc: { 
    
        $$    = ( Content * ) calloc( 1 , sizeof( Content ) ) ;

        $$->s = getMemoryBloc( memory ) ;

        freeBloc( memory ) ; 
        
    }
    ;

AddMemoryBloc:  
             { addMemoryBloc( memory ) ; }
    |   Leol { addMemoryBloc( memory ) ; }
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

            /* Vérification de la validité de la déclaration */

            if( searchVar( $2 , memory ) ) {

                printf( "Déclaration multiple de la variable %s\n", $2 ) ;

                free( $2 ) ;

                return 1 ;

            }

            /* Enregistrement de la déclaration */

            else
                logStatement( memory , $2 , $$->typeVar ) ;

            /* ! Discuter du type void pour les variables ! */

        }

    |   TYPE NAME SET Expr EOL  {
            
        }  
    ;

SetLine:
        Set EOL {}
    ;

Set:
        NAME SET Expr {

            if( searchVar( $1 , memory ) )
                ;
            else {

                printf( "Variable %s non définie\n", $1 ) ;
                return 1;
            
            } 

        }
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
        If      EOL {

        }

    |   While   EOL {

        }

    |   For     EOL {

        }
    ;

If:
        Bif Content END { 

            $1->children->child[ 2 ] = createNode( NT_EMPTY ) ;

            $1->children->child[ 1 ] = createNode( NT_IF ) ;

            $1->children->child[ 1 ]->memory = $2->s ;

            $1->children->child[ 1 ]->children = createChildren( 1 ) ;

            $1->children->child[ 1 ]->children->child[ 0 ] = $2->n ;

            $$ = $1 ;

        }

    |   Bif Content ELSE Content END { 

            $1->children->child[ 1 ] = createNode( NT_IF ) ;
            $1->children->child[ 2 ] = $3 ;

            $1->children->child[ 1 ]->memory = $2->s ;
            $1->children->child[ 2 ]->memory = $4->s ;

            $1->children->child[ 1 ]->children = createChildren( 1 ) ;
            $1->children->child[ 2 ]->children = createChildren( 1 ) ;

            $1->children->child[ 1 ]->children->child[ 0 ] = $2->n ;
            $1->children->child[ 2 ]->children->child[ 0 ] = $4->n ;

            $$ = $1 ;

        }
    ;

Bif:
        IF LP BoolExprInvoke RP EOL {

            Children * c = createChildren( 3 ) ;
            // c'est pas plutot
            // Children * c = createChildren( 1 ) ;

            c->child[ 0 ] = $3 ;

            $$ = nodeChildren( $1 , c );


            free(c);

        }
    ;

BoolExpr:
        BOOL            { $$ = $1 ; }
    |   BoolExprMore    { $$ = $1 ; }
    ;

BoolExprMore:  
        BoolCondition                           { $$ = $1; }
    |   NOT     BoolExprInvoke                  { 

            Children * c = createChildren( 1 );

            c->child[0] = $2;

            $$ = nodeChildren( $1, c );

        }
    |   BoolExprInvoke  OR    BoolExprInvoke    {

            Children * c = createChildren( 2 ) ;

            c->child[0] = $1 ;
            c->child[1] = $3 ;

            $$ = nodeChildren( $2, c );

            free(c);

    }
    |   BoolExprInvoke  AND   BoolExprInvoke    {

            Children * c = createChildren( 2 ) ;

            c->child[0] = $1 ;
            c->child[1] = $3 ;

            $$ = nodeChildren( $2, c );

            free(c);

    }
    ;

BoolExprInvoke:
        Invoke      { $$ = $1 ; }
    |   BoolExpr    { $$ = $1 ; }
    ;

BoolCondition:
        EqualCondition             { $$ = $1 ; }
    |   ArthExpr    GT    ArthExpr {

            Children * c = createChildren( 2 ) ;

            c->child[0] = $1 ;
            c->child[1] = $3 ;

            $$ = nodeChildren( $2, c );

            free(c);

    }
    |   ArthExpr    GE    ArthExpr {

            Children * c = createChildren( 2 ) ;

            c->child[0] = $1 ;
            c->child[1] = $3 ;

            $$ = nodeChildren( $2, c );

            free(c);

    }
    |   ArthExpr    LT    ArthExpr {

            Children * c = createChildren( 2 ) ;

            c->child[0] = $1 ;
            c->child[1] = $3 ;

            $$ = nodeChildren( $2, c );

            free(c);

    }
    |   ArthExpr    LE    ArthExpr {

            Children * c = createChildren( 2 ) ;

            c->child[0] = $1 ;
            c->child[1] = $3 ;

            $$ = nodeChildren( $2, c );

            free(c);

    }
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
        Bwhile Content END { 


        
        }
    ;

Bwhile:
        WHILE LP BoolExprInvoke RP EOL {}
    ;


For:
        Bfor Content END { 


        
        }
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

            if( searchVar( $1 , memory ) )
                ;
            else {

                printf( "Undefined variable: %s\n", $1 ) ;
                return 1;
            
            }  
        }
    ;

ArthExpr:
        REAL        { $$ = $1 ; }          
    |   ArthExpr1   { $$ = $1 ; }
    |   ArthExpr2   { $$ = $1 ; }
    |   ArthExpr3   { $$ = $1 ; }
    |   ArthExpr4   { $$ = $1 ; }
    ;

ArthExpr1:
        ArthExprInvoke  PLUS    ArthExprInvoke {
            
            Children * c = createChildren( 2 ) ;

            c->child[0] = $1;
            c->child[1] = $3;

            $$ = nodeChildren( $2, c ) ;

            free( c );

        }
    |   ArthExprInvoke  MINUS   ArthExprInvoke {
            
            Children * c = createChildren( 2 ) ;

            c->child[0] = $1;
            c->child[1] = $3;

            $$ = nodeChildren( $2, c ) ;

            free( c );

        }
    ;

ArthExpr2:
        ArthExpr6   MULT    ArthExpr6 { 
        
            Children * c = createChildren( 2 );

            c->child[0] = $1 ;
            c->child[1] = $3 ;

            $$ = nodeChildren( $2, c ) ;

            free( c );

        }
    |   ArthExpr6   MOD     ArthExpr6 { 
        
            Children * c = createChildren( 2 );

            c->child[0] = $1 ;
            c->child[1] = $3 ;

            $$ = nodeChildren( $2, c ) ;

            free( c );

        }
    |   ArthExpr6   DIV     ArthExpr6 { 
        
            Children * c = createChildren( 2 );

            c->child[0] = $1 ;
            c->child[1] = $3 ;

            $$ = nodeChildren( $2, c ) ;

            free( c );

        }
    ;

ArthExpr3:
        MINUS ArthExpr7 %prec NEG {

            Children * c = createChildren( 1 ) ;

            c->child[0] = $2;

            $$ = nodeChildren( $1, c );

            free( c );

        }
    ;

ArthExpr4:
        ArthExpr8 POW ArthExpr9 {

            Children * c = createChildren( 2 ) ;

            c->child[0] = $1;
            c->child[0] = $3;

            $$ = nodeChildren( $2, c );

            free( c );

        }
    ;

ArthExprInvoke:
        ArthExpr    { $$ = $1 ; }
    |   Invoke      { $$ = $1 ; }
    ;

ArthExpr6:
        ArthExpr2   { $$ = $1 ; }
    |   ArthExpr3   { $$ = $1 ; }
    |   ArthExpr10  { $$ = $1 ; }
    ;

ArthExpr7:
        LP ArthExpr3 RP { $$ = $2 ; }
    |   ArthExpr10      { $$ = $1 ; }
    ;

ArthExpr8:
        ArthExpr11      { $$ = $1 ; }
    |   LP ArthExpr3 RP { $$ = $2 ; }
    ;

ArthExpr9:
        ArthExpr11  { $$ = $1 ; }
    |   ArthExpr3   { $$ = $1 ; }
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

            $$ = $1 ;

        }

    |   ConcWithInvoke CONC ConcWithInvoke  {
            
            Children * c  = createChildren( 2 ) ;

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

        initMemory( &memory ) ;

        printf("Début du parsing\n\n");

        if( yyparse() == 1 ) {
            
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