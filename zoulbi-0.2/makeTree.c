#include <stdio.h>
#include <stdlib.h>
#include "makeTree.h"


Node * createNode( int type ) {
	
	Node * n 	 = (Node*) malloc( sizeof( Node ) ) ;
	n->type 	 = type;
	n->children  = NULL;
	n->container = NULL;
	n->memory	 = NULL;
	
	return n;
}

Node * nodeChildren( Node * father, Children * c ) { 
	
	father->children = (Node**) malloc( sizeof( Node * ) * c->length );
	
	int i;
	
	for(i = 0; i < c->length; i++)
		father->children[i] = c->node[i];

	return father;
}


















