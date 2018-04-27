#include "UserDefined.h"
#include "types.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/*
  Routines used by the GLIB hash table structure
*/

/*
  Create a new  entry to the hash table
*/

/*
entry_p NewItem (char * varName_p, char * type, unsigned int lineNumber){
                   entry_p ent = (entry_p)malloc(sizeof(entry_p));
                   //ent->value = (union val *) malloc(sizeof(union val));
                   ent->name_p = varName_p;
                   ent->type = type;
                   // ent->value = value;
                   //memcpy(ent->value, value, sizeof(union val));
                   ent->lineNumber = lineNumber;
                   return ent;
                 }

*/

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
    printf("Name: %s -- Type: %d -- Value: %f -- Line: %u\n",theEntry_p->name_p,theEntry_p->type,theEntry_p->value.r_value,theEntry_p->lineNumber);
  }
  else if(theEntry_p->type == integer){
    printf("Name: %s -- Type: %d -- Value: %d -- Line: %u\n",theEntry_p->name_p,theEntry_p->type,theEntry_p->value.i_value,theEntry_p->lineNumber);
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
    //entry_p item = malloc(sizeof(tableEntry));
    return g_hash_table_lookup(theTable_p,name);


    // if(symEntry!= NULL){
    //   // item->name_p 		= symEntry->name_p;
	  //   // item->value 	= symEntry->value;
	  //   // item->type 		= symEntry->type;
    //   return symEntry;
    // }
    // return NULL;
}

GList * NewList(int quad){
  GList * list = NULL;
  return g_list_append(list, GINT_TO_POINTER(quad));
  ;
}

GList * MergeList(GList * list1, GList * list2){
  return g_list_concat(list1, list2);
}

int PrintList(GList * list){
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
  printf("List %d \n",i);
  return 1;
}

int Backpatch(GList * quads, GList * list, int quadNumber){
  GList *l = list;
  while (l != NULL)
  {
    GList * next = l->next;
    quad_p patch = g_list_nth_data(quads, GPOINTER_TO_INT(l->data));
    char buffer[16];
    sprintf(buffer, "goto %d", quadNumber);
    strcpy(patch->destination, buffer);

    l = next;
  }
  return EXIT_SUCCESS;
}

<<<<<<< HEAD

// CODE GENERATION functions
void newQuad(char * op, char * arg1, char * arg2, char * dest, GList * quadList){
    quad_p quadToAdd = malloc(sizeof(quad));
    strcpy(quadToAdd->operation, op );
    strcpy(quadToAdd->arg1, arg1 );
    strcpy(quadToAdd->arg2, arg2 );
    strcpy(quadToAdd->destination, dest );

    quadList = g_list_append(quadList, quadToAdd);
}

char * newTemp(int index){
  char tempBuffer[16];
  sprintf(tempBuffer, "t%d", index);
  char * tempString = (char *)malloc(sizeof(char) * 16);
  strcpy(tempString, tempBuffer);

  return tempString;
=======
GList * NewList(int quad){
  GList * list = NULL;
  return g_list_append(list, GINT_TO_POINTER(quad));
  ;
}

GList * MergeList(GList * list1, GList * list2){
  return g_list_concat(list1, list2);
}

int PrintList(GList * list){
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
  printf("List %d \n",i);
  return 1;
}

int Backpatch(GList * quads, GList * list, int quadNumber){
  GList *l = list;
  while (l != NULL)
  {
    GList * next = l->next;
    quad_p patch = g_list_nth_data(quads, GPOINTER_TO_INT(l->data));
    char buffer[16];
    sprintf(buffer, "goto %d", quadNumber);
    strcpy(patch->destination, buffer);

    l = next;
  }
  return EXIT_SUCCESS;
>>>>>>> 4b5f395143ee0e288dec48529b184afc674b1bb2
}
