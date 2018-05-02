/**
 *
 * @file    UserDefined.h
 *
 * @author  Erik Martin & Raul Morales
 *
 * @date    Fri 13 May 2016 10:07 DST
 *
 * @brief   Declares all the user defined functions for handling the
 *          specific user-defined data structure that is pointed to
 *          by the doubly linked list node.
 *
 *
 * Revision history:
 *          Fri 13 May 2016 10:07 DST -- File created
 *
 * @warning If there is not enough memory to create a node or the hash
 *          management fails the related function indicates failure.
 *
 *
 */

#include <glib.h>
#include "types.h"

/**
 * @union val
 *
 * @brief Defines the 32-bit value of a symbol table element.
 *
 * The @c val union defines the possible values for the elements in the
 * symbol table.
 *
 */

union val {            /* Note that both values are 32-bits in length */
   int     i_value;                   /**< Interpret it as an integer */
   float   r_value;                      /**< Interpret it as a float */
};

/**
 * @struct tableEntry
 *
 * @brief This is the user-defined symbol table entry.
 *
 * @c TableEntry is the user-defined structure that describes a symbol table
 * entry. Each entry has the following fields:
 *
 * @c name_p is a string holding the name of the variable. This may be
 *    different from the hash key (the key is the variable name plus the
 *    value of the current context).
 *
 * @c type indicates if the variable is integer or float.
 *
 * @c scope is an integer indicating the symbol table entry scope.
 *
 * @c lineNumber is the line number where the variable was defined.
 *
 * @c value is a union of all possible values (integer/float). Not space
 *    efficient if smaller types are allowed.
 *
 */
typedef struct tableEntry_{
   char     * name_p;            /**< The name is just the string */
   enum myTypes    type;               /**< Identifier type */
   unsigned int     lineNumber;  /**< Line number of the last reference */
   union val      value;       /**< Value of the symbol table element */
}tableEntry;

/**
 * @typedef entry_p
 *
 * @brief declare a pointer to the @c tableEntry @c structure
 */
typedef struct tableEntry_ *entry_p; /**< Declaration of ptr to an entry */

typedef struct _line{
    int quad;
    char * place;
    enum myTypes    type;
    union val      value;
    GList * true_list;
    GList * false_list;
    GList * next_list;
}line;

/**
 * @typedef entry_p
 *
 * @brief declare a pointer to the @c _line @c structure
 */
typedef struct _line * line_p;

/**
 * @struct _quad
 *
 * @brief This is the user-defined quads.
 *
 **/
typedef struct _quad
{
    char  operation;
    char * arg1;
    char * arg2;
    char * destination;
}quad;

/**
 * @typedef quad_p
 *
 * @brief declare a pointer to the @c _quad @c structure
 */
typedef struct _quad * quad_p;

/**
 *
 * @brief Prints the contents of the symbol table entry.
 *
 * @b PrintItem will print each field according to the user's formatting.
 *
 * @param  theEntry_p is a pointer to a user-defined structure element.
 *
 * @return @c EXIT_SUCCESS the item was printed with no
 *         problems, otherwise return @c EXIT_FAILURE
 *
 * @code
 *  PrintItem(theEntry_p);
 * @endcode
 *
 */
int PrintItem (entry_p theEntry_p);

/**
 *
 * @brief Captures the key, value and data pointers from @c g_hash_foreach
 * and calls PrintItem for each element.
 *
 * @b SupportPrint is a support function that captures the key, value and
 * data pointers from @c g_hash_foreach and in turn calls @c PrintItem to
 * display each hash entry.
 *
 * @param  key_p pointer to the key
 * @param  value_p pointer to the value
 * @param  user_p pointer to the user defined data
 * @return @c void
 *
 * @code
 *  g_hash_table_foreach(theTable_p, (GHFunc)SupportPrint, NULL);
 * @endcode
 *
 */
void SupportPrint (gpointer key_p, gpointer value_p, gpointer user_p);

/**
 *
 * @brief Prints all the elements of a table.
 *
 * @b PrintTable will print all the elements of @p table_p. It calls
 * the user-defined function PrintItem which handles the format of the data
 * portion of the items in the table.
 *
 * @param  theTable_p pointer to the table to be printed.
 * @return @c EXIT_SUCCESS if the table was traversed with no
 *         problems, otherwise return @c EXIT_FAILURE.
 *
 * @code
 *  if (PrintTable(theTable_p) != EXIT_SUCCESS)
 *  printf("Error printing the symbol table\n");
 * @endcode
 *
 * @warning This function @b requires a user-defined function to do the
 *          actual printing of the data element.
 *
 */
int PrintTable (GHashTable * theTable_p);

/**
*  Use GLIB function to return the pointer to theEntry
*  based on the key
**/
entry_p SymbolLookUp (GHashTable *theTable_p, char *name);

/**
*  Use GLIB function to insert a new entry to
*  the hashtable
**/
void InsertSymbol(GHashTable *theTable_p, char * name, enum myTypes type, unsigned int lineNumber);

/**
 *
 * @brief De-allocates memory assigned to user-defined data structure.
 *
 * @b FreeItem will de-allocate the @c string inside the user-defined data
 * structure @c tableEntry.
 *
 * @param  theEntry_p is a pointer to the user-defined data structure.
 * @return @c EXIT_SUCCESS if the item was de-allocated with no
 *         problems, otherwise return @c EXIT_FAILURE.
 *
 * @code
 *  FreeItem(theEntry_p);
 * @endcode
 *
 * @warning This function must be passed as a parameter when calling
 *          DestroyTable() since it will call it to de-allocate the
 *          user-defined structure.
 */
int FreeItem (entry_p theEntry_p);
int FreeKey(char * key);

/**
 *
 * @brief De-allocates memory assigned to each user-defined data structure in
 *        the hash table.
 *
 * @b DestroyTable will de-allocate the user-defined data structure. It also
 *    deallocates memory for the hash table.
 *
 * @param  theTable_p is a pointer to the hast table.
 * @return @c EXIT_SUCCESS if the list was de-allocated with no problems,
 *         otherwise return @c EXIT_FAILURE
 *
 * @code
 *  DestroyList(theList_p);
 * @endcode
 *
 * @see FreeItem()
 *
 */
int DestroyTable (GHashTable * theTable_p);

int InsertItem(GHashTable * theTable_p, entry_p theEntry_p);

entry_p GetItem(GHashTable * theTable_p, char *key);

GList * NewList(int quad);

GList * MergeList(GList *list1, GList *list2);

int PrintList(GList *list);

void SupportPrintList(gpointer data, gpointer user_data);

int PrintItemList(int i);

int Backpatch(GList * list, int quadNumber);

void newQuad(char op, char * arg1, char * arg2, char * dest);

char * newTemp(int index);

int PrintQuads();

void SupportPrintQuads(gpointer data, gpointer user_data);

int PrintItemQuads(quad_p quad);

GList * GetList();

int IntegerToReal(GHashTable *theTable_p, char *name);
