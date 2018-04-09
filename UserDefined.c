#include "UserDefined.h"
#include <stdio.h>
#include <stdlib.h>


/*
  Routines used by the GLIB hash table structure
*/

/*
  Create a new  entry to the hash table
*/


entry_p NewItem (char * varName_p, char * type, unsigned int lineNumber){
                   entry_p ent = malloc(sizeof(entry_p));
                   ent->name_p = varName_p;
                   ent->type = type;
                   ent->lineNumber = lineNumber;
                   return ent;
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
  printf("Name: %s -- Type: %s --Line:%d\n",theEntry_p->name_p,theEntry_p->type, theEntry_p->lineNumber);
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
//  free(theEntry_p->name_p);
  free(theEntry_p);
  return(EXIT_SUCCESS);
}

/*
  Memory deallocation of the hash table
*/

int DestroyTable (GHashTable * theTable_p){
  g_hash_table_destroy(theTable_p);
  return(EXIT_SUCCESS);
}

entry_p GetItem(GHashTable * theTable_p, char *key){
  entry_p ent = malloc(sizeof(entry_p));
  ent = (entry_p)g_hash_table_lookup(theTable_p,key);
  return ent;
}

/*
int  main(void){
  GHashTable * theTable_p;
  entry_p      node_p;
  node_p = malloc(sizeof(entry_p));

  theTable_p = g_hash_table_new_full(g_str_hash, g_str_equal, NULL, (GDestroyNotify)FreeItem);

  node_p = NewItem("Holi", integer, 3);
  PrintItem(node_p);
  g_hash_table_insert(theTable_p, node_p->name_p, node_p);
  PrintTable(theTable_p);

   DestroyTable(theTable_p);

  return(EXIT_SUCCESS);
}
*/
