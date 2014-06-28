#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "makeTree.h"
#include "evalTree.h"
#include "utils.h"

typedef union result {

	bool 	b ;
	int 	i ;
	double 	f ;
	char *	s ;

} Result ;




void createVariable( Node * node ) {

	printf("Container de ");
	printType( node->type , 1 ) ;
	printf( "%p\n", node->container ) ;

}


double evalArthExpr( Node * node ) {

	return 0.0 ;

}



bool evalBoolExpr( Node * node ) {

	return false ;

}



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



bool executeTree( Node * node ) {

	Result result ;
	
	printType( node->type , 1 ) ;

	switch( node->type ) {

		/* Fonction */
		case NT_FUNCTION :

				if( executeTree( node->children->child[ 1 ] ) == false )
					return false ;

			break ;

		/* Noeud Vide */

		case NT_EMPTY :
			break ;


		/* Liste d'instructions */

		case NT_LISTINST :
			
				if( executeTree( node->children->child[ 0 ] ) == false )
					return false ;

				if( executeTree( node->children->child[ 1 ] ) == false )
					return false ;
				
			break ;


		/* Les instructions blocs */
		
		case NT_IFELSE :

				result.b = evalBoolExpr( node->children->child[ 0 ] ) ;

				if( result.b == 1 ) {

					if( executeTree( node->children->child[ 1 ] ) == false )
						return false ;

				} else {

					if( executeTree( node->children->child[ 2 ] ) == false )
						return false ;

				}

			break ;


		case NT_IF   :
		case NT_ELSE :

				if( executeTree( node->children->child[ 0 ] ) == false )
					return false ;

			break ;


		case NT_WHILE :
			
				while( evalBoolExpr( node->children->child[ 0 ] ) ) {

					if( executeTree( node->children->child[ 1 ] ) == false )
						return false ;

				}

			break ;


		case NT_FOR :

				if( executeTree( node->children->child[ 0 ] ) == false )
					return false ;

				while( evalBoolExpr( node->children->child[ 1 ] ) ) {

					if( executeTree( node->children->child[ 2 ] ) == false )
						return false ;
					
					if( executeTree( node->children->child[ 3 ] ) == false )
						return false ;
				}

			break ;


		/* Affectation et déclaration */

		case NT_DEC :

				createVariable( node ) ;

			break ;

		case NT_SET :

				if( node->children->child[ 1 ]->typeExpr != node->children->child[ 0 ]->typeVar ) {
					printf( "Erreur sementique du code\n" );
					return false ;
				}
				
				switch( node->children->child[ 1 ]->typeVar ) {

    				case T_VOID :
    						
    						printf( "Non permis\n" ) ;
    						return false ;
    					
    					break ;


    				case T_BOOL   :
    					
    						node->children->child[ 0 ]->boolean = evalBoolExpr( node->children->child[ 1 ] ) ;

    					break ;


    				case T_REAL   :
    						
    						node->children->child[ 0 ]->real = evalArthExpr( node->children->child[ 1 ] ) ;

    					break ;


    				case T_STRING :

    						if( false == evalConc( node->children->child[ 1 ] , &( node->children->child[ 0 ]->string ) ) )
    							return false ;
    					
    					break ;


    				default:
    					printf( "Erreur de programmation: switch déclaration type = %i\n" , node->children->child[ 1 ]->type );
				}

			break ;


		/* Appel de fonction (la seule opération de la ligne) */

		case NT_CALL :
			break;


		/* Instruction return */

		case NT_RETURN :

				if( 1 ) {

				}

			break ;

		default : 
			printf( "Erreur switch ExecuteTree: type = %i\n" , node->type );
			return false ;
	}

	return true ;
}


