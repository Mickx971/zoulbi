#include <stdio.h>

void printType( int type ) {

	switch( type ) {
		case 000 : printf("NT_EMPTY\n");
			break ;

		case 001 : printf("NT_BOOL\n");
			break ;

		case 002 : printf("NT_STRING\n");
			break ;

		case 003 : printf("NT_REAL\n");
			break ;

		case 100 : printf("NT_FUNCTION\n");
			break ;

		case 101 : printf("NT_IF\n");
			break ;

		case 102 : printf("NT_ELSE\n");
			break ;

		case 103 : printf("NT_WHILE\n");
			break ;

		case 104 : printf("NT_FOR\n");
			break ;

		case 200 : printf("NT_LISTINST\n");
			break ;

		case 201 : printf("NT_CONCEXP\n");
			break ;

		case 202 : printf("NT_BOOLEXP\n");
			break ;

		case 203 : printf("NT_ARTHEXP\n");
			break ;

		case 204 : printf("NT_CALLPARAM\n");
			break ;

		case 205 : printf("NT_IFELSE\n");
			break ;

		case 300 : printf("NT_PLUS\n");
			break ;

		case 301 : printf("NT_MINUS\n");
			break ;

		case 302 : printf("NT_MULT\n");
			break ;

		case 303 : printf("NT_DIV\n");
			break ;

		case 304 : printf("NT_MOD\n");
			break ;

		case 305 : printf("NT_POW\n");
			break ;

		case 400 : printf("NT_CONC\n");
			break ;

		case 500 : printf("NT_NOT\n");
			break ;

		case 501 : printf("NT_OR\n");
			break ;

		case 502 : printf("NT_AND\n");
			break ;

		case 600 : printf("NT_LT\n");
			break ;

		case 601 : printf("NT_LE\n");
			break ;

		case 602 : printf("NT_GT\n");
			break ;

		case 603 : printf("NT_GE\n");
			break ;

		case 604 : printf("NT_EQ\n");
			break ;

		case 605 : printf("NT_NE\n");
			break ;

		case 700 : printf("NT_SET\n");
			break ;

		case 800 : printf("NT_DEC\n");
			break ;

		case 801 : printf("NT_VAR\n");
			break ;

		case 900 : printf("NT_CALL\n");
			break ;

		case 901 : printf("NT_RETURN\n");
			break ;

		default:
			printf("Unknown type: %i\n", type );
	}
}