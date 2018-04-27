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
int quadLine = 0;
int indexForTemp = 0;
GList * quadList = NULL;

  /* Function definitions */
void yyerror(GHashTable * theTable_p, const char* const message);
int yylex();
%}
%union {
    char *s;
    float f;
    int i;
    entry_p entry;
    line_p line;
}
%parse-param{GHashTable * theTable_p}

//%define parse.error verbose       /*Used by the yyerror function for a more descriptive error reporting*/

/*****************************All the tokens return by the lex file*******************************/
%token <s>ID
%token SEMI
%token <i>INTEGER
%token <f>FLOAT
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

%type <i> type
%type <line> variable factor term simple_exp exp stmt_seq block stmt



/**** How is the TinyC GRAMMAR constructed     *****/

%%
statement_list: program        { printf ("No errors on the program.\n");}
    ;

M : %empty{
            //$$->quad = incrementQuad();
          }
  ;

N : %empty{
            //$$->next_list = newList(incrementQuad());
          }
  ;
program:  var_dec stmt_seq{

                          }
    ;

var_dec: var_dec single_dec
    | %empty{

            }
    ;

single_dec: type ID SEMI {
                              if(SymbolLookUp(theTable_p, $2) == NULL){
                                InsertSymbol(theTable_p, $2,$1,lineCount);
                              }else{
                                printf("Variable '%s' declared before. \n",$2);
                                yyerror(theTable_p, "Error");
                                return FALSE;
                              }
}
;

type:  INTEGER{
                $$ = integer; //tells to the hash table the type of the variable
              }
    |   FLOAT{
                $$ = real;
              }
    ;

stmt_seq: stmt_seq M stmt
    | %empty{
              //backpatch($1->next_list, $2->quad);
              //$$->next_list = $3->next_list;
            }
    ;

  stmt:  IF exp THEN M stmt{
                              //backpatch($2->true_list, quadLine );
                              //$$->next_list = mergeList($2->false_list, $5->next_list);
                          }
    |    IF exp THEN M stmt N ELSE M stmt{
                                      //backpatch($2->true_list, $4->quad);
                                      //backpatch($2->false_list, $8->quad);
                                      //$$->next_list = mergeList($5, mergeList($6->next_list, $9->next_list));

                                    }
    |    WHILE M exp DO M stmt{
                                  //backpatch($3->true_list, $5->quad);
                                  //$$->next_list = $3->false_list;
                                  //gen('goto_', $2->quad);

                          }
    |    variable ASSIGN exp SEMI {

                                  // $$=$3;
                                   //printf("Esto es un %s\n", $1->place);
                                   //TODO add type checkng and typeconversion
                                   entry_p entry = SymbolLookUp(theTable_p, $1->place);
                                   if(entry != NULL){
                                     //gen(p->name_p ':=' $3->place)
                                   }
                                   else{
                                     printf("No Variable '%s' declared before. ", $1);
                                     yyerror(theTable_p,"Error");
                                     return FALSE;
                                   }

      // $$=$3;

                                   //printf("Esto es un %s", $1->place);
                                   free($1);
                                  }
    |    READ LPAREN variable RPAREN SEMI {

                                          }
    |    WRITE LPAREN variable RPAREN SEMI{
                                          }
    |     block{
                //$$->next_list = $1->next_list;
    }
    ;

block:  LBRACE stmt_seq RBRACE{
                                //$$->next_list = $2->next_list;
                              }

    ;

exp:    simple_exp LT simple_exp{
                                  //$$->true_list = newList(incrementQuad());
                                  //$$->false_list = newList(incrementQuad() + 1);
                                  //gen('if' $1->place < $3->place 'goto_');
                                  //gen(goto_);
                                }
    |   simple_exp EQ simple_exp{
                                  //$$->true_list = newList(incrementQuad());
                                  //$$->false_list = newList(incrementQuad() + 1);
                                  //gen('if' $1->place == $3->place 'goto_');
                                  //gen(goto_);
                                }
    |   simple_exp{
                    //$$ = $1;
                    //$$->next_list = $1->next_list;
                  }
    ;

simple_exp:   simple_exp PLUS term{
                                      //TODO add typechecking - conversion
                                      //$$->place = newTemp(indexForTemp);
                                      //indexForTemp = indexForTemp + 1;
                                      //gen($$->place ':=' $1->place '+' $3->place)

                                  }
    |         simple_exp MINUS term{
                                      //TODO add typechecking - conversion
                                      //$$->place = newTemp(indexForTemp);
                                      //indexForTemp = indexForTemp + 1;
                                      //gen($$->place ':=' $1->place '-' $3->place)
                                    }
    |         term{$$ = $1;
                  }
    ;

term:   term TIMES factor{
                            //TODO add typechecking - conversion
                            //$$->place = newTemp(indexForTemp);
                            //indexForTemp = indexForTemp + 1;
                            //gen($$->place ':=' $1->place '*' $3->place)

                      }
    |   term DIV factor{
                            //TODO add typechecking - conversion
                            //$$->place = newTemp(indexForTemp);
                            //indexForTemp = indexForTemp + 1;
                            //gen($$->place ':=' $1->place '/' $3->place)
                          }
    |   factor{$$ = $1;
              }
    ;

factor:   LPAREN exp RPAREN{
                              //$$->next_list = $3->next_list;
                            }
    |     INT_NUM{
                  }
    |     FLOAT_NUM{
                    }
    |     variable{
                      $$ = $1;
                      //printf("Esto es un %s\n", $1->place);
                  }
    ;

variable: ID{
          entry_p entry = SymbolLookUp(theTable_p, $1);
          line_p l = malloc(sizeof(line_p));
          if(entry != NULL){
              //printf("Variable YES declared %s\n", entry ->name_p );
              //$$ = entry->type;

              l->place = entry->name_p;
              //printf("Esto es un %s", l->place);
              $$ = l;

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

int incrementQuad(){
  quadLine = quadLine + 1;
  return quadLine;
}

int getQuadLine(){
  return quadLine;
}



/* Main entry needed by Bison */
int main (){
  GHashTable * theTable_p; //declaration of hash table
  theTable_p = g_hash_table_new_full(g_str_hash, g_str_equal, NULL, (GDestroyNotify)FreeItem);  //creation of hash table
  //printf("NEW TEMP : %s\n", newTemp(3));
  yyparse(theTable_p);
  PrintTable(theTable_p);  //printing of hash table
  DestroyTable(theTable_p); //memory de allocation of the hash table
}
