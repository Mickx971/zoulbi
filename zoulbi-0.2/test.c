#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "maketree.h"

bool evalConc( Node * node , char ** string ) {

	char * strings[ 2 ] ;
	Node * child[ 2 ] ;
	child[ 0 ] = node->children->child[ 0 ] ;
	child[ 1 ] = node->children->child[ 1 ] ;

	int i ;

	for( i = 0; i < 2 ; i++ ) {
	
		switch( child[ i ]->type ) {

			case NT_STRING :
			
					strings[ i ] = copyString( child[ i ]->string , 0 ) ;
			
				break ;

			case NT_CONC   :

					if( evalConc( child[ i ] , &strings[ i ] ) == false )
						return false ;
			
				break ;

			case NT_VAR    :
				break ;
			
			case NT_CALL   :
				break ;

			default : 
				printf("Erreur de programmation: appel de evalConc avec type = %i\n", child[ i ]->type ) ;
				return false ;
		}
	}
	
	*string = ( char * ) malloc( sizeof( char ) * ( strlen( strings[ 0 ] ) + strlen( strings[ 1 ] ) ) ) ; 
	strcpy( *string , strings[ 0 ] ) ;
	strcpy( *string + strlen( strings[ 0 ] ) , strings[ 1 ] ) ;

	free( strings[ 0 ] ) ;
	free( strings[ 1 ] ) ; 

	return true ;
}

int main() {

	Node * node1 = createNode( NT_CONC ) ;
	Node * node2 = createNode( NT_CONC ) ;


	Node * strings[ 3 ] ;
	strings[ 0 ] = createNode( NT_STRING ) ;
	strings[ 1 ] = createNode( NT_STRING ) ;
	strings[ 2 ] = createNode( NT_STRING ) ;

	strings[ 0 ]->string = copyString( "aaaa" , 0 ) ;
	strings[ 1 ]->string = copyString( "bbbb" , 0 ) ;
	strings[ 2 ]->string = copyString( "cccc" , 0 ) ;


	Children * c = createChildren( 2 ) ;
	c->child[ 0 ] = strings[ 1 ] ; 
	c->child[ 1 ] = strings[ 2 ] ;
	node2 = nodeChildren( node2 , c ) ;

	freeChildren( c ) ;


	c = createChildren( 2 ) ;
	c->child[ 0 ] = strings[ 0 ] ; 
	c->child[ 1 ] = node2 ;
	node1 = nodeChildren( node1 , c ) ;
	
	freeChildren( c ) ;

	char * s = NULL ;

	evalConc( node1 , &s ) ; 

	printf("%s\n", s );

	return EXIT_SUCCESS ;

}

