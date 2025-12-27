#!/bin/bash
# embed_scripts.sh - Génère les headers C pour tous les scripts

set -e

LIST_FILE="list.conf"
MAIN_SCRIPT="Katyusha.tcl"
OUTPUT_FILE="scripts_embedded.h"

# Vérifier que le script principal existe
if [ ! -f "$MAIN_SCRIPT" ]; then
    echo "ERROR : $MAIN_SCRIPT (principal script) not found !"
    exit 1
fi

# Début du fichier header
cat > "$OUTPUT_FILE" << 'EOF'
/* scripts_embedded.h - Scripts TCL embarqués */
/* Généré automatiquement par embed_scripts.sh */

#ifndef SCRIPTS_EMBEDDED_H
#define SCRIPTS_EMBEDDED_H

#include <stddef.h>

/* Structure pour un script embarqué */
typedef struct {
    const char *name;
    const unsigned char *data;
    unsigned int length;
    int is_main;  /* 1 si c'est le script principal */
} EmbeddedScript;

EOF

script_count=0
declare -a script_names
declare -a script_vars

# Fonction pour convertir un nom de fichier en nom de variable C valide
get_var_name() {
    local filename="$1"
    # Remplacer . / - par _
    echo "$filename" | sed 's/[\.\/\-]/_/g'
}

# TOUJOURS embarquer Katyusha.tcl en premier
echo "Embeding principal script : $MAIN_SCRIPT..."

# xxd génère automatiquement des noms basés sur le nom du fichier
xxd -i "$MAIN_SCRIPT" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

script_names[0]="$MAIN_SCRIPT"
script_vars[0]="Katyusha_tcl"  # Nom généré par xxd pour Katyusha.tcl
script_count=1

# Embarquer les scripts additionnels si list.conf existe
if [ -f "$LIST_FILE" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        # Ignorer les lignes vides et commentaires
        line=$(echo "$line" | sed 's/#.*//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        
        if [ -z "$line" ]; then
            continue
        fi
        
        # Éviter d'embarquer script.tcl deux fois
        if [ "$line" = "$MAIN_SCRIPT" ]; then
            echo "ADVERTISSEMENT : $MAIN_SCRIPT already embeded, ignored"
            continue
        fi
        
        if [ ! -f "$line" ]; then
            echo "ADVERTISSEMENT : $line not found, ignored"
            continue
        fi
        
        echo "Embeding $line..."
        
        # xxd génère le nom de variable automatiquement
        xxd -i "$line" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        # Stocker le nom du fichier et le nom de variable
        script_names[$script_count]="$line"
        # xxd remplace . par _ dans le nom du fichier
        script_vars[$script_count]=$(get_var_name "$line")
        
        script_count=$((script_count + 1))
    done < "$LIST_FILE"
else
    echo "Note : $LIST_FILE not found, $MAIN_SCRIPT only will be embeded, Program could be broken !"
fi

# Générer le tableau de scripts
cat >> "$OUTPUT_FILE" << 'EOF'

/* Tableau de tous les scripts embarqués */
static const EmbeddedScript embedded_scripts[] = {
EOF

# Script principal en premier
echo "    {\"${script_names[0]}\", ${script_vars[0]}, sizeof(${script_vars[0]}), 1}" >> "$OUTPUT_FILE"

# Scripts additionnels
for ((i=1; i<script_count; i++)); do
    echo "," >> "$OUTPUT_FILE"
    echo -n "    {\"${script_names[$i]}\", ${script_vars[$i]}, sizeof(${script_vars[$i]}), 0}" >> "$OUTPUT_FILE"
done

cat >> "$OUTPUT_FILE" << EOF

};

#define EMBEDDED_SCRIPTS_COUNT $script_count
#define MAIN_SCRIPT_INDEX 0

#endif /* SCRIPTS_EMBEDDED_H */
EOF

echo ""
echo "✓ Principal script: $MAIN_SCRIPT (${script_vars[0]})"
if [ $script_count -gt 1 ]; then
    echo "✓ Aditionnal scripts :"
    for ((i=1; i<script_count; i++)); do
        echo "  - ${script_names[$i]} (${script_vars[$i]})"
    done
fi
echo "✓ Total: $script_count scripts embarqués dans $OUTPUT_FILE"
