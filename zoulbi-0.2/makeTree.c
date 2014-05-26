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

    if( mem->stack == NULL || mem->top == -1 ) return indexs;

    for( i = mem->top ; i >= 0 ; i-- ) {

        for( j = 0 ; j <= mem->stack[ i ].top; j++ ) {

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

    if( mem->stack == NULL ) {

        mem->stack = ( Variables * ) malloc( sizeof( Variables ) ) ;
        mem->top   = 0 ;

    }

    int i = ++ mem->stack[ mem->top ].top ;

    mem->stack[ mem->top ].v            = ( Variable ** ) realloc( mem->stack[ mem->top ].v , sizeof( Variable * ) * i + 1 ) ;

    mem->stack[ mem->top ].v[ i ]       = ( Variable * ) malloc( sizeof( Variable ) ) ;

    mem->stack[ mem->top ].v[ i ]->name = copyString( name , 0 ) ;

    mem->stack[ mem->top ].v[ i ]->type = type ;

}


void freeBloc( Stack * mem ) {



}


















