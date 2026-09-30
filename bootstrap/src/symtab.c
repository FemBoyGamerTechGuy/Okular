/* symtab.c — scopes and symbols. */
#include "ok/symtab.h"

Scope *scope_new(const char *label, Scope *parent) {
    Scope *s = ok_xmalloc(sizeof *s);
    s->label = label;
    s->parent = parent;
    s->syms = NULL;
    s->n = s->cap = 0;
    return s;
}

Symbol *scope_insert(Scope *s, const char *name, SymKind kind, size_t line, size_t col) {
    Symbol *ex = scope_find_local(s, name);
    if (ex) return ex;
    if (s->n == s->cap) {
        s->cap = s->cap ? s->cap * 2 : 8;
        s->syms = ok_xrealloc(s->syms, s->cap * sizeof(Symbol *));
    }
    Symbol *sym = ok_xmalloc(sizeof *sym);
    memset(sym, 0, sizeof *sym);
    sym->name = ok_xstrdup(name);
    sym->kind = kind;
    sym->scope = s;
    sym->line = line;
    sym->col = col;
    s->syms[s->n++] = sym;
    return sym;
}

Symbol *scope_find_local(Scope *s, const char *name) {
    for (size_t i = 0; i < s->n; i++)
        if (strcmp(s->syms[i]->name, name) == 0) return s->syms[i];
    return NULL;
}

Symbol *scope_lookup(Scope *s, const char *name) {
    for (Scope *sc = s; sc; sc = sc->parent) {
        Symbol *sym = scope_find_local(sc, name);
        if (sym) return sym;
    }
    return NULL;
}

Symbol *scope_lookup_nslocal(Scope *s, const char *name) {
    for (Scope *sc = s; sc; sc = sc->parent) {
        Symbol *sym = scope_find_local(sc, name);
        if (sym) return sym;
    }
    return NULL;
}

FuncInfo *funcinfo_new(const char *name, const char *mangled, OkType ret,
                       struct Node *decl, struct OkModule *mod) {
    FuncInfo *fi = ok_xmalloc(sizeof *fi);
    memset(fi, 0, sizeof *fi);
    fi->name = ok_xstrdup(name);
    fi->mangled = ok_xstrdup(mangled);
    fi->ret = ret;
    fi->decl = decl;
    fi->module = mod;
    return fi;
}
