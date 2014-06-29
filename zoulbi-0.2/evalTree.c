#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "makeTree.h"
#include "evalTree.h"
#include "utils.h"


#define PRINT 1


FunctionList * functions ;

double      evalArthExpr( Node *               ) ;
bool        evalBoolExpr( Node *               ) ;
void        evalConc(     Node * , char **     ) ;
bool        executeTree(  Node *               ) ;
Variable  * callFunction( Node *               ) ;
Node      * getFunctionNode(  char *           ) ;


void delBloc( Node * node ) {

#ifdef PRINT
    printf("In delBloc\n");
    fflush( stdout ) ;
#endif

    int i ;

    node = node->container ;

    if( node->memory && node->memory->stack ) {

        for( i = 0 ; i < node->memory->stack[ node->memory->top ].top ; i++ ) {

            free( node->memory->stack[ node->memory->top ].v[ i ] ) ;

        }

        free( node->memory->stack[ node->memory->top ].v ) ;

        node->memory->stack[ node->memory->top ].v = NULL  ;

        node->memory->stack[ node->memory->top ].top = -1  ;
    }

#ifdef PRINT
    printf("Out delBloc\n");
    fflush( stdout ) ;
#endif

}

void delMemory( Node * node ) {

#ifdef PRINT
    printf("In delMemory\n") ;
    fflush(stdout) ;
#endif

    int i = 0 ;

    switch( node->type ) {
       
        case NT_FUNCTION  :
        case NT_IF        :
        case NT_ELSE      :
        case NT_WHILE     :
        case NT_FOR       :

                if( node->memory && node->memory->stack ) {

                    for( i = 0 ; i < node->memory->stack[ node->memory->top ].top ; i++ )
                        free( node->memory->stack[ node->memory->top ].v[ i ] ) ;


                    node->memory->stack[ node->memory->top ].v = NULL ;

                    if( node->memory->top == 0 ) {

                        free( node->memory->stack ) ;
                        free( node->memory ) ;
                        node->memory = NULL ;
                    
                    }

                    else {
                        
                        node->memory->stack = ( Variables * ) realloc( node->memory->stack , sizeof( Variables ) * node->memory->top ) ;
                        node->memory->top--;

                    }
                }

                delMemory( node->children->child[ node->children->number - 1 ] ) ;

            break ;

        case NT_LISTINST :

                while( node->type != NT_EMPTY ) {

                    if( node->children->child[ 0 ]->type == NT_IF || node->children->child[ 0 ]->type == NT_ELSE || node->children->child[ 0 ]->type == NT_WHILE || node->children->child[ 0 ]->type == NT_FOR )
                        delMemory( node->children->child[ 0 ] ) ;

                    node = node->children->child[ 1 ] ;

                }

            break ;

        default : 
            printf("Erreur de programmation: appel de delMemory avec type == %i\n", node->type );
            getchar( ) ;
    }

#ifdef PRINT
    printf("Out delMemory\n") ;
    fflush(stdout) ;
#endif

}


void delCall( Node * node ) {

#ifdef PRINT
    printf("In delCall\n") ;
    fflush(stdout) ;
#endif

    while( node->container != NULL ) node = node->container ;

    delMemory( node ) ;

#ifdef PRINT
    printf("Out delCall\n") ;
    fflush(stdout) ;
#endif


}


void addCall( Node * node ) {

#ifdef PRINT
    printf("In addCall\n") ;
    fflush( stdout ) ;
#endif

    switch( node->type ) {
       
        case NT_FUNCTION  :
        case NT_IF        :
        case NT_ELSE      :
        case NT_WHILE     :
        case NT_FOR       :

                if( node->memory == NULL ) {

                    node->memory = ( Stack * ) malloc( sizeof( Stack ) ) ;
                    node->memory->stack = NULL ;
                    node->memory->top = -1 ;
                
                }

                node->memory->top++;

                if( node->memory->stack == NULL )
                    node->memory->stack = ( Variables * ) malloc( sizeof( Variables ) ) ;

                else
                    node->memory->stack = ( Variables * ) realloc( node->memory->stack , sizeof( Variables ) * ( node->memory->top + 1 ) ) ;


                node->memory->stack[ node->memory->top ].top = -1 ;
                node->memory->stack[ node->memory->top ].v = NULL ;


                addCall( node->children->child[ node->children->number - 1 ] ) ;

            break ;

        case NT_LISTINST :

                while( node->type != NT_EMPTY ) {

                    if( node->children->child[ 0 ]->type == NT_IFELSE ) {

                        addCall( node->children->child[ 0 ]->children->child[ 1 ] ) ;

                        if( node->children->child[ 0 ]->children->child[ 2 ]->type != NT_EMPTY )

                            addCall( node->children->child[ 0 ]->children->child[ 2 ] ) ;

                    }

                    else
                        if( node->children->child[ 0 ]->type == NT_WHILE || node->children->child[ 0 ]->type == NT_FOR )
                            addCall( node->children->child[ 0 ] ) ;

                    node = node->children->child[ 1 ] ;
                }

            break ;

        default : 
            printf("Erreur de programmation: appel de addCall avec type == %i\n", node->type );
            getchar();
    }

#ifdef PRINT
    printf("Out addCall\n") ;
    fflush( stdout ) ;
#endif


}


void setParams( Node * callparams , Node * function ) {

#ifdef PRINT
    printf("In setParams\n");
    fflush( stdout ) ;
#endif

    int i = 0 ;

    addCall( function ) ;

    printType( callparams->type , 1 ) ;

    switch( callparams->type ) {
        
        case NT_EMPTY :
            return ;
        
        case NT_CALLPARAM :
        
                executeTree( function->children->child[ 0 ] ) ;

                while( callparams->type != NT_EMPTY ) {

                    switch( callparams->children->child[ 0 ]->typeVar ) {

                        case T_BOOL   :
                        
                                function->memory->stack[ function->memory->top ].v[ i ]->boolean = evalBoolExpr( callparams->children->child[ 0 ] ) ;
                        
                            break ;
                        
                        case T_REAL   :
                        
                                function->memory->stack[ function->memory->top ].v[ i ]->val = evalArthExpr( callparams->children->child[ 0 ] ) ;
                        
                            break ;
                        
                        case T_STRING :
                        
                                evalConc( callparams->children->child[ 0 ] , &function->memory->stack[ function->memory->top ].v[ i ]->str ) ;

                            break ;

                        default :
                            printf("Erreur de rpogrammtion: second switch setParams type == %i\n" , callparams->children->child[ 0 ]->type );
                            getchar() ;

                    }

                    callparams = callparams->children->child[ 1 ] ;

                    i++;
                }

            break ;

        default : 
            printf("Erreur de programmation: appel de setParams avec type == %i\n", callparams->type );
            getchar() ;
    }

#ifdef PRINT
    printf("Out setParams\n");
    fflush( stdout ) ;   
#endif

}

Node * getFunctionNode( char * name ) {

#ifdef PRINT
    printf("In getFunctionNode\n");
    fflush( stdout ) ;
#endif

    int i ;

    for( i = 0 ; i < functions->number ; i++ ) {
        
        if( strcmp( functions->f[ i ]->name , name ) == 0 ) {
        
            printf("Function %s found\n", name );

#ifdef PRINT
            printf("Out getFunctionNode\n");
            fflush( stdout ) ;
#endif


            return functions->f[ i ]->func ;
        
        }
    }

    printf("Erreur de programmation: fonction %s non trouvée dans getParams\n", name ) ;

    return NULL ;

}


Variable * callFunction( Node * node ) {

#ifdef PRINT
    printf("In callFunction\n");
    fflush( stdout ) ;
#endif

    printf("New appeal %s\n", node->name );
    fflush( stdout ) ;

    Node * function = getFunctionNode( node->name ) ;

    setParams( node->children->child[ 0 ] , function ) ;

    executeTree( function->children->child[ 1 ] ) ;

    printf("End appeal\n");

    int i ;

    for( i = 0 ; i < functions->number ; i++ ) {

        if( strcmp( functions->f[ i ]->name , node->name ) == 0 ) {
            printf("Return !!!!!!!!!!!!!!!\n");
            printf("%f\n", functions->f[ i ]->returnBack.val );
            return &functions->f[ i ]->returnBack ;
        }
    }

    printf("Erreur de programmation: fonction %s non trouvé dans callFunction\n", node->name );

    return NULL ;
}


void Execute( FunctionList * fl , Variables * params ) {

#ifdef PRINT
    printf("In Execute\n");
    fflush( stdout ) ;
#endif

    functions = fl ;

    Node * initCall = createNode( NT_CALL ) ;

    initCall->children = createChildren( 1 ) ;
    
    initCall->name = copyString( "main" , 0 ) ;
    
    initCall->children->child[ 0 ] = createNode( NT_EMPTY ) ;

    callFunction( initCall ) ;

#ifdef PRINT
    printf("Out Execute\n");
    fflush( stdout ) ;
#endif

}


Variable * getVar( Node * node ) {

#ifdef PRINT
    printf("In getVar\n");
    fflush( stdout ) ;
#endif

    Variable * var = NULL ;

    Node * container = node->container ;

    int i ;

    while( container != NULL ) {


        while( container->memory->stack[ container->memory->top ].v == NULL ) {
            container = container->container ;
        }
        
        for( i = 0 ; i <= container->memory->stack[ container->memory->top ].top ; i++ ) {


            if( strcmp( container->memory->stack[ container->memory->top ].v[ i ]->name , node->name ) == 0 ) {


                var = container->memory->stack[ container->memory->top ].v[ i ] ;

                container = NULL ;

                break ;

            }
        }

        if( ! container ) break ;

        container = node->container ;
    }


#ifdef PRINT
    printf("Out getVar\n");
    fflush( stdout ) ;
#endif


    return var ;

}



void createVariable( Node * node ) {

#ifdef PRINT
    printf("In createVariable\n");
    fflush( stdout ) ;
#endif

    Stack * mem = node->container->memory ;

    if( mem->stack[ mem->top ].top == -1 )
        mem->stack[ mem->top ].v   = ( Variable ** ) malloc( sizeof( Variable * ) ) ;

    else
        mem->stack[ mem->top ].v   = ( Variable ** ) realloc( mem->stack[ mem->top ].v , sizeof( Variable * ) * ( mem->stack[ mem->top ].top + 2 ) ) ;
    
    mem->stack[ mem->top ].top++ ;

    Variable ** newVar = &mem->stack[ mem->top ].v[ mem->stack[ mem->top ].top ] ;
    
    *newVar = ( Variable * ) malloc( sizeof( Variable ) ) ;

    (*newVar)->type = node->typeVar ;

    (*newVar)->name = node->name ;

    printf("%s\n", (*newVar)->name );

    switch( (*newVar)->type ) {

        case T_BOOL   :
            
                (*newVar)->boolean = true ;

            break ;

        case T_REAL   :
            
                (*newVar)->val = 0.0 ;

            break ;

        case T_STRING :
            
                (*newVar)->str = "" ;

            break ;


        default:
            printf("Erreur de programmation: createVariable avec type = %i\n", (*newVar)->type );
    
    }

#ifdef PRINT
    printf("Out createVariable\n");
    fflush( stdout ) ;
#endif

}


double evalArthExpr( Node * node ) {

#ifdef PRINT
    printf("In evalArthExpr ");
    fflush( stdout ) ;
#endif

    Variable  * var    = NULL ;
    Variables * params = NULL ;

    if( node->type == NT_ARTHEXP ) node = node->children->child[ 0 ] ;

    // printType( node->type , 1 );
    // fflush( stdout ) ;

    switch( node->type ) {

        case NT_PLUS    :
            
                return evalArthExpr( node->children->child[0] ) + evalArthExpr( node->children->child[1] ) ;

            break ;

        case NT_MINUS   :
            
                return evalArthExpr( node->children->child[0] ) - evalArthExpr( node->children->child[1] ) ;

            break ;

        case NT_MULT    :
            
                return evalArthExpr( node->children->child[0] ) * evalArthExpr( node->children->child[1] ) ;

            break ;

        case NT_DIV     :
            
                return evalArthExpr( node->children->child[0] ) / evalArthExpr( node->children->child[1] ) ;

            break ;

        case NT_MOD     :
            
                return ( (int) evalArthExpr( node->children->child[0] ) ) % ( (int) evalArthExpr( node->children->child[1] ) ) ;

            break ;

        case NT_POW     :
            
                return pow( evalArthExpr( node->children->child[0] ) , evalArthExpr( node->children->child[1] ) ) ;

            break ;

        case NT_REAL    :

                return node->real ;

            break ;

        case NT_VAR     :
            
                var = getVar( node ) ;

                return var->val ;

            break ;

        case NT_CALL    :

                var = callFunction( node ) ;

                return var->val ;

            break ;

        default :
            printf("Erreur de programmation: evalArthExpr avec type == %i\n", node->type );
    }

#ifdef PRINT
    printf("Out evalArthExpr\n");
    fflush( stdout ) ;
#endif


    return 0.0 ;
}



bool evalBoolExpr( Node * node ) {

#ifdef PRINT
    printf("In evalBoolExpr\n");
    fflush( stdout ) ;
#endif

    Variable   * var    = NULL ;
    Variables  * params = NULL ;

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

        case NT_LT   :

                return evalArthExpr( node->children->child[ 0 ] ) < evalArthExpr( node->children->child[ 1 ] ) ;

            break ;

        case NT_LE   :

                return evalArthExpr( node->children->child[ 0 ] ) <= evalArthExpr( node->children->child[ 1 ] ) ;

            break ;

        case NT_GT   :

                return evalArthExpr( node->children->child[ 0 ] ) > evalArthExpr( node->children->child[ 1 ] ) ;

            break ;

        case NT_GE   :

                return evalArthExpr( node->children->child[ 0 ] ) >= evalArthExpr( node->children->child[ 1 ] ) ;

            break ;

        case NT_EQ   :

                return evalArthExpr( node->children->child[ 0 ] ) == evalArthExpr( node->children->child[ 1 ] ) ;

            break ;

        case NT_NE   :

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

#ifdef PRINT
    printf("Out evalBoolExpr\n");
    fflush( stdout ) ;
#endif


    return false ;
}



void evalConc( Node * node , char ** string ) {

#ifdef PRINT
    printf("In evalConc\n");
    fflush( stdout ) ;
#endif

    if( node->type == NT_CONCEXP ) node = node->children->child[ 0 ] ;

    char * strings[ 2 ] ;
    
    Node * child[ 2 ] ;
    child[ 0 ] = node->children->child[ 0 ] ;
    child[ 1 ] = node->children->child[ 1 ] ;

    int i ;

    Variable  * var    = NULL ;
    Variables * params = NULL ; 

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

#ifdef PRINT
    printf("Out evalConc\n");
    fflush( stdout ) ;
#endif

}



bool executeTree( Node * node ) {

    Node * end = NULL ;

    Variable * var = NULL ;

    int i ;
    
#ifdef PRINT
    printf("In executeTree ");
    printType( node->type , 1 ) ;
    fflush( stdout ) ;
#endif

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


                if( node->children->child[ 1 ]->type == NT_EMPTY ) {

                    end = node->container->children->child[ node->container->children->number - 1 ] ;

                    while( end->type != NT_EMPTY ) end = end->children->child[ 1 ] ;

                    if( end == node->children->child[ 1 ] ) {

                        switch( node->container->type ) {

                            case NT_FUNCTION  :

                                    delCall( node ) ;

                                break ;

                            case NT_IF        :
                            case NT_ELSE      :
                            case NT_WHILE     :
                            case NT_FOR       :

                                    delBloc( node ) ;

                                break ;

                            default :
                                printf("ListInst switch type == %i\n", node->container->type ) ;
                                break ;
                        } 

                    }

                    return true ;
                }


                if( executeTree( node->children->child[ 1 ] ) == false )
                    return false ;
                
            break ;


        /* Les instructions blocs */
        
        case NT_IFELSE :

                if( evalBoolExpr( node->children->child[ 0 ] ) == 1 ) {

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

                    case T_VOID   :
                            
                            printf( "Non permis\n" ) ;
                            return false ;
                        
                        break ;


                    case T_BOOL   :
                        

                            var = getVar( node->children->child[ 0 ] ) ;

                            var->boolean = evalBoolExpr( node->children->child[ 1 ] ) ;
                            printf("%s == %i\n", var->name , var->boolean );
                            fflush( stdout ) ;

                        break ;


                    case T_REAL   :
                            
                            var = getVar( node->children->child[ 0 ] ) ;

                            var->val = evalArthExpr( node->children->child[ 1 ] ) ;
                            printf("%s == %f\n", var->name , var->val );
                            fflush( stdout ) ;

                        break ;


                    case T_STRING :

                            var = getVar( node->children->child[ 0 ] ) ;

                            evalConc( node->children->child[ 1 ] , &( var->str ) ) ;
                            printf("%s == %s\n", var->name , var->str );
                            fflush( stdout ) ;
                        
                        break ;


                    default :
                        printf( "Erreur de programmation: switch déclaration type = %i\n" , node->children->child[ 1 ]->type );
                        getchar() ;
                }

            break ;


        /* Appel de fonction (la seule opération de la ligne) */

        case NT_CALL :

                callFunction( node ) ;

            break;


        /* Instruction return */

        case NT_RETURN :

                if( node->children->number == 1 ) {

                    end = node ;

                    while( end->container != NULL ) end = end->container ;

                    for( i = 0 ; i < functions->number ; i++ ) {

                        if( strcmp( end->name , functions->f[ i ]->name ) == 0 ) {

                            switch( functions->f[ i ]->type ) {

                                case T_REAL   :
                                    
                                        functions->f[ i ]->returnBack.val = evalArthExpr( node->children->child[ 0 ] ) ;

                                    break ;

                                case T_STRING :
                                    
                                        evalConc( node->children->child[ 0 ] , &functions->f[ i ]->returnBack.str ) ;

                                    break ;

                                case T_BOOL   :
                                    
                                        functions->f[ i ]->returnBack.boolean = evalBoolExpr( node->children->child[ 0 ] ) ;

                                    break ;

                                case T_VOID   :
                                        printf("Return value ignoré car fonction void. Le programme aura un comportement aléatoire \n");
                                    break ;

                            }
                        }
                    }
                }

                delCall( node ) ;

            break ;

        default : 
            printf( "Erreur switch ExecuteTree: type = %i\n" , node->type );
            return false ;
    }

#ifdef PRINT
    printf("Out executeTree ");
    printType( node->type , 1 ) ;
#endif

    fflush( stdout ) ;

    return true ;
}