%option noyywrap
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "makeTree.h"
%}

empty   [ \t]+

num 	[0-9]
int		{num}+
exp 	[eE][+-]?{int}
real	{int}("."{int})?({exp})?

let 	[a-zA-Z]
name 	{let}({num}|{let}|"_")*

string	\"[^\"]*\" 

%%

{empty}	{/* Do nothing */}



<<EOF>>	{ return(END_OF_FILE); }

"\n"	{ return(EOL); 	  }

"("		{ return(LP); 	  }

")"		{ return(RP); 	  }

","		{ return(VIRGUL); }

";"		{ return(COLON);  }

"end"	{ return(END);    }


"." 	{
	yyval.node = createNode(NT_CONC);
	return(CONC);
}

"+"		{ 
	yyval.node = createNode(NT_PLUS);
	return(PLUS);
}

"-"		{ 
	yyval.node = createNode(NT_MINUS);
	return(MINUS);
}

"*"		{ 
	yyval.node = createNode(NT_MULT);
	return(MULT);
}

"/"		{ 
	yyval.node = createNode(NT_DIV);
	return(DIV);
}

"%"		{ 
	yyval.node = createNode(NT_MOD);
	return(MOD);
}

"^" 	{
	yyval.node = createNode(NT_POW);
	return(POW);
}


"="		{
	yyval.node = createNode(NT_SET);
	return(SET);
}


"=="	{
	yyval.node = createNode(NT_EQ);
	return(EQ);
}

">"		{
	yyval.node = createNode(NT_GT);
	return(GT);
}

"<"		{
	yyval.node = createNode(NT_LT);
	return(LT);
}

">="	{
	yyval.node = createNode(NT_GE);
	return(GE);
}

"<="	{
	yyval.node = createNode(NT_LE);
	return(LE);
}

"!="	{
	yyval.node = createNode(NT_NE);
	return(NE);
}


"!"		{
	yyval.node = createNode(NT_NOT);
	return(NOT);
}

"or"	{
	yyval.node = createNode(NT_OR);
	return(OR);
}

"and"	{
	yyval.node = createNode(NT_AND);
	return(AND);
}



("real"|"bool"|"string") { 
	yyval.node = createNode(NT_DEC);
	yyval.string = yytext;
	return(TYPE); 
	// Vérifier la declaration de variables/fonctions
}


"for"	{
	yyval.node = createNode(NT_FOR);
	return(FOR);
}

"while"	{
	yyval.node = createNode(NT_WHILE);
	return(WHILE);
}


"if"	{
	yyval.node = createNode(NT_IF);
	return(IF);
}

"else" {
	yyval.node = createNode(NT_ELSE);
	return(ELSE); 
}



("true"|"false") 	{
	
	yyval.node = createNode(NT_BOOL);
	
	if( yytext == 't' )
		yylval.node->boolean = 1;
	else
		yylval.node->boolean = 0;
	
	return(BOOL);
}

"return" {
	yyval.node = createNode(NT_RETURN);
	return(RETURN);
}


{real} 	{
	yylval.node = createNode(NT_REAL);
    yylval.node->real = atof(yytext);
	return(REAL);
}

{string}	{
	yylval.node = createNode(NT_STRING);
	yyval.node->string = yytext;
	return(STRING);
}



{name}	{
	yyval.str = yytext;
	return(NAME);
}

%%