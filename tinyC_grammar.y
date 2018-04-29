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
%token <i>INT_NUM
%token <f>FLOAT_NUM

%type <i> type
%type <line> variable factor term simple_exp exp stmt_seq block stmt single_dec



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
                                   entry_p entry = SymbolLookUp(theTable_p, $1->place);
                                   if(entry != NULL){
                                       if($1->type == $3->type){
                                        if($1->type == real){
                                          entry->value.r_value = $3->value.r_value;
                                          $1->value.r_value = $3->value.r_value;
                                        }
                                        else if($1->type == integer){
                                          entry->value.i_value = $3->value.i_value;
                                          $1->value.r_value = $3->value.i_value;
                                        }
                                      }
                                      else{
                                        if($1->type == integer && $3->type == real){
                                          yyerror(theTable_p,"Loss of Precision. Casting Float to Integer.");
                                          entry->value.i_value = (int)$3->value.r_value;
                                          $1->value.i_value = (int)$3->value.r_value;
                                        }
                                        else if($1->type == real && $3->type == integer){
                                          yyerror(theTable_p,"Warning, implicit casting between int and float");
                                          entry->value.r_value = (float)$3->value.i_value;
                                          $1->value.r_value = (float)$3->value.i_value;
                                        }
                                      }
                                      //PrintItem(entry);
                                       //gen(p->name_p ':=' $3->place)
                                       //newQuad("=",entry->name_p,$3->place,"-",quadList);
                                   }
                                   else{
                                     printf("No Variable '%s' declared before. ", $1->place);
                                     yyerror(theTable_p,"Error");
                                     return FALSE;
                                   }

                                  // free($1);
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
                    //$$->next_list = $1->next_list;

                    $$ = $1;
                  }
    ;

simple_exp:   simple_exp PLUS term{

                                      if($1->type == $3->type){
                                        if($3->type == real){   // floating types
                                          $$->type = real;
                                        }
                                        else{
                                          $$->type = integer;
                                        }
                                      }
                                      else{
                                        yyerror(theTable_p,"Warning, implicit casting between int and float");
                                        if($1->type == integer && $3->type == real){
                                          $$->type = real;
                                        }
                                        else if($1->type == real && $3->type == integer){
                                          $$->type = real;
                                        }
                                      }
                                      //TODO add typechecking - conversion
                                      //$$->place = newTemp(indexForTemp);
                                      //indexForTemp = indexForTemp + 1;
                                      //gen($$->place ':=' $1->place '+' $3->place)

                                  }
    |         simple_exp MINUS term{

                                      if($1->type == $3->type){
                                        if($3->type == real){   // floating types
                                          $$->type = real;
                                        }
                                        else{
                                          $$->type = integer;
                                        }
                                      }
                                      else{
                                        yyerror(theTable_p,"Warning, implicit casting between int and float");
                                        if($1->type == integer && $3->type == real){
                                          $$->type = real;
                                        }
                                        else if($1->type == real && $3->type == integer){
                                          $$->type = real;
                                        }
                                      }
                                      //TODO add typechecking - conversion
                                      //$$->place = newTemp(indexForTemp);
                                      //indexForTemp = indexForTemp + 1;
                                      //gen($$->place ':=' $1->place '-' $3->place)
                                    }
    |         term{
                    $$ = $1;
                  }
    ;

term:   term TIMES factor{
                            //TODO add typechecking - conversion
                            //$$->place = newTemp(indexForTemp);
                            //indexForTemp = indexForTemp + 1;
                            //gen($$->place ':=' $1->place '*' $3->place)

                            if($1->type == $3->type){ //equal types
                            if($3->type == real){   // floating types
                              $$->type = real;
                            }
                            else{
                              $$->type = integer;
                            }
                          }
                          else{
                            yyerror(theTable_p,"Warning, implicit casting between int and float");
                            if($1->type == integer && $3->type == real){
                              $$->type = real;
                            }
                            else if($1->type == real && $3->type == integer){
                              $$->type = real;
                            }
                          }

                      }
    |   term DIV factor{
                          printf("Division entre %d y %d\n",$1->type,$3->type);
                          if($3->type == real){
                            printf("Divison factor value : %f\n", $3->value.r_value);
                          }
                          else{
                            printf("Divison factor value : %d\n", $3->value.i_value);
                          }

                          if($1->type == $3->type){ //equal types
                              if($3->type == real){   // floating types
                                if($3->value.r_value == 0.0){
                                  yyerror(theTable_p,"Error, Division By Zero.");
                                  return 1; //recovery imposible
                                }
                              }
                              else { // integer types
                                if($3->value.i_value == 0){
                                  yyerror(theTable_p,"Error, Division By Zero.");
                                  return 1; //recovery imposible
                                }
                                else{
                                  yyerror(theTable_p,"Division between two ints. Implicit casting to float");
                                  $$->type = real;
                                }
                              }
                            }
                            else{ //Different types
                              yyerror(theTable_p,"#Term 1, Warning, implicit casting between int and float");
                              if($1->type == integer && $3->type == real){ //term int and factor float?
                                $$->type = real;
                              }
                              else if($1->type == real && $3->type == integer){
                                $$->type = real;
                              }
                            }

                            //TODO add typechecking - conversion
                            //$$->place = newTemp(indexForTemp);
                            //indexForTemp = indexForTemp + 1;
                            //gen($$->place ':=' $1->place '/' $3->place)


                          }
    |   factor{
                  $$ = $1;
              }
    ;

factor:   LPAREN exp RPAREN{
                              //$$->next_list = $2->next_list;
                              $$ = $2;
                            }
    |     INT_NUM{
                      line_p l = malloc(sizeof(struct _line));
                      l->value.i_value = $1;
                      l->type = integer;

                      char ts[30];
                      sprintf(ts, "%d", l->value.i_value);
                      char *s = (char*)malloc(sizeof(char)*strlen(ts) + 1);
                      strcpy(s,ts);
                      l->place = s;
                      $$ = l;
                  }
    |     FLOAT_NUM{
                      line_p l = malloc(sizeof(struct _line));
                      l->value.r_value = $1;
                      l->type = real;

                      char ts[30];
                      sprintf(ts, "%f", l->value.r_value);
                      char *s = (char*)malloc(sizeof(char)*strlen(ts) + 1);
                      strcpy(s,ts);
                      l->place = s;
                      $$ = l;
                    }
    |     variable{
                    line_p l = malloc(sizeof(struct _line));
                    l->type = $1->type;
                    l-> value = $1->value;
                    if($1->type == 2){
                      l->value.r_value = $1->value.r_value;
                    }else if($1->type == 1){
                      l->value.i_value = $1->value.i_value;
                    }
                    l->place = $1->place;
                    $$ = l;
                  }
    ;

variable: ID{
          entry_p entry = SymbolLookUp(theTable_p, $1);
          line_p l = malloc(sizeof(struct _line));
          if(entry != NULL){
              l->place = entry->name_p;
              l->type = entry->type;
              l-> value = entry->value;
              if(entry->type == real){
                  l->value.r_value = entry->value.r_value;
              }else if(entry->type == integer){
                l->value.i_value = entry->value.i_value;
              }
              //printf("Esto es un %s\n", l->place);
              $$ = l;
            //  printf("Esto es un %s\n", $$->place);
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
  if(yyparse(theTable_p) == 0){
    printf("No Errors\n");
    PrintTable(theTable_p);  //printing of hash table
  }
  //PrintTable(theTable_p);  //printing of hash table
  DestroyTable(theTable_p); //memory de allocation of the hash table
}
