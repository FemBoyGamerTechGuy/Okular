# Okular Language Basics (0.1)

A tour of what Okular 0.1 does today. The specification
(`specs/spec-v0.2.md`) is the source of truth; this page is the friendly
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
```

Fixed-width types (`int8`, `uint32`, …) are designed but not implemented
yet. Assignment must match types exactly, except `number` widens to
`decimal` (with a warning under `-w` when it isn't a literal).

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

See `specs/spec-v0.2.md` §8.4 for the complete rules.

## What 0.2 does not have (yet)

Structs, unions, pointers, manual heap management, dynamic-length arrays,
FFI, threads, match expressions, type inference, constants, aliases, and
visibility modifiers are all **designed** (see `specs/spec-v0.2.md` §20 and
`docs/roadmap.md`) and **not implemented**. The compiler says so plainly
when you use a reserved construct — it never pretends.
