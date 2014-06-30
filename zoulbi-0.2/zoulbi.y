%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>
    #include "makeTree.h"
    #include "evalTree.h"

    extern int  yyparse() ;
    extern FILE *yyin ;

    void           yyerror(char *) ;
    int            yylex()         ;
    int            yydebug  =  0   ;
    FunctionList * functions       ;  
    Stack * memory ;

%}

/*  

    Union des types reconnus
    par ce fichier bison.

*/

%union {
   
    Node      *   node    ;
    char      *   str     ;

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
%type <node>    Content
%type <node>    FreeMemoryBloc
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
        
        Prot Content END { 
        
            $1->children->child[ 1 ] = $2 ; 
            $$ = $1 ;

            setContainer( $$ ) ;

            freeBloc( memory );
        }
    ;

Prot:
        TYPE NAME LP ListArgOrEmpty RP EOL {

            $$ = createNode( NT_FUNCTION ) ;
            $$->container = NULL ;
            $$->children = createChildren( 2 ) ;
            $$->children->child[ 0 ] = $4 ;
            $$->name = $2 ;
            $$->typeVar = $1->typeVar ;

            stockFunction( $$ , &functions ) ;
        
        }
    ;

ListArgOrEmpty:
    
        { $$ = createNode( NT_EMPTY ) ; }
    
    |   ListArg { 
        
            $$ = $1 ; 
       
        }
    ;

ListArg:
        Arg {

            $$ = createNode( NT_LISTINST ) ;
            $$->children = createChildren( 2 ) ;
            $$->children->child[ 0 ] = $1 ;
            $$->children->child[ 1 ] = createNode( NT_EMPTY ) ;
        
        }

    |   Arg VIRGUL ListArg {

            $$ = createNode( NT_LISTINST ) ;
            $$->children = createChildren( 2 ) ;
            $$->children->child[ 0 ] = $1 ;
            $$->children->child[ 1 ] = $3 ;

        }
    ;

Arg:
        TYPE NAME {

            if( memory->stack == NULL ) addMemoryBloc( memory ) ;

            /* Vérification de la validité de la déclaration */

            if( searchVar( $2 , memory ) ) {

                printf( "Déclaration multiple de la variable %s\n", $2 ) ;

                free( $2 ) ;

                return 1 ;

            }

            /* Enregistrement de la déclaration */

            logStatement( memory , $2 , $1->typeVar ) ;

            $1->name = $2 ;
            $$ = $1 ;

        }
    ;

Content:
        LeolOrNull {
        
            $$ = createNode( NT_EMPTY ) ;
        
        }

    |   AddMemoryBloc Insts FreeMemoryBloc {

            $$ = $2 ;

        }
    ;

FreeMemoryBloc: 
             { freeBloc( memory ) ; }
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
        Inst LeolOrNull { 

            if( $1->type == NT_LISTINST ) {

                $$ = $1 ;
            
            } else {
        
                $$ = createNode( NT_LISTINST ) ;

                Children * c = createChildren( 2 ) ;

                c->child[ 0 ] = $1 ;
                c->child[ 1 ] = createNode( NT_EMPTY ) ;

                $$ = nodeChildren( $$ , c ) ;

                freeChildren( c ) ;
            }
        }

    |   Inst LeolOrNull Insts {

            if( $1->type == NT_LISTINST ) {

                $1->children->child[ 1 ]->children->child[ 1 ] = $3 ;

                $$ = $1 ;
            
            } else {

                $$ = createNode( NT_LISTINST ) ;

                Children * c = createChildren( 2 ) ;

                c->child[ 0 ] = $1 ;
                c->child[ 1 ] = $3 ;

                $$ = nodeChildren( $$ , c ) ;

                freeChildren( c ) ;
            }
        }
    ;

Inst:
        SetLine     { $$ = $1 ; }
    |   CallLine    { $$ = $1 ; }
    |   DefVarLine  { $$ = $1 ; }
    |   Bloc        { $$ = $1 ; }
    |   ReturnLine  { $$ = $1 ; }
    ;

ReturnLine:
        
        RETURN EOL { 
        
            $1->typeVar = T_VOID ; 
            $$ = $1 ;
        }

    |   RETURN Expr EOL {

            free( $1->children->child[ 0 ] ) ;

            $1->children->child[ 0 ] = $2 ;

            $1->children->number = 1 ;

            $1->typeVar = $2->typeVar ;

            $$ = $1 ;

        }
    ;

DefVarLine:

        TYPE NAME EOL           {

            /* Vérification de la validité de la déclaration */

            if( searchVar( $2 , memory ) ) {

                printf( "Déclaration multiple de la variable %s\n", $2 ) ;

                free( $2 ) ;

                return 1 ;

            }

            /* Enregistrement de la déclaration */

            logStatement( memory , $2 , $1->typeVar ) ;

            
            /* Ajout du nom de la variable au noeud Déclaration */

            $1->name = $2 ;

            $$ = $1 ;
        }

    |   TYPE NAME SET Expr EOL  {

            /* Vérification de la validité de la déclaration */

            if( searchVar( $2 , memory ) ) {

                printf( "Déclaration multiple de la variable %s\n", $2 ) ;

                free( $2 ) ;

                return 1 ;

            }


            /* On vérifie que l'affectation est valide */

            if( $1->typeVar != $4->typeExpr ) {

                printf("Erreur: incompatibilitée de type\n");
                printf("Affectation de la variable %s impossible\n", $2 );
                
                free( $2 ) ;

                return 1 ;
            }


            /* On décompose cette instruction en une déclaration et une affectation */


            $$ = createNode( NT_LISTINST ) ;


            // Déclaration
            $1->name = $2 ;


            //Affectation
            Children * c            = createChildren( 2 )  ;
            c->child[ 0 ]           = createNode( NT_VAR ) ;
            c->child[ 0 ]->typeVar  = $1->typeVar          ;
            c->child[ 0 ]->name     = $2                   ;
            c->child[ 1 ]           = $4                   ;
            $3 = nodeChildren( $3 , c ) ;


            /* Ajout des instruction dans la liste d'instruction */

            c->child[ 0 ] = $1                        ; 
            c->child[ 1 ] = createNode( NT_LISTINST ) ;
            $$            = nodeChildren( $$ , c )    ;

            c->child[ 0 ]            = $3                                           ;
            c->child[ 1 ]            = createNode( NT_EMPTY )                       ;
            $$->children->child[ 1 ] = nodeChildren( $$->children->child[ 1 ] , c ) ;

            freeChildren( c ) ;


            /* Enregistrement de la déclaration */

            logStatement( memory , $2 , $1->typeVar ) ;


        }  
    ;

SetLine:
        Set EOL { $$ = $1 ; }
    ;

Set:
        NAME SET Expr {

            int * indexs ;

            if( ( indexs = searchVar( $1 , memory ) ) != NULL ) {

                if( memory->stack[ indexs[ 0 ] ].v[ indexs[ 1 ] ]->type != $3->typeExpr ) {

                    printf("Erreur: incompatibilitée de type\n");
                    printf("Affectation de la variable %s impossible\n", $1 );
                    
                    return 1 ;
                }

                Children * c = createChildren( 2 ) ;

                c->child[ 0 ] = createNode( NT_VAR ) ;
                c->child[ 0 ]->typeVar = memory->stack[ indexs[ 0 ] ].v[ indexs[ 1 ] ]->type ;
                c->child[ 0 ]->name = $1 ;
                
                switch( c->child[ 0 ]->typeVar ) {
                    
                    case NT_REAL :
                            c->child[ 0 ]->real = memory->stack[ indexs[ 0 ] ].v[ indexs[ 1 ] ]->val ;
                        break ;
                    
                    case NT_BOOL :
                            c->child[ 0 ]->boolean = memory->stack[ indexs[ 0 ] ].v[ indexs[ 1 ] ]->boolean ;
                        break ;
                    
                    case NT_STRING :
                            c->child[ 0 ]->string = memory->stack[ indexs[ 0 ] ].v[ indexs[ 1 ] ]->str ;
                        break ;
                    
                    default :
                        printf("Erreur de programmation: yack Set: avec typeVar == %i\n", c->child[ 0 ]->typeVar );
                        return 1 ;
                }
                
                c->child[ 1 ] = $3 ;

                $$ = nodeChildren( $2 , c ) ;

                freeChildren( c ) ;

                free( indexs ) ;
            }

            else {

                printf( "Variable %s non définie\n", $1 ) ;
                return 1;
            
            } 

        }
    ;

CallLine:
        Call EOL { $$ = $1 ; }
    ;

Call:
        NAME LP ListParamOrEmpty RP {

            $$ = createNode( NT_CALL ) ;
            $$->children = createChildren( 1 ) ;
            $$->children->child[ 0 ] = $3 ;
            $$->name = $1 ;

            int i , found = 0 ;

            if( strcmp( $$->name , "print" ) == 0 ) {

                $$->typeVar = T_VOID ;
                found = 1 ;
            
            }

            if( found == 0 ) {

                for( i = 0 ; i < functions->number ; i++ ) {

                    if( strcmp( functions->f[ i ]->name , $1 ) == 0 ) {

                        $$->typeVar = functions->f[ i ]->type ;
                        found = 1 ;
                    
                    }
                }
            }
            
            if( found == 0 ) {
                printf("Fonction %s non trouvée\n", $$->name );
                return 1 ;
            }
        }
    ;

ListParamOrEmpty:

        { $$ = createNode( NT_EMPTY ) ; }
    
    |   ListParam { $$ = $1 ; }
    ;

ListParam:

        Expr VIRGUL ListParam {

            $$ = createNode( NT_CALLPARAM ) ;
            $$->children = createChildren( 2 ) ;
            $$->children->child[ 0 ] = $1 ;
            $$->children->child[ 1 ] = $3 ;

        }

    |   Expr {

            $$ = createNode( NT_CALLPARAM ) ;
            $$->children = createChildren( 2 ) ;
            $$->children->child[ 0 ] = $1 ;
            $$->children->child[ 1 ] = createNode( NT_EMPTY ) ;

        }
    ;

Bloc:
        If      EOL { $$ = $1 ; }
    |   While   EOL { $$ = $1 ; }
    |   For     EOL { $$ = $1 ; }
    ;

If:
        Bif Content END { 

            $1->children->child[ 2 ] = createNode( NT_EMPTY ) ;

            $1->children->child[ 1 ] = createNode( NT_IF ) ;

            $1->children->child[ 1 ]->children = createChildren( 1 ) ;

            $1->children->child[ 1 ]->children->child[ 0 ] = $2 ;

            $$ = $1 ;

        }

    |   Bif Content ELSE Content END { 

            $1->children->child[ 1 ] = createNode( NT_IF ) ;
            $1->children->child[ 2 ] = $3 ;

            $1->children->child[ 1 ]->children = createChildren( 1 ) ;
            $1->children->child[ 2 ]->children = createChildren( 1 ) ;

            $1->children->child[ 1 ]->children->child[ 0 ] = $2 ;
            $1->children->child[ 2 ]->children->child[ 0 ] = $4 ;

            $$ = $1 ;

        }
    ;

Bif:
        IF LP BoolExprInvoke RP EOL {

            Children * c = createChildren( 3 ) ;

            c->child[ 0 ] = $3 ;

            $$ = nodeChildren( $1 , c );

            freeChildren( c ) ;
        }
    ;

BoolExpr:

        BOOL            { $$ = $1 ; }

    |   BoolExprMore    { $$ = $1 ; }

    ;

BoolExprMore:  
        
        BoolCondition   {

            $$ = $1 ;

        }

    |   NOT BoolExprInvoke  {

            Children * c = createChildren( 1 ) ;

            c->child[ 0 ] = $2 ;

            $$ = nodeChildren( $1 , c ) ;

            freeChildren( c ) ;
        }

    |   BoolExprInvoke  OR    BoolExprInvoke    {

            Children * c = createChildren( 2 ) ;

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c ) ;

            freeChildren( c ) ;
        }

    |   BoolExprInvoke  AND   BoolExprInvoke    {

            Children * c = createChildren( 2 ) ;

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c ) ;

            freeChildren( c ) ;
        }
    ;

BoolExprInvoke:

        Invoke      { 
            
            $$ = createNode( NT_BOOLEXP );
            $$->children = createChildren( 1 ) ;
            $$->children->child[ 0 ] = $1 ;
            $$->typeExpr = T_BOOL ;
        
        }

    |   BoolExpr    { 

            $$ = createNode( NT_BOOLEXP );
            $$->children = createChildren( 1 ) ;
            $$->children->child[ 0 ] = $1 ;
            $$->typeExpr = T_BOOL ;

        }
    ;

BoolCondition:
        
        EqualCondition { $$ = $1 ; }

    |   ArthExprInvoke    GT    ArthExprInvoke { 

            Children * c = createChildren( 2 ) ;

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c ) ;

            freeChildren( c ) ;
        }

    |   ArthExprInvoke    GE    ArthExprInvoke { 

            Children * c = createChildren( 2 ) ;

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c ) ;

            freeChildren( c ) ;
        }

    |   ArthExprInvoke    LT    ArthExprInvoke { 

            Children * c = createChildren( 2 ) ;

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c ) ;

            freeChildren( c ) ;
        }

    |   ArthExprInvoke    LE    ArthExprInvoke { 

            Children * c = createChildren( 2 ) ;

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c ) ;

            freeChildren( c ) ;
        }

    ;

EqualCondition:

        Operand EQ Operand  {

            Children * c = createChildren( 2 ) ;

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c ) ;

            freeChildren( c ) ;
        }

    |   Operand NE Operand  {

            Children * c = createChildren( 2 ) ;

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c ) ;

            freeChildren( c ) ;
        }
    ;

Operand:
        ArthExpr            { $$ = $1 ; }
    |   Conc                { $$ = $1 ; }
    |   Invoke              { $$ = $1 ; }
    |   LP BoolExprMore RP  { $$ = $2 ; }
    |   BOOL                { $$ = $1 ; }
    ;

While:
        Bwhile Content END { 

            $1->children->child[ 1 ] = $2 ;
            $$ = $1 ;
        
        }
    ;

Bwhile:
        
        WHILE LP BoolExprInvoke RP EOL {

            Children * c = createChildren( 2 ) ;

            c->child[ 0 ] = $3 ;
            c->child[ 1 ] = NULL ;

            $$ = nodeChildren( $1 , c ) ;

            freeChildren( c ) ;
        }
    ;


For:
        Bfor Content END { 

            $1->children->child[ 3 ] = $2 ;
            $$ = $1 ;
        
        }
    ;

Bfor:
        FOR LP InstsList COLON BoolExprInvoke COLON InstsList RP EOL {

            Children * c = createChildren( 4 ) ;

            c->child[ 0 ] = $3 ;
            c->child[ 1 ] = $5 ;
            c->child[ 2 ] = $7 ;
            c->child[ 3 ] = NULL ;

            $$ = nodeChildren( $1 , c ) ;

            freeChildren( c ) ;
        }
    ;

InstsList:
       
        { $$ = createNode( NT_EMPTY ) ; }

    |   IList { $$ = $1 ; }
    ;

IList:
        Set VIRGUL IList    {

            $$ = createNode( NT_LISTINST ) ;
            
            Children * c = createChildren( 2 ) ;
            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $$ , c ) ;

            freeChildren( c ) ;
        }

    |   Call VIRGUL IList   {

            $$ = createNode( NT_LISTINST ) ;
            
            Children * c = createChildren( 2 ) ;
            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $$ , c ) ;

            freeChildren( c ) ;
        }
    
    |   Set                 { 
            $$ = createNode( NT_LISTINST ) ;
            
            Children * c = createChildren( 2 ) ;
            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = createNode( NT_EMPTY ) ;

            $$ = nodeChildren( $$ , c ) ;

            freeChildren( c ) ;
        }

    |   Call                {
            
            $$ = createNode( NT_LISTINST ) ;
            
            Children * c = createChildren( 2 ) ;
            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = createNode( NT_EMPTY ) ;

            $$ = nodeChildren( $$ , c ) ;

            freeChildren( c ) ;
        }
    ;

Expr:
        ArthExpr    {

            $$ = createNode( NT_ARTHEXP );
            $$->children = createChildren( 1 ) ;
            $$->children->child[ 0 ] = $1 ;
            $$->typeExpr = T_REAL ; 
                 
        }

    |   BoolExpr    {

            $$ = createNode( NT_BOOLEXP );
            $$->children = createChildren( 1 ) ;
            $$->children->child[ 0 ] = $1 ;
            $$->typeExpr = T_BOOL ;
        
        }

    |   Conc        {

            $$ = createNode( NT_CONCEXP );
            $$->children = createChildren( 1 ) ;
            $$->children->child[ 0 ] = $1 ;
            $$->typeExpr = T_STRING ; 
        
        }

    |   Invoke      {

            switch( $1->typeVar ) {

                case T_STRING :
                        $$ = createNode( NT_CONCEXP );
                        $$->typeExpr = T_STRING ;
                    break ;

                case T_BOOL   :
                        $$ = createNode( NT_BOOLEXP );
                        $$->typeExpr = T_BOOL ;
                    break ;

                case T_REAL   :
                        $$ = createNode( NT_ARTHEXP );
                        $$->typeExpr = T_REAL ;
                    break ;

                default :
                    printf("Erreur de programmation: Invoke type inconnu = %i\n", $1->typeVar );
                    return 1 ;

            }

            $$->children = createChildren( 1 ) ;
            $$->children->child[ 0 ] = $1 ;

        }
    ;

Invoke:
        Call    { $$ = $1 ; }

    |   NAME    {

            int * indexs ;

            if( ( indexs = searchVar( $1 , memory ) ) != NULL ) {
            
                $$ = createNode( NT_VAR ) ;

                switch( memory->stack[ indexs[ 0 ] ].v[ indexs [ 1 ] ]->type ) {

                    case T_BOOL   :
                    case T_REAL   :
                    case T_STRING :
                            $$->typeVar = memory->stack[ indexs[ 0 ] ].v[ indexs [ 1 ] ]->type ;
                        break ;

                    default :
                        printf("Erreur de programmation: switch invoke name: var memory type == %i\n", memory->stack[ indexs[ 0 ] ].v[ indexs [ 1 ] ]->type );
                        return 1 ;
                }

                $$->name = $1 ;

                free( indexs ) ;
            }

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

            Children * c = createChildren( 2 );

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c ) ;

            freeChildren( c );
        }


    |   ArthExprInvoke  MINUS   ArthExprInvoke {

            Children * c = createChildren( 2 );

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c ) ;

            freeChildren( c );

        }
    ;

ArthExpr2:
        ArthExpr6   MULT    ArthExpr6 {

            Children * c = createChildren( 2 );

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c ) ;

            freeChildren( c );

        }


    |   ArthExpr6   MOD     ArthExpr6 {

            Children * c = createChildren( 2 );

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c ) ;

            freeChildren( c );

        }


    |   ArthExpr6   DIV     ArthExpr6 {

            Children * c = createChildren( 2 );

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c ) ;

            freeChildren( c );

        }
    ;

ArthExpr3:
        MINUS ArthExpr7 %prec NEG {

            Children * c = createChildren( 2 ) ;

            c->child[ 1 ] = $2 ;
            c->child[ 0 ] = createNode( NT_REAL ) ;
            c->child[ 0 ]->real = 0 ;

            $$ = nodeChildren( $1 , c );

            freeChildren( c );
        }
    ;

ArthExpr4:
        ArthExpr8 POW ArthExpr9 {

            Children * c = createChildren( 2 ) ;

            c->child[ 0 ] = $1;
            c->child[ 1 ] = $3;

            $$ = nodeChildren( $2 , c );

            freeChildren( c );
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
        ArthExpr11      { $$ = $1 ;}
    |   LP ArthExpr3 RP { $$ = $2 ;}
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
        STRING {

            $$ = $1 ;

        }

    |   ConcWithInvoke CONC ConcWithInvoke  {
            
            Children * c  = createChildren( 2 ) ;

            c->child[ 0 ] = $1 ;
            c->child[ 1 ] = $3 ;

            $$ = nodeChildren( $2 , c );

            freeChildren( c ) ;
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

    if ( ( argc >= 3 ) && ( strcmp( argv[ 1 ] , "-f" ) == 0 ) ) {
    
        if ( argc == 3 )
            yydebug = 0 ;
        else
            yydebug = atoi( argv[ 3 ] ) ;

        FILE * fp = fopen( argv[ 2 ] , "r" );

        if( !fp ) {
            
            printf( "Impossible d'ouvrir le fichier à executer.\n" );
            return EXIT_FAILURE ;
        
        }

        yyin = fp;

        initMemory( &memory ) ;

        if( yyparse() == 1 ) {
            
            printf( "Echec du parsing\n" );
            fclose( fp );
        
            return EXIT_FAILURE ;
        
        }
        else {
         
            printf( "\nFichier correct\n" );
            printf( "Execution ... \n\n" );

            Execute( functions , NULL ) ;

        }
  
        fclose( fp );
    }
    
    return EXIT_SUCCESS ;
}