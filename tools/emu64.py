#!/usr/bin/env python3
"""emu64.py — a small AArch64 user-mode emulator for Okular backend verification.

Decodes and executes exactly the instruction subset the Okular ARM64
backend emits, plus the Linux syscall interface the runtime rides on
(write/read/openat/close/fstatat/mmap/exit/fchmodat/mkdirat/getdents64).
Loads a static ELF64 ET_EXEC image and runs it until exit.

Usage: python3 emu64.py <binary> [args...] [-v]
"""
import struct
import sys

PAGE = 4096
STACK_TOP = 0x7fff_ffff_0000
STACK_SIZE = 8 * 1024 * 1024
MMAP_BASE = 0x1000_0000_0000


class Emu:
    def __init__(self):
        self.mem = {}          # page index -> bytearray(PAGE)
        self.x = [0] * 32      # X registers (index 31 = SP via helper)
        self.v = [0] * 32      # SIMD registers (raw 64-bit patterns)
        self.nzcv = 0          # N Z C V bits 31..28
        self.pc = 0
        self.exit_code = None
        self.fd_counter = 3
        self.files = {0: sys.stdin.buffer, 1: sys.stdout.buffer, 2: sys.stderr.buffer}
        self.mmap_next = MMAP_BASE
        self.verbose = False
        self.out = bytearray()

    # ---- memory ----
    def page(self, addr):
        idx = addr // PAGE
        p = self.mem.get(idx)
        if p is None:
            p = bytearray(PAGE)
            self.mem[idx] = p
        return p

    def read(self, addr, n):
        off = addr & 0xFFF
        if off + n <= PAGE:
            # fast path: entirely within one page
            p = self.mem.get(addr >> 12)
            if p is None:
                p = self.page(addr)
            return p[off:off + n]
        out = bytearray()
        while n > 0:
            off = addr % PAGE
            take = min(n, PAGE - off)
            out += self.page(addr)[off:off + take]
            addr += take
            n -= take
        return bytes(out)

    def write(self, addr, data):
        off = addr & 0xFFF
        n = len(data)
        if off + n <= PAGE:
            # fast path: entirely within one page
            p = self.mem.get(addr >> 12)
            if p is None:
                p = self.page(addr)
            p[off:off + n] = data
            return
        i = 0
        while i < n:
            off = addr % PAGE
            take = min(n - i, PAGE - off)
            self.page(addr)[off:off + take] = data[i:i + take]
            addr += take
            i += take

    def rd64(self, addr):
        off = addr & 0xFFF
        if off <= 0xFF8:
            p = self.mem.get(addr >> 12)
            if p is None:
                p = self.page(addr)
            return struct.unpack_from('<Q', p, off)[0]
        return struct.unpack('<Q', self.read(addr, 8))[0]

    def wr64(self, addr, v):
        off = addr & 0xFFF
        if off <= 0xFF8:
            p = self.mem.get(addr >> 12)
            if p is None:
                p = self.page(addr)
            struct.pack_into('<Q', p, off, v & 0xFFFFFFFFFFFFFFFF)
            return
        self.write(addr, struct.pack('<Q', v & 0xFFFFFFFFFFFFFFFF))

    def rd32(self, addr):
        off = addr & 0xFFF
        if off <= 0xFFC:
            p = self.mem.get(addr >> 12)
            if p is None:
                p = self.page(addr)
            return struct.unpack_from('<I', p, off)[0]
        return struct.unpack('<I', self.read(addr, 4))[0]

    def wr32(self, addr, v):
        self.write(addr, struct.pack('<I', v & 0xFFFFFFFF))

    # ---- registers ----
    def sp(self):
        return self.x[31]

    def set_sp(self, v):
        self.x[31] = v & 0xFFFFFFFFFFFFFFFF

    def get_flags(self):
        n = (self.nzcv >> 31) & 1
        z = (self.nzcv >> 30) & 1
        c = (self.nzcv >> 29) & 1
        v = (self.nzcv >> 28) & 1
        return n, z, c, v

    def set_flags_logic(self, res):
        res &= 0xFFFFFFFFFFFFFFFF
        self.nzcv = ((1 if res == 0 else 0) << 30) | ((res >> 63) << 31)

    def set_flags_add(self, a, b, cin=0):
        r = (a + b + cin) & 0xFFFFFFFFFFFFFFFF
        n = (r >> 63) & 1
        z = 1 if r == 0 else 0
        c = 1 if (a + b + cin) > 0xFFFFFFFFFFFFFFFF else 0
        v = (((a ^ r) & (b ^ r)) >> 63) & 1
        self.nzcv = (n << 31) | (z << 30) | (c << 29) | (v << 28)

    def set_flags_sub(self, a, b):
        # a - b as a + ~b + 1
        self.set_flags_add(a, (~b) & 0xFFFFFFFFFFFFFFFF, 1)

    def cond(self, cc):
        n, z, c, v = self.get_flags()
        t = {
            0: z == 1,                    # EQ
            1: z == 0,                    # NE
            2: c == 1,                    # CS/HS
            3: c == 0,                    # CC/LO
            4: n == 1,                    # MI
            5: n == 0,                    # PL
            6: v == 1,                    # VS
            7: v == 0,                    # VC
            8: c == 1 and z == 0,         # HI
            9: c == 0 or z == 1,          # LS
            10: n == v,                   # GE
            11: n != v,                   # LT
            12: z == 0 and n == v,        # GT
            13: z == 1 or n != v,         # LE
            14: True,                     # AL
            15: False,
        }
        return t.get(cc, False)

    # ---- float helpers ----
    def f32(self, r):
        return struct.unpack('<f', struct.pack('<I', self.v[r] & 0xFFFFFFFF))[0]

    def set_f32(self, r, val):
        try:
            self.v[r] = struct.unpack('<I', struct.pack('<f', val))[0]
        except OverflowError:
            # IEEE 754 overflow rounds to infinity, like real hardware
            self.v[r] = 0x7F800000 if val > 0 else 0xFF800000

    def f64(self, r):
        return struct.unpack('<d', struct.pack('<Q', self.v[r]))[0]

    def set_f64(self, r, val):
        self.v[r] = struct.unpack('<Q', struct.pack('<d', val))[0]

    # ---- ELF loading ----
    def load(self, path):
        data = open(path, 'rb').read()
        assert data[:4] == b'\x7fELF', 'not an ELF'
        e_type, e_machine = struct.unpack_from('<HH', data, 16)
        assert e_machine == 183, 'not AArch64 (e_machine=%d)' % e_machine
        e_entry = struct.unpack_from('<Q', data, 24)[0]
        e_phoff = struct.unpack_from('<Q', data, 32)[0]
        e_phnum = struct.unpack_from('<H', data, 56)[0]
        for i in range(e_phnum):
            off = e_phoff + i * 56
            p_type, p_flags = struct.unpack_from('<II', data, off)
            p_offset, p_vaddr, p_paddr, p_filesz, p_memsz = struct.unpack_from('<QQQQQ', data, off + 8)
            if p_type != 1:
                continue
            self.write(p_vaddr, data[p_offset:p_offset + p_filesz])
            if p_memsz > p_filesz:
                self.write(p_vaddr + p_filesz, b'\0' * (p_memsz - p_filesz))
        # stack: [sp]=argc, [sp+8..]=argv pointers, NULL, envp NULL
        sp = STACK_TOP - STACK_SIZE
        argv_addrs = []
        for a in [path] + self.argv:
            b = a.encode() + b'\0'
            sp -= len(b)
            sp &= ~7
            self.write(sp, b)
            argv_addrs.append(sp)
        # align DOWN to 16 BEFORE laying out the vector
        sp -= 64
        sp &= ~15
        vec = struct.pack('<Q', len(argv_addrs))
        for a in argv_addrs:
            vec += struct.pack('<Q', a)
        vec += struct.pack('<Q', 0)   # argv terminator
        vec += struct.pack('<Q', 0)   # envp terminator
        sp -= len(vec)
        sp &= ~15
        self.write(sp, vec)
        self.set_sp(sp)
        self.pc = e_entry

    # ---- syscalls ----
    def syscall(self):
        nr = self.x[8]
        a = [self.x[i] for i in range(6)]
        if self.verbose:
            sys.stderr.write('[svc %d] x0=%x x1=%x x2=%x pc=%x\n' % (nr, a[0], a[1], a[2], self.pc))
        if nr == 93:      # exit
            self.exit_code = a[0] & 0xFF if a[0] < 256 else a[0]
            return False
        if nr == 64:      # write
            fd, buf, count = a[0], a[1], a[2]
            data = self.read(buf, count)
            if fd == 1:
                self.out += data
                if not self.verbose:
                    sys.stdout.buffer.write(data)
                    sys.stdout.buffer.flush()
                self.x[0] = count
            elif fd == 2:
                sys.stderr.buffer.write(data)
                sys.stderr.buffer.flush()
                self.x[0] = count
            elif fd in self.files:
                self.files[fd].write(data)
                self.x[0] = count
            else:
                self.x[0] = -9 & 0xFFFFFFFFFFFFFFFF
            return True
        if nr == 63:      # read
            fd, buf, count = a[0], a[1], a[2]
            if fd in self.files:
                data = self.files[fd].read(count)
                self.write(buf, data)
                self.x[0] = len(data)
            else:
                self.x[0] = -9 & 0xFFFFFFFFFFFFFFFF
            return True
        if nr == 56:      # openat
            dirfd, pathp, flags, mode = a[0], a[1], a[2], a[3]
            # path = NUL-terminated
            path = b''
            p = pathp
            while True:
                c = self.read(p, 1)
                if c == b'\0' or len(path) > 4096:
                    break
                path += c
                p += 1
            try:
                fname = path.decode()
                base = fname.split('/')[-1]
                if flags & 0o100:  # O_CREAT? crude: treat O_WRONLY|O_CREAT|O_TRUNC as write-mode
                    self.files[self.fd_counter] = open(fname, 'wb')
                    self.x[0] = self.fd_counter
                    self.fd_counter += 1
                else:
                    self.files[self.fd_counter] = open(fname, 'rb')
                    self.x[0] = self.fd_counter
                    self.fd_counter += 1
            except OSError as e:
                # Linux returns -errno, not +errno
                self.x[0] = (-(e.errno or 2)) & 0xFFFFFFFFFFFFFFFF
            return True
        if nr == 57:      # close
            fd = a[0]
            if fd > 2 and fd in self.files:
                self.files[fd].close()
                del self.files[fd]
            self.x[0] = 0
            return True
        if nr == 80:      # newfstatat(dirfd, pathname, buf, flags)
            import os
            dirfd, pathp, statp, eflags = a[0], a[1], a[2], a[3]
            # path = NUL-terminated
            path = b''
            p = pathp
            while True:
                c = self.read(p, 1)
                if c == b'\0' or len(path) > 4096:
                    break
                path += c
                p += 1
            try:
                if (eflags & 0x1000) and path == b'':
                    # AT_EMPTY_PATH: stat the descriptor itself
                    f = self.files.get(dirfd)
                    if f is None or not hasattr(f, 'fileno'):
                        st = os.fstat(dirfd)
                    else:
                        st = os.fstat(f.fileno())
                else:
                    fname = path.decode()
                    if not fname.startswith('/') and dirfd != -100:
                        # relative to dirfd: emulate via /proc/<pid>/fd
                        base = os.readlink('/proc/self/fd/%d' % dirfd)
                        fname = base + '/' + fname
                    st = os.stat(fname)
                # aarch64 struct stat: dev@0 ino@8 mode@16 nlink@20 uid@24 gid@28 rdev@32 pad@40 size@48
                self.write(statp + 0, struct.pack('<Q', st.st_dev & 0xFFFFFFFFFFFFFFFF))
                self.write(statp + 8, struct.pack('<Q', st.st_ino & 0xFFFFFFFFFFFFFFFF))
                self.write(statp + 16, struct.pack('<I', st.st_mode))
                self.write(statp + 20, struct.pack('<I', st.st_nlink))
                self.write(statp + 24, struct.pack('<I', st.st_uid))
                self.write(statp + 28, struct.pack('<I', st.st_gid))
                self.write(statp + 32, struct.pack('<Q', st.st_rdev & 0xFFFFFFFFFFFFFFFF))
                self.write(statp + 48, struct.pack('<q', st.st_size))
                self.x[0] = 0
            except OSError as e:
                self.x[0] = (-(e.errno or 2)) & 0xFFFFFFFFFFFFFFFF
            return True
        if nr == 222:     # mmap
            addr, length = a[0], a[1]
            base = self.mmap_next
            self.mmap_next += (length + PAGE - 1) // PAGE * PAGE + PAGE
            self.x[0] = base
            return True
        if nr == 53:      # fchmodat(dirfd, path, mode, flags)
            pathp = a[1]
            mode = a[2] & 0o7777
            path = b''
            p = pathp
            while True:
                c = self.read(p, 1)
                if c == b'\0' or len(path) > 4096:
                    break
                path += c
                p += 1
            try:
                import os
                os.chmod(path.decode(), mode)
                self.x[0] = 0
            except OSError as e:
                self.x[0] = (-(e.errno or 2)) & 0xFFFFFFFFFFFFFFFF
            return True
        if nr == 34:      # mkdirat
            pathp = a[1]
            path = b''
            p = pathp
            while True:
                c = self.read(p, 1)
                if c == b'\0':
                    break
                path += c
                p += 1
            try:
                import os
                os.mkdir(path.decode(), 0o777)
                self.x[0] = 0
            except OSError as e:
                self.x[0] = (e.errno or 2) & 0xFFFFFFFFFFFFFFFF
            return True
        if nr == 61:      # getdents64
            fd, buf, count = a[0], a[1], a[2]
            f = self.files.get(fd)
            if f is None or not hasattr(f, 'fileno'):
                self.x[0] = -1 & 0xFFFFFFFFFFFFFFFF
                return True
            import os
            import ctypes
            import ctypes.util
            # use os.scandir to synthesize getdents64 records
            if not hasattr(f, '_dent_cache'):
                try:
                    f._dent_cache = list(os.scandir(f.name))
                except OSError:
                    f._dent_cache = []
                f._dent_pos = 0
            total = 0
            while f._dent_pos < len(f._dent_cache):
                e = f._dent_cache[f._dent_pos]
                name = e.name.encode() + b'\0'
                dtype = 4 if e.is_dir() else 8
                reclen = 19 + len(name)
                reclen = (reclen + 7) & ~7
                rec = struct.pack('<QQHHB', e.stat(follow_symlinks=False).st_ino or 1,
                                  0, reclen, dtype, 0) if False else None
                # ino(8) off(8) reclen(2) type(1) name...
                rec = struct.pack('<QQHB', e.stat(follow_symlinks=False).st_ino or 1,
                                  0, reclen, dtype) + name
                rec += b'\0' * (reclen - len(rec))
                if total + reclen > count:
                    break
                self.write(buf + total, rec)
                total += reclen
                f._dent_pos += 1
            self.x[0] = total
            return True
        raise RuntimeError('unimplemented syscall %d' % nr)

    # ---- execution ----
    def step(self):
        insn = self.rd32(self.pc)
        if insn == 0:
            raise RuntimeError('hit zero instruction at %x' % self.pc)
        self.pc += 4
        self.decode(insn)

    def decode(self, op):
        # fixed pair forms used by the prologue/epilogue
        if op == 0xA9BF7BFD:      # stp x29, x30, [sp, #-16]!
            sp = self.sp() - 16
            self.set_sp(sp)
            self.wr64(sp, self.x[29])
            self.wr64(sp + 8, self.x[30])
            return
        if op == 0xA8C17BFD:      # ldp x29, x30, [sp], #16
            sp = self.sp()
            self.x[29] = self.rd64(sp)
            self.x[30] = self.rd64(sp + 8)
            self.set_sp(sp + 16)
            return
        # general pre/post-index pair decode (STP/LDP 64-bit pre/post)
        if (op >> 25) == 0x54 and ((op >> 23) & 1) == 1:
            # bits[31:25] = 1010100: pair, 64-bit, pre/post index
            is_load = (op >> 22) & 1
            imm7 = (op >> 15) & 0x7F
            if imm7 & (1 << 6):
                imm7 -= 1 << 7
            off = imm7 * 8
            post = ((op >> 23) & 3) == 0b10  # bits 24-23 == 01/11? post: bit23=0? use the x1 pattern
            rt2 = (op >> 10) & 0x1F
            rn = (op >> 5) & 0x1F
            rt = op & 0x1F
            # pre-index: bits 24..23 = 11; post-index: 01; unsigned: 10
            mode = (op >> 23) & 3
            base = self.x[rn]
            if mode == 0b11:      # pre-index
                addr = (base + off) & 0xFFFFFFFFFFFFFFFF
                self.x[rn] = addr
                if is_load:
                    self.x[rt] = self.rd64(addr)
                    self.x[rt2] = self.rd64(addr + 8)
                else:
                    self.wr64(addr, self.x[rt])
                    self.wr64(addr + 8, self.x[rt2])
                return
            if mode == 0b01:      # post-index
                if is_load:
                    self.x[rt] = self.rd64(base)
                    self.x[rt2] = self.rd64(base + 8)
                else:
                    self.wr64(base, self.x[rt])
                    self.wr64(base + 8, self.x[rt2])
                self.x[rn] = (base + off) & 0xFFFFFFFFFFFFFFFF
                return
            # signed-offset pair: mode 0b10
            addr = (base + off) & 0xFFFFFFFFFFFFFFFF
            if is_load:
                self.x[rt] = self.rd64(addr)
                self.x[rt2] = self.rd64(addr + 8)
            else:
                self.wr64(addr, self.x[rt])
                self.wr64(addr + 8, self.x[rt2])
            return
        top = op >> 24

        # exceptions
        if top == 0xD4:
            if op == 0xD4000001:      # SVC #0
                self.syscall()
            else:
                raise RuntimeError('unknown exception op %08x' % op)
            return

        # B / BL
        if (op >> 26) in (0x05, 0x25):
            imm26 = op & 0x3FFFFFF
            if imm26 & (1 << 25):
                imm26 -= 1 << 26
            if (op >> 26) == 0x25:    # BL
                self.x[30] = self.pc
            self.pc = (self.pc + imm26 * 4) & 0xFFFFFFFFFFFFFFFF
            return

        # B.cond
        if top == 0x54:
            imm19 = (op >> 5) & 0x7FFFF
            if imm19 & (1 << 18):
                imm19 -= 1 << 19
            if self.cond(op & 0xF):
                self.pc = (self.pc + imm19 * 4) & 0xFFFFFFFFFFFFFFFF
            return

        # CBZ / CBNZ
        if top in (0x34, 0x35, 0xB4, 0xB5):
            imm19 = (op >> 5) & 0x7FFFF
            if imm19 & (1 << 18):
                imm19 -= 1 << 19
            rt = op & 0x1F
            val = self.x[rt]
            if top < 0x80:
                val &= 0xFFFFFFFF
            taken = (val == 0) if (top & 1) == 0 else (val != 0)
            if taken:
                self.pc = (self.pc + imm19 * 4) & 0xFFFFFFFFFFFFFFFF
            return

        # unconditional branch register (RET etc.)
        if top == 0xD6:
            if op == 0xD65F03C0:      # RET
                self.pc = self.x[30]
                return
            raise RuntimeError('unknown br op %08x' % op)

        # ---- loads/stores: op[29:27] = 111, op[25] = 0 ----
        if (op >> 27) & 0x7 == 0x7 and ((op >> 25) & 1) == 0:
            self.loadstore(op)
            return

        # ---- data processing (immediate) ----
        if (op >> 23) & 0x1FF in (0b10001_0000 >> 4,):
            pass
        # ADD/SUB imm: op[28:24] = x10001
        if (op >> 24) & 0x1F == 0x11 or (op >> 24) & 0x1F == 0x1B and False:
            pass
        if ((op >> 24) & 0x7F) in (0x11, 0x31, 0x51, 0x71, 0x91, 0xB1, 0xD1, 0xF1):
            self.addsub_imm(op)
            return
        # move wide (MOVN/MOVZ/MOVK): op[28:23] = 100101
        if (op >> 23) & 0x3F == 0b100101 or (op >> 23) & 0x3F == 0b000101:
            self.movewide(op)
            return
        # logical immediate: op[28:23] = 100100 — not emitted; fall through to error

        # ---- data processing (register) ----
        # logical shifted: 32-bit 0x0A/0x2A/0x4A/0x6A, 64-bit 0x8A/0xAA/0xCA/0xEA
        if top in (0x0A, 0x2A, 0x4A, 0x6A, 0x8A, 0xAA, 0xCA, 0xEA):
            self.dp_reg_logical(op)
            return
        # arithmetic shifted: 32-bit 0x0B/0x2B/0x4B/0x6B, 64-bit 0x8B/0xAB/0xCB/0xEB
        if top in (0x0B, 0x2B, 0x4B, 0x6B, 0x8B, 0xAB, 0xCB, 0xEB):
            self.dp_reg_arith(op)
            return
        # MADD/MSUB: 0x1B/0x9B with op[21]=0 and op[15:10] != div/shift forms
        if top in (0x1B, 0x9B):
            self.dp_reg_3src(op)
            return
        # 2-source (div/shifts) vs cond-select: bit 22 discriminates
        # (2-source has bit 22 = 1; conditional select has bit 22 = 0)
        if top in (0x1A, 0x9A):
            if ((op >> 22) & 1) == 1:
                self.dp_reg_2src(op)
            else:
                self.cond_select(op)
            return

        # ---- SIMD/FP: op[28:24] = 01110 ----
        if (op >> 24) & 0x1F == 0x0E or top in (0x1E, 0x5E, 0x9E, 0xDE):
            self.simd(op)
            return

        raise RuntimeError('unknown instruction %08x at %x' % (op, self.pc - 4))

    def movewide(self, op):
        is64 = (op >> 31) & 1
        opc = (op >> 29) & 3
        hw = (op >> 21) & 3
        imm16 = (op >> 5) & 0xFFFF
        rd = op & 0x1F
        val = imm16 << (hw * 16)
        if opc == 0:    # MOVN
            val = (~val) & (0xFFFFFFFFFFFFFFFF if is64 else 0xFFFFFFFF)
        elif opc == 3:  # MOVK keeps other bits
            old = self.x[rd]
            mask = 0xFFFF << (hw * 16)
            val = (old & ~mask & (0xFFFFFFFFFFFFFFFF if is64 else 0xFFFFFFFF)) | val
        if rd != 31:
            self.x[rd] = val if is64 else val & 0xFFFFFFFF

    def dp_reg_logical(self, op):
        is64 = (op >> 31) & 1
        N = (op >> 21) & 1
        opc = (op >> 29) & 3
        rm = (op >> 16) & 0x1F
        imm6 = (op >> 10) & 0x3F
        rn = (op >> 5) & 0x1F
        rd = op & 0x1F
        shift = (op >> 22) & 3
        mask = 0xFFFFFFFFFFFFFFFF if is64 else 0xFFFFFFFF
        a = self.reg_xzr(rn) & mask
        b = self.reg_xzr(rm) & mask
        if shift == 0:
            b = (b << imm6) & mask
        elif shift == 1:
            b = b >> imm6
        elif shift == 2:
            sa = b - (1 << (64 if is64 else 32)) if b & (1 << ((64 if is64 else 32) - 1)) else b
            b = (sa >> imm6) & mask
        else:
            b = ((b >> imm6) | (b << ((64 if is64 else 32) - imm6))) & mask if imm6 else b
        nb = (~b) & mask
        key = (opc << 1) | N
        r = {0b000: a & b, 0b001: a & nb, 0b010: a | b, 0b011: a | nb,
             0b100: a ^ b, 0b101: a ^ nb, 0b110: a & b, 0b111: a & b}[key]
        if key == 0b110:      # ANDS
            self.set_flags_logic(r)
        if rd != 31:
            self.x[rd] = r

    def dp_reg_arith(self, op):
        is64 = (op >> 31) & 1
        opc = (op >> 29) & 3
        rm = (op >> 16) & 0x1F
        imm6 = (op >> 10) & 0x3F
        rn = (op >> 5) & 0x1F
        rd = op & 0x1F
        shift = (op >> 22) & 3
        mask = 0xFFFFFFFFFFFFFFFF if is64 else 0xFFFFFFFF
        a = self.reg_xzr(rn) & mask
        b = self.reg_xzr(rm) & mask
        if shift == 0:
            b = (b << imm6) & mask
        elif shift == 1:
            b = b >> imm6
        elif shift == 2:
            sa = b - (1 << (64 if is64 else 32)) if b & (1 << ((64 if is64 else 32) - 1)) else b
            b = (sa >> imm6) & mask
        if opc == 0b00:   # ADD
            r = (a + b) & mask
        elif opc == 0b10: # SUB
            r = (a - b) & mask
        elif opc == 0b01: # ADDS
            r = (a + b) & mask
            self.set_flags_add(a, b)
        else:              # SUBS
            r = (a - b) & mask
            self.set_flags_sub(a, b)
        if rd != 31:
            self.x[rd] = r

    def dp_reg_3src(self, op):
        # MADD/MSUB (MUL is MADD with Ra=XZR): selector o0 at bit 15
        o1 = (op >> 15) & 1
        rm = (op >> 16) & 0x1F
        ra = (op >> 10) & 0x1F
        rn = (op >> 5) & 0x1F
        rd = op & 0x1F
        is64 = (op >> 31) & 1
        mask = 0xFFFFFFFFFFFFFFFF if is64 else 0xFFFFFFFF
        a = self.reg_xzr(rn) & mask
        b = self.reg_xzr(rm) & mask
        c = self.reg_xzr(ra) & mask
        r = ((a * b + c) if o1 == 0 else (c - a * b)) & mask
        if rd != 31:
            self.x[rd] = r

    def dp_reg_2src(self, op):
        rm = (op >> 16) & 0x1F
        rn = (op >> 5) & 0x1F
        rd = op & 0x1F
        is64 = (op >> 31) & 1
        bits = 64 if is64 else 32
        mask = (1 << bits) - 1
        op2 = (op >> 10) & 0x3F
        a = self.reg_xzr(rn) & mask
        sh = self.reg_xzr(rm) & 0x3F
        if op2 == 0x08:   # LSLV
            r = (a << sh) & mask if sh < bits else 0
        elif op2 == 0x09: # LSRV
            r = a >> sh if sh < bits else 0
        elif op2 == 0x0A: # ASRV
            sa = a - (1 << bits) if a & (1 << (bits - 1)) else a
            r = (sa >> min(sh, bits - 1)) & mask
        elif op2 == 0x0B: # RORV
            r = ((a >> sh) | (a << (bits - sh))) & mask if sh % bits else a
            r &= mask
        elif op2 == 0x02: # UDIV
            bv = self.reg_xzr(rm) & mask
            r = (a // bv) & mask if bv else 0
        elif op2 == 0x03: # SDIV
            b = self.reg_xzr(rm) & mask
            if b == 0:
                r = 0
            else:
                sa = a - (1 << bits) if a & (1 << (bits - 1)) else a
                sb = b - (1 << bits) if b & (1 << (bits - 1)) else b
                q = abs(sa) // abs(sb)
                if (sa < 0) != (sb < 0):
                    q = -q
                r = q & mask
        else:
            raise RuntimeError('unknown 2src op2 %x (%08x)' % (op2, op))
        if rd != 31:
            self.x[rd] = r

    def reg_xzr(self, r):
        # register 31 is XZR (zero) in data-processing ops
        return 0 if r == 31 else self.x[r]

    def cond_select(self, op):
        rm = (op >> 16) & 0x1F
        cond = (op >> 12) & 0xF
        op2 = (op >> 10) & 3
        rn = (op >> 5) & 0x1F
        rd = op & 0x1F
        is64 = (op >> 31) & 1
        mask = 0xFFFFFFFFFFFFFFFF if is64 else 0xFFFFFFFF
        a = self.reg_xzr(rn) & mask
        b = self.reg_xzr(rm) & mask
        if self.cond(cond):
            r = a
        elif op2 == 0:    # CSEL
            r = b
        elif op2 == 1:    # CSINC
            r = (b + 1) & mask
        elif op2 == 2:    # CSINV
            r = (~b) & mask
        else:             # CSNEG
            r = (-b) & mask
        if rd != 31:
            self.x[rd] = r

    def addsub_imm(self, op):
        is64 = (op >> 31) & 1
        sf = is64
        sets = ((op >> 29) & 1) == 1
        is_sub = ((op >> 30) & 1) == 1
        sh = (op >> 22) & 1
        imm12 = (op >> 10) & 0xFFF
        rn = (op >> 5) & 0x1F
        rd = op & 0x1F
        imm = imm12 << (12 if sh else 0)
        a = self.x[rn]
        if not is64:
            a &= 0xFFFFFFFF
        b = imm
        if is_sub:
            r = (a - b) & (0xFFFFFFFFFFFFFFFF if is64 else 0xFFFFFFFF)
            if sets:
                self.set_flags_sub(a, b)
        else:
            r = (a + b) & (0xFFFFFFFFFFFFFFFF if is64 else 0xFFFFFFFF)
            if sets:
                self.set_flags_add(a, b)
        # Rd=31: SP for plain ADD/SUB, XZR (discard) for the flag-setting forms
        if not (sets and rd == 31):
            self.x[rd] = r if is64 else (r & 0xFFFFFFFF)

    def loadstore(self, op):
        size = (op >> 30) & 3
        opc = (op >> 22) & 3
        V = (op >> 26) & 1
        imm12 = (op >> 10) & 0xFFF
        rn = (op >> 5) & 0x1F
        rt = op & 0x1F
        base = self.x[rn]
        # register-offset form: bit 21 set, Rm at 20:16, option 15:13, S 12
        if ((op >> 21) & 1) == 1 and ((op >> 27) & 7) == 7 and ((op >> 25) & 1) == 0 and ((op >> 24) & 1) == 0:
            rm = (op >> 16) & 0x1F
            option = (op >> 13) & 7
            S = (op >> 12) & 1
            offreg = self.x[rm]
            scale = size
            if S == 0:
                scale = 0
            addr = (base + (offreg << scale)) & 0xFFFFFFFFFFFFFFFF
            if V == 0:
                if size == 0 and opc == 1:   # LDRB Wt, [Xn, Xm]
                    self.x[rt] = self.read(addr, 1)[0]
                elif size == 3 and opc == 1:  # LDR Xt, [Xn, Xm]
                    self.x[rt] = self.rd64(addr)
                elif size == 3 and opc == 0:  # STR Xt, [Xn, Xm]
                    self.wr64(addr, 0 if rt == 31 else self.x[rt])
                elif size == 0 and opc == 0:  # STRB Wt, [Xn, Xm]
                    self.write(addr, bytes([0 if rt == 31 else self.x[rt] & 0xFF]))
                else:
                    raise RuntimeError('unknown reg-offset loadstore %08x' % op)
            else:
                if opc == 1:  # LDR Dt/St, [Xn, Xm]
                    self.v[rt] = self.rd64(addr)
                else:
                    self.wr64(addr, self.v[rt])
            return
        if size == 3 and V == 0 and opc in (0, 1):
            off = imm12 * 8
            addr = base + off
            if opc == 0:   # STR X (Rt=31 = XZR = zero)
                self.wr64(addr, 0 if rt == 31 else self.x[rt])
            else:           # LDR X
                self.x[rt] = self.rd64(addr)
            return
        if size == 2 and V == 0 and opc in (0, 1):
            off = imm12 * 4
            addr = base + off
            if opc == 0:   # STR W
                self.wr32(addr, 0 if rt == 31 else self.x[rt] & 0xFFFFFFFF)
            else:           # LDR W (zero-extend)
                self.x[rt] = self.rd32(addr)
            return
        if size == 0 and V == 0:
            off = imm12
            addr = base + off
            if opc == 0:   # STRB (Rt=31 = WZR = zero)
                self.write(addr, bytes([0 if rt == 31 else self.x[rt] & 0xFF]))
            elif opc == 1:  # LDRB
                self.x[rt] = self.read(addr, 1)[0]
            elif opc == 2:  # LDRSB (64)
                v = self.read(addr, 1)[0]
                self.x[rt] = v - 256 if v & 0x80 else v
            else:           # LDRSB (32)
                v = self.read(addr, 1)[0]
                self.x[rt] = (v - 256 if v & 0x80 else v) & 0xFFFFFFFF
            return
        if size == 1 and V == 0:
            off = imm12 * 2
            addr = base + off
            if opc == 0:   # STRH
                self.write(addr, struct.pack('<H', self.x[rt] & 0xFFFF))
            elif opc == 1:  # LDRH
                self.x[rt] = struct.unpack('<H', self.read(addr, 2))[0]
            elif opc == 2:  # LDRSH 64
                v = struct.unpack('<H', self.read(addr, 2))[0]
                self.x[rt] = v - 0x10000 if v & 0x8000 else v
            else:
                v = struct.unpack('<H', self.read(addr, 2))[0]
                self.x[rt] = (v - 0x10000 if v & 0x8000 else v) & 0xFFFFFFFF
            return
        if size == 2 and V == 0 and opc == 2:  # LDRSW
            off = imm12 * 4
            addr = base + off
            v = struct.unpack('<i', struct.pack('<I', self.rd32(addr)))[0]
            self.x[rt] = v & 0xFFFFFFFFFFFFFFFF
            return
        if V == 1:  # SIMD LDR/STR
            off = imm12 * (8 if size == 3 else 4)
            addr = base + off
            if opc == 0:   # STR (S/D)
                self.wr64(addr, self.v[rt])
            else:           # LDR
                self.v[rt] = self.rd64(addr)
            return
        raise RuntimeError('unknown loadstore %08x at %x' % (op, self.pc - 4))

    def simd(self, op):
        rmode = (op >> 19) & 3
        opcode = (op >> 12) & 0xF
        rn = (op >> 5) & 0x1F
        rd = op & 0x1F
        typ = (op >> 22) & 3     # 00 = S (32-bit), 01 = D (64-bit)
        is_d = typ == 1
        rm = (op >> 16) & 0x1F
        bit21 = (op >> 21) & 1
        import math

        # exact-match single forms first
        exact = {
            0x1E204000: 'fmov_ss', 0x1E604000: 'fmov_dd',
            0x1E270000: 'fmov_sw', 0x1E260000: 'fmov_ws',
            0x9E670000: 'fmov_dx', 0x9E660000: 'fmov_xd',
            0x1E624000: 'fcvt_sd', 0x1E22C000: 'fcvt_ds',
        }
        for base, name in exact.items():
            if (op & 0xFFFFFC00) == base:
                if name == 'fmov_ss':
                    self.v[rd] = self.v[rn] & 0xFFFFFFFF
                elif name == 'fmov_dd':
                    self.v[rd] = self.v[rn]
                elif name == 'fmov_sw':
                    self.v[rd] = self.x[rn] & 0xFFFFFFFF
                elif name == 'fmov_ws':
                    self.x[rd] = self.v[rn] & 0xFFFFFFFF
                elif name == 'fmov_dx':
                    self.v[rd] = self.x[rn]
                elif name == 'fmov_xd':
                    self.x[rd] = self.v[rn]
                elif name == 'fcvt_sd':
                    self.set_f32(rd, self.f64(rn))
                else:
                    self.set_f64(rd, self.f32(rn))
                return

        # FCMP: skeleton (Rm/Rn/op bits masked) 0x1E202000 (S) / 0x1E602000 (D)
        skel = op & ~((0x1F << 16) | (0x1F << 5) | (7 << 3))
        if skel == (0x1E202000 if not is_d else 0x1E602000):
            a = (self.f64 if is_d else self.f32)(rn)
            b = (self.f64 if is_d else self.f32)(rm)
            if math.isnan(a) or math.isnan(b):
                # NaN: NZCV = 0011 (N=0 Z=0 C=1 V=1)
                self.nzcv = (1 << 29) | (1 << 28)
            elif a == b:
                self.nzcv = (1 << 30) | (1 << 29)   # Z + C
            elif a < b:
                self.nzcv = (1 << 31)               # N=1, V=0 -> LT true
            else:
                self.nzcv = (1 << 29)               # C=1 -> GT/GE
            return

        # FNEG / FABS: opcode 0001 (FMOV reg) / 0010 (FABS) / 0101?? — FNEG = opcode 0101 bit21=0? no:
        # FABS: 0001 1110 001 0000 011 0000 0 Rn Rd = 0x1E20C000 base? hmm: FABS S: 0x1E20C000; FNEG S: 0x1E214000
        if (op & 0xFFFFFC00) in (0x1E20C000, 0x1E60C000):  # FABS
            self.do_unop(is_d, rd, rn, abs)
            return
        if (op & 0xFFFFFC00) in (0x1E214000, 0x1E614000):  # FNEG
            self.do_unop(is_d, rd, rn, lambda z: -z)
            return
        if rmode == 0 and opcode == 0b0001 and bit21 == 0:
            # FMOV register (S or D)
            if is_d:
                self.v[rd] = self.v[rn]
            else:
                self.v[rd] = self.v[rn] & 0xFFFFFFFF
            return

        # three-operand arithmetic: opc6 at bits 15:10
        # fadd=0x0A fsub=0x0E fmul=0x02 fdiv=0x06 (capstone-verified layout)
        opc6 = (op >> 10) & 0x3F
        if opc6 == 0x0A:
            self.do_binop(is_d, rd, rn, rm, lambda x, y: x + y)
            return
        if opc6 == 0x0E:
            self.do_binop(is_d, rd, rn, rm, lambda x, y: x - y)
            return
        if opc6 == 0x02:
            self.do_binop(is_d, rd, rn, rm, lambda x, y: x * y)
            return
        if opc6 == 0x06:
            def ddiv(x, y):
                import math
                if y == 0:
                    if x == 0 or math.isnan(x):
                        return float('nan')
                    return float('-inf') if (x < 0) != (math.copysign(1, y) < 0) else float('inf')
                return x / y
            self.do_binop(is_d, rd, rn, rm, ddiv)
            return

        # conversions
        # SCVTF: bases 0x1E220000 (S,W) 0x9E220000 (S,X) 0x1E620000 (D,W) 0x9E620000 (D,X)
        for base, to_d, to64 in ((0x1E220000, False, False), (0x9E220000, False, True),
                                 (0x1E620000, True, False), (0x9E620000, True, True)):
            if (op & 0xFFFFF000) == base:
                if to64:
                    val = struct.unpack('<q', struct.pack('<Q', self.x[rn]))[0]
                else:
                    val = struct.unpack('<i', struct.pack('<I', self.x[rn] & 0xFFFFFFFF))[0]
                if to_d:
                    self.set_f64(rd, float(val))
                else:
                    self.set_f32(rd, float(val))
                return
        # UCVTF: bases with opcode bit set: 0x1E230000 etc.
        for base, to_d, to64 in ((0x1E230000, False, False), (0x9E230000, False, True),
                                 (0x1E630000, True, False), (0x9E630000, True, True)):
            if (op & 0xFFFFF000) == base:
                if to64:
                    val = self.x[rn]
                else:
                    val = self.x[rn] & 0xFFFFFFFF
                if to_d:
                    self.set_f64(rd, float(val))
                else:
                    self.set_f32(rd, float(val))
                return
        # FCVTZS: 0x1E380000 (W<-S) 0x9E380000 (X<-S) 0x1E780000 (W<-D) 0x9E780000 (X<-D)
        for base, from_d, to64 in ((0x1E380000, False, False), (0x9E380000, False, True),
                                   (0x1E780000, True, False), (0x9E780000, True, True)):
            if (op & 0xFFFFF000) == base:
                fv = (self.f64 if from_d else self.f32)(rn)
                if math.isnan(fv):
                    iv = 0
                elif math.isinf(fv):
                    iv = (1 << 63) - 1 if fv > 0 else -(1 << 63) if to64 else ((1 << 31) - 1 if fv > 0 else -(1 << 31))
                else:
                    iv = int(fv)
                    if to64:
                        iv = max(-(1 << 63), min((1 << 63) - 1, iv))
                    else:
                        iv = max(-(1 << 31), min((1 << 31) - 1, iv))
                self.x[rd] = iv & (0xFFFFFFFFFFFFFFFF if to64 else 0xFFFFFFFF)
                return
        # FCVTZU: 0x1E390000 etc.
        for base, from_d, to64 in ((0x1E390000, False, False), (0x9E390000, False, True),
                                   (0x1E790000, True, False), (0x9E790000, True, True)):
            if (op & 0xFFFFF000) == base:
                fv = (self.f64 if from_d else self.f32)(rn)
                if math.isnan(fv):
                    iv = 0
                elif math.isinf(fv):
                    iv = (1 << (64 if to64 else 32)) - 1 if fv > 0 else 0
                else:
                    iv = max(0, int(fv))
                    if to64:
                        iv = min((1 << 64) - 1, iv)
                    else:
                        iv = min((1 << 32) - 1, iv)
                self.x[rd] = iv & (0xFFFFFFFFFFFFFFFF if to64 else 0xFFFFFFFF)
                return

        raise RuntimeError('unknown simd %08x at %x' % (op, self.pc - 4))

    def do_unop(self, is_d, rd, rn, fn):
        if is_d:
            self.set_f64(rd, fn(self.f64(rn)))
        else:
            self.set_f32(rd, fn(self.f32(rn)))

    def do_binop(self, is_d, rd, rn, rm, fn):
        if is_d:
            a, b = self.f64(rn), self.f64(rm)
            self.set_f64(rd, fn(a, b))
        else:
            a, b = self.f32(rn), self.f32(rm)
            self.set_f32(rd, fn(a, b))

    def run(self, max_steps=None):
        import os
        if max_steps is None:
            max_steps = int(os.environ.get('EMU_MAXSTEPS', '400000000'))
        steps = 0
        trace = os.environ.get('EMU_TRACE', '')
        trace_from = int(trace) if trace else None
        trace_n = 0
        while self.exit_code is None:
            if trace_from is not None and steps >= trace_from and trace_n < 400:
                sys.stderr.write('%08x: %08x  x0=%x x1=%x x2=%x sp=%x\n' % (
                    self.pc, self.rd32(self.pc), self.x[0], self.x[1], self.x[2], self.sp()))
                trace_n += 1
            self.step()
            steps += 1
            if steps > max_steps:
                raise RuntimeError('step limit exceeded (infinite loop?) pc=%x' % self.pc)
        return self.exit_code


def main():
    args = sys.argv[1:]
    verbose = '-v' in args
    args = [a for a in args if a != '-v']
    if not args:
        print(__doc__)
        return 2
    emu = Emu()
    emu.verbose = verbose
    emu.argv = args[1:]
    emu.load(args[0])
    code = emu.run()
    return code


if __name__ == '__main__':
    sys.exit(main())
