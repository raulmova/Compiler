/**
 * Copyright (c) 2016 Abelardo López Lagunas
 *
 * @file    UserDefined.h
 *
 * @author  Abelardo López Lagunas
 *
 * @date    Fri 13 May 2016 10:07 DST
 *
 * @brief   Declares all the user defined functions for handling the
 *          specific user-defined data structure that is pointed to
 *          by the doubly linked list node.
 *
 * References:
 *          Code loosely based on my Generic Singly linked list algorithm.
 *
 * Revision history:
 *          Fri 13 May 2016 10:07 DST -- File created
 *
 * @warning If there is not enough memory to create a node or the hash
 *          management fails the related function indicates failure.
 *          If the DEBUG compiler flag is set then the program will terminate
 *          but more information is displayed indicating the source of error.
 *
 * @note    The code is meant to show how to implement hash tables using GLib
 *
 */

#include <glib.h>


/**
 * @struct item
 *
 * @brief This is the basic user-defined element of the hash table
 *
 * The user-defined data structure is a @c string and a @c pointer to the
 * the symbol table entry.
 *
 */
typedef struct item_{
   char * key;                           /**< Hash table key is a string */
   void * tableEntry;           /**< Pointer to a generic data structure */
}item;

/**
 * @typedef item_p
 *
 * @brief declare a pointer to the @c item @c structure
 */
typedef struct item_ *item_p;        /**< Declaration of ptr to an entry */

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
   char *    type;               /**< Identifier type */
   unsigned int     lineNumber;  /**< Line number of the last reference */
   union val      value;       /**< Value of the symbol table element */
}tableEntry;

/**
 * @typedef entry_p
 *
 * @brief declare a pointer to the @c tableEntry @c structure
 */
typedef struct tableEntry_ *entry_p; /**< Declaration of ptr to an entry */

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
 *
 * @brief Allocates memory to a node of the user-defined data structure.
 *
 * @b NewItem will allocate space for the @c varName_p string and set the
 * fields of the @c tableEntry structure.
 *
 * @param  varName_p is the input string which is copied by NewItem.
 * @param  type is the variable type   (integer or real).
 * @param  scope is the scope of the variable.
 * @param  lineNumber line where the variable was declared.
 *
 * @return @c entry_p pointer to the memory block that holds the newly created
 *         symbol table entry. The 32-bit value for the variable is set to
 *         zero.
 *
 * @code
 *  newNode_p = NewItem("someVariable", integer, 0, 13, 27);
 * @endcode
 *
 */
entry_p NewItem (char * varName_p, char * type, unsigned int lineNumber);

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
