# Makefile pour programme C avec TCL/TK et scripts multiples embarqués

# Détection automatique de TCL et TK
TCL_CFLAGS = $(shell pkg-config --cflags tcl tk 2>/dev/null || echo "-I/usr/include")
TCL_LIBS = $(shell pkg-config --libs tcl tk 2>/dev/null || echo "-ltcl -ltk")

ifeq ($(TCL_LIBS),-ltcl -ltk)
    TCL_CFLAGS = -I/usr/include
    TCL_LIBS = -ltcl -ltk -lX11
endif

# Compilateur et flags
CC = gcc
CFLAGS = -Wall -Wextra -O2 $(TCL_CFLAGS)
LDFLAGS = $(TCL_LIBS)

# Cible et sources
TARGET = Katyusha_MCD
SOURCES = main.c
OBJECTS = $(SOURCES:.c=.o)
LIST_FILE = scripts.conf
EMBEDDED_HEADER = scripts_embedded.h
FILES_LIST = files.conf
EMBEDDED_FILES_HEADER = files_embedded.h

EMBEDDED_HEADERS = scripts_embedded.h files_embedded.h

# Script d'embarquement
EMBED_SCRIPT = "./embed_scripts.sh"

# Règle par défaut
all: $(EMBEDDED_HEADERS) $(TARGET)
	@echo ""
	@echo "=========================================="
	@echo "✓ Successfuly compiled !"
	@echo ""
	@./$(TARGET) --list-scripts
	@echo ""
	@echo "Executed with : ./$(TARGET)"
	@echo "=========================================="

# Générer le header avec tous les scripts embarqués
$(EMBEDDED_HEADERS): Katyusha.tcl $(LIST_FILE) $(FILES_LIST)
	@echo "Embedded headers generation..."
	@if [ -f "embed_scripts.py" ]; then \
		python3 embed_scripts.py; \
	elif [ -f "embed_scripts.sh" ]; then \
		chmod +x embed_scripts.sh; \
		./embed_scripts.sh; \
	else \
		echo "ERREUR : No script found !"; \
		exit 1; \
	fi

# Compilation du programme
$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) -o $(TARGET) $(LDFLAGS)

# Compilation des fichiers objets (dépend du header embarqué)
%.o: %.c $(EMBEDDED_HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

# Créer Katyusha.tcl par défaut s'il n'existe pas
Katyusha.tcl:
	@echo "ERREUR: Katyusha.tcl (principal) manquant!"
	@exit 1

# Créer list.conf par défaut s'il n'existe pas
$(LIST_FILE):
	@echo "Création de $(LIST_FILE) par défaut..."
	@echo "# Liste des scripts TCL additionnels à embarquer" > $(LIST_FILE)
	@echo "# Katyusha.tcl est TOUJOURS embarqué automatiquement" >> $(LIST_FILE)
	@echo "" >> $(LIST_FILE)
	@echo "# Exemples:" >> $(LIST_FILE)
	@echo "# extensions.tcl" >> $(LIST_FILE)
	@echo "# config.tcl" >> $(LIST_FILE)

# Règle de nettoyage
clean:
	rm -f $(OBJECTS) $(TARGET) $(EMBEDDED_HEADERS)
	@echo "Nettoyage effectué."

# Nettoyage complet
distclean: clean
	rm -f $(LIST_FILE) $(FILES_LIST)
	@echo "Complete cleaning done."

# Règle pour exécuter le programme
run: $(TARGET)
	./$(TARGET)

# Recompiler après modification des scripts
rebuild: clean all

# Règle pour debug avec gdb
debug: CFLAGS += -g -O0
debug: clean $(TARGET)
	gdb ./$(TARGET)

# Lister les scripts embarqués
list-scripts: $(TARGET)
	./$(TARGET) --list-scripts

# Afficher le contenu du header embarqué
show-embedded: $(EMBEDDED_HEADERS)
	@echo "Content of scripts_embedded.h:"
	@head -40 scripts_embedded.h
	@echo ""
	@echo "Content of files_embedded.h:"
	@head -40 files_embedded.h

# Afficher les flags utilisés
info:
	@echo "Compiler : $(CC)"
	@echo "CFLAGS : $(CFLAGS)"
	@echo "LDFLAGS : $(LDFLAGS)"
	@echo "Embed script : $(EMBED_SCRIPT)"
	@echo "List : $(LIST_FILE)"
	@echo "Generated header : $(EMBEDDED_HEADER)"

# Vérifier les dépendances
check-deps:
	@echo "Dependencies verification..."
	@which gcc > /dev/null || echo "ERROR : gcc not installed"
	@which xxd > /dev/null || echo "ERROR : xxd not installed (vim-common)"
	@which python3 > /dev/null || echo "ATTENTION : python3 not installed (optionnel)"
	@which pkg-config > /dev/null || echo "ATTENTION : pkg-config not installed"
	@pkg-config --exists tcl || echo "ERREO : TCL not found"
	@pkg-config --exists tk || echo "ERROR : TK not found"
	@echo "✓ Finish."

# Installation des dépendances
install-deps-debian:
	sudo apt-get install tcl8.6-dev tk8.6-dev build-essential vim-common python3

install-deps-redhat:
	sudo yum install tcl-devel tk-devel libX11-devel gcc make vim-common python3

install-deps-fedora:
	sudo dnf install tcl-devel tk-devel libX11-devel gcc make vim-common python3

.PHONY: all clean distclean run rebuild debug list-scripts info check-deps show-embedded \
        install-deps-debian install-deps-redhat install-deps-fedora
