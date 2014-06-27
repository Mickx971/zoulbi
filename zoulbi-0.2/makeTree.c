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


void freeChildren( Children * c ) {
    free( c->child ) ;
    free( c ) ;
    c = NULL ; 
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


void freeBloc( Stack * mem ) {

    int i ;

    for( i = 0 ; i <= mem->stack[ mem->top ].top ; i++ ) {

        free( mem->stack[ mem->top ].v[ i ] ) ;
        mem->stack[ mem->top ].v[ i ] = NULL  ;

    }

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

void setContainer( Node * node ) {

    if( node == NULL ) {
        printf("Erreur de programe: appel de setContainer avec node == NULL\n");
        return ;
    }

    Node * inst ;

    int i , number ;

    switch( node->type ) {

        case NT_FUNCTION  :
        case NT_IF        :
        case NT_ELSE      :

                setContainer( node->children->child[ node->children->number - 1 ] ) ;
            
            break ;

        case NT_IFELSE    :
        case NT_WHILE     :
        case NT_FOR       :

                number = node->children->number ;

                for( i = 0 ; i < number ; i++ ) {

                    node->children->child[ i ]->container = node ;

                    setContainer( node->children->child[ i ] ) ;

                }

            break ;

        case NT_LISTINST :

                inst = node ;

                while( inst->type != NT_EMPTY ) {

                    inst->children->child[ 0 ]->container = node->container ;

                    setContainer( inst->children->child[ 0 ] ) ;

                    inst = inst->children->child[ 1 ] ;

                }

            break ;

        case NT_PLUS      :
        case NT_MINUS     :
        case NT_MULT      :
        case NT_DIV       :
        case NT_MOD       :
        case NT_POW       :
        case NT_CONC      :
        case NT_NOT       :
        case NT_OR        :
        case NT_AND       :
        case NT_LT        :
        case NT_LE        :
        case NT_GT        :
        case NT_GE        :
        case NT_EQ        :
        case NT_NE        :
        case NT_BOOLEXP   :
        case NT_ARTHEXP   :
        case NT_CONCEXP   :
        case NT_SET       :
        case NT_CALL      :
        case NT_CALLPARAM :
        case NT_RETURN    :

                number = node->children->number ;

                for( i = 0 ; i < number ; i++ ) {

                    node->children->child[ i ]->container = node->container ;

                    setContainer( node->children->child[ i ] ) ;

                }

            break ;

        case NT_DEC       :
        case NT_VAR       :
        case NT_BOOL      :
        case NT_STRING    :
        case NT_REAL      :
        case NT_EMPTY     :
            break ;

        default :
            printf("Erreur de programe: appel de setContainer avec node->type == %i\n", node->type );
            return ;
    }

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


// void setContainer( Node * parent ) {

//     Node * inst = parent ;

//     if( inst->type != NT_EMPTY ) {

//         inst->children->child[ inst->children->number - 1 ]->container = parent ;
//         inst = inst->children->child[ inst->children->number - 1 ] ;

//         while( inst->type != NT_EMPTY ) {

//             inst->children->child[ 0 ]->container = parent ;
//             inst = inst->children->child[ 1 ] ;

//         }
//     }
// }













