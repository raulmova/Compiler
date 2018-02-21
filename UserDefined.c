#include "UserDefined.h"
#include "types.h"
#include <stdio.h>
#include <stdlib.h>


entry_p NewItem (char * varName_p, enum myTypes type, unsigned int lineNumber){
                   entry_p ent = malloc(sizeof(entry_p));
                   ent->name_p = varName_p;
                   ent->type = type;
                   ent->lineNumber = lineNumber;
                   return ent;
                 }

int PrintTable (GHashTable * theTable_p){
  g_hash_table_foreach(theTable_p, (GHFunc)SupportPrint, NULL);
  return(EXIT_SUCCESS);
}

void SupportPrint (gpointer key_p, gpointer value_p, gpointer user_p){
  PrintItem(value_p);
}

int PrintItem (entry_p theEntry_p){
  printf("Name: %s -- Type: %d\n",theEntry_p->name_p,theEntry_p->type);
  return 1;
}

int FreeItem (entry_p theEntry_p){
//  free(theEntry_p->name_p);
  free(theEntry_p);
  return(EXIT_SUCCESS);
}

int DestroyTable (GHashTable * theTable_p){
  g_hash_table_destroy(theTable_p);
  return(EXIT_SUCCESS);
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
