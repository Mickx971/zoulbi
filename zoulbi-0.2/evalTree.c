#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "makeTree.h"
#include "evalTree.h"
#include "utils.h"

typedef union result {

	bool 	b ;
	double 	f ;
	char *	s ;

} Result ;



Variable * callFunction( Node * node ) {

	Variable * var = NULL ;

	return var ;

}


Variable * getVar( Node * node ) {

	Variable * var = NULL ;

	return var ;

}



void createVariable( Node * node ) {

	Stack * mem = node->container->memory ; 

	if( mem == NULL ) initMemory( &mem ) ;

	if( mem->top == -1 ) {
		mem->stack = ( Variables * ) malloc( sizeof( Variables ) ) ;
		mem->top = 0 ;
		mem->stack[ 0 ].v = NULL ;
		mem->stack[ 0 ].top = -1 ;
	}

	if( mem->stack[ mem->top ].top == -1 )
		mem->stack[ mem->top ].v   = ( Variable ** ) malloc( sizeof( Variable * ) ) ;

	else
		mem->stack[ mem->top ].v   = ( Variable ** ) realloc( mem->stack[ mem->top ].v , sizeof( Variable * ) * ( mem->stack[ mem->top ].top + 1 ) ) ;
	
	mem->stack[ mem->top ].top++ ;

	Variable * newVar = mem->stack[ mem->top ].v[ mem->stack[ mem->top ].top ] ;
	
	newVar = ( Variable * ) malloc( sizeof( Variable ) ) ;

	newVar->type = node->typeVar ;

	newVar->name = node->name ;

	switch( newVar->type ) {

		case T_BOOL   :
			
				newVar->boolean = true ;

			break ;

		case T_REAL   :
			
				newVar->val = 0.0 ;

			break ;

		case T_STRING :
			
				newVar->str = "" ;

			break ;


		default:
			printf("Erreur de programmation: createVariable avec type = %i\n", newVar->type );
	
	}
}


double evalArthExpr( Node * node ) {

	Variable * var = NULL ;

	if( node->type == NT_ARTHEXP ) node = node->children->child[ 0 ] ;

	switch( node->type ) {

		case NT_PLUS 	:
			
				return evalArthExpr( node->children->child[0] ) + evalArthExpr( node->children->child[1] ) ;

			break ;

		case NT_MINUS 	:
			
				return evalArthExpr( node->children->child[0] ) - evalArthExpr( node->children->child[1] ) ;

			break ;

		case NT_MULT 	:
			
				return evalArthExpr( node->children->child[0] ) * evalArthExpr( node->children->child[1] ) ;

			break ;

		case NT_DIV 	:
			
				return evalArthExpr( node->children->child[0] ) / evalArthExpr( node->children->child[1] ) ;

			break ;

		case NT_MOD 	:
			
				return ( (int) evalArthExpr( node->children->child[0] ) ) % ( (int) evalArthExpr( node->children->child[1] ) ) ;

			break ;

		case NT_POW 	:
			
				return pow( evalArthExpr( node->children->child[0] ) , evalArthExpr( node->children->child[1] ) ) ;

			break ;

		case NT_REAL 	:
			
				return node->real ;

			break ;

		case NT_VAR 	:
			
				var = getVar( node ) ;

				return var->boolean ;

			break ;

		case NT_CALL 	:
			
				var = callFunction( node ) ;

			break ;

		default :
			printf("Erreur de programmation: evalArthExpr avec type == %i\n", node->type );
	}

	return 0.0 ;
}



bool evalBoolExpr( Node * node ) {

	Variable * var = NULL ;

	if( node->type == NT_BOOLEXP ) node = node->children->child[ 0 ] ;

	switch( node->type ) {

		case NT_NOT  :

				return ! evalBoolExpr( node->children->child[ 0 ] ) ;

			break ;

		case NT_OR   :

				return evalBoolExpr( node->children->child[ 0 ] ) || evalBoolExpr( node->children->child[ 1 ] ) ;

			break ;

		case NT_AND  :

				return evalBoolExpr( node->children->child[ 0 ] ) && evalBoolExpr( node->children->child[ 1 ] ) ;

			break ;

		case NT_LT 	 :

				return evalArthExpr( node->children->child[ 0 ] ) < evalArthExpr( node->children->child[ 1 ] ) ;

			break ;

		case NT_LE 	 :

				return evalArthExpr( node->children->child[ 0 ] ) <= evalArthExpr( node->children->child[ 1 ] ) ;

			break ;

		case NT_GT 	 :

				return evalArthExpr( node->children->child[ 0 ] ) > evalArthExpr( node->children->child[ 1 ] ) ;

			break ;

		case NT_GE 	 :

				return evalArthExpr( node->children->child[ 0 ] ) >= evalArthExpr( node->children->child[ 1 ] ) ;

			break ;

		case NT_EQ 	 :

				return evalArthExpr( node->children->child[ 0 ] ) == evalArthExpr( node->children->child[ 1 ] ) ;

			break ;

		case NT_NE 	 :

				return evalArthExpr( node->children->child[ 0 ] ) != evalArthExpr( node->children->child[ 1 ] ) ;

			break ;

		case NT_VAR  :

				var = getVar( node ) ;

				return var->boolean ;

			break ;

		case NT_CALL :

				var = callFunction( node ) ; 

				return var->boolean ;

			break ;


		default :
			printf("Erreur de programmation: evalBoolExpr avec type == %i\n", node->type );
	}

	return false ;
}



void evalConc( Node * node , char ** string ) {

	if( node->type == NT_CONCEXP ) node = node->children->child[ 0 ] ;

	char * strings[ 2 ] ;
	
	Node * child[ 2 ] ;
	child[ 0 ] = node->children->child[ 0 ] ;
	child[ 1 ] = node->children->child[ 1 ] ;

	int i ;

	Variable * var = NULL ;

	for( i = 0; i < 2 ; i++ ) {
	
		switch( child[ i ]->type ) {

			case NT_STRING :
			
					strings[ i ] = copyString( child[ i ]->string , 0 ) ;
			
				break ;

			case NT_CONC   :

					evalConc( child[ i ] , &strings[ i ] ) ;
			
				break ;

			case NT_VAR    :

					var = getVar( node ) ;

					strings[ i ] = var->str ;

				break ;
			
			case NT_CALL   :

					var = callFunction( node ) ;

					strings[ i ] = var->str ;

				break ;

			default : 
				printf("Erreur de programmation: appel de evalConc avec type = %i\n", child[ i ]->type ) ;
				return ;
		}
	}
	
	*string = ( char * ) malloc( sizeof( char ) * ( strlen( strings[ 0 ] ) + strlen( strings[ 1 ] ) ) ) ; 
	strcpy( *string , strings[ 0 ] ) ;
	strcpy( *string + strlen( strings[ 0 ] ) , strings[ 1 ] ) ;

	free( strings[ 0 ] ) ;
	free( strings[ 1 ] ) ; 
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

    						evalConc( node->children->child[ 1 ] , &( node->children->child[ 0 ]->string ) ) ;

    					
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


