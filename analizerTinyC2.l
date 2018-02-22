/*Raul Morales A01365009
  Erik Martin A01365096*/

/*This is the declaration section
The only one needed is the variable for the program line */


%{
  int lineCount = 1;

%}



  /*This is the rule definition (Regular expressions)*/
comment   [/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]
id        [A-Za-z_][A-Za-z0-9_]*
float    [-]*[1-9][0-9]*|0(c|C)[0-7]+|0(x|X)[0-9A-Fa-f]+|[+-]?[0-9]*"."[0-9]+([eE][-+]?[0-9]+)?
int		   [-]*[0-9][0-9]*

%%

[\n]                        {lineCount++;}
{comment}                   {
                              for(size_t i = 0;i < strlen(yytext);i++)
                              {
                                if(yytext[i] =='\n')
                                {
                                lineCount++;      /*Increase line Counter for every \n inside the comment*/
                                }
                              }
                            }
"int"                     {yylval.s = strdup(yytext);return INTEGER;}
"float"                   {yylval.s = strdup(yytext);return FLOAT;}
"if"                      {return IF;}
"then"                    {return THEN;}
"else"                    {return ELSE;}
"while"                   {return WHILE;}
"do"                      {return DO;}
"read"                    {return READ;}
"write"                   {return WRITE;}


"{"                       {return LBRACE;}
"}"                       {return RBRACE;}
";"                       {return SEMI;}
"("                       {return LPAREN;}
")"                       {return RPAREN;}

"<"                       {return LT;}
"=="                      {return EQ;}

"+"                       {return PLUS;}
"-"                       {return MINUS;}
"*"                       {return TIMES;}
"/"                       {return DIV;}

":="                      {return ASSIGN;}

{id}                      {yylval.s = strdup(yytext);
                              return ID;}
{int}                     {yylval.i = atoi(yytext);
                              return INT_NUM;}
{float}                   {yylval.f = atof(yytext);
                              return FLOAT_NUM;}

[ \t\r]                   /* Skip Whitespace */

.                         {printf("Error on line: %d: %s\n",lineCount,yytext);return yytext[0];} /*Error handling for unkwown tokens*/

%%
