# Okular Language Specification

**Version:** 0.13 (short-circuit booleans; the parser written in Okular)
**Status:** Evolving draft
**Implementation:** bootstrap compiler in C (`bootstrap/`); the parser
also runs in Okular itself (`selfhost/parser`, milestone M4)

> 0.13 makes **`and`/`or` short-circuit** (§9): the right operand is
> evaluated only when it can change the result. Guarding a dereference
> or an index behind a condition — `p != null and *p == x`,
> `i < n and xs[i] == v` — is a normal Okular idiom; eager evaluation
> would trap. Two literal operands still constant-fold.
>
> 0.13 also fixes three implementation defects found while building the
> self-hosted parser: the heap allocator's split no longer overlaps
> adjacent blocks (fields stored before a later allocation were silently
> clobbered); releasing no longer erases the double-release marker; and
> record assignment through a pointer index or dereference
> (`p[i] = q[j]`, `*p = v`) now copies the record's bytes instead of
> storing the source's address (`heap_split_regression`,
> `struct_ptr_copy`).
>
> **Milestone M4 progressed further than any prior release: the parser
> itself is now written in Okular** (`selfhost/parser/src/parser.ok`,
> a faithful port of the C recursive descent parser). `--selfhost-parse`
> routes the compiler's parsing phase through it; `--selfhost-verify`
> differentially proves the trees byte-identical on the whole positive
> suite. See §23/§24 and docs/roadmap.md.

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

Active in 0.8:

```
type  function  struct  union  const  when  else  loop  from  to  until
break  continue  return  print  write  true  false
and  or  not  end  alloc  release  null
```

Reserved for designed-but-unimplemented features (using them as identifiers
is a compile error, so future adoption is non-breaking):

```
pointer  guard  fail  with
priv  pub  match  case
```

`libs`, `source`, `use`, `array`, and `ptr` are not keywords: they are
contextual segments of language column paths or of type references
(`[libs.use]`, `type.array<...>`, `type.ptr<...>`) and may appear as
ordinary identifiers elsewhere.

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
&  |  ^  ~  <<  >>     bitwise (0.11, §9)
=                       declaration/assignment (never equality)
->                      function return-type arrow
.  ,  (  )  {  }  [  ] punctuation
```

`=` never tests equality. Equality is always `==`. Word logical operators were
chosen over `&& || !` because they read naturally at statement level and are
impossible to confuse with bitwise operators (§9) — the symbol family above
is the bitwise family. Prefix `&` is address-of (§12); infix `a & b` is
bitwise AND — parse position decides, exactly like prefix `*` (dereference)
versus infix `*` (multiplication). `[` `]` index arrays (§8.4/9) and also
suppress newlines (§1.2). A `>>` token is one shift operator in expression
position; where a nested type argument closes (`ptr<ptr<number>>`), the
parser splits it back into the two `>` closings.

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
| struct types | named records (§8.3) | sum of fields + padding |

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
* **Text conversions are implemented (0.6)**: `number.to_text(n)`,
  `uint64.to_text(u)`, `decimal.to_text(d)` (the documented 6-fraction
  write format), `bool.to_text(b)`, `text.to_number(s)`,
  `text.to_decimal(s)`. Converting a constant folds at compile time —
  including global initializers (`type.text label = "n=" +
  number.to_text(7)`). Parsing is strict (`[+-]?digits`, optional fraction
  for decimals); malformed text is a compile error for constants and a
  fatal runtime trap (exit 76) for dynamic text. `T.to_bool` does not
  exist: compare explicitly (`x != 0`).
* Array types never convert.

### 4.5 Text operations (implemented in 0.9)

Three builtins give byte-level access to text without pointers — the
foundation for lexers, parsers, and every text-processing algorithm:

```ok
type.number n = text.length(s)          # byte count
type.uint8  b = text.byte_at(s, i)      # byte at i (bounds-checked)
type.text   t = text.slice(s, 1, 5)     # bytes [1, 5) — end-exclusive, O(1)
```

* `text.length(s)` is the byte length (UTF-8 text is measured in bytes;
  code points are a higher-level facility that arrives with the standard
  library's text module).
* `text.byte_at(s, i)` reads byte `i` as `uint8`. The index may be any
  integer type. Out-of-range positions are fatal traps (exit 70, the
  bounds-trap family — same philosophy as arrays, D24) with a text-specific
  message.
* `text.slice(s, from, to)` is the substring `[from, to)` — **end-
  exclusive**, matching `until` semantics. Bounds are `0 <= from <= to <=
  text.length(s)`; violations trap at runtime and are compile errors when
  the operands fold. The result shares the original's immutable bytes —
  slicing is pointer arithmetic, not a copy: O(1), and the slice lives as
  long as the original (text is immutable; nothing dangles).
* All three fold at compile time when their operands do: `const.n =
  text.length("hello")` is 5, `text.slice("okular", 0, 6)` in a global
  initializer is the constant `"okular"`.
* The names are builtins, not a namespace: a developer column named `text`
  with members `length`/`byte_at`/`slice` must be renamed (the compiler
  says so).
* These join `+` (concatenation) and `==`/`!=` (content equality) as the
  complete 0.9 text surface.

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

### 6.4 File builtins (implemented in 0.10)

Three builtins bridge programs to the filesystem until the standard
library's `fs` module arrives (written in Okular itself, M4+):

```ok
type.text src = fs.read("main.ok")        # whole file as text
type.number n = fs.save("out.txt", data)  # write text; bytes written
type.bool yes = fs.exists("out.txt")      # probe
```

* `fs.read(path)` reads the whole file into the text arena and returns it
  as `text` — immutable bytes, process lifetime, exactly like every other
  runtime-produced text. Reading a directory or a huge file is a fatal
  trap.
* `fs.save(path, data)` writes `data` to `path` (created or truncated,
  mode 0644) and returns the byte count. The name is `save`, not `write`,
  because `write` is a statement keyword and cannot follow `.` — the
  future Okular-written fs module will name freely.
* `fs.exists(path)` is `true` when the path opens for reading.
* **Failures are loud** (the §13 philosophy): any OS error is a fatal trap
  with exit code 77, the path, and the errno-shaped value on stderr —
  never a silent empty text or false.
* Paths are relative to the process's working directory; they are bytes,
  not decoded characters. These are builtins, not a namespace: a developer
  column named `fs` with these members must be renamed.

### 6.5 Environment builtins (implemented in 0.12)

Programs read their own invocation arguments:

```ok
type.number n = env.arg_count()      # argc, program name included
type.text first = env.arg(1)         # the first argument after the name
```

* `env.arg_count() -> number` is the argument count, exactly as the
  kernel reported it to `_start` — the program's own path is index 0.
* `env.arg(i) -> text` returns argument `i` (any integer index type).
  Bytes are copied into the text arena — immutable, process lifetime,
  like every other runtime-produced text.
* Out-of-range indices (`i >= arg_count()`, negatives included) are fatal
  bounds traps with a message naming the index and the count, exit 70 —
  never silent empty text (D24).
* These are builtins, not a namespace: a developer column named `env`
  with these members must be renamed. Reading environment variables
  (`env.var`-style) is designed future work.
* Rationale: command-line arguments are the smallest, most universal
  program input — real tools need them before any standard library
  exists, and the self-hosting toolchain itself will need them (the
  Okular-written lexer takes its input path this way).

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

#### Constants (implemented in 0.8)

```ok
const.limit = 100
const.greeting = "hi"
const.combined = limit * 3 + 2        # folds: 302

config = {
    const.capacity = 512
    function.is_big(number.n) -> bool {
        return n > capacity
    }
}.end
```

* `const.name = expr` declares a named constant at file or column scope —
  single line, like variable declarations. Not inside function bodies.
* The value must fold at compile time: literals, other constants,
  constant arithmetic, conversions. Anything runtime-dependent is a
  compile error with the `const` context named.
* Constants are `number`, `decimal`, `text`, `bool`, or fixed-width values —
  the scalar world. Arrays, structs, unions, and pointers are not constants.
* Reads **inline the folded value** — no storage, no load; the value is the
  code. Constants fold into other constants, global initializers (array
  elements, struct fields), and constant expressions.
* Constants cannot be assigned (`limit = 5` is a compile error) and cannot
  collide with variable/type/function names in the same scope.
* Array lengths still require literals in 0.8 (`type.array<type.number,
  limit>` is designed, not implemented — it needs module-aware parsing).

#### Type inference (implemented in 0.8)

```ok
type.auto x = limit + 5          # number
type.auto d = 1.5                # decimal
type.auto t = "hi" + "!"         # text
type.auto p = &base.x            # ptr<number> — the FIELD's type
type.auto r = existing_rect      # Rect (copies)
```

* `type.auto name = init` infers the type from the initializer's checked
  type — locals, globals, and column members.
* Cannot infer from `{ ... }` literals (they need a target type), from
  `null` (needs a pointer type), or from void expressions. Each rejection
  says so precisely.
* Parameters, return types, struct/union members, array elements, and
  pointer pointees stay explicit — inference is for initializers only.
* An auto global must precede its uses in file order (its type is not
  known before it is checked).

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
  and the callee sees only that copy (§8.4, D23). Reference-style parameter
  passing is available through pointers since 0.4: `ptr<number>.p` hands the
  caller's storage to the callee (out-parameters).
* Functions **cannot return arrays directly** — the return ABI carries a
  single register value. Since 0.4 the pointer route works: return
  `ptr<array<T, N>>` (heap- or global-backed).

### 8.3 Structs (implemented in 0.5)

A struct is a named record type: fields in declaration order, natural
alignment, explicit size:

```ok
struct.Packet = {
    type.uint32 length
    type.uint8 flags
}.end

type.Packet p = {120, 0xFF}
p.length = 124
write(p.flags)
```

* **Declaration** `struct.Name = { fields }.end` at the top of a file or
  inside a column. Struct names form one flat type namespace across the
  project (a documented bootstrap simplification), and forward references
  are legal — a two-phase loader lexes every file before parsing any.
* **Fields** use the standard declaration grammar *without initializers*
  (explicit construction instead of silent defaults). Every field type is
  legal: scalars, fixed-width integers, `text`, arrays, nested structs,
  pointers (including `ptr` to the struct itself — linked structures).
  A struct may not contain itself, directly or through a cycle.
* **Layout** is predictable: fields sit at their natural alignment in
  declaration order; the struct's alignment is its largest field's
  alignment; the size is rounded up to that alignment (tail padding).
  `struct.Mixed = { int8 a; int32 b; int16 c }` occupies 12 bytes with
  `a` at 0, padding 1–3, `b` at 4, `c` at 8. Explicit layout control
  (packed/offset attributes) is designed, not implemented.
* **Literals** are positional: `type.Name v = { f1, f2, ... }` with one
  initializer per field in declaration order, each following the
  assignment rules (safe widening, fitting literals). Nested literals
  nest (`{{1, 2}, {3, 4}}`). Literals only initialize declarations.
* **Field access** is `value.field` — on variables (`p.length`), through
  namespaces (`config.center.x`), on array elements (`pts[i].x`), and on
  pointers with **auto-deref** (`ptr.length` means `(*ptr).length`,
  null-checked). Assignment `value.field = expr` stores; whole
  struct-valued fields copy.
* **Value semantics.** Assignment, initialization, and parameter passing
  copy the contents (arrays and structs alike). Mutating a copy never
  touches the original. Reference-style access goes through `ptr<Name>`
  (§12).
* **Parameters** pass by value (caller-owned copy, one register — the
  same ABI shape as arrays). **Functions cannot return structs directly**
  (single-register return ABI): return `ptr<Name>` or write through a
  pointer parameter.
* **Globals** may be structs with constant field initializers, emitted
  into `.data` with explicit padding. Arrays of structs, structs in
  arrays, `array<Name, N>` and `ptr<Name>` all compose.
* Structs are not comparable (`==` is an error — compare fields), not
  writable as a whole, and not convertible (no casts between struct
  types).

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
  copy. (Reference-style access exists since 0.4: take `&xs[i]` or pass
  `ptr<T>` — §12.)
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

### 8.5 Unions (implemented in 0.7)

A union is one storage shared by several members — the low-level
reinterpretation type (spec §0's "no ceiling" principle made concrete):

```ok
union.Word = {
    type.uint32 u
    type.uint8 low
}.end

type.Word w = { 258 }   # activates `u`; w.low reinterprets byte 0
```

Rules:

* **Declaration** mirrors `struct`: top level or inside a column, members
  are `type.T name` lines, the body closes with `}.end`. Struct and union
  names share one flat namespace — a duplicate name of either kind is a
  compile error. Forward references and cross-file references resolve the
  same way structs do (the two-phase loader).
* **Layout is overlap.** Every member sits at offset 0; the union's size is
  the widest member rounded up to the widest member's alignment; the union's
  alignment is the widest member's alignment. A `uint32`/`uint8` union is
  therefore 4 bytes, 4-aligned.
* **Literals are type-directed.** `type.U v = { value }` takes exactly ONE
  value and activates the **first member whose type accepts it** under the
  assignment rules (§4.4 — safe widening, fitting literals). `{ 65 }` with
  members `number n` and `uint8 b` activates `n` (first). A nested literal
  `{ { 1, 2 } }` targets the first array/record member. No member accepting
  the value is a compile error with the member list; more than one value is
  a compile error.
* **Member access** is `.name` exactly as for structs — including through
  pointers (`pv[0].n`, with the 0.4 null check) and after indexing
  (`cells[1].id`).
* **Reading is the documented unsafe part.** Okular does not track the
  active member: reading `w.low` after writing `w.u` reinterprets the
  shared bytes. That is the point of unions — but it means the value read
  depends on the byte-level representation, which the compiler defines:
  two's-complement little-endian on the x86-64 backend. Padding bytes are
  indeterminate after member stores (globals are zero-filled at load).
* **Value semantics.** Assignment, initialization, and parameter passing
  copy the union's full storage — copies are independent, byte for byte.
* **Unions are not comparable** (`==`/`!=` are errors — padding and
  inactive bytes make byte equality meaningless), not writable as a whole
  (`write(u)` is an error with guidance), and functions cannot return them
  directly in 0.7 (same restriction and workaround as structs, §8.3).
* **Nesting works both ways**: a struct field may be a union, a union
  member may be a struct/array/another union, arrays of unions and
  unions on the heap (`ptr<U>`, `alloc<U>(n)`) follow the 0.4/0.5 rules.
* Globals may be unions; the initializer folds as one constant, the
  activated member's encoding is emitted, and the remaining bytes are
  zero-filled — deterministic `.data` even for the overlapping tail.

---

## 9. Expressions

Precedence, loosest to tightest:

| Level | Operators | Associativity |
|---|---|---|
| 1 | `or` | left |
| 2 | `and` | left |
| 3 | `==  !=  <  <=  >  >=` | left (non-associative) |
| 4 | `\|` | left |
| 5 | `^` | left |
| 6 | `&` | left |
| 7 | `<<  >>` | left |
| 8 | `+  -` | left |
| 9 | `*  /  %` | left |
| 10 | unary `not`, `-`, `~`, `&` (address-of), `*` (deref) | prefix |
| 11 | call `f(x)`, member `a.b` (struct fields, §8.3), index `a[i]`, literals, names, `( expr )` | — |

* `+` on `text` concatenates. `+` on `number`/`decimal` adds. There is no
  `+` between `text` and `number` (planned explicit conversion builtins).
* Comparisons yield `bool`. `and`/`or`/`not` operate on `bool` only.
* **Short-circuit (0.13)**: `a and b` evaluates `b` only when `a` was
  `true`; `a or b` evaluates `b` only when `a` was `false`. Guarding a
  dereference or an index behind a condition — `p != null and *p == x`,
  `i < n and xs[i] == v` — is a normal Okular idiom and must not trap;
  eager evaluation would. Two literal operands still constant-fold
  (`true and false` is `false` at compile time).
* Division `/` on `number` is integer division; on `decimal` it is floating
  division. `%` is remainder, `number` only.
* **Bitwise operations (0.11)** — `&`, `|`, `^` combine two integer values
  of combinable types through the widening lattice (§4.2/§4.4), exactly
  like `%`; the result carries the common type. `~x` is bitwise not on any
  integer type and preserves the operand's type. Decimal, `text`, `bool`,
  and pointers are rejected with precise diagnostics — there is no silent
  truthiness or pointer-as-integer path.
* **Shifts (0.11)** — `value << count` and `value >> count`: the result
  carries the *value's* type; the count may be any integer type. `>>` is
  arithmetic for signed types and logical for unsigned types; `<<` wraps
  through the width like all arithmetic (§4.2). A shift count outside
  `[0, width)` is a bug, not a wrap: constant expressions with out-of-range
  counts fail to compile, and runtime counts out of range trap fatally
  (exit 72, §13) — the x86 hardware masking of counts is deliberately not
  exposed. Precedence note: bitwise operators bind *tighter* than
  comparisons (Rust ordering), so `flags & MASK == FLAG` reads as
  `(flags & MASK) == FLAG` — the intuitive grouping, not C's; and shifts
  bind *looser* than `+`/`-` (C and Rust ordering), so `1 << 2 + 3` shifts
  by 5 — parenthesize mixed shift/arithmetic when in doubt.
* Constant expressions (literals folded at compile time) are required for
  global initializers (§7) and are folded by the IR constant-folding pass;
  bitwise operations and in-range shifts fold with the same signedness and
  wrap rules as runtime evaluation.
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

## 12. Memory Model (implemented in 0.4)

Okular's memory model is now real, not just designed:

* **Stack allocation** is the default for locals (unchanged since 0.1).
* **Manual heap control** is explicit and always available:

  ```ok
  type.ptr<type.number> p = alloc<type.number>(3)
  p[0] = 1
  release(p)
  ```

* **Pointer types** are `ptr<T>` for any value type T (nested pointers
  included: `ptr<ptr<number>>`). Declaration form `type.ptr<type.number>`,
  parameter/return forms `ptr<number>.p`, `-> ptr<number>`.
* **Pointers are first-class values**: address-of (`&x`, `&xs[i]`, `&*p`),
  dereference (`*p` as expression, `*p = v` as statement), pointer
  indexing (`p[i]`), arithmetic (`p + n`, `p - n` scaled by `size(T)`;
  `p - q` is the signed element difference), comparisons (`==`, `!=`
  against a matching pointer or `null`), and `null` itself (assignable to
  any `ptr<T>`; `release(null)` is a no-op).
* **The heap is a real allocator** (runtime shim): mmap-backed pools,
  16-byte block headers, first-fit with splitting, address-ordered free
  list with neighbor coalescing. Zero-byte allocations trap; releasing an
  invalid or already-released pointer is detected through header
  validation and traps.
* **Safety profile, honestly stated:**
  * Dereferencing or indexing through `null` traps (exit 73).
  * `alloc(0)` and invalid/double `release` trap (exit 74).
  * **Pointer indexing is NOT bounds-checked** — an allocation's length is
    not recoverable from a derived pointer. Arrays (`array<T, N>`) remain
    the always-checked default (§8.4).
  * **Use-after-release is NOT detected** (no quarantine). Releasing
    memory that has live pointers into it is undefined behavior, exactly
    as documented here.
  * **Dangling stack pointers** are possible: `&local` escaping its
    function (for example by returning it) is undefined behavior. Static
    escape analysis is future work; the hazard is stated plainly instead
    of being hidden.
  * Integers never convert to or from pointers — no
    number-to-address casts in 0.4 (a `type.mem=1`-gated raw-address
    facility remains the designed escape hatch for driver-level work).
* No garbage collection, mandatory or otherwise (design principle: native
  performance). Region/arena helpers are planned in the standard library.
* Global pointer variables initialize to `null` only; `&global` in a
  global initializer awaits relocation support (state it, don't fake it).

---

## 13. Error Model (design; partial in 0.1)

* **Compile-time errors** — precise diagnostics (§15), build fails, no
  executable is produced from required code.
* **Runtime fatal errors** — traps with a message and a nonzero exit code:
  array bounds and text-arena exhaustion exit 70; **integer division by zero
  (0.3) exits 71**; **shift count out of range (0.11) exits 72**; **null
  dereference (0.4) exits 73**; **invalid or zero-sized allocation /
  invalid release (0.4) exits 74**; output-buffer overflow exits 75;
  **malformed text in `text.to_number`/`text.to_decimal` (0.6) exits 76**;
  **file operation failures (0.10) exit 77**. Implemented for the cases the
  runtime can hit.
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
| D26 | Union literals are type-directed: the FIRST member whose type accepts the value is activated (§8.5) | every member sits at offset 0, so selection affects only checking and the store's type; declaration order breaks ties predictably |
| D27 | Constants inline their folded value (no storage, no load); `type.auto` infers from the initializer only | consts stay compile-time facts; inference stays local to declarations — params/returns/members stay explicit |
| D28 | `text.slice` is end-exclusive and O(1) (shares immutable bytes); text bounds trap like array bounds (exit 70) | `until`-consistent ranges; slicing is pointer arithmetic, not copying; safety stays opt-out, not opt-in |
| D29 | File failures are fatal traps (exit 77) naming path and errno; file bytes land in the text arena | the loud-failure philosophy extends to I/O; no silent empty reads; the fs builtins are a bridge to the Okular-written stdlib module |

---

## 20. What 0.2 Deliberately Does NOT Contain

Slices, structs, ~~unions~~ (0.7), pointers, manual allocation, FFI, threads,
match expressions, ~~type inference, constants~~ (0.8), aliases, `priv`, block
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
| Conversion builtins `T.to_U(x)` | §4.4 | implemented (text pairs included, 0.6) |
| `f32` | §4.2 | NOT IMPLEMENTED (float milestone) |
| `type.text=1` gate | §5 | implemented |
| Variables, scoping, reassignment | §8.1 | implemented |
| Functions, recursion, return checking | §8.2 | implemented |
| Structs (layout, literals, fields, value copies) | §8.3 | implemented (explicit layout attributes planned) |
| Unions (overlap layout, type-directed literals, reinterpretation) | §8.5 | implemented (0.7) |
| Constants `const.name = value` (fold, inline, no storage) | §8.1 | implemented (0.8) |
| Type inference `type.auto x = init` | §8.1 | implemented (0.8) |
| Text ops: `text.length` / `text.byte_at` / `text.slice` | §4.5 | implemented (0.9) |
| Text from bytes: `text.from_bytes` | §4.5 | implemented (0.13) |
| System builtins: `sys.write/read/open/close/size/mmap/exit/chmod` | §6.6 | implemented (0.13) |
| Pointer address conversions: `ptr.to_number` / `number.to_ptr` | §12 | implemented (0.13) |
| Keyword path members (`sys.write`, `mod.print`) | §1 | implemented (0.13; `end` stays reserved) |
| File builtins: `fs.read` / `fs.save` / `fs.exists` | §6.4 | implemented (0.10) |
| Environment builtins: `env.arg_count` / `env.arg` | §6.5 | implemented (0.12) |
| Short-circuit `and`/`or` | §9 | implemented (0.13) |
| Constants as array lengths | §8.1 | NOT IMPLEMENTED (needs module-aware parsing) |
| Expressions, precedence, constant folding | §9 | implemented |
| Bitwise operators `& \| ^ ~` (0.11) | §9 | implemented |
| Shifts `<< >>` with range traps (0.11) | §9/§13 | implemented |
| `>>` splitting in nested type arguments (0.11) | §1.8/§9 | implemented |
| `when`/`else` | §10 | implemented |
| `else when` chains | §10 | implemented |
| `loop` counted (to/until) + conditional | §10 | implemented |
| `break`/`continue` | §10 | implemented |
| `write`/`print` buffer model | §11 | implemented |
| Pointers, manual memory | §12 | implemented (unchecked indexing, use-after-release, dangling `&local` documented) |
| Recoverable errors (`guard`/`fail`) | §13 | NOT IMPLEMENTED |
| Runtime traps (bounds, div by zero, null deref, bad alloc/release) | §13 | implemented |
| Diagnostics: format, multi-error recovery | §14 | implemented |
| `-w`, `-xw`, `-s`, `-l` flags | §14 | implemented (no legacy constructs exist yet) |
| x86-64 freestanding native codegen | §15 | implemented |
| Assembler/linker integration (`as`, `ld`) | §15 | implemented |
| Own integrated assembler | §15 | NOT IMPLEMENTED (self-hosting milestone) |
| Optimization beyond constant folding | — | NOT IMPLEMENTED |
| ARM64 / RISC-V backends | — | NOT IMPLEMENTED (planned) |
| Self-hosted lexer (token stream in Okular) | — | implemented (0.11; `--selfhost-lex` bridge 0.12) |
| Self-hosted parser (full grammar in Okular) | — | implemented (0.13; `--selfhost-parse` bridge, differentially verified) |
| Machine AST protocol (parser bridge) | — | implemented (0.13) |
| Self-hosted runtime (formatters, arena, allocator, fs) | — | implemented (0.13; `selfhost/runtime`, on `sys.*`) |
| Integrated assembler: native ELF emission from Okular | §15 | begun (0.13; `selfhost/assembler`, M5 seed) |

"implemented" above means: covered by the test suite in `tests/`.

---

## 23. The System Module (implemented in 0.13)

The typed raw-syscall floor (`sys.*`). Every entry is one Linux x86-64
syscall plus ABI adaptation — no policy, no buffering, no hidden state.
The Okular-written runtime (`selfhost/runtime`) is built entirely on
these; user programs may call them for direct system interfaces.

```ok
type.number n  = sys.write(1, "bytes to stdout\n")     # fd, buffer -> count
type.number fd = sys.open("path", 577, 420)             # path, flags, mode -> fd
type.number g  = sys.read(fd, buf, 64)                  # fd, ptr<byte>, len -> count
type.number sz = sys.size(fd)                           # fd -> file size
type.number c  = sys.close(fd)                          # fd -> 0 or -errno
type.number m  = sys.chmod("path", 448)                 # path, mode -> 0 or -errno
type.ptr<type.byte> p = sys.mmap(4096)                  # len -> bytes (null on failure)
sys.exit(1)                                             # terminate; never returns
```

Semantics, honestly:

* `sys.write` takes the buffer as `text` (the immutable byte view);
  `sys.read` reads into a caller-owned `ptr<byte>` buffer.
* `sys.mmap` maps anonymous zeroed private memory; the result is raw
  byte storage, not a heap block — `release` must not be called on it.
  Failures return `null`, never a trap.
* `sys.open`/`read`/`close`/`size`/`chmod` return negative errno-shaped
  values on failure (the kernel convention), not traps: syscall-level
  error handling belongs to the caller.
* `sys.exit` never returns; the compiler emits `hlt` after it.
* These are the floor. Everything else — buffering, parsing, the
  allocator, file convenience (`fs.*`) — is policy above them, and in
  0.13 that policy also exists as Okular code (`selfhost/runtime`).

Pointer address conversions (§12, 0.13): `ptr.to_number(p)` reads any
pointer's address as u64 bits; `number.to_ptr(x)` reifies `ptr<byte>`
from them. Raw by design — the memory-model escape hatch. Named after
the conversion family (`T.to_U`): the source type names the operation.

## 24. Changelog

### 0.13

* **Short-circuit `and`/`or`** (§9): the right operand evaluates only when
  it can change the result; guards like `p != null and *p == x` no longer
  trap. Two literals still fold.
* **The parser written in Okular** (milestone M4): `selfhost/parser`
  ports the full recursive descent grammar — expressions with the
  complete precedence ladder, statements, functions, structs, unions,
  columns, directives, the `>>` split for nested type arguments, and the
  recovery model. `--selfhost-parse BIN` makes it the compiler's parser
  (sema consumes the reconstructed AST); `--selfhost-verify BIN`
  differentially compares the two parsers' serializations byte for byte.
  All positive suite cases: identical trees, identical program output.
* Fixed the heap allocator's block-split overlap (`rt_alloc` wrote the
  new block's header inside the previous allocation's payload; fields
  stored before a later allocation were silently clobbered).
* Fixed double-release detection (`rt_release`'s forward coalescing
  erased the poisoned marker).
* Fixed record assignment through pointer indexing and dereference
  (`p[i] = q[j]`, `*p = v`): the code stored the source's ADDRESS instead
  of copying the record's bytes. Found by the self-hosted parser's token
  buffer growth.
* The Okular-written lexers now accept `_` digit grouping (`1_000_000`)
  like the C lexer and stop text literals at newline.
* **The system module** (§23/§6.6): `sys.write/read/open/close/size/
  mmap/exit/chmod` — the typed raw-syscall floor. Keywords are now legal
  dotted-path members (`sys.write`, §1) except `end`.
* **`text.from_bytes`** (§4.5): adopt a byte buffer as immutable text —
  the raw-memory bridge the Okular runtime builds every text through.
* **Pointer address conversions** (§12): `ptr.to_number` /
  `number.to_ptr` — the explicit address-bits escape hatch.
* **The runtime written in Okular** (milestone M4): `selfhost/runtime` —
  output formatters, the text arena, all to_text/parse conversions,
  text equality and concatenation, the free-list heap allocator
  (splitting, coalescing, double-release detection, the 0.13 block
  geometry), and the file operations — on the `sys.*` floor. What
  remains in C is the syscall wrappers themselves.
* Short-circuit booleans and the parser work above land in the same
  0.13 release: the parser found the codegen defects, and the runtime
  proves the fixes at scale.
* **The integrated assembler begins** (§15, M5 seed): `selfhost/assembler`
  emits a native ELF64 executable from Okular — headers, code, symbol
  fixups (ABS32 data references, REL32 calls), chmod — with no `as` and
  no `ld`. The emitted binary runs: "native from Okular / no as, no ld"
  (`tests/cases/positive/selfhost_assembler`; the suite executes the
  artifact through its new `exec_after` chain).

### 0.12

* **Environment builtins** (§6.5): `env.arg_count() -> number`,
  `env.arg(i) -> text` — the program's own command-line arguments.
  `_start` forwards the kernel argument vector to `rt_init`; argument
  bytes copy into the immutable text arena; out-of-range indices are
  bounds traps (exit 70) naming index and count. A developer column
  named `env` must be renamed, exactly like `fs`.
* The test runner supports an `args` file per case (one line, split on
  spaces) so programs with arguments are testable.
* **Self-hosting: the lexer bridge (M4 begun)**:
  `okular --compile --selfhost-lex <binary>` tokenizes every project
  file through the compiled Okular-written tokenizer
  (`selfhost/lexer`, machine token stream per
  `bootstrap/src/selfhost_bridge.c`) instead of the C lexer. The C
  lexer stays the default; the whole positive suite was verified to
  produce identical results through both. `make selfhost-lex` builds
  the component; `tests/cases/flags/selfhost_lex` covers the flag.
* Tests: 517 → 528 (env args with arguments, the index trap, two
  negative cases) and 530 with the lexer-bridge flag case; spec
  0.11 → 0.12.

### 0.11

* **Bitwise operations** (§9): `&`, `|`, `^` combine integer values
  through the widening lattice (same shape as `%`); `~x` is bitwise not
  on any integer type. Constant folding included — consts and global
  initializers fold with runtime signedness and wrap semantics.
* **Shifts** (§9/§13): `value << count`, `value >> count`. The result
  carries the value's type; the count may be any integer type.
  Arithmetic shift for signed, logical for unsigned, wrapping left
  shifts. Out-of-range counts (`>= width`, negatives included) are a
  compile error in constant expressions and a fatal runtime trap
  (exit 72) otherwise — hardware count masking is not exposed.
* **Precedence** (§9): comparisons bind looser than `|`/`^`/`&`
  (Rust ordering — `a & b == c` groups intuitively); shifts bind looser
  than `+`/`-` (C/Rust ordering). Prefix `&` (address-of) and infix `&`
  (bitwise AND) coexist by parse position, like prefix/infix `*`.
* **`>>` token splitting** (§1.8): the lexer emits one `>>` token; the
  parser splits it into two `>` closings where nested type arguments
  end, so `ptr<ptr<number>>` and `alloc<type.array<type.number, 3>>(2)`
  parse without spaces.
* Tests: 468 → 514 (bitwise basics/shifts/precedence/fold/globals,
  nested generics, two shift-trap programs, eight negative cases);
  `examples/bitwise`; spec 0.10 → 0.11.
* **Self-hosting seed (M3)**: `selfhost/lexer` — the tokenizer written
  in Okular (`selfhost/lexer/src/lexer.ok`), same token set and kind
  numbering as `bootstrap/src/lexer.c`, proven by the golden-stream test
  `tests/cases/positive/selfhost_lexer` (517 checks total).

### 0.10

* **File builtins** (§6.4): `fs.read(path) -> text` (whole file, text
  arena, immutable), `fs.save(path, data) -> number` (bytes written;
  create/truncate, 0644), `fs.exists(path) -> bool`. Raw syscalls
  (open/read/write/close/fstat) in the freestanding runtime; OS errors
  are fatal traps with exit 77, the path, and the errno on stderr. The
  write-side name is `save` because `write` is a statement keyword.
* The test runner now executes programs with the case directory as the
  working directory, making relative-path tests deterministic.
* Tests: 457 → 468 (fs basics, the read trap, two negative cases);
  `examples/file_io`; spec 0.9 → 0.10.

### 0.9

* **Text operations** (§4.5): `text.length(s)` (bytes), `text.byte_at(s,
  i)` (uint8, bounds-checked, any integer index), `text.slice(s, from,
  to)` (end-exclusive `[from, to)`, O(1) — shares the immutable bytes).
  All three fold at compile time when operands do (consts and global
  initializers included). Bounds violations trap with exit 70 and a
  text-specific message; constant slice bounds are validated at compile
  time.
* **Fix (0.6 ABI defect)**: text locals' length word was stored one slot
  *below* its storage — any later local clobbered it (`type.text s` +
  `type.number x` corrupted `s`'s length). Slots now keep both words
  inside their own storage; parameter adoption matches.
* **Fix (0.2 ABI defect)**: adopting one parameter clobbered scratch
  registers that later parameters still needed — the third text parameter
  (arg register rdx) crashed the program at entry. Argument registers are
  now saved before the adoption loop. Regression: `text_local_layout`.
* Tests: 430 → 457 (text ops basics/const/chains, three trap programs,
  four negative cases, the layout regression); `examples/text_ops` (a
  substring scanner built from slices and equality); spec 0.8 → 0.9.

### 0.8

* **Constants** (§8.1): `const.name = expr` at file or column scope. The
  value folds at compile time (literals, other consts, constant arithmetic,
  conversions); reads inline the folded value — no storage, no load.
  Constants fold into other constants and into global initializers
  (array elements, struct fields). Assignment to a constant and duplicate
  names are compile errors. Consts are scalar/text only.
* **Type inference** (§8.1): `type.auto name = init` for locals, globals,
  and column members. Inference is initializer-driven; literals, `null`,
  and void expressions are rejected with precise messages. Parameters,
  returns, record members, array elements, and pointees stay explicit.
* **Fix (0.5 defect)**: `&record.field` now yields a pointer to the FIELD
  (type and address) — previously it silently took the whole record's
  address with the record's type. Nested paths (`&r.corner.y`) and pointer
  parameters now write through the correct member. Regression test:
  `positive/field_addr`.
* Tests: 388 → 430 checks (5 positive: const basics/columns/globals, auto
  basics/types, field_addr regression; 8 negative: non-constant, assignment,
  in-function, duplicates, auto literal/null/param/return);
  `examples/consts`; spec 0.7 → 0.8.

### 0.7

* **Unions** (§8.5): `union.Name = { type.T member ... }.end` — the overlap
  type. Every member sits at offset 0; size = widest member rounded to the
  widest alignment. Literals are **type-directed** (`{ value }` activates
  the first member whose type accepts it — D26); member access, pointers,
  indexing, nesting in structs, arrays of unions, heap unions, and copy
  semantics all follow the struct machinery. Globals emit the activated
  member's constant and zero-fill the overlap tail.
* Reinterpretation semantics are documented, not tracked: reading a member
  other than the last one written is the explicitly-unsafe operation unions
  exist for (two's-complement little-endian on x86-64).
* Struct/union type names share one flat namespace; duplicate names of
  either kind are compile errors.
* Tests: 349 → 388 checks (7 positive programs: basics, in-struct, globals,
  copies, params, arrays, heap; 6 negative: arity, unknown member,
  no-accepting member, whole-union write, union returns, duplicate names);
  `examples/unions`; spec 0.6 → 0.7.

### 0.6

* **Text conversion builtins** (§4.4): `number.to_text`, `uint64.to_text`,
  `decimal.to_text`, `bool.to_text`, `text.to_number`, `text.to_decimal`.
  Constant arguments fold at compile time (global initializers included,
  and conversions nested inside foldable expressions); dynamic conversions
  call the runtime. `decimal` travels through the internal ABI as raw bits
  in integer registers, exactly as documented.
* Parsing is strict (`[+-]?digits[.digits]`); malformed literals are
  compile errors, malformed runtime text traps with exit 76 — loud
  failures, never silent zeros (the `guard`/`fail` model remains the
  designed recoverable path).
* Integer literal arguments to conversions take the source type when they
  fit (`uint64.to_text(5)` formats unsigned — contextual typing, §4.2).
* Tests: 343 → 349 checks (conversions of every kind, constant folds,
  the parse trap); spec 0.5 → 0.6.

### 0.5

* **Structs** (§8.3): `struct.Name = { fields }.end` with natural-alignment
  layout (offsets, padding, size documented per type), positional literals
  `{ ... }` (nested; same rules as array literals), field access
  `value.field` on variables, namespace paths, array elements, and pointers
  (auto-deref, null-checked), field assignment, whole-value copies, struct
  parameters by value, global structs in `.data` with explicit padding,
  arrays of structs, structs in arrays, `ptr<Name>`, and self-referential
  pointer fields (linked structures).
* Struct names are one flat type namespace across the project; forward
  references work because the loader now lexes every file before parsing
  any (two-phase load). Cycles and unknown field types are diagnosed.
* Functions cannot return structs directly (single-register return ABI):
  return `ptr<Name>` or write through a pointer parameter.
* IR: `I_ADDOFF` (field offsets); struct expressions evaluate to addresses
  exactly like arrays; struct literals store field-by-field in place.
* Tests: 301 → 343 checks; example `examples/structs`.

### 0.4

* **Pointers & manual memory** (§12): `ptr<T>` types (nested pointers
  included), `&x` / `&xs[i]` / `&*p` address-of, `*p` dereference loads and
  `*p = v` stores, unchecked pointer indexing `p[i]`, scaled arithmetic
  `p ± n`, element-difference `p - q`, `==`/`!=` against matching pointers or
  `null`, and the `null` literal (assignable to any pointer).
* **Heap** (§12): `alloc<T>(count)` and `release(p)` over a real allocator —
  mmap pools, 16-byte headers, first-fit with splitting, address-ordered
  free list with coalescing; zero-size and invalid/double releases trap
  (exit 74); `release(null)` is a no-op.
* **Null safety** (§13): every dereference, pointer store, and pointer
  index null-checks; `null` traps with exit 73.
* Safety profile stated honestly: pointer indexing is unchecked, use-after-
  release is undetected, and `&local` escaping its function is undefined —
  documented in §12 rather than hidden. Arrays stay always-checked.
* Runtime: `rt_alloc`/`rt_release` (freestanding, mmap syscall),
  `rt_null_trap`.
* IR: `I_ALLOC`, `I_RELEASE`, `I_PTRCHK`, `I_PTR_SCALE`, `I_PTR_DIFF`;
  pointer arithmetic and comparisons lower through the typed stack machine.
* Tests: 246 → 301 checks; example `examples/pointers`.

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
