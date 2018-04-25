####################################################################
#Raul Morales A01365009
#Erik Martin A01365096
# File name:    Makefile
#
# Description:  Flex & Bison Makefile
#
#
#
####################################################################
#
# Define the compiler optimization flags
#
COPT    = -O2
COPT2   = -Wall -O2
CDBG    = -g -DDEBUG
CC      = gcc
LEX     = flex
YACC    = bison
VAL 	= valgrind
#
# Define the target names
#
TARGET_LEX 	= analizerTinyC2.l
TARGET_GRAM = tinyC_grammar.y
TARGET_NAME	= tiny
TARGET_USER	= UserDefined.c
TEST		= test1.c
TEST2		= test5.c

#
# Rule definitioans for target builds
#
all:
	$(YACC) -v $(TARGET_GRAM) -o $(TARGET_NAME).tab.c
	$(LEX) $(TARGET_LEX)
	$(CC) -DGRAMMAR $(COPT2) -o $(TARGET_NAME) $(TARGET_NAME).tab.c -ll `pkg-config --cflags --libs glib-2.0` $(TARGET_USER)

gdb:
		$(YACC) -v $(TARGET_GRAM) -o $(TARGET_NAME).tab.c
		$(LEX) $(TARGET_LEX)
		$(CC) -DGRAMMAR $(COPT2) $(CDBG) -o $(TARGET_NAME) $(TARGET_NAME).tab.c -ll `pkg-config --cflags --libs glib-2.0` $(TARGET_USER)
		gdb ./$(TARGET_NAME) <$(TEST)

debug:
	$(YACC) -v $(TARGET_GRAM) -o $(TARGET_NAME).tab.c
	$(LEX) $(TARGET_LEX)
	$(CC) -DGRAMMAR $(COPT2) -o $(TARGET_NAME) $(TARGET_NAME).tab.c -ll `pkg-config --cflags --libs glib-2.0` $(TARGET_USER)
	$(VAL) --leak-check=yes ./$(TARGET_NAME) <$(TEST)


clean:
	rm -f *~ core lex.yy.c $(TARGET_NAME).tab.* $(TARGET_NAME).output

clobber: clean
	rm -f $(TARGET_NAME)
