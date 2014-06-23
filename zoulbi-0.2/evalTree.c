#include <stdlib.h>
#include <stdio.h>
#include "makeTree.h"
#include "evalTree.h"

typedef union result {

	bool 	b ;
	int 	i ;
	double 	f ;
	char *	s ;

} Result ;


void createVariable( Node * node ) {

}


double evalArthExpr( Node * node ) {

	return 0.0 ;

}



bool evalBoolExpr( Node * node ) {

	return false ;

}



char * evalConc( Node * node ) {

	return NULL ;

}



bool executeTree( Node * node ) {

	Result result ;
	
	switch( node->type ) {

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

					if( executeTree( node->children->child[ 0 ] ) == false )
						return false ;

				}

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
				
				if( executeTree( node->children->child[ 0 ] ) == false )
					return false ; 
				/* Si il c'est juste une une déclaration child[ 0 ] est de type NT_EMPTY */

			break ;

		case NT_SET :

				if( node->typeExpr != node->children->child[ 0 ]->typeVar ) {
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

    						node->children->child[ 0 ]->string = evalConc( node->children->child[ 1 ] ) ;
    					
    					break ;


    				default:
    					printf( "Erreur de programmation: switch déclaration type = %i\n" , node->children->child[ 1 ]->type );
				}

			break ;


		/* Appel de fonction (la seule opération de la ligne) */

		case NT_CALL :



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


