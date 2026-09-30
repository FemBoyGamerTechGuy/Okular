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
 *   rt_print()
 *   rt_concat(out16, lptr, llen, rptr, rlen)
 *   rt_text_eq(lptr, llen, rptr, rlen) -> bool
 *   rt_bounds_trap(index, length)  array index out of bounds (spec §8.4)
 *   rt_trap(msg, len, code)      fatal runtime error (spec §13)
 */

typedef long           i64;
typedef unsigned long  u64;
typedef unsigned char  u8;
typedef int            b32;

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

/* spec §8.4: array indexing is always bounds-checked; a violation is a
 * fatal runtime trap naming the index and the array length. */
void rt_bounds_trap(i64 index, u64 length) {
    char msg[96];
    u64 n = 0;

    const char *pre = "array index ";
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
