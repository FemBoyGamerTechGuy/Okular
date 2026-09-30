# Okular Language Specification

**Version:** 0.3 (fixed-width integers)
**Status:** Evolving draft
**Implementation:** bootstrap compiler in C (`bootstrap/`)

> 0.3 adds the fixed-width integer family with wrapping semantics, the
> implicit widening lattice, and the `T.to_U(x)` conversion builtins
> (§4.2/§4.4) on top of 0.2. See the changelog in §23.

> This specification is the source of truth for the Okular language.
> When the implementation changes the language, this document changes with it.
> When something is not implemented yet, the status table (§22) says so plainly.
> Nothing is claimed to work unless the test suite proves it.

---

## 0. Design Philosophy

Okular is a general-purpose, **natively compiled** systems language.

> Simple to understand, powerful enough to build anything, and low-level control
> when the developer needs it.

Three principles govern every syntax decision in this document:

1. **Approachable by default.** A programmer who knows C, C++, Rust, or Python
   should be able to read Okular within minutes and write it within an hour,
   without first learning pointers, allocation, unions, or ABI details.
2. **No ceiling.** The same language must eventually express operating-system
   components, drivers, and the Okular compiler itself. Convenience features
   are additive, never mandatory, and never remove the low-level escape hatch.
3. **Okular is its own language.** Familiar concepts may keep familiar names,
   but the grammar, module system, type system, and memory model are designed
   as one coherent whole — not inherited from C, Rust, or Python.

C is bootstrap scaffolding only (see `docs/architecture.md`). Nothing in this
specification is defined in terms of C semantics.

---

## 1. Lexical Structure

### 1.1 Source files

Okular source files use the `.ok` extension (`main.ok`, `player.ok`,
`physics.ok`). Source encoding is UTF-8. Line endings may be LF or CRLF.

### 1.2 Lines and statement separation

Okular is **newline-sensitive at the statement level**:

* A newline terminates a statement, declaration, or directive.
* Blank lines are ignored.
* Newlines occurring inside parentheses `(` `)` or square brackets `[` `]`
  are ignored. This permits readable multi-line call argument lists without
  any continuation character.

Rationale: no semicolons (they are unnecessary punctuation, §4 of the design
goals), no arbitrary automatic-continuation heuristics (they are ambiguous),
and a natural error-recovery sync point for the parser (§16).

### 1.3 Comments

```ok
# A line comment. Everything after # to the end of the line is ignored.
write("ok")   # trailing comments are allowed
```

Block comments are **planned** (not implemented in 0.1).

### 1.4 Identifiers

`[A-Za-z_][A-Za-z0-9_]*`, case-sensitive. Identifiers starting with `__ok_`
are reserved for compiler internals.

### 1.5 Keywords

Active in 0.1:

```
type  function  struct  when  else  loop  from  to  until
break  continue  return  print  write  true  false
and  or  not  end
```

Reserved for designed-but-unimplemented features (using them as identifiers
is a compile error, so future adoption is non-breaking):

```
union  pointer  alloc  release  null  guard  fail  with
priv  pub  match  case  const  ptr
```

`libs`, `source`, `use`, and `array` are not keywords: they are contextual
segments of language column paths or of type references (`[libs.use]`,
`type.array<...>`) and may appear as ordinary identifiers elsewhere.

### 1.6 Number literals

| Form | Examples | Notes |
|---|---|---|
| Decimal integer | `42`, `0`, `1_000_000` | underscores group digits freely |
| Hexadecimal | `0xFF`, `0xdead_beef` | |
| Floating point | `3.14`, `0.5`, `1000.0` | has `.fraction`; no exponent form yet (planned) |

A `-` is **not** part of the literal; it is the unary negation operator.

### 1.7 Text literals

```ok
"Hello Okular"
"tab:\there"
"line1\nline2"
"quote:\" backslash:\\ nul:\0"
```

Text literals are immutable UTF-8 byte sequences. Escapes: `\n \t \r \\ \" \0`.
Unknown escapes are a compile error (not silently passed through). Raw
multi-line text literals are planned.

### 1.8 Operators and punctuation

```
+  -  *  /  %          arithmetic
==  !=  <  <=  >  >=   comparison
and  or  not            logical (word operators)
=                       declaration/assignment (never equality)
->                      function return-type arrow
.  ,  (  )  {  }  [  ] punctuation
```

`=` never tests equality. Equality is always `==`. Word logical operators were
chosen over `&& || !` because they read naturally at statement level and are
impossible to confuse with bitwise operators (§9, planned). `[` `]` index
arrays (§8.4/9) and also suppress newlines (§1.2).

---

## 2. Program and Project Structure

An Okular *project* is a directory:

```
Project/
├── main.ok      entry point and composition root (required)
├── src/         optional reusable .ok source components
├── libs/        project libraries and library references
├── deps/        external dependencies
└── etc/         metadata, tooling data, generated info (reserved)
```

* **main.ok** — the primary entry point. Contains the executable body of the
  program: the top-level statements of `main.ok` run when the program runs
  (§7). May import source components and libraries, define functions, columns,
  and its own code directly. Not everything must live in `src/`.
* **src/** — optional reusable source files (`player.ok`, `physics.ok`, ...).
  They provide declarations (functions, columns, globals) that `main.ok` uses
  via the module system (§6). Source files are *not* standalone programs.
* **libs/** — project libraries (searched for `[libs.use]` entries).
* **deps/** — external dependencies (searched after `libs/`).
* **etc/** — reserved; the compiler does not interpret its contents in 0.1.

The simplest Okular program is a single `main.ok` file. No manifest file is
required, and none exists in 0.1 — the project *is* the directory plus
`main.ok`. (If a manifest becomes necessary later it will be introduced with a
documented rationale, not by imitation.)

### 2.1 Optional source policy

`src/` files are **optional components**. The deliberate rule is:

| Situation | Normal mode | Strict mode (`--strict`) |
|---|---|---|
| Broken file in `src/` **not used** by the project | warning, skipped, build succeeds | build fails |
| Broken file in `src/` **used** by the project | build fails | build fails |

"Used" means: referenced from `main.ok` (directly or transitively through
other used files) via `[source.files.use]`.

---

## 3. Columns and `.end`

The **column** is Okular's distinctive structuring concept.

### 3.1 The column rule

> Any block introduced by `=` is a **column** and is terminated by `.end`.
> Blocks attached to constructs (function bodies, `when`/`loop` bodies) close
> with `}` alone.

```ok
[libs.use] = {
    "math"
}.end              # column: introduced by =

function.greet() -> text {
    return "hi"    # function body: attached block, closes with }
}
```

`.end` means: *the current column ends here; the following content belongs to
another syntactic region.* It never means the program ended.

### 3.2 Language columns

Columns whose name is a bracketed dotted path are **language-defined**:

```ok
[libs.use] = {
    "math",
    "filesystem"
}.end

[source.files.use] = {
    "player",
    "physics"
}.end
```

Only the paths defined by the language are legal (`libs.use`,
`source.files.use` in 0.1). An unknown bracketed path is a compile error
listing the known columns.

### 3.3 Developer columns (namespaces)

Any other identifier on the left of `= {` declares a **developer column**,
which is a named namespace:

```ok
physics = {
    type.number gravity = 9

    function.fall(number.seconds) -> number {
        return gravity * seconds
    }
}.end

write(physics.fall(3))      # namespaced access
```

Semantics:

* Declarations inside a developer column are scoped to that column's name.
* Inside the column, sibling names are visible directly (`gravity`).
* Outside, they are reached through the dotted path (`physics.fall`).
* Columns nest; access paths compose (`engine.physics.fall`).
* A developer column in `main.ok` behaves exactly like one in `src/` files —
  the mechanism is file-independent.

This gives columns real meaning (organization + namespacing) without magic,
and without making them comments or formatting.

### 3.4 Column classification

The compiler distinguishes, per §7 of the engineering brief:

* **language-defined columns** — `[libs.use]`, `[source.files.use]`
* **project-defined columns** — same syntax, resolved per project (future:
  project metadata may define additional reserved paths in `etc/`)
* **developer-defined columns** — plain names, namespaces as above
* **ordinary executable code** — everything else; top-level statements are
  only legal in `main.ok` (§7)

---

## 4. Types

### 4.1 Built-in types

| Okular type | Meaning | Size |
|---|---|---|
| `number` | signed integer, the approachable default | 64-bit |
| `decimal` | floating point, the approachable default | IEEE-754 binary64 |
| `text` | immutable UTF-8 text (pointer + length) | 16 bytes |
| `bool` | `true` / `false` | 1 byte |
| `int8` / `int16` / `int32` | signed fixed-width integers | 1 / 2 / 4 bytes |
| `uint8` / `uint16` / `uint32` / `uint64` | unsigned fixed-width integers | 1 / 2 / 4 / 8 bytes |
| `array<T, N>` | N elements of type T, laid out contiguously | N × size(T) |

Array types are written `type.array<type.number, 5>` (§8.4).

`number` and `decimal` are deliberately not named "int"/"float": they are the
*default* types a beginner reaches for, sized by the platform for the era
(64-bit), while the explicit fixed-width types below are the *systems* names.

### 4.2 Fixed-width types (implemented in 0.3)

```
int8   int16   int32   int64
uint8  uint16  uint32  uint64
f32    f64
byte   (alias of uint8)
```

* `int64` is **`number`'s systems name** — the same type. `f64` is
  `decimal`'s. `byte` is `uint8`. Aliases exist so systems code reads the
  way systems programmers think; they add no new semantics.
* `f32` remains designed-not-implemented (a true 32-bit float needs its own
  ABI path; it arrives with the float milestone).
* All share the declaration grammar (`type.uint32 flags = 0xFF`) and the
  dotted parameter/return forms (`int32.x`, `-> uint16`).
* **Arithmetic wraps** — two's-complement, modulo 2^N, at the operand type:
  `int8 127 + 1 == -128`, `uint8 255 + 1 == 0`, `uint16 60000 * 60000 ==
  41984`. Overflow is never undefined behavior; it is silent wrap. (An
  opt-in overflow diagnostic is future work.)
* **Division truncates toward zero** and `INT64_MIN / -1` wraps to
  `INT64_MIN` rather than faulting. Division or remainder by **zero is a
  fatal runtime trap** (§13, exit 71).
* **Comparisons use the operand type's signedness**: `uint8 200 > 100` is
  `true`; `-1 < 1` is `true` for signed types. Mixing signed and unsigned
  values of incompatible widths is a compile error (§4.4), so the
  signedness of every comparison is always statically known.
* **Literals are contextually typed**: an integer literal (or negated
  literal) whose value fits the *other* operand's type participates as that
  type — `int32_big * 2` stays `int32`; `uint64_max - 1` stays `uint64`.
  A literal that does not fit promotes to `number` semantics.
* Storage: exact width in arrays and globals (packed from the storage
  start); local slots round up to 8 bytes with unobservable padding.
  Register representation: values travel sign- or zero-extended in 64-bit
  registers and re-encode (wrap) after arithmetic.

### 4.3 Type grammar

Type references in declarations use the dotted form:

```ok
type.number age = 18
type.text name = "Alex"
type.decimal ratio = 0.5
type.bool ready = true
```

The parser distinguishes a **directive** from a **declaration** by one token
of lookahead after `type.<name>`:

* next token `=` → feature directive (`type.text=1`, §5)
* next token identifier → variable declaration

### 4.4 Conversions

**Implicit** (assignment, arguments, returns, array elements, operands):

* **Safe widening only** — the value is representable in the target:
  * signed → wider signed (`int8` → `int16`/`int32`/`number`)
  * unsigned → wider unsigned (`uint8` → `uint16`/`uint32`/`uint64`)
  * unsigned → strictly-wider signed (`uint8` → `int16`…`number`,
    `uint32` → `number`; never `uint32` → `int32`, never `uint64` →
    `number`)
  * any integer → `decimal` (warning under `-w`, silent for literals)
* **Literal rule** — an integer literal (or negated literal, or foldable
  constant) may initialize a narrower type when its value fits:
  `type.int8 x = 100` and `type.int8 y = -100` are legal;
  `type.int8 z = 200` and `type.uint8 u = -1` are errors naming the range.
* Everything else is a compile error — no silent narrowing, no
  signedness changes, no `bool`↔number coercion, no `text` coercion.

**Mixed arithmetic** uses the common type: the wider of two safely-
convertible types, `decimal` when either side is `decimal`. Pairs with no
common type (`int8 + uint8`, `number + uint64`) are compile errors with a
conversion suggestion. `number` and `decimal` interconvert exactly as in
0.2 (implicit widening with `-w` warning).

**Explicit** — the conversion builtins, one per ordered type pair:

```ok
type.uint8 u = number.to_uint8(300)     # 44 — wrap (truncate to width)
type.int8  s = int16.to_int8(-300)      # 44 — wrap
type.decimal d = uint64.to_decimal(h)   # exact when representable
type.number n = decimal.to_int32(3.99)  # 3 — truncate toward zero
type.number b = bool.to_number(true)    # 1
```

* `T.to_U(x)` — `T` and `U` are any scalar type names (aliases included:
  `number.to_byte(515)`).
* Integer → integer **wraps** (reinterpret at the target width); widening
  conversions via the builtin are the explicit form of the implicit rule.
* `decimal` → integer truncates toward zero; out-of-range/NaN results wrap
  deterministically (the hardware `INT64_MIN` sentinel, then the target
  width).
* Conversions of constants fold at compile time — including global
  initializers (`type.byte convb = number.to_byte(515)`).
* `text` conversions (`text.to_number`, `number.to_text`) are designed but
  **not implemented** — the compiler says so plainly. `T.to_bool` does not
  exist: compare explicitly (`x != 0`).
* Array types never convert.

---

## 5. Feature Directives: `type.<feature>=<value>`

```ok
type.text=1        activate the text subsystem
type.text=0        deactivate it
```

Semantics: `type.<name>=<value>` is a **compile-time feature switch** for the
current file. Directives take effect for the whole file regardless of
position (conventionally placed at the top). In 0.1 the only feature is
`text`:

* `type.text=1` activates the text output builtins `write` and `print`.
* Calling `write`/`print` in a file where the text subsystem is not active is
  a compile error whose message states the fix (`type.text=1`).
* Text *values* (literals, variables, parameters, returns) are always legal;
  the gate governs the **output subsystem**, not the type.

This preserves the user-facing concept from the original brief while keeping
strings, functions, arrays, and everything else fully usable without the
directive. The mechanism is a general registry: future features (e.g.
`type.mem=1` gating manual allocation) plug into the same grammar, and
unknown features are compile errors (never silently ignored).

---

## 6. Modules

### 6.1 Using source files

```ok
[source.files.use] = {
    "greeting",
    "player"
}.end
```

* Entries name files in `src/` (`"greeting"` → `src/greeting.ok`).
* A source file may itself declare `[source.files.use]`, pulling in further
  components (transitive).
* Cycles are detected and reported as errors naming the cycle path.
* Compilation order is the topological order of the dependency graph; `main.ok`
  is the root.

### 6.2 Symbol visibility and namespacing

Every loaded source file forms a **module namespace** named after the file
(without extension):

```ok
# src/greeting.ok
function.greet() -> text {
    return "Hello from greeting"
}
```

```ok
# main.ok
[source.files.use] = {
    "greeting"
}.end

write(greeting.greet())     # module-qualified access
print
```

* All top-level declarations of a source file are **public** in 0.1 and are
  reached as `module.name`.
* `priv` visibility is designed (keyword reserved) for a later release.
* Duplicate exported names *within* one module are errors; the same simple
  name in different modules is fine (they occupy different namespaces).
* Aliases (`use greeting as g`) are planned.

### 6.3 Libraries

```ok
[libs.use] = {
    "math"
}.end
```

Resolution order (design; search itself implemented in 0.1):

1. `Project/libs/<name>` (or `<name>.oklib` — format planned)
2. `Project/deps/<name>`
3. the compiler's standard library directory
4. system library locations (platform backend concern)

In 0.1 the compiler **verifies resolution** of each `[libs.use]` entry
(unknown entries produce a warning in normal mode, an error in strict mode)
but **library binding is not yet implemented** — no standard library exists
yet. Referencing a library symbol therefore surfaces as a normal unresolved
symbol diagnostic. This is stated plainly in the status table.

---

## 7. `main.ok` and Program Execution

The top-level statements of `main.ok` *are* the program body:

```ok
type.text=1

write("Hello Okular")
print
```

* Top-level statements execute in source order at program start.
* Top-level `return <number>` terminates the program with that exit code.
  Otherwise the program exits with code 0.
* Top-level *declarations* (variables, functions, columns) are legal in any
  `.ok` file; top-level *executable statements* are only legal in `main.ok`.
  Source components expose functionality; they do not run on their own.
  (Module initialization blocks are a designed future feature.)
* Global variables may be declared in any file, but their initializers must
  be compile-time constants (literal or foldable) in 0.1, because there is no
  ordering machinery yet. This restriction is documented and will lift.

---

## 8. Declarations

### 8.1 Variables

```ok
type.number count = 0
type.text user = "Alex"
type.decimal ratio = 0.75
type.bool active = true
type.array<type.number, 5> scores = {10, 20, 30, 40, 50}
```

* Initialization is **required** in 0.2 (no default initialization — explicit
  behavior over implicit; see design principles). This is a deliberate,
  documented restriction, not an oversight.
* Reassignment: `count = count + 1` (same type only).
* Scope: block-scoped locals; file/module-scoped globals; column-scoped
  members.
* Constants (`const`) are designed; keyword reserved.
* Type inference (`type.auto x = f()`) is planned but not in 0.1 — explicit
  types first.

### 8.2 Functions

```ok
function.add(number.a, number.b) -> number {
    return a + b
}

function.greet() -> text {
    return "hi"
}

function.reset() {
    count = 0
}
```

Grammar:

```
function.<name>(<typeRef>.<param>, ...) [-> <typeRef>] { body }
```

* The `function` prefix and the dotted parameter typing mirror the variable
  grammar — one declaration style across the language.
* A function with no `->` clause returns nothing (`void` is not a type you
  write; absence *is* the statement).
* `return expr` returns a value; bare `return` returns from a valueless
  function. Falling off the end of a valueless function is legal.
* Recursion is supported.
* Function values / function pointers: designed, arrive with pointers (§12).
* Functions may take up to **6 parameters** in 0.1 (the internal ABI's
  register budget; `docs/architecture.md` §3.5); the limit lifts with the
  stack-args milestone.
* Arguments evaluate **right-to-left** — a consequence of the 0.1 calling
  convention, visible only through side effects such as `write` order.
* Missing `return` on a valued function: compile error, checked by a
  reachability analysis of the body's terminal statements.
* Array parameters are passed **by value**: the caller makes a private copy
  and the callee sees only that copy (§8.4, D23).
* Functions **cannot return arrays** in 0.2 — the return ABI carries a
  single register value. This documented restriction lifts with the memory
  milestone (§12).

### 8.3 Structs (designed; not implemented in 0.1)

```ok
struct.Packet = {
    type.uint32 length
    type.uint8 flags
}.end
```

Fields use the standard declaration grammar (without initializers). Methods,
nested structs, arrays-in-structs, explicit layout/alignment attributes, and
value vs reference semantics are designed in `docs/roadmap.md`. The keyword is
reserved and the column-style shape above is the committed direction.

### 8.4 Arrays

A fixed-length array holds exactly N elements of one element type T, stored
contiguously:

```ok
type.array<type.number, 5> scores = {10, 20, 30, 40, 50}
type.array<type.text, 2>   names  = {"Ada", "Grace"}
type.array<type.array<type.number, 3>, 2> grid = {{1, 2, 3}, {4, 5, 6}}
```

Rules:

* **The count is part of the type.** `array<number, 5>` and `array<number, 6>`
  are different types that never convert. The count is a literal between
  1 and 65536 in the bootstrap compiler (a documented limit that lifts with
  the memory milestone; total storage is bounded to 1 MiB per array).
* **Literals only initialize declarations** — `= { ... }` after a declaration.
  Assignment copies whole arrays from other arrays of the exact same type;
  a literal in assignment position is a compile error.
* **Element rules**: literal elements must each be assignable to T (safe
  widening, or the fitting-literal rule for fixed-width integers — `number`
  literals widen to `decimal` elements); the element count must match exactly.
  Nested literals follow the nested element type.
* **Value semantics.** Assignment (`a = b`), initialization from another array,
  and parameter passing **copy the contents**. Mutating a copy never touches
  the original; a function that mutates its parameter mutates only its own
  copy. (Reference-style access arrives with pointers, §12.)
* **Indexing** is `name[index]` (§9); `name[index] = value` stores. Indices
  are any integer type (`number`, `int8`…`uint64`). Indexing chains nest
  for array-of-array types (`grid[1][2]`).
* **Bounds are always checked** — in every mode, at every index operation.
  An out-of-bounds index (including a negative one) is a fatal runtime trap
  naming the index and the array's length, exit code 70 (§13). The
  default is safe; opting out arrives only with the low-level memory gate
  (`type.mem=1`, planned). This decision is D24.
* **Arrays are not comparable** (`==`/`!=` are errors — compare elements),
  not writable as a whole (`write(arr)` is an error with guidance), and not
  usable in arithmetic or conditions.
* Globals and column members may be arrays; their elements must be
  compile-time constants, emitted as static data (§7).
* Arrays of every scalar type work; elements are laid out from the storage
  start, each aligned to its natural size.

---

## 9. Expressions

Precedence, loosest to tightest:

| Level | Operators | Associativity |
|---|---|---|
| 1 | `or` | left |
| 2 | `and` | left |
| 3 | `==  !=  <  <=  >  >=` | left (non-associative) |
| 4 | `+  -` | left |
| 5 | `*  /  %` | left |
| 6 | unary `not`, unary `-` | prefix |
| 7 | call `f(x)`, member `a.b`, index `a[i]`, literals, names, `( expr )` | — |

* `+` on `text` concatenates. `+` on `number`/`decimal` adds. There is no
  `+` between `text` and `number` (planned explicit conversion builtins).
* Comparisons yield `bool`. `and`/`or`/`not` operate on `bool` only.
* Division `/` on `number` is integer division; on `decimal` it is floating
  division. `%` is remainder, `number` only.
* Constant expressions (literals folded at compile time) are required for
  global initializers (§7) and are folded by the IR constant-folding pass.
* `xs[i]` requires an array base and an integer index (any width — the
  register representation doubles as the unsigned bounds key, so negative
  indices trap); its type is the element type. Bounds are checked at
  runtime (§8.4). `xs[i] = v` is the indexed store form; chained indices
  (`grid[i][j]`) walk element types.

---

## 10. Control Flow

The conditional is **`when`**, deliberately not C's `if`:

```ok
when (count > 10) {
    write("many")
}
else {
    write("few")
}
```

* Parenthesized condition — explicit, unambiguous, easy to parse, and it
  reads as a unit with the block.
* Brace body — consistent with function bodies and columns.
* `else` binds to the nearest open `when`.
* **`else when (…) { … }` chains** select among several conditions:

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

  Conditions test top to bottom; the first true branch runs and the rest are
  skipped. A chain may end with a plain `else` or with nothing. The final
  `else` (or its absence) participates in return checking exactly like a
  nested `when`: a function whose chain covers every branch with `return`s
  satisfies the return analysis.

Rationale (§15 of the brief demanded an Okular-specific conditional):
`when (…) { … } else { … }` is instantly readable to C/Rust/Python
programmers, parses without lookahead tricks, avoids C's dangling-else
foot-gun by construction of the block grammar, and the word *when* positions
the construct as a question about a condition rather than C's imperative
*if*. It is not a copy of Kotlin/Rust `when` (theirs is match-style; ours is
a plain conditional in statement position).

Loops:

```ok
loop (i from 0 to 10) {        # inclusive: runs 11 times (i = 0..10)
    write(i)
}

loop (i from 0 until 10) {     # exclusive: runs 10 times (i = 0..9)
    write(i)
}

loop (lives > 0) {             # condition loop
    lives = lives - 1
}
```

* `from/to` is **inclusive** because "from 0 to 10" naturally reads as
  reaching 10. `until` is the exclusive spelling for the half-open range
  programmers expect. Both exist; both are documented; neither is a surprise.
* The counted form declares `i` scoped to the loop body.
* `break` exits the innermost loop; `continue` skips to the next iteration.
* Loop bounds evaluate once, before the first iteration.

---

## 11. Input/Output: `write` and `print`

```ok
type.text=1

write("Total: ")
write(total)
print
```

Semantics:

* `write(x)` **appends** the formatted value of `x` to the program's output
  buffer. `text` appends its bytes; `number` appends decimal digits;
  `decimal` appends an approximate plain decimal form; `bool` appends
  `true`/`false`.
* `print` (a paren-less statement) **flushes** the buffer to standard output
  and appends a newline. Composing a line from several `write` calls then
  flushing once with `print` is the intended idiom.
* An empty buffer flushed by `print` prints just the newline.

This is a real, distinct I/O model (build-then-emit), it makes the original
brief's `write(...)` / `print` pair load-bearing rather than decorative, and
it avoids dragging in buffered C stdio semantics. `write` and `print` are
language keywords in 0.1 (they are not user-callable function values).

---

## 12. Memory Model (design; implementation milestone 5)

Okular's memory design is committed even where 0.1 does not implement it:

* **Stack allocation** is the default for locals.
* **Manual heap control** is explicit and always available:

  ```ok
  type.ptr<type.number> p = alloc<type.number>(1)
  release(p)
  ```

  (grammar provisional, keyword `ptr`/`alloc`/`release` reserved)
* Pointers are first-class: address-of (`&x`), dereference, pointer
  arithmetic, null (`null` keyword reserved), comparisons.
* **Safety is opt-out, not opt-in**: the default path is memory-safe, and
  low-level operations are gated by explicit constructs (`type.mem=1`
  feature directive planned), so beginners are not *forced* into unsafe code
  and experts are never *blocked* from it.
* No mandatory garbage collection (design principle: native performance).
  Optional region/arena helpers are planned in the standard library.

0.1 implements only stack frames and a static output buffer; all pointer and
heap machinery is honestly marked NOT IMPLEMENTED in §22.

---

## 13. Error Model (design; partial in 0.1)

* **Compile-time errors** — precise diagnostics (§15), build fails, no
  executable is produced from required code.
* **Runtime fatal errors** — traps with a message and a nonzero exit code:
  array bounds and text-arena exhaustion exit 70; **integer division by zero
  (0.3) exits 71**; output-buffer overflow exits 74; internal runtime errors
  use 75+. Implemented for the cases the runtime can hit.
* **Recoverable errors** — designed model: valued functions can signal
  failure through a `guard`/`fail` mechanism with explicit propagation:

  ```ok
  function.parse(text.input) -> number {
    fail "not a number"        # provisional grammar
  }

  guard result = parse(userInput) else {
    # error path; result unusable here
  }
  ```

  This is documented direction, not 0.1 behavior; keywords are reserved.

---

## 14. Diagnostics and Warnings

The compiler reports problems as `file:line:column` with a source excerpt,
a caret, what was found, and a note suggesting the fix (§15 of the brief for
the exact format).

* `-w` / `--warnings` — meaningful warnings: unused variable, unreachable
  code, implicit `number`→`decimal` widening, unresolved `[libs.use]` entry.
* `-xw` / `--extra-warnings` — noisier analysis: constant division by zero,
  comparisons that fold to a constant truth value, name shadowing.
* `-s` / `--strict` — strict builds (§2.1): optional-source failures become
  fatal, unresolved libraries are errors, and the compiler treats the
  warnings above as build failures.
* `-l` / `--legacy` — enables compatibility with older Okular syntax. The
  mechanism (a per-construct version registry) exists in 0.1; no legacy
  constructs exist yet because 0.1 is the first release. This is stated
  honestly rather than pretending the flag does something.

Warnings never replace errors; errors always fail the build of required code.

---

## 15. Compilation

```
Project/main.ok
      |
      v
 [okular] project loader -> module graph
      |   lexer ---- token stream
      |   parser ---- AST (with recovery)
      |   sema ------ symbols, namespaces, types
      |   IR -------- typed stack IR (+ constant folding)
      |   backend --- x86-64 assembly (freestanding)
      v
 build/objects/*.s -> as -> *.o -> ld -> build/output/<name>
```

* Output executables are **freestanding**: no C library is linked; entry is
  the Okular-generated `_start`, and system interaction happens through raw
  Linux x86-64 syscalls in the bootstrap runtime shim.
* The assembler and linker (`as`, `ld`) are used as system tools during the
  bootstrap. Okular's own integrated assembler is a self-hosting milestone
  (see `docs/roadmap.md`). The brief's rule "do not make C an intermediate
  target" is honored: **no C code is ever generated**; the pipeline's own
  output is assembly from Okular's own backend.
* Build outputs go to `build/objects/` and `build/output/`; sources are never
  overwritten.
* Exit codes: `0` success; `1` compilation errors; `2` usage/internal error.

---

## 16. Grammar (EBNF, 0.1)

```
file            = { toplevel } EOF ;

toplevel        = directive | lang_column | dev_column
                | funcdecl | vardecl | statement ;

directive       = "type" "." IDENT "=" INTLIT ;          (* e.g. type.text=1 *)

lang_column     = "[" IDENT { "." IDENT } "]" "=" "{" [ stringlist ] "}" "." "end" ;
stringlist      = STRINGLIT { "," STRINGLIT } ;

dev_column      = IDENT "=" "{" { column_member } "}" "." "end" ;
column_member   = directive | dev_column | funcdecl | vardecl ;

funcdecl        = "function" "." IDENT "(" [ params ] ")"
                  [ "->" typeref ] block ;
params          = param { "," param } ;
param           = typeref "." IDENT ;

(* type references: scalars, or arrays with the `type.` prefix.
 * parameter/return positions also accept the bare scalar names
 * for 0.1 compatibility (`number.a`); arrays must use the full form. *)
typeref         = "type" "." ( scalar | "array" "<" typeref "," INT ">" ) ;
scalar          = "number" | "decimal" | "text" | "bool" ;
baretyperef     = scalar | typeref ;

vardecl         = typeref IDENT "=" initializer ;
initializer     = expr | arraylit ;
arraylit        = "{" [ initializer { "," initializer } ] "}" ;
assignment      = path "=" expr
                | postfix "[" expr "]" "=" expr ;   (* indexed store *)

block           = "{" { statement } "}" ;

statement       = vardecl | assignment | exprstmt
                | whenstmt | loopstmt
                | "return" [ expr ]
                | "break" | "continue"
                | "print" ;

whenstmt        = "when" "(" expr ")" block
                  { "else" ( whenstmt | block ) } ;
loopstmt        = "loop" "(" loophead ")" block ;
loophead        = IDENT "from" expr ("to" | "until") expr
                | expr ;

exprstmt        = callexpr ;
callexpr        = path "(" [ expr { "," expr } ] ")" ;

path            = IDENT { "." IDENT } ;

expr            = orx ;
orx             = andx { "or" andx } ;
andx            = cmpx { "and" cmpx } ;
cmpx            = addx [ ("=="|"!="|"<"|"<="|">"|">=") addx ] ;
addx            = mulx { ("+"|"-") mulx } ;
mulx            = unary { ("*"|"/"|"%") unary } ;
unary           = ("not" | "-") unary | postfix ;
postfix         = primary { "." IDENT | "(" [ args ] ")" | "[" expr "]" } ;
primary         = INTLIT | FLOATLIT | STRINGLIT | "true" | "false"
                | path | "(" expr ")" ;
```

Notes: `print` is a statement keyword; `write(...)` is parsed as a builtin
call expression-statement and type-checked against the text subsystem gate.
Member access on values (methods) arrives with structs. Array literals are
parsed as initializers only; array indexing is a postfix form chained after
the base expression (`grid[i][j]`).

---

## 17. Example: complete program

```ok
# main.ok — FizzBuzz in Okular

type.text=1

[source.files.use] = {
    "helpers"
}.end

math = {
    function.mod3(number.n) -> number {
        return n - (n / 3) * 3
    }
}.end

loop (i from 1 until 21) {
    when (math.mod3(i) == 0) {
        write("Fizz")
    }
    else {
        write(i)
    }
    print
}
```

---

## 18. Versioning

* This document specifies **Okular 0.2**. 0.1 was the first bootstrap
  release; 0.2 adds arrays (§23).
* The version registry is the compatibility mechanism behind `--legacy`:
  every construct records the version that introduced it; the compiler may
  translate superseded constructs forward rather than accumulating special
  cases.
* The specification and implementation move together; divergence is a bug
  (file it against whichever is wrong).

---

## 19. Design Decision Register

Major decisions and their rationale (required by the engineering brief §4.10):

| # | Decision | Rationale |
|---|---|---|
| D1 | Newline = statement separator; suppressed inside parens | no semicolons, no ASI-style ambiguity, natural parser recovery points |
| D2 | `X = { … }.end` is the column form; attached blocks close with `}` | one rule explains every block in the language; `.end` gains meaning |
| D3 | Declarations `type.number x = 1`; directives `type.text=1` | one grammar shape; single-token lookahead disambiguates |
| D4 | `when`/`else` conditional | Okular-specific, readable, parseable, not a C copy (brief §15) |
| D5 | `loop (i from A to B)` inclusive / `until` exclusive | both intuitions honored explicitly, zero surprises |
| D6 | `write` buffers, `print` flushes + newline | makes the brief's hello-world pair semantically real |
| D7 | `type.text=1` gates output builtins, not string values | preserves the concept without crippling the type system (brief §12) |
| D8 | Word operators `and or not` | statement-level readability; zero confusion with future bitwise ops |
| D9 | `#` comments | distinct from C family, zero grammar conflicts in 0.1 |
| D10 | Modules namespace by file name; public by default | simplest sound default; `priv` designed for later |
| D11 | Top-level statements only in `main.ok` | entry semantics stay trivial; module-init blocks designed for later |
| D12 | Global initializers must be constant-foldable | no init-order machinery yet; restriction documented, will lift |
| D13 | Required variable initialization | explicit over implicit (design principle 2/§0) |
| D14 | `number`=i64, `decimal`=f64 defaults | platform-sized defaults; fixed-width names reserved for systems work |
| D15 | Freestanding executables, raw syscalls, no libc | brief §3: native, own backend, C is scaffolding — output depends on no C runtime |
| D16 | Internal Okular ABI in 0.1 (args in integer regs, decimals by bit-pattern) | keeps bootstrap codegen simple and honest; SysV interop is a designed milestone |
| D17 | Struct shape `struct.Name = { fields }.end` | consistent with columns; keyword reserved until milestone 5 |
| D18 | Developer columns are namespaces | real semantics, no magic, composes with module namespaces |
| D19 | Loop bounds evaluate once, before iteration | no surprise re-evaluation; matches the `from A to B` reading |
| D20 | Counted loops increment; `from`/`to`/`until` are keywords | descending loops use condition loops in 0.1 |
| D21 | Executables are non-PIE, `ld`-linked, `_start` entry | simplest freestanding start; PIE is a backend milestone |
| D22 | Text args pass as pointers to (ptr,len) pairs; scalars in integer registers | one coherent internal ABI (docs/architecture.md §3.5) |
| D23 | Array args: caller copies into private scratch, passes the copy's address; callee copies into its own frame (ABI v1) | value semantics without new register classes; same shape as D22; the shared scratch is sound because copies happen at call time |
| D24 | Bounds checks always on, trap with index+length, exit 70 | safety is opt-out, not opt-in (§12); the low-level escape arrives with `type.mem=1` |
| D25 | `type.array<T, N>` mirrors the committed `type.ptr<T>` shape (§12) | one type-reference grammar; the count lives in the type, not the value |

---

## 20. What 0.2 Deliberately Does NOT Contain

Slices, structs, unions, pointers, manual allocation, FFI, threads,
match expressions, type inference, constants, aliases, `priv`, block
comments, scientific-notation literals, method calls, debug symbols,
optimization beyond constant folding, an optimizer framework, and the
self-hosted compiler. Each is designed in `docs/roadmap.md` with a milestone.
Nothing in this list is claimed to work.

0.2 also does not contain: array returns from functions (D23-adjacent
restriction, lifts with the memory milestone), array literals outside
declarations, dynamic-length arrays, or bounds-check opt-out.

---

## 21. Conformance

An implementation claiming "Okular 0.1" must:

1. accept every construct in §16 and reject malformed input with the
   diagnostic format of §14/§15;
2. implement the optional-source policy of §2.1 including strict mode;
3. produce freestanding native executables from `main.ok` projects, with
   programs' observable behavior matching §§5–11;
4. pass the repository's test suite (`tools/run_tests.sh`).

---

## 22. Implementation Status Table

| Feature | Spec § | Status in 0.1 bootstrap |
|---|---|---|
| Lexer (locations, all literals, comments) | §1 | implemented |
| Columns: language + developer + `.end` | §3 | implemented |
| `[source.files.use]` + transitive + cycle detection | §6.1 | implemented |
| Module namespaces (`greeting.greet()`) | §6.2 | implemented |
| `[libs.use]` resolution check | §6.3 | implemented (binding NOT IMPLEMENTED) |
| Types: number/decimal/text/bool | §4.1 | implemented |
| Fixed-length arrays `type.array<T, N>` | §8.4 | implemented |
| Array literals (nested), indexed load/store | §8.4/9 | implemented |
| Array value semantics (copy on assign/pass) | §8.4 | implemented |
| Bounds checks + runtime trap | §8.4/13 | implemented |
| Fixed-width integers (all widths, wrap, lattice) | §4.2 | implemented |
| Conversion builtins `T.to_U(x)` | §4.4 | implemented (text pairs planned) |
| `f32` | §4.2 | NOT IMPLEMENTED (float milestone) |
| `type.text=1` gate | §5 | implemented |
| Variables, scoping, reassignment | §8.1 | implemented |
| Functions, recursion, return checking | §8.2 | implemented |
| Structs | §8.3 | NOT IMPLEMENTED (reserved) |
| Expressions, precedence, constant folding | §9 | implemented |
| `when`/`else` | §10 | implemented |
| `else when` chains | §10 | implemented |
| `loop` counted (to/until) + conditional | §10 | implemented |
| `break`/`continue` | §10 | implemented |
| `write`/`print` buffer model | §11 | implemented |
| Pointers, manual memory | §12 | NOT IMPLEMENTED |
| Recoverable errors (`guard`/`fail`) | §13 | NOT IMPLEMENTED |
| Runtime traps (buffer overflow, array bounds, div by zero) | §13 | implemented |
| Diagnostics: format, multi-error recovery | §14 | implemented |
| `-w`, `-xw`, `-s`, `-l` flags | §14 | implemented (no legacy constructs exist yet) |
| x86-64 freestanding native codegen | §15 | implemented |
| Assembler/linker integration (`as`, `ld`) | §15 | implemented |
| Own integrated assembler | §15 | NOT IMPLEMENTED (self-hosting milestone) |
| Optimization beyond constant folding | — | NOT IMPLEMENTED |
| ARM64 / RISC-V backends | — | NOT IMPLEMENTED (planned) |

"implemented" above means: covered by the test suite in `tests/`.

---

## 23. Changelog

### 0.3

* **Fixed-width integers** (§4.2): `int8`/`int16`/`int32`, `uint8`/`uint16`/
  `uint32`/`uint64`, with aliases `byte`=`uint8`, `int64`=`number`,
  `f64`=`decimal`. Wrapping two's-complement arithmetic; signedness-correct
  comparisons; contextual literal typing; exact-width storage in arrays,
  globals, and parameters. `f32` stays designed.
* **Conversion builtins** (§4.4): `T.to_U(x)` for every integer/decimal/bool
  pair — integer→integer wraps, `decimal`→integer truncates, constants fold
  (including global initializers). `text` conversions documented as planned.
* **Implicit widening lattice** (§4.4): signed→wider-signed,
  unsigned→wider-unsigned, unsigned→strictly-wider-signed, integer→`decimal`;
  the fitting-literal rule for declarations; `int8 + uint8` and
  `number + uint64` are compile errors suggesting an explicit conversion.
* **Division is checked** (§13): division/remainder by zero traps with exit
  71 (was a raw SIGFPE); `INT64_MIN / -1` wraps instead of faulting.
* **`bool` storage is 1 byte** as the type table always claimed (locals keep
  8-byte padded slots; the padding is unobservable).
* Fixes found while testing: constant folding compared and divided signed
  `number` values as unsigned (so `-1 < 1` folded to `false`, and folded
  division of negatives was wrong); folding a negated literal left its
  source constant on the machine stack, corrupting enclosing expressions
  (`x / -1` computed `1 / -1`); bare `make` built one object and stopped
  (the dependency rule was the Makefile's first target).
* Runtime: `rt_write_uint` for unsigned printing; `rt_div_trap`.
* IR: `I_CONV` (typed source→destination) replaces `I_CONV_NUM_DEC`; folding
  is signedness-aware and re-encodes to the operand width.
* Compiler: 243 checks; example `examples/fixed_width`.

### 0.2

* **`else when` chains** (§10): multi-branch condition selection on the
  `when` foundation; return analysis understands chains.
* **Arrays** (§8.4): fixed-length, value-copied, bounds-checked. Declaration
  `type.array<type.number, 5> xs = { ... }`; indexing `xs[i]`; indexed store
  `xs[i] = v`; nesting `grid[i][j]`; function parameters by value; global and
  column-member arrays with constant elements.
* Type system rebuilt on interned descriptors (`OkType` is now a pointer;
  scalars are singletons, arrays intern per element+count) — the foundation
  for pointers, structs, and unions.
* Internal ABI v1: array arguments travel as caller-owned copies addressed
  through one register (D23).
* Fixes found while testing: top-level `when` without `else` no longer swallows
  the following statement separator; global variables are now exported
  (`.globl`) so cross-module access links; call diagnostics no longer show an
  argument name in place of the function name (shared-buffer aliasing).
* Compiler: 178 checks (positive/negative/policy/flags/traps); examples
  `examples/arrays`, `examples/sieve`.

### 0.1

* Initial bootstrap release: language columns, modules, functions, control
  flow, text subsystem, freestanding x86-64 code generation.
