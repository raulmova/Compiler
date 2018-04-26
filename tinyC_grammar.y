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
int quad = 1;
int tempIndex = 0;

  /* Function definitions */
void yyerror(GHashTable * theTable_p, const char* const message);
int yylex();
%}
%union {
    char *s;
    float f; //valor flotante
    int i; //tipo y valor entero
    entry_p entry;
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

%type <i> type INT_NUM
%type <f> FLOAT_NUM
%type <entry> variable factor term simple_exp exp block stmt_seq stmt m n single_dec


/**** How is the TinyC GRAMMAR constructed     *****/

%%
statement_list: program        { printf ("No errors on the program.\n");}
    ;

program:  var_dec stmt_seq{

                          }
    ;

var_dec: %empty | var_dec single_dec{

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

    m           : %empty   {
                                  $$->p_line.quad = quad;
                                }
                ;

n :  %empty {
        char t[BUFFER_SIZE];
        sprintf(t, "%d", quad);
        char* s = (char*)malloc(sizeof(char)*strlen(t) + 1);
        strcpy(s,t);
        $$->p_line.next_list = s;
        lines[quad].quad = quad;
        lines[quad].operation = "-";
        lines[quad].arg1 = "-";
        lines[quad].arg2 = "-";
        lines[quad].destination = "S.next";
        quad++;
    };

stmt_seq:
          stmt_seq m stmt{

                        }
      | %empty{

      }
    ;

  stmt:  IF exp THEN m stmt{
                              $$ = $2;
                              if($2->p_line.false_list){
                                mergeWithNextList($2, FALSE_LIST, $5, $$);
                              }
                              generateCodeCond($2,$2->p_line.destination,$$);
                              backpathList($2, TRUE_LIST,$4->p_line.quad);

                              int index = $2->p_line.quad + 1;
                              lines[index].quad = index;
                              lines[index].operation = "-";
                              lines[index].arg1 = "-";
                              lines[index].arg2 = "-";
                              lines[index].destination = "S.next";

                          }

    |    IF exp THEN m stmt n ELSE m stmt{
                                      $$ = $2;

                                      if($6->p_line.next_list){
                                        mergeWithNextList($6,NEXT_LIST,$9,$$);
                                      }
                                      if($5->p_line.next_list){
                                        mergeWithNextList($5,NEXT_LIST,$$,$$);
                                      }

                                      generateCodeCond($2,$2->p_line.destination,$$);
                                      backpathList($2,TRUE_LIST,$4->p_line.quad);
                                      backpathList($2,FALSE_LIST,$8->p_line.quad);

                                      int index = $2->p_line.quad + 1;
                                      lines[index].quad = index;
                                      lines[index].operation = "-";
                                      lines[index].arg1 = "-";
                                      lines[index].arg2 = "-";
                                    }
    |    WHILE m exp DO m stmt{
                                    $$ = $3;
                                    mergeWithNextList($3, FALSE_LIST, $$,$$);

                                    generateCodeCond($3,$3->p_line.destination,$$);

                                    backpathList($3, TRUE_LIST, $5->p_line.quad);

                                    int index = $3->p_line.quad + 1;
                                    lines[index].quad = index;
                                    lines[index].operation = "-";
                                    lines[index].arg1 = "-";
                                    lines[index].arg2 = "-";
                                    lines[index].destination = "S.next";

                                    index = getQuadWhile();
                                    lines[index].quad = index;
                                    lines[index].operation = "-";
                                    lines[index].arg1 = "-";
                                    lines[index].arg2 = "-";

                                    char ts[BUFFER_SIZE];
                                    sprintf(ts,"%d",$2->p_line.quad);
                                    char* s = (char*)malloc(sizeof(char) * strlen(ts) + 1);
                                    strcpy(s,ts);
                                    lines[index].destination = s;

                                    quad = index + 1;
                          }
    |    variable ASSIGN exp SEMI{

                                    entry_p t = malloc(sizeof(struct tableEntry_));
                                    t = SymbolLookUp(theTable_p, $1->name_p);
                                    //PrintItem(t);
                                    //TYPE CONVERSION
                                    if($1->type == $3->type){
                                      if($1->type == real){
                                        t->value.r_value = $3->value.r_value;
                                      }
                                      else if($1->type == integer){
                                        t->value.i_value = $3->value.i_value;
                                      }
                                    }
                                    else{
                                      if($1->type == integer && $3->type == real){
                                        yyerror(theTable_p,"Loss of Precision. Casting Float to Integer.");
                                        t->value.i_value = (int)$3->value.r_value;
                                      }
                                      else if($1->type == real && $3->type == integer){
                                        yyerror(theTable_p,"Warning, implicit casting between int and float");
                                        t->value.r_value = (float)$3->value.i_value;
                                      }
                                    }

                                    //CODE GENERATION
                                    generateCode("=",t,$3,"-",$$);

                                    //REUTILIZAR VARIABLES

                                    //reutilizar variables temporales
                                    //int ret = strcmp($3->name_p[0], 't');
                                    //if($3->name_p != NULL && ret ==0){
                                    //  tempIndex = 0;
                                    //}

                                }
    |    READ LPAREN variable RPAREN SEMI{
                                          }
    |    WRITE LPAREN variable RPAREN SEMI{
                                          }
    |     block {
        //  $$ = $1;
    }
    ;

block:  LBRACE stmt_seq RBRACE{

                              }

    ;

exp:    simple_exp LT simple_exp{
                                  //CODE GENERATION
                                  putNextQuad($$,TRUE_LIST,0);
                                  putNextQuad($$,FALSE_LIST,1);
                                  generateCode("<", $1, $3, "goto", $$);
                                  strcat($$->p_line.code, "\ngoto");
                                  quad++;
                                }
    |   simple_exp EQ simple_exp{
                                  //CODE GENERATION
                                  putNextQuad($$,TRUE_LIST,0);
                                  putNextQuad($$,FALSE_LIST,1);
                                  generateCode("==", $1, $3, "goto", $$);
                                  strcat($$->p_line.code, "\ngoto");
                                  quad++;
                                }
    |   simple_exp{
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
                                      //CODE GENERATION
                                      //NEW TEMP
                                      newTemp("+",$1,$3,$$);
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
                                      //CODE GENERATION
                                      //NEW TEMP
                                      newTemp("-",$1,$3,$$);
                                    }
      |         term{
                        $$ = $1;
                    }
      ;

term:   term TIMES factor{
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
                            //CODE GENERATION
                            //NEW TEMP
                            newTemp("*",$1,$3,$$);
                      }
        |   term DIV factor{
                              if($1->type == $3->type){ //equal types
                                if($3->type == real){   // floating types
                                  if($3->value.r_value == 0.0){
                                    yyerror(theTable_p,"Error, Division By Zero.");
                                    return 1; //recovery imposible
                                  }
                                }
                                else{ // integer types
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

                              //CODE GENERATION
                              //NEW TEMP
                              newTemp("/",$1,$3,$$);
                          }
    |   factor{
                $$ = $1;
              }
    ;

factor:   LPAREN exp RPAREN{
                              $$ = $2;
                            }
    |     INT_NUM{
                    entry_p t = malloc(sizeof(struct tableEntry_));
                    t->value.i_value = $1;
                    printf("INT_NUM PROD : %d\n", t->value.i_value);
                    t->type = integer;

                    //CODE GENERATION
                    char ts[BUFFSIZE];
                    sprintf(ts, "%d", t->value.i_value);
                    char *s = (char*)malloc(sizeof(char)*strlen(ts) + 1);
                    //printf("%d\n", sizeof(char)*strlen(ts) + 1);
                    strcpy(s,ts);
                    t->name_p = s;

                    $$ = t;
                  }
    |     FLOAT_NUM{
                    entry_p t = malloc(sizeof(struct tableEntry_));
                    t->value.r_value = $1;
                    printf("FLOAT_NUM PROD : %f\n", t->value.r_value);
                    t->type = real;

                    //CODE GENERATION
                    char ts[BUFFSIZE];
                    sprintf(ts, "%f", t->value.r_value);
                    char *s = (char*)malloc(sizeof(char)*strlen(ts) + 1);
                    strcpy(s,ts);
                    t->name_p = s;

                    $$ = t;
                    //printf("%s %d \n", $$->name_p, $$->value.i_value);
                    }
    |     variable{
                    //se regresa el valor de la variable
                    entry_p t = malloc(sizeof(struct tableEntry_));
                    t->type = $1->type;
                    t-> value = $1->value;
                    if($1->type == 2){
                      t->value.r_value = $1->value.r_value;
                    }else if($1->type == 1){
                      t->value.i_value = $1->value.i_value;
                    }
                    t->name_p = $1->name_p;
                    $$ = t;
                  //  printf("%s %d \n", $$->name_p, $$->value);
                  }
    ;

variable: ID{
          //entry_p entry = SymbolLookUp(theTable_p, $1);
          if(SymbolLookUp(theTable_p, $1) != NULL){
            $$ = SymbolLookUp(theTable_p, $1);
              //$$ = entry;
            }
            else{
              printf("No Variable '%s' declared before. ", $1);
              yyerror(theTable_p,"Error");
              return FALSE;
            }
      }
    ;


%%

//CODE GENERATION FUNCTIONS //

void putNextQuad(entry_p arg, int list, int increment){
    char tempBuffer[BUFFER_SIZE];
    sprintf(tempBuffer, "%d", quad + increment);
    char* tempString = (char*)malloc(sizeof(char) * strlen(tempBuffer) + 1);
    strcpy(tempString, tempBuffer);

    if(list == TRUE_LIST){
      arg->p_line.true_list = tempString;
    }
    else if( list == FALSE_LIST){
      arg->p_line.false_list = tempString;
    }
    else if(list == NEXT_LIST){
      arg->p_line.next_list = tempString;
    }
}

void generateCode(char* op, entry_p arg1, entry_p arg2, char* dest, entry_p top ){
  top->p_line.quad = quad;

  lines[quad].quad = quad;
  lines[quad].operation = op;
  lines[quad].arg1 = arg1->name_p;
  lines[quad].arg2 = arg2->name_p;
  lines[quad].destination = dest;
  quad++;

  top->p_line.operation = op;
  top->p_line.arg1 = arg1->name_p;
  top->p_line.arg2 = arg2->name_p;
  top->p_line.destination = dest;

  char tempBuffer[BUFFER_SIZE];
  sprintf(tempBuffer, "%s %s %s %s", op, arg1->name_p, arg2->name_p, dest);
  char* tempString = (char*)malloc(sizeof(char)*strlen(tempBuffer) + 1);
  strcpy(tempString, tempBuffer);
  top->p_line.code = tempString;
  top->p_line.next_list = NULL;

}

void generateCodeCond(entry_p arg, char* dest, entry_p top){
  int index = arg->p_line.quad;
  lines[index].quad = index;
  lines[index].operation = arg->p_line.operation;
  lines[index].arg1 = arg->p_line.arg1;
  lines[index].arg2 = arg->p_line.arg2;
  lines[index].destination = arg->p_line.destination;

  top->p_line.quad = index;
  top->p_line.operation = arg->p_line.operation;
  top->p_line.arg1 = arg->p_line.arg1;
  top->p_line.arg2 = arg->p_line.arg2;
  top->p_line.destination = arg->p_line.destination;

  char tempBuffer[BUFFER_SIZE];
  sprintf(tempBuffer, "%s %s %s %s", arg->p_line.operation, arg->p_line.arg1, arg->p_line.arg2, dest);
  char* tempString = (char*)malloc(sizeof(char) * strlen(tempBuffer) + 1);
  strcpy(tempString, tempBuffer);
  top->p_line.code = tempString;
  top->p_line.next_list = NULL;

  quad++;
}

void newTemp(char* op, entry_p arg1, entry_p arg2, entry_p top){
  lines[quad].quad = quad;
  lines[quad].operation = op;
  lines[quad].arg1 = arg1->name_p;
  lines[quad].arg2 = arg2->name_p;

  top->p_line.quad = quad;
  char tempBuffer[BUFFER_SIZE];
  sprintf(tempBuffer, "%s %s %s t%d", op,arg1->name_p,arg2->name_p, tempIndex);
  char* tempString = (char*)malloc(sizeof(char)*strlen(tempBuffer) + 1);
  strcpy(tempString, tempBuffer);
  char t[BUFFER_SIZE];
  tempIndex++;
  sprintf(t, "t%d", tempIndex -1);
  char* s = (char*)malloc(sizeof(char) * strlen(t) + 1);
  strcpy(s,t);

  top->name_p = s;
  top->p_line.operation = op;
  top->p_line.arg1 = arg1->name_p;
  top->p_line.arg2 = arg2->name_p;
  top->p_line.code = tempString;
  top->p_line.destination = s;

  lines[quad].destination = s;

  quad++;

}

void backpathList(entry_p e, int list, int nQuad){
  char* strToken = "";
  char t[BUFFER_SIZE];
  sprintf(t, "%d", nQuad);
  char* s = (char*)malloc(sizeof(char) * strlen(t) + 1);
  strcpy(s,t);

  if(list == FALSE_LIST){
    strToken = strtok(e->p_line.false_list, " ");
  } else if(list == TRUE_LIST){
    strToken = strtok(e->p_line.true_list, " ");
  }else if(list == NEXT_LIST){
    strToken = strtok(e->p_line.next_list, " ");
  }

  while (strToken != NULL) {
    int i = atoi(strToken);
    lines[i].destination = s;
    strToken = strtok(NULL, " ");
  }
}

void mergeWithNextList(entry_p arg1, int l1, entry_p arg2, entry_p top){
  char t[BUFFER_SIZE];

  if(arg2->p_line.next_list == NULL){
    if(l1 == FALSE_LIST)
      sprintf(t, "%s", arg1->p_line.false_list);
    else if(l1 == TRUE_LIST)
      sprintf(t, "%s", arg1->p_line.true_list);
    else if(l1 == NEXT_LIST)
      sprintf(t, "%s", arg1->p_line.next_list);
  } else if(l1 == FALSE_LIST) {
    sprintf(t, "%s %s", arg1->p_line.false_list,arg2->p_line.next_list);
  } else if(l1 == TRUE_LIST) {
    sprintf(t, "%s %s", arg1->p_line.true_list,arg2->p_line.next_list);
  } else if(l1 == NEXT_LIST) {
    sprintf(t, "%s %s", arg1->p_line.next_list,arg2->p_line.next_list);
  }
  char* s = (char*)malloc(sizeof(char)*strlen(t) + 1);
  strcpy(s,t);
  top->p_line.next_list = s;
}

void printLines(){
  int i = 1;
  while(lines[i].quad){
    printf("%d %s %s %s %s\n", lines[i].quad, lines[i].operation, lines[i].arg1, lines[i].arg2, lines[i].destination);
    i++;
  }
}

int getQuadWhile(){
  int i = 1;
  while(lines[i].quad){
    i++;
  }
  return i;
}

#include "lex.yy.c"

/* Bison does NOT implement yyerror, so we must implement it */
void yyerror(GHashTable * theTable_p, const char* const message){
  printf ("%s on Line: %d\n",message, lineCount);
}



/* Main entry needed by Bison */
int main (){
  GHashTable * theTable_p; //declaration of hash table
  theTable_p = g_hash_table_new_full(g_str_hash, g_str_equal, NULL, (GDestroyNotify)FreeItem);  //creation of hash table
  if(yyparse(theTable_p) == 0){
    printf("No Errors\n");
    printLines();
    //PrintTable(theTable_p);  //printing of hash table
  }
  //yyparse(theTable_p);
  //PrintTable(theTable_p);  //printing of hash table
  //DestroyTable(theTable_p); //memory de allocation of the hash table
}
