typedef enum NodeType {
    
    /**************/
    /* Noeud vide */
    /**************/
    
        NT_EMPTY      = 000 ,

    /*****************/ 
    /* valeurs typés */
    /*****************/
        
        NT_BOOL       = 001 ,
        NT_STRING     = 002 ,
        NT_REAL       = 003 , 
    
    /**************/
    /* Conteneurs */
    /**************/
        
        NT_FUNCTION   = 100 ,
        NT_IF         = 101 ,
        NT_ELSE       = 102 ,
        NT_WHILE      = 103 ,
        NT_FOR        = 104 ,

    /***************************/
    /* Noeuds de structuration */
    /***************************/
        
        NT_LISTINST   = 200 ,    // liste d'instructions
        NT_LISTEXPR   = 201 ,    // liste d'expression
        NT_BOOLEXP    = 202 ,    // Expression booléenne
        NT_ARTHEXP    = 203 ,    // Expression arithmétique
        NT_CALLPARAM  = 204 ,    // liste de paramètres (appel)
        NT_IFELSE     = 205 ,    // Noeud qui contient deux enfants: la liste d'instructions du if et potentiellement celle du else

    /***************************/
    /* Opérateurs arithmétique */
    /***************************/

        NT_PLUS       = 300 ,
        NT_MINUS      = 301 ,
        NT_MULT       = 302 ,
        NT_DIV        = 303 ,
        NT_MOD        = 304 ,
        NT_POW        = 305 ,

    /*******************************/
    /* Opérateurs de concaténation */
    /*******************************/

        NT_CONC       = 400 ,

    /***********************/
    /* Connecteurs logique */
    /***********************/

        NT_NOT        = 500 ,
        NT_OR         = 501 ,
        NT_AND        = 502 ,

    /*****************************/
    /* Opérateurs de comparaison */
    /*****************************/

        NT_LT         = 600 ,
        NT_LE         = 601 ,
        NT_GT         = 602 ,
        NT_GE         = 603 ,
        NT_EQ         = 604 ,
        NT_NE         = 605 ,

    /***************************/
    /* Opérateur d'affectation */
    /***************************/

        NT_SET        = 700 ,

    /*************/
    /* Variables */
    /*************/

        NT_DEC        = 800 ,
        NT_VAR        = 801 ,

    /*******************/
    /* Appel et return */
    /*******************/

        NT_CALL       = 900 ,
        NT_RETURN     = 901

} NodeType ;


typedef enum Type {
    T_BOOL      =   0 ,
    T_REAL      =   1 ,
    T_STRING    =   2 ,
    T_VOID      =   3
} Type ;


typedef enum bool {
    false = 0 ,
    true  = 1
} bool ;


typedef struct Variable {
    
    char * name ;
    
    Type type ;
    
    union {
        double  val     ;
        char *  str     ;
        bool    boolean ;
    } ;

} Variable ;


typedef struct Variables {

    Variable ** v ;

    int top ;

} Variables;


typedef struct Stack {

    Variables * stack ;
    int         top   ;

} Stack ;


typedef struct children {
    
    int            number ;
    struct Node ** child  ;   

} Children ;


typedef struct Node {

    NodeType type ; 
    
    union {
    
        char * string ;
        char * name   ;
    
    } ;

    double   real     ;
    
    bool     boolean  ;

    union{
        
        Type    typeVar  ;
        Type    typeExpr ;
    
    } ;

    Stack *  memory   ;

    Children    *  children  ;
    struct Node *  container ;

} Node ;


typedef struct Function {

    char * name ;
    Type   type ;
    Node * func ;

} Function ;



Node     *     createNode( int                                ) ;
Node     *   nodeChildren( Node     *  ,  Children *          ) ;
char     *     copyString( char     *  ,  int                 ) ;
int      *      searchVar( char     *  ,  Stack    *          ) ;
void         logStatement( Stack    *  ,  char     *  ,  int  ) ;
void             freeBloc( Stack    *                         ) ;
void        addMemoryBloc( Stack    *                         ) ;
void          printMemory( Stack    *                         ) ;
void           initMemory( Stack    **                        ) ;
Children * createChildren( int                                ) ;
void         freeChildren( Children *                         ) ;
void         setContainer( Node *                             ) ;



