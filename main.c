#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <tcl.h>
#include <tk.h>

/**
 * Ce script est basé sur celui de Pat Thoyts.
 * Petite mention aussi à Poor Yorick du wiki TCL.
 * https://wiki.tcl-lang.org/page/How+to+embed+Tcl+in+C+applications
 */


/* ============================================================================
 * Configuration et macros
 * ========================================================================= */

static int verbose = 0;

#define VERBOSE_LOG(...) do { \
    if (verbose) { \
        printf("[VERBOSE] " __VA_ARGS__); \
        printf("\n"); \
    } \
} while(0)

#define LOG_INFO(...)  do { printf("[INFO] " __VA_ARGS__); printf("\n"); } while(0)
#define LOG_ERROR(...) do { fprintf(stderr, "[ERROR] " __VA_ARGS__); fprintf(stderr, "\n"); } while(0)
#define LOG_WARN(...)  do { fprintf(stderr, "[WARN] " __VA_ARGS__); fprintf(stderr, "\n"); } while(0)

/* ============================================================================
 * Scripts embarqués
 * ========================================================================= */

#include "scripts_embedded.h"

/* ============================================================================
 * Variables globales
 * ========================================================================= */

typedef struct {
    Tcl_Interp *interp;
    int initialized;
    char **loaded_scripts;
    int script_count;
} AppState;

static AppState app_state = {
    .interp = NULL,
    .initialized = 0,
    .loaded_scripts = NULL,
    .script_count = 0
};

/* ============================================================================
 * Gestion des signaux
 * ========================================================================= */

static void cleanup_all(void)
{
    int i;
    
    VERBOSE_LOG("Complete cleaning Katyusha...");
    
    if (app_state.interp != NULL) {
        VERBOSE_LOG("Deleting TCL interpreter...");
        Tcl_DeleteInterp(app_state.interp);
        app_state.interp = NULL;
    }
    
    if (app_state.loaded_scripts != NULL) {
        VERBOSE_LOG("Freeing embeded scripts...");
        for (i = 0; i < app_state.script_count; i++) {
            if (app_state.loaded_scripts[i] != NULL) {
                free(app_state.loaded_scripts[i]);
            }
        }
        free(app_state.loaded_scripts);
        app_state.loaded_scripts = NULL;
    }
    
    app_state.initialized = 0;
    app_state.script_count = 0;
    VERBOSE_LOG("Cleaning OK !");
}

static void signal_handler(int signo)
{
    (void)signo;
    LOG_INFO("Signal receive...");
    cleanup_all();
    exit(0);
}

static void setup_signal_handlers(void)
{
    VERBOSE_LOG("Signals gestion installations...");
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
}

/* ============================================================================
 * Commandes TCL personnalisées
 * ========================================================================= */

static int SourceExternal_Cmd(void *clientData, Tcl_Interp *interp,
                              int objc, Tcl_Obj *const objv[])
{
    char *filename;
    int result;
    const char *err;
    
    (void)clientData;
    
    if (objc != 2) {
        Tcl_WrongNumArgs(interp, 1, objv, "filename");
        return TCL_ERROR;
    }
    
    filename = Tcl_GetString(objv[1]);
    
    VERBOSE_LOG("Loading script : %s", filename);
    
    result = Tcl_EvalFile(interp, filename);
    
    if (result != TCL_OK) {
        err = Tcl_GetStringResult(interp);
        if (strstr(err, "couldn't read file") != NULL) {
            LOG_ERROR("Could not find file : %s", filename);
        } else {
            LOG_ERROR("Error %s: %s", filename, err);
        }
    } else {
        VERBOSE_LOG("Script %s successfully laoded", filename);
    }
    
    return result;
}

static int ReloadEmbedded_Cmd(void *clientData, Tcl_Interp *interp,
                              int objc, Tcl_Obj *const objv[])
{
    char *script_name;
    int i, result;
    
    (void)clientData;
    
    if (objc != 2) {
        Tcl_WrongNumArgs(interp, 1, objv, "script_name");
        return TCL_ERROR;
    }
    
    script_name = Tcl_GetString(objv[1]);
    
    VERBOSE_LOG("Searching embeded script : %s", script_name);
    
    for (i = 0; i < app_state.script_count; i++) {
        if (strcmp(embedded_scripts[i].name, script_name) == 0) {
            LOG_INFO("Loading %s...", script_name);
            
            result = Tcl_Eval(interp, app_state.loaded_scripts[i]);
            
            if (result != TCL_OK) {
                LOG_ERROR("Error while loading : %s", 
                         Tcl_GetStringResult(interp));
            } else {
                LOG_INFO("Script %s successfully laoded", script_name);
            }
            
            return result;
        }
    }
    
    Tcl_SetResult(interp, "Script not found", TCL_STATIC);
    return TCL_ERROR;
}

static int ReloadMain_Cmd(void *clientData, Tcl_Interp *interp,
                         int objc, Tcl_Obj *const objv[])
{
    int result;
    
    (void)clientData;
    (void)objc;
    (void)objv;
    
    LOG_INFO("Reloading initial script of Katyusha...");
    
    result = Tcl_Eval(interp, app_state.loaded_scripts[MAIN_SCRIPT_INDEX]);
    
    if (result != TCL_OK) {
        LOG_ERROR("Error xhile loading : %s", 
                 Tcl_GetStringResult(interp));
    } else {
        LOG_INFO("Initial script successfully laoded");
    }
    
    return result;
}

static int ListEmbedded_Cmd(void *clientData, Tcl_Interp *interp,
                           int objc, Tcl_Obj *const objv[])
{
    Tcl_Obj *listObj;
    int i;
    
    (void)clientData;
    (void)objc;
    (void)objv;
    
    listObj = Tcl_NewListObj(0, NULL);
    
    for (i = 0; i < EMBEDDED_SCRIPTS_COUNT; i++) {
        Tcl_ListObjAppendElement(interp, listObj,
            Tcl_NewStringObj(embedded_scripts[i].name, -1));
    }
    
    Tcl_SetObjResult(interp, listObj);
    return TCL_OK;
}

/* ============================================================================
 * Fonctions d'initialisation
 * ========================================================================= */

static int safe_set_var(Tcl_Interp *interp, const char *varName, 
                       const char *value, int flags)
{
    const char *result = Tcl_SetVar(interp, varName, value, flags);
    if (result == NULL) {
        LOG_WARN("Impossible define variable : %s", varName);
        return 0;
    }
    VERBOSE_LOG("Variable %s = %s", varName, value);
    return 1;
}

static int register_custom_commands(Tcl_Interp *interp)
{
    VERBOSE_LOG("Saving custom procs...");
    
    Tcl_CreateObjCommand(interp, "source_external", 
                        SourceExternal_Cmd, 
                        (void *)NULL, NULL);
    
    Tcl_CreateObjCommand(interp, "reload_embedded", 
                        ReloadEmbedded_Cmd, 
                        (void *)NULL, NULL);
    
    Tcl_CreateObjCommand(interp, "reload_main", 
                        ReloadMain_Cmd, 
                        (void *)NULL, NULL);
    
    Tcl_CreateObjCommand(interp, "list_embedded", 
                        ListEmbedded_Cmd, 
                        (void *)NULL, NULL);
    
    return TCL_OK;
}

static int setup_tcl_variables(Tcl_Interp *interp, int argc, char *argv[])
{
    char buf[32];
    Tcl_Obj *argvList;
    int i;
    
    VERBOSE_LOG("TCL variables configuration...");
    
    safe_set_var(interp, "argv0", argv[0], TCL_GLOBAL_ONLY);
    
    snprintf(buf, sizeof(buf), "%d", argc - 1);
    safe_set_var(interp, "argc", buf, TCL_GLOBAL_ONLY);
    
    argvList = Tcl_NewListObj(0, NULL);
    for (i = 1; i < argc; i++) {
        Tcl_ListObjAppendElement(interp, argvList, 
                                Tcl_NewStringObj(argv[i], -1));
    }
    
    if (Tcl_SetVar2Ex(interp, "argv", NULL, argvList, TCL_GLOBAL_ONLY) == NULL) {
        LOG_WARN("Impossible dto define argv");
        Tcl_DecrRefCount(argvList);
        return 0;
    }
    
    VERBOSE_LOG("TCL variables configured : argc=%d", argc - 1);
    return 1;
}

static int load_embedded_scripts(Tcl_Interp *interp)
{
    int i, rc;
    unsigned int len;
    
    if (EMBEDDED_SCRIPTS_COUNT == 0) {
        LOG_ERROR("NBo embeded scripts found !");
        return 1;
    }
    
    LOG_INFO("Loading embeded scripts...");
    LOG_INFO("  Initial script : %s", embedded_scripts[MAIN_SCRIPT_INDEX].name);
    if (EMBEDDED_SCRIPTS_COUNT > 1) {
        LOG_INFO("  Secondary scripts : %d", EMBEDDED_SCRIPTS_COUNT - 1);
    }
    
    app_state.loaded_scripts = (char **)calloc(EMBEDDED_SCRIPTS_COUNT, sizeof(char *));
    if (app_state.loaded_scripts == NULL) {
        LOG_ERROR("Failed memory allocation for embeded scripts !");
        return 1;
    }
    
    app_state.script_count = EMBEDDED_SCRIPTS_COUNT;
    
    /* Charger tous les scripts */
    for (i = 0; i < EMBEDDED_SCRIPTS_COUNT; i++) {
        const char *type = embedded_scripts[i].is_main ? "principal" : "additionnel";
        
        /* CORRECTION: Déréférencer le pointeur length */
        len = embedded_scripts[i].length;
        
        VERBOSE_LOG("Loading %s (%s, %u bytes)...", 
                   embedded_scripts[i].name,
                   type,
                   len);
        
        app_state.loaded_scripts[i] = (char *)malloc(len + 1);
        if (app_state.loaded_scripts[i] == NULL) {
            LOG_ERROR("Failed memory allocation for %s", embedded_scripts[i].name);
            return 1;
        }
        
        memcpy(app_state.loaded_scripts[i], 
               embedded_scripts[i].data, 
               len);
        app_state.loaded_scripts[i][len] = '\0';
        
        rc = Tcl_Eval(interp, app_state.loaded_scripts[i]);
        
        if (rc != TCL_OK) {
            LOG_ERROR("Error in %s : %s", 
                     embedded_scripts[i].name,
                     Tcl_GetStringResult(interp));
            return 1;
        }
        
        LOG_INFO("✓ %s loaded (%s)", embedded_scripts[i].name, type);
    }
    
    return 0;
}

static int load_external_scripts(Tcl_Interp *interp)
{
    const char *external_scripts[] = {
        "external.tcl",
        "runtime.tcl",
        NULL
    };
    int i, rc;
    const char *err;
    
    LOG_INFO("Searching external scripts (runtime)...");
    
    for (i = 0; external_scripts[i] != NULL; i++) {
        rc = Tcl_EvalFile(interp, external_scripts[i]);
        
        if (rc == TCL_OK) {
            LOG_INFO("✓ %s loaded (external)", external_scripts[i]);
        } else {
            err = Tcl_GetStringResult(interp);
            if (strstr(err, "couldn't read file") == NULL) {
                LOG_WARN("%s: %s", external_scripts[i], err);
            } else {
                VERBOSE_LOG("  %s not found (optionnal)", external_scripts[i]);
            }
            Tcl_ResetResult(interp);
        }
    }
    
    return 0;
}

static int check_display(void)
{
    const char *display = getenv("DISPLAY");
    
    if (display == NULL) {
        LOG_WARN("Failed define DISPLAY variable");
        LOG_WARN("L'interface graphique TK pourrait ne pas fonctionner");
        LOG_INFO("Please try : export DISPLAY=:0");
        return 0;
    }
    
    VERBOSE_LOG("DISPLAY défini: %s", display);
    return 1;
}

static int InitScriptTk(int argc, char *argv[])
{
    VERBOSE_LOG("Initialisation TCL...");
    
    Tcl_FindExecutable(argv[0]);
    
    app_state.interp = Tcl_CreateInterp();
    if (app_state.interp == NULL) {
        LOG_ERROR("Impossible de build interpreter !");
        return 1;
    }
    
    VERBOSE_LOG("TCL Interpreter successfuly builded !");
    
    if (Tcl_Init(app_state.interp) != TCL_OK) {
        LOG_ERROR("Tcl_Init failed : %s", Tcl_GetStringResult(app_state.interp));
        Tcl_DeleteInterp(app_state.interp);
        app_state.interp = NULL;
        return 1;
    }
    
    VERBOSE_LOG("TCL initialised");
    
    check_display();
    
    VERBOSE_LOG("Initialisation TK...");
    if (Tk_Init(app_state.interp) != TCL_OK) {
        LOG_ERROR("Tk_Init échoué: %s", Tcl_GetStringResult(app_state.interp));
        Tcl_DeleteInterp(app_state.interp);
        app_state.interp = NULL;
        return 1;
    }
    
    VERBOSE_LOG("TK initialised");
    
    setup_tcl_variables(app_state.interp, argc, argv);
    register_custom_commands(app_state.interp);
    
    if (load_embedded_scripts(app_state.interp) != 0) {
        Tcl_DeleteInterp(app_state.interp);
        app_state.interp = NULL;
        return 1;
    }
    
    app_state.initialized = 1;
    return 0;
}

/* ============================================================================
 * Fonction principale
 * ========================================================================= */

static void print_usage(const char *progname)
{
    printf("Usage : %s [OPTIONS]\n", progname);
    printf("Options :\n");
    printf("  -v, --verbose    Verbose mode\n");
    printf("  -h, --help       Display help (you're doing it !)\n");
    printf("  --list-scripts   Listing embeded scripts\n");
    printf("\nExemples:\n");
    printf("  %s              # Standard lunching\n", progname);
    printf("  %s -v           # Verbose mode lunching\n", progname);
    printf("  %s --list-scripts # Display embeded scripts\n", progname);
}

static void list_embedded_scripts(void)
{
    int i;
    unsigned int len;
    
    printf("Embeded scripts (%d) :\n\n", EMBEDDED_SCRIPTS_COUNT);
    printf("%-30s %12s  %s\n", "Nom", "Taille", "Type");
    printf("%-30s %12s  %s\n", "---", "------", "----");
    
    for (i = 0; i < EMBEDDED_SCRIPTS_COUNT; i++) {
        const char *type = embedded_scripts[i].is_main ? "Principal" : "Additionnel";
        
        /* CORRECTION: Déréférencer le pointeur length */
        len = embedded_scripts[i].length;
        
        printf("%-30s %10u o  %s\n", 
               embedded_scripts[i].name,
               len,
               type);
    }
}

int main(int argc, char *argv[])
{
    int rc, i;
    
    for (i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-v") == 0 || strcmp(argv[i], "--verbose") == 0) {
            verbose = 1;
            LOG_INFO("Verbose mode ON");
        } else if (strcmp(argv[i], "--list-scripts") == 0) {
            list_embedded_scripts();
            return 0;
        } else if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            print_usage(argv[0]);
            return 0;
        } else {
            fprintf(stderr, "Unknown option : %s\n", argv[i]);
            print_usage(argv[0]);
            return 1;
        }
    }
    
    setup_signal_handlers();
    
    LOG_INFO("=== Initialisation TCL/TK ===");
    
    rc = InitScriptTk(argc, argv);
    if (rc != 0) {
        LOG_ERROR("ERROR : TCL/TK initialisation failed");
        cleanup_all();
        return 1;
    }
    
    load_external_scripts(app_state.interp);
    
    LOG_INFO("Loading evenment loop TK...\n");
    
    Tk_MainLoop();
    
    cleanup_all();
    
    LOG_INFO("=== The End ! ===");
    return 0;
}
