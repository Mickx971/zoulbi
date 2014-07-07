#include <stdio.h>

void printType( int type , int RC ) {

	switch( type ) {
		case 000 : 
				if( RC ) 
					printf("NT_EMPTY\n");
				else
					printf("NT_EMPTY");
			break ;

		case 001 : 
				if( RC ) 
					printf("NT_BOOL\n");
				else
					printf("NT_BOOL");
			break ;

		case 002 : 
				if( RC ) 
					printf("NT_STRING\n");
				else
					printf("NT_STRING");
			break ;

		case 003 : 
				if( RC ) 
					printf("NT_REAL\n");
				else
					printf("NT_REAL");
			break ;

		case 100 : 
				if( RC ) 
					printf("NT_FUNCTION\n");
				else
					printf("NT_FUNCTION");
			break ;

		case 101 : 
				if( RC ) 
					printf("NT_IF\n");
				else
					printf("NT_IF");
			break ;

		case 102 : 
				if( RC ) 
					printf("NT_ELSE\n");
				else
					printf("NT_ELSE");
			break ;

		case 103 : 
				if( RC ) 
					printf("NT_WHILE\n");
				else
					printf("NT_WHILE");
			break ;

		case 104 : 
				if( RC ) 
					printf("NT_FOR\n");
				else
					printf("NT_FOR");
			break ;

		case 200 : 
				if( RC ) 
					printf("NT_LISTINST\n");
				else
					printf("NT_LISTINST");
			break ;

		case 201 : 
				if( RC ) 
					printf("NT_CONCEXP\n");
				else
					printf("NT_CONCEXP");
			break ;

		case 202 : 
				if( RC ) 
					printf("NT_BOOLEXP\n");
				else
					printf("NT_BOOLEXP");
			break ;

		case 203 : 
				if( RC ) 
					printf("NT_ARTHEXP\n");
				else
					printf("NT_ARTHEXP");
			break ;

		case 204 : 
				if( RC ) 
					printf("NT_CALLPARAM\n");
				else
					printf("NT_CALLPARAM");
			break ;

		case 205 : 
				if( RC ) 
					printf("NT_IFELSE\n");
				else
					printf("NT_IFELSE");
			break ;

		case 300 : 
				if( RC ) 
					printf("NT_PLUS\n");
				else
					printf("NT_PLUS");
			break ;

		case 301 : 
				if( RC ) 
					printf("NT_MINUS\n");
				else
					printf("NT_MINUS");
			break ;

		case 302 : 
				if( RC ) 
					printf("NT_MULT\n");
				else
					printf("NT_MULT");
			break ;

		case 303 : 
				if( RC ) 
					printf("NT_DIV\n");
				else
					printf("NT_DIV");
			break ;

		case 304 : 
				if( RC ) 
					printf("NT_MOD\n");
				else
					printf("NT_MOD");
			break ;

		case 305 : 
				if( RC ) 
					printf("NT_POW\n");
				else
					printf("NT_POW");
			break ;

		case 400 : 
				if( RC ) 
					printf("NT_CONC\n");
				else
					printf("NT_CONC");
			break ;

		case 500 : 
				if( RC ) 
					printf("NT_NOT\n");
				else
					printf("NT_NOT");
			break ;

		case 501 : 
				if( RC ) 
					printf("NT_OR\n");
				else
					printf("NT_OR");
			break ;

		case 502 : 
				if( RC ) 
					printf("NT_AND\n");
				else
					printf("NT_AND");
			break ;

		case 600 : 
				if( RC ) 
					printf("NT_LT\n");
				else
					printf("NT_LT");
			break ;

		case 601 : 
				if( RC ) 
					printf("NT_LE\n");
				else
					printf("NT_LE");
			break ;

		case 602 : 
				if( RC ) 
					printf("NT_GT\n");
				else
					printf("NT_GT");
			break ;

		case 603 : 
				if( RC ) 
					printf("NT_GE\n");
				else
					printf("NT_GE");
			break ;

		case 604 : 
				if( RC ) 
					printf("NT_EQ\n");
				else
					printf("NT_EQ");
			break ;

		case 605 : 
				if( RC ) 
					printf("NT_NE\n");
				else
					printf("NT_NE");
			break ;

		case 700 : 
				if( RC ) 
					printf("NT_SET\n");
				else
					printf("NT_SET");
			break ;

		case 800 : 
				if( RC ) 
					printf("NT_DEC\n");
				else
					printf("NT_DEC");
			break ;

		case 801 : 
				if( RC ) 
					printf("NT_VAR\n");
				else
					printf("NT_VAR");
			break ;

		case 900 : 
				if( RC ) 
					printf("NT_CALL\n");
				else
					printf("NT_CALL");
			break ;

		case 901 : 
				if( RC ) 
					printf("NT_RETURN\n");
				else
					printf("NT_RETURN");
			break ;

		default:
			printf("Unknown type: %i\n", type );
	}
}