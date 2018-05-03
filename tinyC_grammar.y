/*Raul Morales A01365009*/
/*Erik Martin A01365096*/



%{
/*Extern files included */
//#include "UserDefined.h"
#include "interpreter.h"
#include <string.h>
#include <stdio.h>
#include <glib.h>

/*Extern variable declared on the lex file to handle the program line*/
extern int lineCount;

int incrementQuad();

int getQuadLine();
//Variables
int quadLine = 0;
int indexForTemp = 0;


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
%type <line> variable factor term simple_exp exp stmt_seq block stmt N M



/**** How is the TinyC GRAMMAR constructed     *****/

%%
statement_list: program        { }
    ;

M: %empty{
            $$ = (line_p) malloc(sizeof(line));
            $$->quad = quadLine;
          }
  ;

N: %empty{
            $$ = (line_p) malloc(sizeof(line));
            $$->next_list= NULL;
            $$->next_list = NewList(quadLine);
            newQuad('j',"","", "goto_");
            incrementQuad();
          }
  ;
program:  var_dec stmt_seq M{
                              //Backpatch($2->next_list, $3->quad);
                            }
    ;

var_dec: var_dec single_dec{
                              // $$ = $2;
                            }
    | %empty{
              // $$ = (line_p) malloc(sizeof(line));
              // $$->next_list = NULL;
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

stmt_seq: stmt_seq M stmt {
                            $$ = (line_p) malloc(sizeof(line));
                            $$->next_list = NULL;
                            //PrintList($1->next_list);
                            // PrintList($3->next_list);
                            // printf("Quad: %d \n", $2->quad);

                            //Backpatch($1->next_list, $2->quad);
                            //Backpatch($3->next_list, $2->quad);
                            $$->next_list = MergeList($1->next_list, $3->next_list);
                            // PrintList($$->next_list);
                          }
    | %empty{
               $$ = (line_p) malloc(sizeof(line));
               $$->next_list = NULL;

            }
    ;

stmt:  IF exp THEN M stmt{
                            $$ = (line_p) malloc(sizeof(line));
                            $$->next_list = NULL;
                            Backpatch($2->true_list, $4->quad );
                            $$->next_list = MergeList($2->false_list, $5->next_list);
                        }
  |    IF exp THEN M stmt N ELSE M stmt{
                                        $$ = (line_p) malloc(sizeof(line));
                                        $$->next_list = NULL;
                                        //PrintList($2-> true_list);
                                        Backpatch($2->true_list, $4->quad);
                                        Backpatch($2->false_list, $8->quad);

                                        $$->next_list = MergeList($5->next_list, MergeList($6->next_list, $9->next_list));
                                        //PrintList($$->next_list);
                                        Backpatch($$->next_list, quadLine);
                                        }
  |    WHILE M exp DO M stmt{
                                $$ = (line_p) malloc(sizeof(line));
                                $$->next_list = NULL;
                                // PrintList($3->false_list);
                                // printf("%d", quadLine);
                                Backpatch($3->true_list, $5->quad);
                                Backpatch($3->false_list, quadLine+1);
                                $$->next_list = $3->false_list;
                                char buffer[16];
                                sprintf(buffer, "goto_%d", $2->quad);
                                char *tempString = (char *)malloc(sizeof(char) * 16);
                                strcpy(tempString, buffer);


                                newQuad('j',"","", tempString);
                                incrementQuad();
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
                                        $1->value.i_value = $3->value.i_value;
                                      }
                                    }
                                    else{
                                      if($1->type == integer && $3->type == real){
                                        yyerror(theTable_p,"Loss of Precision. Casting Float to Integer.");
                                        entry->value.i_value = (int)$3->value.r_value;
                                        $1->value.i_value = (int)$3->value.r_value;
                                        IntegerToReal(theTable_p, $1->place);
                                      }
                                      else if($1->type == real && $3->type == integer){
                                        yyerror(theTable_p,"Warning, implicit casting between int and float");
                                        entry->value.r_value = (float)$3->value.i_value;
                                        $1->value.r_value = (float)$3->value.i_value;

                                      }
                                    }
                                    //PrintItem(entry);
                                      //gen(p->name_p ':=' $3->place)
                                      newQuad('=',$3->place,"", entry->name_p);
                                      incrementQuad();
                                      //PrintQuads(quadList);
                                  }
                                  else{
                                    printf("No Variable '%s' declared before. ", $1->place);
                                    yyerror(theTable_p,"Error");
                                    return FALSE;
                                  }

                                }
  |    READ LPAREN variable RPAREN SEMI {

                                        }
  |    WRITE LPAREN variable RPAREN SEMI{
                                        }
  |     block{
              $$ = (line_p) malloc(sizeof(line));
              $$->next_list = NULL;
              $$->next_list = $1->next_list;
  }
  ;

block:  LBRACE stmt_seq RBRACE{
                                $$ = (line_p) malloc(sizeof(line));
                                $$->next_list = NULL;
                                $$->next_list = $2->next_list;
                              }

    ;

exp:    simple_exp LT simple_exp{
                                  $$ = (line_p) malloc(sizeof(line));
                                  $$->next_list = NULL;
                                  $$->true_list = NULL;
                                  $$->false_list = NULL;
                                  $$->true_list = NewList(quadLine);
                                  $$->false_list = NewList(quadLine+1);
                                  //gen('if' $1->place < $3->place 'goto_');
                                  newQuad('<',$1->place,$3->place, "goto_");
                                  incrementQuad();
                                  newQuad('j',"","", "goto_");
                                  incrementQuad();
                                  //gen(goto_);
                                }
    |   simple_exp EQ simple_exp{
                                  $$ = (line_p) malloc(sizeof(line));
                                  $$->next_list = NULL;
                                  $$->true_list = NULL;
                                  $$->false_list = NULL;
                                  $$->true_list = NewList(quadLine);
                                  $$->false_list = NewList(quadLine+1);
                                  //gen('if' $1->place == $3->place 'goto_');
                                  newQuad('e',$1->place,$3->place, "goto_");
                                  incrementQuad();
                                  newQuad('j',"","", "goto_");
                                  incrementQuad();
                                  //gen(goto_);
                                }
    |   simple_exp{
                    // $$ = (line_p) malloc(sizeof(line));
                    // $$->next_list = NULL;
                    // $$->true_list = NULL;
                    // $$->false_list = NULL;
                    // $$->next_list = $1->next_list;
                    // $$->place = $1->place;

                    // $$->true_list = $1->true_list;
                    //  $$->false_list = $1->false_list;
                    $$ = $1;
                  }
    ;

simple_exp:   simple_exp PLUS term{
                                      $$ = (line_p) malloc(sizeof(line));
                                      $$->next_list = NULL;
                                      $$->true_list = NULL;
                                      $$->false_list = NULL;
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
                                          IntegerToReal(theTable_p, $1->place);
                                        }
                                        else if($1->type == real && $3->type == integer){
                                          $$->type = real;
                                          //IntegerToReal(theTable_p, $3->place);
                                        }
                                      }
                                      //TODO add typechecking - conversion
                                      char * t = newTemp(indexForTemp);
                                      $$->place = t;
                                      InsertSymbol(theTable_p, t,$$->type,0);
                                      indexForTemp = indexForTemp + 1;
                                      //gen($$->place ':=' $1->place '+' $3->place)
                                      newQuad('+',$1->place, $3->place, $$->place);
                                      incrementQuad();


                                  }
    |         simple_exp MINUS term{
                                      $$ = (line_p) malloc(sizeof(line));
                                      $$->next_list = NULL;
                                      $$->true_list = NULL;
                                      $$->false_list = NULL;
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
                                          IntegerToReal(theTable_p, $1->place);
                                        }
                                        else if($1->type == real && $3->type == integer){
                                          $$->type = real;
                                          //IntegerToReal(theTable_p, $3->place);
                                        }
                                      }
                                      //TODO add typechecking - conversion
                                      char * t = newTemp(indexForTemp);
                                      $$->place = t;
                                      InsertSymbol(theTable_p, t,$$->type,0);
                                      indexForTemp = indexForTemp + 1;
                                      //gen($$->place ':=' $1->place '-' $3->place)
                                      newQuad('-',$1->place, $3->place, $$->place);
                                      incrementQuad();
                                    }
    |         term{

                    $$ = $1;
                  }
    ;

term:   term TIMES factor{
                            $$ = (line_p) malloc(sizeof(line));
                            //TODO add typechecking - conversion

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
                          char * t = newTemp(indexForTemp);
                          $$->place = t;
                          indexForTemp = indexForTemp + 1;
                          InsertSymbol(theTable_p, t,$$->type,0);
                            //gen($$->place ':=' $1->place '*' $3->place)
                          newQuad('*',$1->place, $3->place, $$->place);
                          incrementQuad();

                      }
    |   term DIV factor{
                          $$ = (line_p) malloc(sizeof(line));
                          // printf("Division entre %d y %d\n",$1->type,$3->type);
                          // if($3->type == real){
                          //   printf("Divison factor value : %f\n", $3->value.r_value);
                          // }
                          // else{
                          //   printf("Divison factor value : %d\n", $3->value.i_value);
                          // }

                          if($1->type == $3->type){ //equal types
                              if($3->type == real){   // floating types
                                $$->type = real;
                              }
                              else { // integer types
                               $$->type = integer;
                                // if($3->value.i_value == 0){
                                //   yyerror(theTable_p,"Error, Division By Zero.");
                                //   return 1; //recovery imposible
                                // }
                                // else{
                                  // yyerror(theTable_p,"Division between two ints. Implicit casting to float");
                                  // $$->type = real;
                                // }
                              }
                            }
                            else{ //Different types
                              // yyerror(theTable_p,"#Term 1, Warning, implicit casting between int and float");
                              if($1->type == integer && $3->type == real){ //term int and factor float?
                                $$->type = real;
                                IntegerToReal(theTable_p, $1->place);
                              }
                              else if($1->type == real && $3->type == integer){
                                $$->type = real;
                                //IntegerToReal(theTable_p, $3->place);
                              }
                            }

                            //TODO add typechecking - conversion
                            char * t = newTemp(indexForTemp);
                            $$->place = t;
                            indexForTemp = indexForTemp + 1;
                          //  printf("Type %d\n", $$->type);
                            InsertSymbol(theTable_p, $$->place, $$->type,0);
                            //gen($$->place ':=' $1->place '/' $3->place)
                            newQuad('/',$1->place, $3->place, $$->place);
                            incrementQuad();


                          }
    |   factor{
                  $$ = $1;
              }
    ;

factor:   LPAREN exp RPAREN{
                              // $$ = (line_p) malloc(sizeof(line));
                              // $$->true_list = NULL;
                              // $$->false_list = NULL;
                              // $$->next_list = NULL;
                              // $$->true_list = $2->true_list;
                              // $$->false_list = $2->false_list;
                              // $$->next_list = $2->next_list;

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
          line_p l = malloc(sizeof(line));
          if(entry != NULL){
              l->next_list = NULL;
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
  int quad = quadLine;
  quadLine = quadLine + 1;
  return quad;
}

int getQuadLine(){
  return quadLine;
}



/* Main entry needed by Bison */
int main (){
  GHashTable * theTable_p; //declaration of hash table
  theTable_p = g_hash_table_new_full(g_str_hash, g_str_equal, NULL, (GDestroyNotify)FreeItem);  //creation of hash table
  if(yyparse(theTable_p) == 0){
    printf("____________________________________________\n");
    printf("|         NO ERRORS ON THE PROGRAM          |\n");
    printf("____________________________________________\n");
    printf("|       INTERMEDIATE CODE GENERATED         |\n");
    printf("____________________________________________\n");
    PrintQuads();
    printf("____________________________________________\n");
    printf("|                 INTERPRETER               |\n");
    printf("____________________________________________\n");
    Interpreter(GetList(), theTable_p);
    PrintTable(theTable_p);  //printing of hash table
    printf("____________________________________________\n");
  }
  DestroyTable(theTable_p); //memory de allocation of the hash table

}
