/*Raul Morales A01365009*/
/*Erik Martin A01365096*/



%{
/*Extern files included */
#include "UserDefined.h"
#include <string.h>
#include <stdio.h>
#include <glib.h>


/*Extern variable declared on the lex file to handle the program line*/
extern int lineCount;

//Variables


  /* Function definitions */
void yyerror(GHashTable * theTable_p, const char* const message);
int yylex();
%}
%union {
    char *s;
    float f;
    int i;
    entry_p entry;
}
%parse-param{GHashTable * theTable_p}

%define parse.error verbose       /*Used by the yyerror function for a more descriptive error reporting*/

/*****************************All the tokens return by the lex file*******************************/
%token <s>ID
%token SEMI
%token <s>INTEGER
%token <s>FLOAT
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

%type <s> type variable exp simple_exp term factor

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
  entry_p node_p;
  union val values;
  // values = malloc(sizeof(union val));
  node_p =  malloc(sizeof(entry_p)); //memory allocation for the node
  //values = (union val*)malloc(sizeof(union val));
  values.i_value = 10;
  // values->r_value =23.23;

  node_p = NewItem($2, $1,values, lineCount);  //creation of the node with the values provided
  //PrintItem(node_p);
  g_hash_table_insert(theTable_p, node_p->name_p, node_p);  //insertion of node into the table

}
    ;

type:  INTEGER{
                $$ = "integer"; //tells to the hash table the type of the variable
              }
    |   FLOAT{
                $$ = "real";
              }
    ;

stmt_seq: stmt_seq stmt
    | %empty
    ;

  stmt:    IF exp THEN stmt{}
    |    IF exp THEN stmt ELSE stmt{}
    |    WHILE exp DO stmt
    |    variable ASSIGN exp SEMI{
          //entry_p ent = GetItem(theTable_p, $1->name);
          printf("%s\n",$1);
          printf("%s\n",$3);

    }
    |    READ LPAREN variable RPAREN SEMI
    |    WRITE LPAREN variable RPAREN SEMI
    |   block
    ;

block:  LBRACE stmt_seq RBRACE
    ;

exp:    simple_exp LT simple_exp
    |   simple_exp EQ simple_exp
    |   simple_exp{
        $$ = $1;
    }
    ;

simple_exp:   simple_exp PLUS term
    |         simple_exp MINUS term
    |         term{
        $$ = $1;
    }
    ;

term:   term TIMES factor{
        if($1 == "integer" && $3 == "integer"){
          $$ = "integer";
        } else if($1 == "integer" && $3 == "real"){
          $$ = "real";
        } else if($1 == "real" && $3 == "integer"){
          $$ = "real";
        } else if($1 == "real" && $3 == "real"){
          $$ = "real";
        } else{
            $$ = "Error";
        }
    }
    |   term DIV factor{

    }
    |   factor{
        $$ = $1;
    }
    ;

factor:   LPAREN exp RPAREN{
          $$ = $2;
    }
    |     INT_NUM{
          $$ = "integer";
    }
    |     FLOAT_NUM{
          $$ = "real";
    }
    |     variable{
          $$ = $1;
    }
    ;

variable: ID{
          entry_p entry = GetItem(theTable_p, $1);
          if(entry != NULL){
              printf("Variable YES declared %s\n", entry ->name_p );
              $$ = entry->type;
            }
            else{
              printf("No Variable '%s' declared before. ", $1);
              yyerror(theTable_p,"Error");
              return FALSE;
            }
      }
    ;


%%

#include "lex.yy.c"
/* Bison does NOT implement yyerror, so we must implement it */
void yyerror(GHashTable * theTable_p, const char* const message){
  printf ("%s on Line: %d\n",message, lineCount);
}



/* Main entry needed by Bison */
int main (){
  GHashTable * theTable_p; //declaration of hash table

  theTable_p = g_hash_table_new_full(g_str_hash, g_str_equal, NULL, (GDestroyNotify)FreeItem);  //creation of hash table
  yyparse(theTable_p);
  PrintTable(theTable_p);  //printing of hash table
  DestroyTable(theTable_p); //memory de allocation of the hash table
}
