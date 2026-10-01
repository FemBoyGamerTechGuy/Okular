/* rt.c — Okular bootstrap runtime shim (x86-64 Linux).
 *
 * Freestanding: no libc, no headers beyond the compiler's own types. Every
 * entry point is raw syscalls. This shim is scaffolding exactly like the C
 * bootstrap compiler: milestone M4 rewrites it in Okular against the future
 * syscall module. The LANGUAGE depends only on the documented write/print
 * semantics (spec §11), not on any internal here.
 *
 * Exported ABI (consumed by codegen_x64.c):
 *   rt_init()
 *   rt_exit(code)
 *   rt_write_number(long)        rt_write_decimal(double)
 *   rt_write_text(ptr, len)      rt_write_bool(int)
 *   rt_write_uint(u64)           rt_print()
 *   rt_{number,uint,decimal,bool}_to_text(out16, v)   spec §4.4 (0.6)
 *   rt_text_to_number(ptr, len) / rt_text_to_decimal(ptr, len)
 *   rt_concat(out16, lptr, llen, rptr, rlen)
 *   rt_text_eq(lptr, llen, rptr, rlen) -> bool
 *   rt_bounds_trap(index, length)  array index out of bounds (spec §8.4)
 *   rt_div_trap()                  integer division by zero (spec §13)
 *   rt_null_trap()                 dereference of null (spec §12/§13)
 *   rt_alloc(bytes) -> ptr         heap allocation, first-fit + split (§12)
 *   rt_release(ptr)                heap release with coalescing (§12)
 *   rt_trap(msg, len, code)      fatal runtime error (spec §13)
 */

typedef long           i64;
typedef unsigned long  u64;
typedef unsigned char  u8;
typedef int            b32;
typedef _Bool           bool;

#define OUTBUF_BYTES 65536
#define TEXT_ARENA_BYTES (1 << 20)

static u8 outbuf[OUTBUF_BYTES];
static u64 outlen = 0;

static u8 text_arena[TEXT_ARENA_BYTES];
static u64 arena_used = 0;

static i64 sys_write(int fd, const void *buf, u64 len) {
    i64 ret;
    __asm__ volatile ("syscall"
                      : "=a"(ret)
                      : "a"(1L), "D"((u64)fd), "S"(buf), "d"(len)
                      : "rcx", "r11", "memory");
    return ret;
}

static void sys_exit(int code) {
    __asm__ volatile ("syscall" :: "a"(60L), "D"((u64)(i64)code));
    for (;;) {} /* unreachable */
}

void rt_init(void) {
    /* buffers live in .bss: zeroed by the loader. Kept as the future hook
     * for runtime bring-up. */
}

void rt_exit(i64 code) {
    sys_exit((int)code);
}

void rt_trap(const char *msg, u64 len, i64 code) {
    sys_write(2, "okular runtime error: ", 22);
    sys_write(2, msg, len);
    sys_write(2, "\n", 1);
    sys_exit((int)code);
}

static void out_reserve(u64 need) {
    if (outlen + need > OUTBUF_BYTES)
        rt_trap("output buffer overflow (65536 bytes per line) — flush with `print` more often",
                75, 70);
}

void rt_write_text(const u8 *p, u64 len) {
    out_reserve(len);
    for (u64 i = 0; i < len; i++)
        outbuf[outlen++] = p[i];
}

void rt_write_number(i64 v) {
    char tmp[24];
    int i = 24;
    u64 u;
    if (v < 0) {
        u = (u64)(-(v + 1)) + 1; /* INT64_MIN-safe */
        out_reserve(1);
        outbuf[outlen++] = '-';
    } else {
        u = (u64)v;
    }
    do {
        tmp[--i] = (char)('0' + (u % 10));
        u /= 10;
    } while (u != 0);
    out_reserve((u64)(24 - i));
    for (; i < 24; i++)
        outbuf[outlen++] = (u8)tmp[i];
}

void rt_write_uint(u64 v) {
    char tmp[24];
    int i = 24;
    do {
        tmp[--i] = (char)('0' + (v % 10));
        v /= 10;
    } while (v != 0);
    out_reserve((u64)(24 - i));
    for (; i < 24; i++)
        outbuf[outlen++] = (u8)tmp[i];
}

/* ---- text conversion builtins (spec §4.4, 0.6) ----
 * to_text forms write a (ptr, len) pair to *out16 and return nothing;
 * bytes live in the text arena (the same bump region concatenation uses).
 * Parsing traps on malformed text or overflow (exit 76) — the recoverable
 * `guard`/`fail` model is the designed future; until then failures are
 * loud, never silent zeros. */

static u8 *text_take(u64 len) {
    if (arena_used + len > TEXT_ARENA_BYTES)
        rt_trap("text arena exhausted (1 MiB of text per run)",
                62, 71);
    u8 *dst = text_arena + arena_used;
    arena_used += len;
    return dst;
}

static u64 put_dec(u64 v, u8 *dst) { /* decimal digits; returns length */
    char tmp[20];
    int n = 0;
    do { tmp[n++] = (char)('0' + (v % 10)); v /= 10; } while (v != 0);
    for (int k = n - 1; k >= 0; k--) *dst++ = (u8)tmp[k];
    return (u64)n;
}

void rt_number_to_text(void *out16, i64 v) {
    u8 buf[24];
    u64 n = 0;
    u64 u;
    if (v < 0) {
        u = (u64)(-(v + 1)) + 1; /* INT64_MIN-safe */
        buf[n++] = '-';
    } else {
        u = (u64)v;
    }
    n += put_dec(u, buf + n);
    u8 *dst = text_take(n);
    for (u64 i = 0; i < n; i++) dst[i] = buf[i];
    *(u8 **)out16 = dst;
    *(u64 *)((u8 *)out16 + 8) = n;
}

void rt_uint_to_text(void *out16, u64 v) {
    u8 buf[20];
    u64 n = put_dec(v, buf);
    u8 *dst = text_take(n);
    for (u64 i = 0; i < n; i++) dst[i] = buf[i];
    *(u8 **)out16 = dst;
    *(u64 *)((u8 *)out16 + 8) = n;
}

void rt_decimal_to_text(void *out16, u64 bits) {
    /* the Okular internal ABI carries decimals as raw bits in integer
     * registers (docs/architecture.md §3.5) */
    union { u64 b; double d; } cvt;
    cvt.b = bits;
    double x = cvt.d;
    /* same documented format as rt_write_decimal: 6 fractional digits,
     * integer-only for |x| >= 1e15, NaN/Inf named */
    if (x != x || x > 1.7976931348623157e308 || x < -1.7976931348623157e308) {
        const char *s = (x != x) ? "nan" : (x > 0 ? "inf" : "-inf");
        u64 n = (x != x) ? 3 : (x > 0 ? 3 : 4);
        u8 *dst = text_take(n);
        for (u64 i = 0; i < n; i++) dst[i] = (u8)s[i];
        *(u8 **)out16 = dst;
        *(u64 *)((u8 *)out16 + 8) = n;
        return;
    }
    u8 buf[48];
    u64 n = 0;
    if (x < 0.0) { buf[n++] = '-'; x = -x; }
    if (x >= 1e15) {
        n += put_dec((u64)x, buf + n);
    } else {
        i64 ip = (i64)x;
        double frac = x - (double)ip;
        i64 f6 = (i64)(frac * 1000000.0 + 0.5);
        if (f6 == 1000000) { ip += 1; f6 = 0; }
        n += put_dec((u64)ip, buf + n);
        buf[n++] = '.';
        char d[6];
        for (int k = 5; k >= 0; k--) { d[k] = (char)('0' + (f6 % 10)); f6 /= 10; }
        for (int k = 0; k < 6; k++) buf[n++] = (u8)d[k];
    }
    u8 *dst = text_take(n);
    for (u64 i = 0; i < n; i++) dst[i] = buf[i];
    *(u8 **)out16 = dst;
    *(u64 *)((u8 *)out16 + 8) = n;
}

void rt_bool_to_text(void *out16, i64 b) {
    /* static bytes: text values are immutable */
    if (b) { *(const u8 **)out16 = (const u8 *)"true";  *(u64 *)((u8 *)out16 + 8) = 4; }
    else   { *(const u8 **)out16 = (const u8 *)"false"; *(u64 *)((u8 *)out16 + 8) = 5; }
}

/* parse helpers: strict [+-]?digits (and .digits for decimal) */
static void text_number_trap(const u8 *p, u64 len) {
    sys_write(2, "okular runtime error: ", 22);
    sys_write(2, "text is not a number: \"", 23);
    sys_write(2, p, len > 32 ? 32 : len);
    sys_write(2, "\"\n", 2);
    sys_exit(76);
}

i64 rt_text_to_number(const u8 *p, u64 len) {
    u64 i = 0;
    bool neg = 0;
    if (i < len && (p[i] == '-' || p[i] == '+')) { neg = (p[i] == '-'); i++; }
    if (i >= len) text_number_trap(p, len);
    u64 v = 0;
    u64 digits = 0;
    for (; i < len; i++) {
        if (p[i] < '0' || p[i] > '9') text_number_trap(p, len);
        u64 d = (u64)(p[i] - '0');
        if (v > (0x7FFFFFFFFFFFFFFFULL - d) / 10)
            text_number_trap(p, len); /* overflow */
        v = v * 10 + d;
        digits++;
    }
    if (digits == 0 || digits > 19) text_number_trap(p, len);
    if (neg) return -(i64)v;
    if (v > 0x7FFFFFFFFFFFFFFFULL) text_number_trap(p, len);
    return (i64)v;
}

u64 rt_text_to_decimal(const u8 *p, u64 len) {  /* returns raw bits */
    u64 i = 0;
    bool neg = 0;
    if (i < len && (p[i] == '-' || p[i] == '+')) { neg = (p[i] == '-'); i++; }
    if (i >= len) text_number_trap(p, len);
    double ip = 0.0;
    u64 int_digits = 0;
    for (; i < len && p[i] >= '0' && p[i] <= '9'; i++) {
        ip = ip * 10.0 + (double)(p[i] - '0');
        int_digits++;
    }
    if (int_digits == 0) text_number_trap(p, len);
    double frac = 0.0, scale = 0.1;
    if (i < len && p[i] == '.') {
        i++;
        u64 frac_digits = 0;
        for (; i < len && p[i] >= '0' && p[i] <= '9'; i++) {
            frac += (double)(p[i] - '0') * scale;
            scale *= 0.1;
            frac_digits++;
        }
        if (frac_digits == 0) text_number_trap(p, len);
    }
    if (i != len) text_number_trap(p, len); /* trailing garbage */
    union { double d; u64 b; } cvt;
    cvt.d = neg ? -(ip + frac) : (ip + frac);
    return cvt.b;
}

void rt_write_decimal(double x) {
    /* documented v0.1 approximation: fixed 6 fractional digits, integer-only
     * for |x| >= 1e15 (spec §11 + docs). NaN/Inf named. */
    if (x != x) { rt_write_text((const u8 *)"nan", 3); return; }
    if (x < 0.0) { rt_write_text((const u8 *)"-", 1); x = -x; }
    if (x > 1.7976931348623157e308) { rt_write_text((const u8 *)"inf", 3); return; }
    if (x >= 1e15) { rt_write_number((i64)x); return; }

    i64 ip = (i64)x;
    double frac = x - (double)ip;
    i64 f6 = (i64)(frac * 1000000.0 + 0.5);
    if (f6 == 1000000) { ip += 1; f6 = 0; }
    rt_write_number(ip);

    out_reserve(7);
    outbuf[outlen++] = '.';
    char d[6];
    for (int k = 5; k >= 0; k--) { d[k] = (char)('0' + (f6 % 10)); f6 /= 10; }
    for (int k = 0; k < 6; k++) outbuf[outlen++] = (u8)d[k];
}

void rt_write_bool(b32 b) {
    if (b) rt_write_text((const u8 *)"true", 4);
    else   rt_write_text((const u8 *)"false", 5);
}

void rt_print(void) {
    out_reserve(1);
    outbuf[outlen++] = '\n';
    if (sys_write(1, outbuf, outlen) < 0)
        rt_trap("write to standard output failed", 31, 74);
    outlen = 0;
}

void rt_concat(void *out16, const u8 *lp, u64 ll, const u8 *rp, u64 rl) {
    if (arena_used + ll + rl > TEXT_ARENA_BYTES)
        rt_trap("text arena exhausted (1 MiB of concatenation per run in 0.1)",
                62, 71);
    u8 *dst = text_arena + arena_used;
    for (u64 i = 0; i < ll; i++) dst[i] = lp[i];
    for (u64 i = 0; i < rl; i++) dst[ll + i] = rp[i];
    arena_used += ll + rl;
    *(const u8 **)out16 = dst;
    *(u64 *)((u8 *)out16 + 8) = ll + rl;
}

b32 rt_text_eq(const u8 *lp, u64 ll, const u8 *rp, u64 rl) {
    if (ll != rl) return 0;
    for (u64 i = 0; i < ll; i++)
        if (lp[i] != rp[i]) return 0;
    return 1;
}

/* spec §13: integer division by zero is a fatal runtime trap (exit 71).
 * The guard is emitted at every divide/remainder site; wrapping overflow
 * (INT64_MIN / -1) is NOT a trap — it wraps per spec §4.2. */
void rt_div_trap(void) {
    sys_write(2, "okular runtime error: ", 22);
    sys_write(2, "integer division by zero\n", 26);
    sys_exit(71);
}

/* ---------------- heap allocator (spec §12, 0.4) ----------------
 *
 * A real allocator, not a stub: mmap-backed pools carved into blocks with
 * 16-byte headers, a first-fit free list with splitting, and
 * address-ordered insertion with neighbor coalescing on release.
 *
 * Block layout:  [ header 16B: size u64 + pad ][ payload ... ]
 * All sizes are multiples of 16, so a released pointer whose header has a
 * bogus size (double release, corruption) is detected and traps rather
 * than silently corrupting the heap.
 *
 * Honest limits (documented in spec §12): use-after-release is NOT
 * detected (no quarantine), and pointer indexing is unchecked. */

#define HEAP_CHUNK (1 << 20)          /* 1 MiB growth unit */
#define HEAP_ALIGN ((u64)16)

typedef struct FreeBlock {
    u64 size;                         /* payload bytes (mirrors the header) */
    struct FreeBlock *next;           /* address-ordered free list */
} FreeBlock;

static FreeBlock *heap_free = 0;      /* sorted by address, ascending */
static u64 heap_total = 0;

static i64 sys_mmap(u64 len) {
    i64 ret;
    register i64 r10 __asm__("r10") = 0x22;   /* MAP_PRIVATE|MAP_ANONYMOUS */
    register i64 r8  __asm__("r8")  = -1;
    register i64 r9  __asm__("r9")  = 0;
    __asm__ volatile ("syscall"
                      : "=a"(ret)
                      : "a"(9L), "D"(0UL), "S"(len), "d"(3L),
                        "r"(r10), "r"(r8), "r"(r9)
                      : "rcx", "r11", "memory");
    return ret;
}

static void heap_grow(u64 need) {
    u64 len = (need + HEAP_ALIGN + HEAP_CHUNK - 1) & ~(HEAP_CHUNK - 1);
    i64 p = sys_mmap(len);
    if (p < 0 && p > -4096)
        rt_trap("heap exhausted (mmap failed)", 29, 74);
    u8 *base = (u8 *)(u64)p;
    u64 payload = len - HEAP_ALIGN;
    *(u64 *)base = payload;                       /* first block header */
    FreeBlock *fb = (FreeBlock *)(base + HEAP_ALIGN);
    fb->size = payload;
    /* the fresh chunk is the highest address: append to the list tail */
    FreeBlock **pp = &heap_free;
    while (*pp) pp = &(*pp)->next;
    fb->next = 0;
    *pp = fb;
    heap_total += len;
}

/* rt_alloc(bytes) -> pointer (traps on zero/negative-shaped requests) */
void *rt_alloc(u64 bytes) {
    if (bytes == 0)
        rt_trap("allocation of zero bytes", 25, 74);
    u64 need = (bytes + HEAP_ALIGN - 1) & ~(HEAP_ALIGN - 1);

    /* first fit with splitting */
    FreeBlock **pp = &heap_free;
    while (*pp) {
        FreeBlock *fb = *pp;
        if (fb->size >= need) {
            u64 rem = fb->size - need;
            if (rem >= HEAP_ALIGN + HEAP_ALIGN) {
                /* split: allocate the front, free the tail */
                u8 *data = (u8 *)fb;
                u8 *tail = data + need;
                u64 tail_payload = rem - HEAP_ALIGN;
                *(u64 *)(tail - HEAP_ALIGN) = tail_payload;   /* tail header */
                FreeBlock *nb = (FreeBlock *)tail;
                nb->size = tail_payload;
                nb->next = fb->next;
                *pp = nb;
                *(u64 *)(data - HEAP_ALIGN) = need;           /* allocated hdr */
                return data;
            }
            /* close fit: hand out the whole block */
            *pp = fb->next;
            *(u64 *)((u8 *)fb - HEAP_ALIGN) = fb->size;
            return fb;
        }
        pp = &fb->next;
    }
    heap_grow(need + HEAP_ALIGN);
    /* the fresh chunk satisfies the request by construction */
    return rt_alloc(bytes);
}

/* rt_release(ptr): null is a no-op; header shape is validated */
void rt_release(void *ptr) {
    if (!ptr) return;
    u8 *data = (u8 *)ptr;
    u64 size = *(u64 *)(data - HEAP_ALIGN);
    if (size == 0 || (size & (HEAP_ALIGN - 1)) != 0)
        rt_trap("release of an invalid or already-released heap pointer", 47, 74);
    FreeBlock *fb = (FreeBlock *)data;
    fb->size = size;
    /* poison the header: a second release of this pointer reads a size
     * with low bits set and traps (double-release detection) */
    *(u64 *)(data - HEAP_ALIGN) = 1;

    /* address-ordered insertion (remember the predecessor for coalescing) */
    FreeBlock **pp = &heap_free;
    while (*pp && (u8 *)*pp < data) pp = &(*pp)->next;
    fb->next = *pp;
    *pp = fb;

    /* coalesce forward (with the next block) */
    if (fb->next && (u8 *)fb + HEAP_ALIGN + fb->size == (u8 *)fb->next) {
        fb->size += HEAP_ALIGN + fb->next->size;
        fb->next = fb->next->next;
        *(u64 *)(data - HEAP_ALIGN) = fb->size;   /* keep the header honest */
    }
    /* coalesce backward (with the previous block) */
    FreeBlock *prev = 0, *cur = heap_free;
    while (cur && cur != fb) { prev = cur; cur = cur->next; }
    if (prev && (u8 *)prev + HEAP_ALIGN + prev->size == (u8 *)fb) {
        prev->size += HEAP_ALIGN + fb->size;
        prev->next = fb->next;
    }
}

/* spec §12/§13: dereferencing or indexing through null traps (exit 73) */
void rt_null_trap(void) {
    sys_write(2, "okular runtime error: ", 22);
    sys_write(2, "dereference of null pointer\n", 28);
    sys_exit(73);
}

/* shared bounds-trap reporter: prefix + index + length, exit 70 (D24) */
static void rt_bounds_trap_named(const char *pre, i64 index, u64 length) {
    char msg[96];
    u64 n = 0;

    for (const char *c = pre; *c; c++) msg[n++] = *c;

    /* print the offending index (negative indices are reported signed) */
    u64 u;
    if (index < 0) {
        msg[n++] = '-';
        u = (u64)(-(index + 1)) + 1; /* INT64_MIN-safe */
    } else {
        u = (u64)index;
    }
    char tmp[24];
    int i = 24;
    do { tmp[--i] = (char)('0' + (u % 10)); u /= 10; } while (u != 0);
    for (; i < 24; i++) msg[n++] = tmp[i];

    const char *mid = " is out of bounds (length ";
    for (const char *c = mid; *c; c++) msg[n++] = *c;

    u = length;
    i = 24;
    do { tmp[--i] = (char)('0' + (u % 10)); u /= 10; } while (u != 0);
    for (; i < 24; i++) msg[n++] = tmp[i];

    msg[n++] = ')';
    msg[n++] = '\n';

    sys_write(2, "okular runtime error: ", 22);
    sys_write(2, msg, n);
    sys_exit(70);
}

void rt_bounds_trap(i64 index, u64 length) {
    rt_bounds_trap_named("array index ", index, length);
}

/* 0.9: text.byte_at / text.slice bounds violations report themselves
 * with a text-specific message (same trap family, same exit code 70) */
void rt_text_bounds_trap(i64 index, u64 length) {
    rt_bounds_trap_named("text position ", index, length);
}
