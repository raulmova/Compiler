#include "UserDefined.h"
#include "types.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/*
  Routines used by the GLIB hash table structure
*/

GList * quadList = NULL;

int lineC = 0;

void InsertSymbol(GHashTable *theTable_p, char * name, enum myTypes type, unsigned int lineNumber){
  entry_p entry = malloc(sizeof(tableEntry));
  entry->name_p = name;
  entry->type = type;
  entry->lineNumber = lineNumber;
  if(type == real) entry->value.r_value = 0.0;
  else entry->value.i_value = 0;

  g_hash_table_insert(theTable_p, entry->name_p,entry);

}



/*
  Print the hash table content
*/
int PrintTable (GHashTable * theTable_p){
  printf("NAME-------TYPE-------VALUE-------LINE------|\n");
  g_hash_table_foreach(theTable_p, (GHFunc)SupportPrint, NULL);
  return(EXIT_SUCCESS);
}

 /*
Support function needed by GLib
 */
void SupportPrint (gpointer key_p, gpointer value_p, gpointer user_p){
  PrintItem(value_p);
}

 /*
 Actual printing
 */

int PrintItem (entry_p theEntry_p){
  if(theEntry_p->type == real){
    printf("%2s  %9d %12.2f %9u        |\n",theEntry_p->name_p,theEntry_p->type,theEntry_p->value.r_value,theEntry_p->lineNumber);
  }
  else if(theEntry_p->type == integer){
    printf("%2s  %9d %12d %9u        |\n",theEntry_p->name_p,theEntry_p->type,theEntry_p->value.i_value,theEntry_p->lineNumber);
  }

  return 1;
}

/*
  Insert the entry previously created to the hash table
*/

int InsertItem(GHashTable * theTable_p, entry_p theEntry_p){
  g_hash_table_insert(theTable_p, theEntry_p->name_p, theEntry_p);
  return(EXIT_SUCCESS);
}

/*
  Memory deallocation of the table entries
*/

int FreeItem (entry_p theEntry_p){
  free(theEntry_p->name_p);
  free(theEntry_p);
  return(EXIT_SUCCESS);
}


/*
  Memory deallocation of the hash table
*/

int DestroyTable (GHashTable * theTable_p){
  g_hash_table_destroy(theTable_p);
  return (EXIT_SUCCESS);
}

entry_p SymbolLookUp(GHashTable *theTable_p, char *name){
    return g_hash_table_lookup(theTable_p,name);
}

GList * NewList(int quad){
  GList * list = NULL;
  list = g_list_append(list, GINT_TO_POINTER(quad));
  return list;
}

GList * MergeList(GList * list1, GList * list2){
  return g_list_concat(list1, list2);
}

int PrintList(GList * list){
  printf("list: ");
  g_list_foreach(list, (GFunc)SupportPrintList, NULL);
  return (EXIT_SUCCESS);
}

/*
Support function needed by GLib
 */
void SupportPrintList(gpointer data, gpointer user_data){
  PrintItemList(GPOINTER_TO_INT(data));
}

/*
 Actual printing
 */

int PrintItemList(int i){
  printf("%d, ",i);
  return 1;
}

int Backpatch(GList * list, int quadNumber){
  GList *l = list;
  while (l != NULL)
  {
    GList * next = l->next;
    quad_p patch = g_list_nth_data(quadList, GPOINTER_TO_INT(l->data));
    char buffer[16];
    sprintf(buffer, "goto %d", quadNumber);
    char *tempString = (char *)malloc(sizeof(char) * 16);
    strcpy(tempString, buffer);
    patch->destination = tempString;

    l = next;
  }
  return EXIT_SUCCESS;
}

// CODE GENERATION functions
void newQuad(char op, char * arg1, char * arg2, char * dest){
    quad_p quadToAdd = malloc(sizeof(quad));
    quadToAdd->operation = op ;
    quadToAdd->arg1 = arg1 ;
    quadToAdd->arg2 = arg2 ;
    quadToAdd->destination = dest ;
    quadList = g_list_append(quadList, quadToAdd);
}

char * newTemp(int index){
  char tempBuffer[16];
  sprintf(tempBuffer, "t%d", index);
  char * tempString = (char *)malloc(sizeof(char) * 16);
  strcpy(tempString, tempBuffer);

  return tempString;
}

GList * GetList(){
  return quadList;
}
int PrintQuads()
{
  printf("LINE------DEST-----OP-----ARG1-----ARG2-----|\n");
  g_list_foreach(quadList, (GFunc)SupportPrintQuads, NULL);
  return (EXIT_SUCCESS);
}
/*
Support function needed by GLib
 */
void SupportPrintQuads(gpointer data, gpointer user_data)
{
  PrintItemQuads(data);
}

/*
 Actual printing
 */

int PrintItemQuads(quad_p quad){
printf(" %d:   %7s   %4c   %5s   %6s       |\n",lineC++, quad->destination, quad->operation, quad->arg1, quad->arg2);
  return 1;
}

int IntegerToReal(GHashTable *theTable_p, char *name){
  //printf("cast");
  entry_p entry = SymbolLookUp(theTable_p, name);
  float num = (float) entry->value.i_value;
  //free(entry->value.i_value);
  entry->value.r_value = num;
  entry->type = real;
  return EXIT_SUCCESS;
}
