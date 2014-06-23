%option noyywrap
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "makeTree.h"
    #include "zoulbi.h"
    #include <string.h>

    void initializeEmptyChild( Node * node ) {
        
        node->children               = ( Children * ) malloc( sizeof( Children ) ) ;
        node->children->child        = ( Node ** ) malloc( sizeof( Node * ) ) ;
        node->children->child[ 0 ]   = createNode( NT_EMPTY ) ;
        node->children->number          = 0 ;
    
    }
%}

empty   [ \t]+

num     [0-9]
int     {num}+
exp     [eE][+-]?{int}
real    {int}("."{int})?({exp})?

let     [A-Za-z]
name    "_"*({let}|{num})({let}|{num}|"_")*

string  \"[^\"]*\" 

%%

{empty} {  /* Do nothing */  }




"\n"    { return( EOL )    ; }

"("     { return( LP )     ; }

")"     { return( RP )     ; }

","     { return( VIRGUL ) ; }

";"     { return( COLON )  ; }

"end"   { return( END )    ; }


"."     {

    yylval.node = createNode( NT_CONC ) ;
    
    return( CONC ) ;
}



"+"     {

    yylval.node = createNode( NT_PLUS ) ;

    return( PLUS ) ;
}



"-"     {

    yylval.node = createNode( NT_MINUS ) ;

    return( MINUS ) ;
}



"*"     {

    yylval.node = createNode( NT_MULT ) ;

    return( MULT ) ;
}



"/"     {

    yylval.node = createNode( NT_DIV ) ;

    return( DIV ) ;
}



"%"     {

    yylval.node = createNode( NT_MOD ) ;

    return( MOD ) ;
}



"^"     {

    yylval.node = createNode( NT_POW ) ;
    
    return( POW ) ;
}



"="     {

    yylval.node = createNode( NT_SET ) ;
    
    return( SET ) ;
}



"=="    {

    yylval.node = createNode( NT_EQ ) ;
    
    return( EQ ) ;
}



">"     {

    yylval.node = createNode( NT_GT ) ;
    
    return( GT ) ;
}



"<"     {

    yylval.node = createNode( NT_LT ) ;
    
    return( LT ) ;
}



">="    {

    yylval.node = createNode( NT_GE ) ;
    
    return( GE ) ;
}



"<="    {

    yylval.node = createNode( NT_LE ) ;
    
    return( LE ) ;
}



"!="    {

    yylval.node = createNode( NT_NE ) ;
    
    return( NE ) ;
}




"!"     {

    yylval.node = createNode( NT_NOT ) ;
    
    return( NOT ) ;
}



"or"    {

    yylval.node = createNode( NT_OR ) ;
    
    return( OR ) ;
}



"and"   {

    yylval.node = createNode( NT_AND ) ;
    
    return( AND ) ;
}



("real"|"bool"|"string"|"void") { 
    
    yylval.node = createNode( NT_DEC ) ;

    if( *yytext == 'r' )
        yylval.node->typeVar = T_REAL ;
    
    else {
    
        if ( *yytext == 's' )
            yylval.node->typeVar = T_STRING ;

        else {

            if( *yytext == 'b' )
                yylval.node->typeVar = T_BOOL ;

            else
                yylval.node->typeVar = T_VOID ;
        }
    
    }

    initializeEmptyChild( yylval.node ) ;
    
    return( TYPE ) ;
}



"for"   {

    yylval.node = createNode( NT_FOR ) ;
    
    return( FOR ) ;
}



"while" {

    yylval.node = createNode( NT_WHILE ) ;
    
    return( WHILE ) ;
}




"if"    {

    yylval.node = createNode( NT_IFELSE ) ;
    
    return( IF ) ;
}



"else" {

    yylval.node = createNode( NT_ELSE ) ;
    
    return( ELSE ) ; 
}



("true"|"false")    {
    
    yylval.node = createNode( NT_BOOL ) ;
    
    if( *yytext == 't' )
        yylval.node->boolean = 1;
    else
        yylval.node->boolean = 0;
    
    return( BOOL ) ;
}



"return" {

    yylval.node = createNode( NT_RETURN ) ;
    
    initializeEmptyChild( yylval.node ) ;
    
    return( RETURN ) ;

}



{real}  {

    yylval.node       = createNode( NT_REAL ) ;
    yylval.node->real = atof( yytext )  ;

    return( REAL ) ;

}



{string}    {

    yylval.node         = createNode( NT_STRING )      ;
    yylval.node->string = copyString( yytext + 1 , 1 ) ;

    return( STRING ) ;

}



{name}  {

    yylval.str = copyString( yytext , 0 ) ;
    
    return( NAME ) ;

}
