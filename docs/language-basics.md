# Okular Language Basics (0.16)

A tour of what Okular 0.16 does today. The specification
(`specs/spec-v0.16.md`) is the source of truth; this page is the friendly
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

## Match-style `when` (0.15)

The same `when` keyword also reads a **value** instead of testing a
condition — the body's first tokens decide the reading:

```ok
when (score) {
    90 to 100 { write("A") print }     # inclusive range, like loop's `to`
    80 to 89  { write("B") print }
    75, 76    { write("C") print }     # several patterns share one body
    else      { write("F") print }     # wildcard; must be the last arm
}
```

* Patterns are literals, constants, and `null` — never variables
  (`when (x == y)` stays the conditional's job for comparing two values).
* `lo to hi` ranges match numbers, inclusively; `text`, `bool`, and
  pointers take equality patterns (`"yes" { ... }`, `true { ... }`,
  `null { ... }`).
* A **guard** runs only after the pattern matched:

  ```ok
  when (n) {
      1 to 100 when (n % 2 == 0) { write("even") print }
      1 to 100                   { write("odd")  print }
      else                       { write("out")  print }
  }
  ```

* The subject is evaluated exactly once; arms are tried top to bottom
  and the first match wins; no match and no `else` falls through.
* An exhaustive match (an `else` arm, or `true`+`false` for a `bool`
  subject) satisfies the function return analysis like a full
  `when`/`else` chain.
* Text compares for equality only: `"a" < "z"` is a compile error, not a
  silent false. See `specs/spec-v0.16.md` §10.1.

## `f32` — single-precision floats (0.15)

A **true 32-bit IEEE float**, not a stored-as-double approximation:

```ok
type.f32 a = 1.5           # the literal rounds ONCE to the nearest float32
type.f32 b = 2.25
type.f32 c = a + b         # addss — single-precision rounding at every op
write(c)                   # 3.750000
print

type.decimal wide = a      # f32 widens EXACTLY to decimal (every f32 is an f64)
type.f32 narrow = decimal.to_f32(2.5)   # narrowing is explicit
type.number iv = f32.to_number(2.75)    # 2 — truncates toward zero
type.text s = f32.to_text(a)            # "1.500000"
type.f32 p = text.to_f32("4.25")        # parse + one rounding
```

* Arithmetic compiles to SSE single-precision instructions; comparisons
  to `ucomiss`. Memory is 4 bytes — locals, globals, `array<f32, N>`
  elements (stride 4), struct fields.
* Constant folding is **bit-exact** for `+ - *` (computed through the
  wider `decimal` intermediate with one rounding per op — provably
  identical to single-precision hardware). Division is deliberately
  never folded: an intermediate could double-round.
* NaN and infinities keep their IEEE shapes: `nan == nan` is `false`,
  overflow produces `inf`, `inf - inf` is `nan`, signed zero is
  preserved. Magnitudes ≥ 1e15 print scientifically (`3.402823e38`),
  `inf` and `nan` print by name.
* Mixed arithmetic: integers widen to `f32`; `f32` mixed with `decimal`
  computes in `decimal`. `%`, bitwise operators, and `when (float)`
  conditions are compile errors — no silent truthiness.
* Match-style `when` accepts `f32` subjects with equality patterns
  (`1.5 { ... } else { ... }`).

See `specs/spec-v0.16.md` §4.2.

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

See `specs/spec-v0.16.md` §8.4 for the complete rules.

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
self-referential `ptr` fields all work. See `specs/spec-v0.16.md` §8.3.

## Unions

One storage, several member views — the reinterpretation type
(0.7, `specs/spec-v0.16.md` §8.5):

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
empty text. See `specs/spec-v0.16.md` §6.4.

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
See `specs/spec-v0.16.md` §9.

## Program arguments (0.12)

```ok
type.number n = env.arg_count()     # includes the program name (index 0)
loop (i from 1 until n) {
    write(env.arg(i))               # each argument as immutable text
    print
}
```

`env.arg_count()` returns the argument count as the kernel reported it;
`env.arg(i)` returns argument `i` copied into the text arena. Out-of-range
indices are fatal bounds traps (exit 70) naming the index and count. See
`specs/spec-v0.16.md` §6.5.

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
fold at compile time when their operands do. See `specs/spec-v0.16.md` §4.5.

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
members stay explicit. See `specs/spec-v0.16.md` §8.1.

## The standard library (0.15)

Libraries are modules, pulled in with `[libs.use]` and resolved from
your project's `libs/` and `deps/` first, then the compiler's own
`stdlib/`:

```ok
type.text=1

[libs.use] = {
    "math", "text", "io", "memory"
}.end

function.run() -> number {
    io.puts(text.upper("hello"))        # HELLO
    write(math.gcd(48, 18))              # 6
    print
    write(math.sqrt(2.0))                # 1.414214
    print
    return 0
}
run()
```

* **`math`** — `abs`, `sign`, `min`, `max`, `clamp`, `powi`, `gcd`,
  `lcm`, `isqrt`, `sqrt` (decimal; negative → nan), `dabs`, `dmin`,
  `dmax`.
* **`text`** — `upper`, `lower`, `reverse`, `repeat`, `find`,
  `contains`, `starts_with`, `ends_with`, `count`, `trim`. The
  `text.*` builtins (`length`, `byte_at`, `slice`, `from_bytes`)
  keep priority over module functions.
* **`io`** — `puts`/`putn`/`putd`/`putf`/`putb` (one value + newline),
  `eputs`/`ewrite` (stderr).
* **`memory`** — `fill`, `zero`, `copy`, `copy_back`, `same`, and
  little-endian views over `ptr<byte>` (`read_u32le`, `write_u64le`,
  ...).

A missing library name is a warning (an error under `--strict`); your
project's `src/` modules win over same-named libraries.

## What 0.15 does not have (yet)

Dynamic-length arrays, FFI, threads, aliases, struct-pattern matching
(destructuring), and visibility modifiers are all **designed** (see
`specs/spec-v0.16.md` §20 and `docs/roadmap.md`) and **not implemented**.
The compiler says so plainly
when you use a reserved construct — it never pretends.
