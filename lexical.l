%{
	#include "syntax.tab.h"
	Node* install_type();
	Node* install_id();
	Node* install_int();
	Node* install_float();
	Node* install(int);
	Node* install_relop();
	/*
	int yycolumn = 1;
	#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno; yylloc.first_column = yycolumn; yylloc.last_column = yycolumn + yyleng - 1; yycolumn += yyleng;
	*/
%}
%option yylineno
delim	[ \t\n\r]
ws		{delim}+
letter	[A-Za-z]
letter_	[_A-Za-z]
digit	[0-9]
id		{letter_}({letter_}|{digit}){0,31}
octal	0[0-7]+
illegaloct	0[0-7]*[89][0-9]*
decimal 0|([1-9][0-9]*)
hex		0[xX][0-9a-fA-F]+
illegalhex	0[xX][0-9a-fA-F]*[g-zG-Z]({letter}|{digit})*
float	{decimal}\.{digit}+
exp		(({digit}+\.{digit}*)|(\.{digit}+))[eE][+-]?{digit}+
type	(int)|(float)
%%
{ws}	{/* no action and no return. For lloc, yylcolumn set to 1 when meet [\n\r\]. */}
while	{yylval = install(WHILE);return WHILE;}
if	{yylval = install(IF);return IF;}
else	{yylval = install(ELSE);return ELSE;}
return	{yylval = install(RETURN);return RETURN;}
struct	{yylval = install(STRUCT);return STRUCT;}
{type}	{yylval = install_type();return TYPE;}
{id}	{yylval = install_id();return ID;}
{octal}	{yylval = install_int(8);return INT;}
{decimal}	{yylval = install_int(10);return INT;}
{hex}	{yylval = install_int(16);return INT;}
{illegalhex}	{
	yylval = install(INT);
	lex_error ++;
	printf("Error type A at Line %d: Illegal hexadecimal number \'%s\'.\n", yylineno, yytext);
	return INT;
}
{illegaloct}	{
	yylval = install(INT);
	lex_error ++;
	printf("Error type A at Line %d: Illegal octal number \'%s\'.\n", yylineno, yytext);
	return INT;
}
{float}|{exp}	{yylval = install_float();return FLOAT;}
"!"	{yylval = install(NOT);return NOT;}
"="	{yylval = install(ASSIGNOP);return ASSIGNOP;}
">"	{yylval = install_relop(GT); return RELOP;}
"<"	{yylval = install_relop(LT); return RELOP;}
">="	{yylval = install_relop(GE); return RELOP;}
"<="	{yylval = install_relop(LE); return RELOP;}
"=="	{yylval = install_relop(EQ); return RELOP;}
"!="	{yylval = install_relop(NE); return RELOP;}
"("	{yylval = install(LP);return LP;}
")"	{yylval = install(RP);return RP;}
"["	{yylval = install(LB);return LB;}
"]"	{yylval = install(RB);return RB;}
"{"	{yylval = install(LC);return LC;}
"}"	{yylval = install(RC);return RC;}
"+"	{yylval = install(PLUS);return PLUS;}
"-"	{yylval = install(MINUS);return MINUS;}
"*"	{yylval = install(STAR);return STAR;}
"/"	{yylval = install(DIV);return DIV;}
"."	{yylval = install(DOT);return DOT;}
";"	{yylval = install(SEMI);return SEMI;}
","	{yylval = install(COMMA);return COMMA;}
"||"	{yylval = install(OR);return OR;}
"&&"	{yylval = install(AND);return AND;}
"/*"	{
	register int c;
	for ( ; ; ) {
		while ( (c = input()) != '*' && c != EOF ) ;  /* eat up text of comment */ 
		if ( c == '*' ) {
			while ( (c = input()) == '*');
			if ( c == '/' ) break;  /* found the end */
		}
		if ( c == EOF ) {
			//error( "EOF in comment" );
			printf("Error type A at Line %d: EOF in comment.\n", yylineno);
			lex_error ++;
			break;
		}
	}
}
"*/"	{ 
	printf("Error type A at Line %d: Unexpected '*/', expecting '/*' before.\n", yylineno);
	lex_error ++;
}
"//"	{
	char c = input();
	while(c != '\n' && c != '\r') c = input();
}
.	{
	printf("Error type A at Line %d: Mysterious character \'%s\'.\n", yylineno, yytext);
	lex_error ++;
}
%%
Node* install_type(){
	Node* p = init_node(TYPE);
	if(p != NULL){
		p->lineno = yylineno;
		if(yytext[0]=='i')strcpy(p->String ,"int");
		if(yytext[0]=='f')strcpy(p->String ,"float");
	}
	return p;
}
Node* install_id(){
	Node *p;
	p = init_node(ID);
	if(p != NULL){
		p->lineno = yylineno;
		strcpy(p->String, yytext);
	}
	return p;
}
Node* install_int(int n){
	Node* p = init_node(INT);
	if(p != NULL){
		p->lineno = yylineno;
		p->value.Int = strtol(yytext,NULL,n);
	}
	return p;
}
Node* install_float(){
	Node* p = init_node(FLOAT);
	if(p != NULL){
		p->lineno = yylineno;
		p->value.Float = atof(yytext);
	}
	return p;
}
Node* install(int Type){
	Node* p = init_node(Type);
	if(p != NULL){
		p->lineno = yylineno;
	}
	return p;
}
Node* install_relop(int reltype){
	Node* p = init_node(RELOP);
	if(p != NULL){
		p->lineno = yylineno;
		p->value.Int = reltype;
	}
	return p;
}
