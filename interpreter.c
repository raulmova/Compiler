#include "interpreter.h"

int i = 0;
char j;
int Interpreter(GList * quadList, GHashTable * theTable_p){
    while(i < g_list_length(quadList)){
        quad_p quad = g_list_nth_data(quadList, i);

        entry_p dest = NULL;
        entry_p arg1 = NULL;
        entry_p arg2 = NULL;
        switch(quad->operation){
            case '/':
                //printf("Prueba /\n");
                dest = SymbolLookUp(theTable_p, quad->destination);
                arg1 = SymbolLookUp(theTable_p, quad->arg1);
                arg2 = SymbolLookUp(theTable_p, quad->arg2);
                if (arg2 == NULL)
                {
                    if (dest->type == integer)
                    {
                        dest->value.i_value = arg1->value.i_value * atoi(quad->arg2);
                    }
                    else if (dest->type == real)
                    {
                        dest->value.r_value = arg1->value.r_value * atof(quad->arg2);
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                else if (arg1 == NULL)
                {
                    if (dest->type == integer)
                    {
                        dest->value.i_value = atoi(quad->arg1) / arg2->value.i_value;
                    }
                    else if (dest->type == real)
                    {
                        dest->value.r_value = atoi(quad->arg1) / arg2->value.r_value;
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                else
                {
                    // printf("name %s:: type %d",dest->name_p, dest->type);
                    // printf("name %s:: type %d", arg1->name_p, arg1->type);
                    // printf("name %s:: type %d", arg2->name_p, arg2->type);
                    if (dest->type == integer)
                    {
                        dest->value.i_value = arg1->value.i_value / arg2->value.i_value;
                    }
                    else if (dest->type == real)
                    {
                        dest->value.r_value = arg1->value.r_value / arg2->value.r_value;
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                i++;
                break;
            case '*':
                //printf("Prueba *\n");
                dest = SymbolLookUp(theTable_p, quad->destination);
                arg1 = SymbolLookUp(theTable_p, quad->arg1);
                arg2 = SymbolLookUp(theTable_p, quad->arg2);
                if (arg2 == NULL)
                {
                    if (dest->type == integer)
                    {
                        dest->value.i_value = arg1->value.i_value * atoi(quad->arg2);
                    }
                    else if (dest->type == real)
                    {
                        dest->value.r_value = arg1->value.r_value * atof(quad->arg2);
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                else if (arg1 == NULL)
                {
                    if (dest->type == integer)
                    {
                        dest->value.i_value = atoi(quad->arg1)  * arg2->value.i_value ;
                    }
                    else if (dest->type == real)
                    {
                        dest->value.r_value = atoi(quad->arg1) * arg2->value.r_value;
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                else
                {
                    if (dest->type == integer)
                    {
                        dest->value.i_value = arg1->value.i_value * arg2->value.i_value;
                    }
                    else if (dest->type == real)
                    {
                        dest->value.r_value = arg1->value.r_value * arg2->value.r_value;
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                i++;
                break;
            case '+':
                //printf("Prueba +\n");
                // printf("des: %s arg1: %s arg2: %s", quad->destination, quad->arg1, quad->arg2);
                dest = SymbolLookUp(theTable_p, quad->destination);
                arg1 = SymbolLookUp(theTable_p, quad->arg1);
                arg2 = SymbolLookUp(theTable_p, quad->arg2);
                if(arg2 == NULL){
                    if (dest->type == integer)
                    {
                        dest->value.i_value = arg1->value.i_value + atoi(quad->arg2);
                    }
                    else if (dest->type == real)
                    {
                        dest->value.r_value = arg1->value.r_value + atof(quad->arg2);
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                else if (arg1 == NULL)
                {
                    if (dest->type == integer)
                    {
                        dest->value.i_value = atoi(quad->arg1) + arg2->value.i_value;
                    }
                    else if (dest->type == real)
                    {
                        dest->value.r_value = atoi(quad->arg1) + arg2->value.r_value;
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                else
                {
                    if (dest->type == integer)
                    {
                        dest->value.i_value = arg1->value.i_value + arg2->value.i_value;
                    }
                    else if (dest->type == real)
                    {
                        dest->value.r_value = arg1->value.r_value + arg2->value.r_value;
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                i++;
                break;
            case '-':
                //printf("Prueba -\n");
                dest = SymbolLookUp(theTable_p, quad->destination);
                arg1 = SymbolLookUp(theTable_p, quad->arg1);
                arg2 = SymbolLookUp(theTable_p, quad->arg2);
                if (arg2 == NULL)
                {
                    if (dest->type == integer)
                    {
                        dest->value.i_value = arg1->value.i_value - atoi(quad->arg2);
                    }
                    else if (dest->type == real)
                    {
                        dest->value.r_value = arg1->value.r_value - atof(quad->arg2);
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                else if (arg1 == NULL)
                {
                    if (dest->type == integer)
                    {
                        dest->value.i_value = atoi(quad->arg1) - arg2->value.i_value;
                    }
                    else if (dest->type == real)
                    {
                        dest->value.r_value = atoi(quad->arg1) - arg2->value.r_value;
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                else
                {
                    if (dest->type == integer)
                    {
                        dest->value.i_value = arg1->value.i_value - arg2->value.i_value;
                    }
                    else if (dest->type == real)
                    {
                        dest->value.r_value = arg1->value.r_value - arg2->value.r_value;
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                i++;
                break;
            case '=':
                //printf("Prueba =\n");
                dest = SymbolLookUp(theTable_p, quad->destination);
                arg1 = SymbolLookUp(theTable_p, quad->arg1);

                if (arg1 == NULL)
                {
                    if (dest->type == integer)
                    {
                        dest->value.i_value = atoi(quad->arg1);
                    }
                    else if (dest->type == real)
                    {
                        dest->value.r_value = atof(quad->arg1);
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                else
                {
                    if (dest->type == integer)
                    {
                        if (arg1->type == integer)
                        {
                            dest->value.i_value = arg1->value.i_value;
                        }
                        else if (arg1->type == real)
                        {
                            dest->value.i_value = arg1->value.r_value;
                        }
                        else
                        {
                            printf("Unexpected type error");
                        }
                    }
                    else if (dest->type == real)
                    {
                        if (arg1->type == integer)
                        {
                            dest->value.r_value = arg1->value.i_value;
                        }
                        else if (arg1->type == real)
                        {
                            dest->value.r_value = arg1->value.r_value;
                        }
                        else
                        {
                            printf("Unexpected type error");
                        }
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                i++;
                break;
            case '<':
                //printf("Prueba <\n");
                arg1 = SymbolLookUp(theTable_p, quad->arg1);
                arg2 = SymbolLookUp(theTable_p, quad->arg2);
                if (arg2 == NULL && arg1 == NULL)
                {
                    if(atof(quad->arg1) < atof( quad->arg2)){
                        i = GotoLine(quad->destination);
                        //printf("Goto %d", i);
                    }else{
                        i++;
                    }
                }
                else if (arg1 == NULL)
                {
                    if (arg2->type == integer)
                    {
                        if(atoi(quad->arg1) < arg2->value.i_value){
                            i = GotoLine(quad->destination);
                        }else{
                            i++;
                        }
                    }
                    else if (arg2->type == real)
                    {
                        if(atof(quad->arg1) < arg2->value.r_value){
                            i = GotoLine(quad->destination);
                        }else{
                            i++;
                        }
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }else if (arg2 == NULL){
                    if (arg1->type == integer)
                    {
                        if (arg1->value.i_value < atoi(quad->arg2)){
                            i = GotoLine(quad->destination);
                        }else{
                            i++;
                        }
                    }
                    else if (arg1->type == real)
                    {
                        if(arg1->value.i_value < atof(quad->arg2)){
                            i = GotoLine(quad->destination);
                        }else{
                            i++;
                        }
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }else{
                    if (arg1->type == integer){
                        if (arg2->type == integer){
                            if(arg1->value.i_value < arg2->value.i_value){
                                i = GotoLine(quad->destination);
                                //printf("Goto %d", i);
                            }else{
                                i++;
                                //printf("Goto %d", i);
                            }
                        }else{
                            if(arg1->value.i_value < arg2->value.r_value){
                                i = GotoLine(quad->destination);
                            }else{
                                i++;
                            }
                        }
                    }else{
                        if (arg2->type == integer){
                            if(arg1->value.r_value < arg2->value.i_value){
                                i = GotoLine(quad->destination);
                            }else{
                                i++;
                            }
                        }else{
                            if(arg1->value.r_value < arg2->value.r_value){
                                i = GotoLine(quad->destination);
                            }else{
                                i++;
                            }
                        }
                    }
                }
                break;
            case 'e':
                //printf("Prueba <\n");
                arg1 = SymbolLookUp(theTable_p, quad->arg1);
                arg2 = SymbolLookUp(theTable_p, quad->arg2);
                if (arg2 == NULL && arg1 == NULL)
                {
                    if (atof(quad->arg1) == atof(quad->arg2))
                    {
                        i = GotoLine(quad->destination);
                        //printf("Goto %d", i);
                    }
                    else
                    {
                        i++;
                    }
                }
                else if (arg1 == NULL)
                {
                    if (arg2->type == integer)
                    {
                        if (atoi(quad->arg1) == arg2->value.i_value)
                        {
                            i = GotoLine(quad->destination);
                        }
                        else
                        {
                            i++;
                        }
                    }
                    else if (arg2->type == real)
                    {
                        if (atof(quad->arg1) == arg2->value.r_value)
                        {
                            i = GotoLine(quad->destination);
                        }
                        else
                        {
                            i++;
                        }
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                else if (arg2 == NULL)
                {
                    if (arg1->type == integer)
                    {
                        if (arg1->value.i_value == atoi(quad->arg2))
                        {
                            i = GotoLine(quad->destination);
                        }
                        else
                        {
                            i++;
                        }
                    }
                    else if (arg1->type == real)
                    {
                        if (arg1->value.i_value == atof(quad->arg2))
                        {
                            i = GotoLine(quad->destination);
                        }
                        else
                        {
                            i++;
                        }
                    }
                    else
                    {
                        printf("Unexpected type error");
                    }
                }
                else
                {
                    if (arg1->type == integer)
                    {
                        if (arg2->type == integer)
                        {
                            if (arg1->value.i_value == arg2->value.i_value)
                            {
                                i = GotoLine(quad->destination);
                                // printf("Goto %d", i);
                            }
                            else
                            {
                                i++;
                                // printf("Goto %d", i);
                            }
                        }
                        else
                        {
                            if (arg1->value.i_value == arg2->value.r_value)
                            {
                                i = GotoLine(quad->destination);
                            }
                            else
                            {
                                i++;
                            }
                        }
                    }
                    else
                    {
                        if (arg2->type == integer)
                        {
                            if (arg1->value.r_value == arg2->value.i_value)
                            {
                                i = GotoLine(quad->destination);
                            }
                            else
                            {
                                i++;
                            }
                        }
                        else
                        {
                            if (arg1->value.r_value == arg2->value.r_value)
                            {
                                i = GotoLine(quad->destination);
                            }
                            else
                            {
                                i++;
                            }
                        }
                    }
                }
                i++;
                break;
            case 'j':
                //printf("Prueba j\n");
                i = GotoLine(quad->destination);
                // printf("Goto %d", i);
                break;
            default:
                printf("Error");
        }


    }
    return EXIT_SUCCESS;
}

int GotoLine(char * g){
    return g[5] - '0';
}
