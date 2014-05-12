%option noyywrap
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "zoulbi.h"
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

"\n"	{ return(EOL); }

"("		{ return(LP); }

")"		{ return(RP); }

","		{ return(VIRGUL); }

";"		{ return(COLON); }


"+"		{ 

	return(PLUS);
}

"-"		{ 

	return(MINUS);
}

"*"		{ 

	return(MULT);
}

"/"		{ 

	return(DIV);
}

"%"		{ 

	return(MOD);
}

"^" 	{

	return(POW);
}


"="		{

	return(SET);
}


"=="	{

	return(EQ);
}

">"		{

	return(GT);
}

"<"		{

	return(LT);
}

">="	{

	return(GE);
}

"<="	{

	return(LE);
}

"!="	{

	return(NE);
}


"!"		{

	return(NOT);
}

"or"	{

	return(OR);
}

"and"	{

	return(AND);
}



"end"	{ return(END); }


("real"|"bool"|"string") { return(TYPE); }


"for"	{

	return(FOR);
}

"while"	{

	return(WHILE);
}


"if"	{

	return(IF);
}

"else" { return(ELSE); }



("true"|"false") 	{

	return(BOOL);
}


{real} 	{

	return(REAL);
}

{string}	{

	return(STRING);
}


{name}	{

	return(NAME);
}

%%