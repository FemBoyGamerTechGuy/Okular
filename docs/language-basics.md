# Okular Language Basics (0.11)

A tour of what Okular 0.11 does today. The specification
(`specs/spec-v0.11.md`) is the source of truth; this page is the friendly
version. Everything shown here compiles and runs with the bootstrap
compiler.

## Programs

A program is a project directory rooted at `main.ok`. The top-level
statements of `main.ok` **are** the program body:

```ok
type.text=1

type.number count = 0
loop (i from 1 until 11) {
    count = count + i
}
write("1+2+...+10 = ")
write(count)
print

return 0        # top-level return sets the exit code
```

## Variables and types

Declarations read `type.<T> name = initializer` — and initialization is
always required (no silent defaults):

```ok
type.number age = 18          # 64-bit signed integer (the default integer)
type.decimal height = 1.82    # IEEE-754 binary64 (the default float)
type.text name = "Alex"       # immutable UTF-8 text
type.bool active = true       # true / false

type.int8 tiny = -100         # fixed-width integers (0.3)
type.uint8 mask = 0xFF        # byte is an alias of uint8
type.uint16 port = 443
type.uint32 flags = 0x8000_0000
type.uint64 huge = 18446744073709551615
type.int64 same_as_number = 1 # aliases; f64 = decimal
```

Fixed-width arithmetic **wraps** (`int8 127 + 1` is `-128`; `uint8 255 + 1`
is `0`), comparisons use the type's signedness, and division by zero is a
runtime trap. Conversions are explicit builtins — `number.to_uint8(300)` is
`44`, `decimal.to_int32(3.99)` is `3`, `number.to_text(42)` is `"42"`,
`text.to_number("123")` is `123` — and constants fold at compile time.

Assignment widens safely and silently (`int8` → `number`, `uint8` →
`int16`/`number`, any integer → `decimal` with a `-w` warning when it isn't
a literal). A literal that fits a narrower type may initialize it
(`type.int8 x = 100`); one that doesn't is an error naming the range.
Narrowing, signedness changes, and `uint64` ↔ `number` need explicit
conversion.

Number literals: `42`, `1_000_000`, `0xFF`. Text literals: `"hi"`,
escapes `\n \t \r \0 \\ \"`.

## Functions

```ok
function.add(number.a, number.b) -> number {
    return a + b
}

function.greet() -> text {
    return "hi"
}

function.reset() {        # no `->` clause: returns nothing
    count = 0
}
```

Parameters and return types use bare type names inside signatures
(`number.a`, `-> number`); statement declarations use the `type.` prefix.
Both spellings are part of the language. Functions are order-independent
(forward references work), recursion works, and valued functions are
checked so every path returns.

## Control flow

The conditional is **`when`**, not `if`:

```ok
when (count > 10) {
    write("many")
}
else {
    write("few")
}
```

Loops:

```ok
loop (i from 0 to 10) { ... }     # INCLUSIVE: 11 iterations, i = 0..10
loop (i from 0 until 10) { ... }  # EXCLUSIVE: 10 iterations, i = 0..9
loop (lives > 0) { ... }          # condition loop
```

`break` and `continue` work as usual. Loop bounds evaluate once, before
the first iteration.

## Output

```ok
type.text=1

write("Total: ")   # appends to the output buffer
write(total)       # numbers, decimals, bools, text all work
print              # flushes the buffer + newline
```

`type.text=1` activates the text subsystem for the file. This is the
0.1 feature-directive mechanism — future switches (e.g. `type.mem=1` for
manual allocation) will follow the same shape.

## Columns and `.end`

A block introduced by `=` is a **column**, terminated by `.end`. The two
language columns declare libraries and source components:

```ok
[libs.use] = {
    "math"
}.end

[source.files.use] = {
    "player",
    "physics"
}.end
```

Developer columns are namespaces you define yourself:

```ok
physics = {
    type.number gravity = 9

    function.fall(number.seconds) -> number {
        return gravity * seconds
    }
}.end

write(physics.fall(3))    # 27
```

Inside a column, sibling names are visible directly; outside, use the
dotted path. Columns nest.

## Modules

Every file in `src/` is a module named after the file. Its public names
are reached as `module.name`:

```ok
# src/greeting.ok
function.hello() -> text {
    return "Hello from greeting"
}
```

```ok
# main.ok
[source.files.use] = {
    "greeting"
}.end

write(greeting.hello())
print
```

Modules may pull in other modules; cycles are errors that name the cycle.
`main.ok`'s own top-level names act as program globals, visible from
every module.

## Expressions

```ok
type.number a = 1 + 2 * 3          # 7 — precedence as you'd expect
type.bool ok = 3 > 2 and 2 > 3     # false — word logical operators
type.text s = "Ok" + "ular"        # concatenation
type.decimal d = 0.5 + 1           # 1.5 — the literal widens silently
type.number n = -5                 # unary minus
```

Comparisons do not chain (`1 < x and x < 10` instead). Equality works on
`text`. `and`/`or`/`not` operate on `bool`. `%` is integer remainder.

`when` selects among several conditions with `else when` chains:

```ok
when (score >= 90) {
    write("A")
}
else when (score >= 80) {
    write("B")
}
else {
    write("F")
}
```

## Diagnostics you'll meet

```
main.ok:3:19

Error: variable `x` is `number`, but the initializer is `text`.

3 | type.number x = "text"
                     ^

note: only `number` -> `decimal` widening is implicit; everything else must
note: match exactly.
```

Errors always carry the location, the offending line, a caret, and a note
suggesting the fix. One compilation reports many independent errors, and a
failed build never produces an executable from required code.

## Arrays

Fixed-length arrays hold N elements of one type. The count is part of the
type, assignment copies the contents, and bounds are always checked at
runtime — an out-of-bounds index is a fatal trap, not silent corruption:

```ok
type.array<type.number, 5> scores = {10, 20, 30, 40, 50}

scores[2] = 99          # indexed store
write(scores[2])        # indexed load

type.array<type.array<type.number, 3>, 2> grid = {{1, 2, 3}, {4, 5, 6}}
write(grid[1][2])       # nesting chains

function.sum(type.array<type.number, 5>.xs) -> number {   # by value
    type.number total = 0
    loop (i from 0 until 5) {
        total = total + xs[i]
    }
    return total
}

type.array<type.number, 5> copy = {0, 0, 0, 0, 0}
copy = scores           # whole-array copy
```

See `specs/spec-v0.11.md` §8.4 for the complete rules.

## Structs

Records declare named field types with predictable layout (natural
alignment, declaration order):

```ok
struct.Rect = {
    type.Point corner
    type.uint16 w
    type.uint16 h
}.end

type.Rect r = {{1, 2}, 10, 20}   # positional literal
r.w = 15                         # field assignment
write(area(&r))                  # pointer parameter writes back
```

Structs copy by value (assignment, parameters); `value.field` reads
fields — on variables, through namespaces, on array elements, and on
pointers (auto-dereferenced and null-checked). Nesting, arrays of
structs, structs on the heap (`alloc<type.Rect>(2)`), and
self-referential `ptr` fields all work. See `specs/spec-v0.11.md` §8.3.

## Unions

One storage, several member views — the reinterpretation type
(0.7, `specs/spec-v0.11.md` §8.5):

```ok
union.Word = {
    type.uint32 u
    type.uint8 low
}.end

type.Word w = { 258 }   # activates `u` (first member that accepts the value)
write(w.low)            # 2 — byte 0 of the same storage
w.low = 1               # the write lands in the shared bytes
write(w.u)              # 257
```

The literal is **type-directed**: `{ value }` activates the first member
whose type accepts it. Reading a member other than the last one written
is the documented, explicitly-unsafe reinterpretation unions exist for
(two's-complement little-endian on x86-64). Unions nest in structs, hold
arrays, sit in arrays, live on the heap (`ptr<Word>`, `alloc<type.Word>(n)`),
copy by value, and work as globals with deterministic `.data`. They are not
comparable and functions cannot return them directly yet — the same
restrictions as structs.

## Files (0.10)

```ok
type.text src = fs.read("input.ok")     # whole file as text
fs.save("out.txt", "result: " + number.to_text(42))
write(fs.exists("out.txt"))             # true
```

`fs.read` loads a whole file into the immutable text arena; `fs.save`
writes text (create/truncate) and returns the byte count; `fs.exists`
probes. Failures are fatal traps (exit 77) naming the path — never silent
empty text. See `specs/spec-v0.11.md` §6.4.

## Bitwise operations (0.11)

```ok
type.uint32 flags = 0xF0F0
write(flags & 0x0FF0)          # 240   — mask
write(flags | 0x000F)          # 61695 — set bits
write(flags ^ 0x0FF0)          # 65280 — toggle
write(~flags)                  # 4294905615 — invert (uint32 wrap)
write(1 << 20)                 # 1048576 — shift left
type.int8 s = -16
write(s >> 2)                  # -4 — arithmetic shift (signed)
type.uint8 u = 0xF0
write(u >> 2)                  # 60 — logical shift (unsigned)
```

`&`, `|`, `^`, `~`, `<<`, `>>` work on every integer type. Bitwise
operators combine through the widening lattice like `%`; comparisons bind
looser than bitwise (Rust ordering), so `flags & MASK == FLAG` groups as
`(flags & MASK) == FLAG`; shifts bind looser than `+`/`-` (C/Rust
ordering). `>>` is arithmetic for signed types and logical for unsigned
ones. A shift count outside `[0, width)` is a bug, not a wrap: constants
fail to compile, runtime counts trap fatally (exit 72). Prefix `&` is
still address-of; infix `&` is bitwise AND — parse position decides, and
`type.ptr<type.ptr<type.number>>` still parses (the `>>` closes both type arguments).
See `specs/spec-v0.11.md` §9.

## Text operations (0.9)

```ok
type.text s = "hello, okular"
write(text.length(s))            # 13 — bytes
write(text.byte_at(s, 0))        # 104 — 'h'
type.text word = text.slice(s, 0, 5)   # "hello" — end-exclusive, O(1)
```

`text.length` counts bytes; `text.byte_at` reads one bounds-checked byte;
`text.slice(s, from, to)` is the substring `[from, to)` sharing the
original's immutable bytes — pointer arithmetic, not a copy. All three
fold at compile time when their operands do. See `specs/spec-v0.11.md` §4.5.

## Constants and type.auto (0.8)

```ok
const.limit = 100
const.combined = limit * 3 + 2        # folds: 302

type.auto x = limit + 5              # number
type.auto d = 1.5                    # decimal
type.auto p = &base.x                # ptr<number> — the FIELD's type
```

Constants fold at compile time and inline their value — no storage, no
load. They work at file and column scope, fold into other constants and
global initializers, and reject assignment. `type.auto` infers a
declaration's type from its initializer (locals, globals, column
members); literals and `null` cannot drive inference, and params/returns/
members stay explicit. See `specs/spec-v0.11.md` §8.1.

## What 0.11 does not have (yet)

Dynamic-length arrays, FFI, threads, match expressions, aliases, and
visibility modifiers are all
**designed** (see `specs/spec-v0.11.md` §20 and
`docs/roadmap.md`) and **not implemented**. The same goes for `f32` (a true
32-bit float). The compiler says so plainly
when you use a reserved construct — it never pretends.
