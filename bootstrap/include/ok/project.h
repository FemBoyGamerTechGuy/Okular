/* project.h — project & module graph (spec §2/§6, brief §35/§36). */
#ifndef OK_PROJECT_H
#define OK_PROJECT_H

#include "ok.h"
#include "ok/util.h"
#include "ok/source.h"
#include "ok/diag.h"
#include "ok/lexer.h"
#include "ok/ast.h"
#include "ok/parser.h"

typedef enum { MOD_LOADING, MOD_LOADED, MOD_FAILED } ModState;

typedef struct OkModule {
    char *name;        /* "main" or src file base name */
    char *path;        /* filesystem path */
    char *display;     /* diagnostics display path */
    SourceFile *src;
    TokList *toks;
    Node *ast;         /* A_FILE */
    Arena *arena;      /* owns the AST nodes */
    ModState state;
    bool required;     /* reachable from main.ok */
    bool broken;       /* lex/parse/sema produced errors for this module */
    size_t err_watermark; /* engine->errors when this module started */
    Vec uses;          /* char*: source names it pulls in */
    bool features[OK_FEATURE_COUNT];
    struct FuncInfo *entry; /* synthesized __ok_entry (main module only) */
} OkModule;

typedef struct OkProject {
    char *root;        /* directory containing main.ok */
    char *main_path;   /* as given on the command line */
    OkModule *main_mod;
    Vec modules;       /* OkModule* (main first) */
    StrVec libs;       /* [libs.use] entries from required files */
} OkProject;

/* Loads the project: main.ok, the [source.files.use] graph (with cycle
 * detection), and the remaining src/ files as optional modules. Lexes and
 * parses everything, applying the optional-source policy (brief §36):
 * failures in files not used by the project downgrade to warnings unless
 * `strict`. Returns NULL only if main.ok itself cannot be read. */
OkProject *project_load(const char *main_path, DiagEngine *de, bool strict);

/* After sema: mark module broken-ness and re-apply the optional policy. */
void project_finish_optional(OkProject *p, DiagEngine *de, bool strict);

void project_free(OkProject *p);

/* Find module by name (NULL if absent). */
OkModule *project_find(OkProject *p, const char *name);

/* Verify [libs.use] entries against libs/ and deps/ (spec §6.3). */
void project_check_libs(OkProject *p, DiagEngine *de, bool strict);

#endif /* OK_PROJECT_H */
