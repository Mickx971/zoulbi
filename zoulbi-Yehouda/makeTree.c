#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "makeTree.h"


Node * createNode( int type ) {
    
    Node * n     = (Node*) malloc( sizeof( Node ) ) ;
    n->type      = type ;
    n->children  = NULL ;
    n->container = NULL ;
    n->memory    = NULL ;
    
    return n;
}

Node * nodeChildren( Node * father, Children * c ) { 
    
    father->children = ( Children * ) malloc( sizeof( Children ) ) ;
    father->children->child = ( Node ** ) malloc( sizeof( Node * ) * c->number ) ; 
    
    int i ;
    
    for( i = 0 ; i < c->number ; i++ )
        father->children->child[ i ] = c->child[ i ] ;

    return father ;
}


Children * createChildren( int nb ) {
 
    Children * c  = ( Children * ) malloc( sizeof( Children ) ) ;
    c->child      = ( Node ** )    malloc( sizeof( Node * ) * nb ) ;
    c->number     =  nb ;

    return c ;
}


char * copyString( char * s , int n ) {

    int i = strlen( s ) ;

    char * string = ( char * ) malloc( sizeof( char ) * ( i - n + 1 ) ) ;

    strncpy( string , s , i - n ) ;

    string[ i - n ] = '\0' ;

    return string ;

}

int * searchVar( char * var , Stack * mem ) {

    int i , j ;
    int * indexs = NULL ;

    for( i = mem->top ; i >= 0 ; i-- ) {

        for( j = 0 ; j <= mem->stack[ i ].top ; j++ ) {

            if( strcmp( mem->stack[ i ].v[ j ]->name , var ) == 0 ) {

                indexs = ( int * ) malloc( sizeof( int ) * 2 ) ;

                indexs[0] = i ;
                indexs[1] = j ;

            }

        }

    }

    return indexs ;
}

void logStatement( Stack * mem , char * name , int type) {

    int i = ++ mem->stack[ mem->top ].top ;

    mem->stack[ mem->top ].v            = ( Variable ** ) realloc( mem->stack[ mem->top ].v , sizeof( Variable * ) * ( i + 1 ) ) ;

    mem->stack[ mem->top ].v[ i ]       = ( Variable *  ) malloc( sizeof( Variable ) ) ;

    mem->stack[ mem->top ].v[ i ]->name = copyString( name , 0 ) ;

    mem->stack[ mem->top ].v[ i ]->type = type ;

}


Stack * getMemoryBloc( Stack * mem ) {

    Stack * treeMemoryBloc    =  ( Stack * ) malloc( sizeof( Stack ) ) ;
    treeMemoryBloc->stack     =  &( mem->stack[ mem->top ] ) ;
    treeMemoryBloc->top       =  0 ;

    return treeMemoryBloc ;

}


void freeBloc( Stack * mem ) {

    *( &( mem->stack ) + mem->top ) = NULL ;
    mem->stack = ( Variables * ) realloc( mem->stack , sizeof( Variables ) * mem->top ) ;
    mem->top-- ;

}


void addMemoryBloc( Stack * mem ) {

    mem->top++;
    mem->stack = ( Variables * ) realloc( mem->stack , sizeof( Variables ) * ( mem->top + 1 ) ) ;
    mem->stack[ mem->top ].top = -1   ;
    mem->stack[ mem->top ].v   = NULL ;

}

void initMemory( Stack ** mem ) {
   
    ( * mem )         = ( Stack * ) malloc( sizeof( Stack ) ) ;
    ( * mem )->top    = -1   ;
    ( * mem )->stack  = NULL ;

}

void printMemory( Stack * mem ) {
    
    if(! mem || ! mem->stack) {
        printf( "Mémoire vide \n" ) ;
        return ;
    }

    int i , j ;

    for( i = 0 ; i <= mem->top ; i++ ) {

        for( j = 0 ; j <= mem->stack[ i ].top ; j++ )

            printf( "%s: ( height = %i, pos = %i )\n" , mem->stack[ i ].v[ j ]->name , i , j );

        printf( "\n" ) ;

    }
}


















