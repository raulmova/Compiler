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
  entry_p entry = malloc(sizeof(struct tableEntry_));
  entry->name_p = name;
  entry->type = type;
  entry->lineNumber = lineNumber;

  if(type == real) entry->value.r_value = 0.0;
  else entry->value.i_value = 0;

  g_hash_table_insert(theTable_p, entry->name_p,entry);

}

void InsertSymbolTemp(GHashTable *theTable_p, char * name, enum myTypes type){
  entry_p entry = malloc(sizeof(struct tableEntry_));
  entry->name_p = name;
  entry->type = type;

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
  g_free(theEntry_p->name_p);
  //free(theEntry_p->p_line):
  g_free(theEntry_p);
  return(EXIT_SUCCESS);
}

/*
  Memory deallocation of the hash table
*/

int DestroyTable (GHashTable * theTable_p){
  g_hash_table_destroy(theTable_p);
  return(EXIT_SUCCESS);
}

/*
entry_p SymbolLookUp(GHashTable *theTable_p, char *name){
    entry_p item = malloc(sizeof(tableEntry));
    entry_p symEntry = g_hash_table_lookup(theTable_p,name);


    if(symEntry!= NULL){
      item->name_p 		= symEntry->name_p;
	    item->value 	= symEntry->value;
	    item->type 		= symEntry->type;
	    return item;
    }
    return NULL;
}
*/

entry_p SymbolLookUp(GHashTable *theTable_p, char *name){
    return g_hash_table_lookup(theTable_p,name);
}


void SymbolUpdate(GHashTable *theTable_p, char * name, enum myTypes type, union val value){
	entry_p node = g_hash_table_lookup(theTable_p,name);
	if(node != NULL){
		node->type = type;
		node->value = value;
	}
}

/*
entry_p newTemp(GHashTable *theTable_p){
	char * temp = malloc(sizeof(char *));
	char * c = malloc(sizeof(char *));
	int i = 0;
	do{
		strcpy(temp,"t");
		snprintf(c,sizeof(char *),"%d",i);
		strcat(temp,c);
		i++;
	}while(SymbolLookUp(theTable_p,temp) != NULL);
	InsertSymbolTemp(theTable_p,temp,integer);
	return SymbolLookUp(theTable_p,temp);
}
*/

entry_p newTempConstant(GHashTable *theTable_p, union val value, enum myTypes type){
	char * temp = malloc(sizeof(char *));
	char * c = malloc(sizeof(char *));
	int i = 0;
	do{
		strcpy(temp,"t");
		snprintf(c,sizeof(char *),"%d",i);
		strcat(temp,c);
		i++;
	}while(SymbolLookUp(theTable_p,temp)!=NULL);

	//InsertSymbolTemp(theTable_p,temp,integer);
	//SymbolUpdate(theTable_p,temp,type,value);
	return SymbolLookUp(theTable_p,temp);
}
