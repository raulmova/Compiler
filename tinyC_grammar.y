/*Raul Morales A01365009*/
/*Erik Martin A01365096*/

%{
#include <string.h>
#include <stdio.h>
#include <glib.h>
#include "UserDefined.h"

/*Variables
 GHashTable * theTable_p;

 theTable_p = g_hash_table_new_full(g_str_hash, g_str_equal,
                                    NULL,
                                    (GDestroyNotify)FreeItem);
*/
  /* Function definitions */
void yyerror(const char* const message);
int yylex();
%}


%define parse.error verbose       /*Used by the yyerror function for a more descriptive error reporting*/

/*****************************All the tokens return by the lex file*******************************/
%token ID
%token SEMI
%token INTEGER
%token FLOAT
%token IF
%token THEN
%token ELSE
%token READ
%token WRITE
%token RPAREN
%token LPAREN
%token DO
%token WHILE
%token ASSIGN
%token LBRACE
%token RBRACE
%token LT
%token EQ
%token PLUS
%token MINUS
%token TIMES
%token DIV
%token INT_NUM
%token FLOAT_NUM

/**** How is the TinyC GRAMMAR constructed     *****/

%%
statement_list: program        { printf ("No errors on the program.\n");}
    ;

program:  var_dec stmt_seq
    ;

var_dec: var_dec single_dec
    | %empty
    ;

single_dec: type ID SEMI {
printf("%d - %d", $1, $2);
}
    ;

type:  INTEGER
    |   FLOAT
    ;

stmt_seq: stmt_seq stmt
    | %empty
    ;

stmt:    IF exp THEN stmt
    |    IF exp THEN stmt ELSE stmt
    |    WHILE exp DO stmt
    |    variable ASSIGN exp SEMI
    |    READ LPAREN variable RPAREN SEMI
    |    WRITE LPAREN variable RPAREN SEMI
    |   block
    ;

block:  LBRACE stmt_seq RBRACE
    ;

exp:    simple_exp LT simple_exp
    |   simple_exp EQ simple_exp
    |   simple_exp
    ;

simple_exp:   simple_exp PLUS term
    |         simple_exp MINUS term
    |         term
    ;

term:   term TIMES factor
    |   term DIV factor
    |   factor
    ;

factor:   LPAREN exp RPAREN
    |     INT_NUM
    |     FLOAT_NUM
    |     variable
    ;

variable: ID
    ;


%%

/*Extern files included */
#include "lex.yy.c"
/*Extern variable declared on the lex file to handle the program line*/
extern int lineCount;

/* Bison does NOT implement yyerror, so we must implement it */
void yyerror(const char* const message){
  printf ("%s on Line: %d\n",message, lineCount);
}

/* Main entry needed by Bison */
int main (){
  yyparse();
}
