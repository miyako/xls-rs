# xls_rs
### Wraps the `xls-rs` CLI to convert and manipulate spreadsheet files via `4D.SystemWorker`.

> xls_rs.new (class : 4D.Class)

| Parameter | Type | | Description |
| --- | --- | --- | --- |
| class | 4D.Class | -> | Optional custom controller class; must extend `_xls_rs_Controller` (default: `cs.xls_rs._xls_rs_Controller`) |

## Description

`cs.xls_rs.xls_rs` extends [`_CLI`](_CLI.md) and wraps the `xls-rs` executable, a Rust-based spreadsheet conversion tool. It provides `execute()` to run one or more `xls-rs` subcommands with support for both synchronous and asynchronous operation.

If a class that does not extend `_xls_rs_Controller` is passed, the constructor silently falls back to `cs.xls_rs._xls_rs_Controller`. Detection walks the full superclass chain.

### Properties

| Property | Type | Description |
| --- | --- | --- |
| onData | 4D.Function | Called by the controller on each parsed progress update (async mode only) |
| onResponse | 4D.Function | Called by the controller when a command completes |
| onError | 4D.Function | Called by the controller on worker error |
| onTerminate | 4D.Function | Called by the controller when the worker terminates |
| worker | 4D.SystemWorker | The currently active worker (read-only, from controller) |
| controller | cs.xls_rs._xls_rs_Controller | The attached controller instance (read-only) |

### Methods

#### execute (option : Variant; events : Object) → Collection

Runs one or more `xls-rs` commands built from a collection of task arrays, in sync or async mode.

| Parameter | Type | | Description |
| --- | --- | --- | --- |
| option | Collection \| Collection of Collections | -> | A single task array or a collection of task arrays (see below) |
| events | Object | -> | Event callbacks; if `events.onResponse` is set the call is asynchronous |
| Result | Collection | <- | Collection of stdout strings (one per task), or `Null` in async mode |

**Sync mode** (no `events.onResponse`): each worker runs to completion before the next starts. `controller.stdOut` is collected into `$results` and `controller.clear()` is called after each command. Returns a Collection of raw stdout strings, or `Null` entries where `-o` / `--output` was specified.

**Async mode** (`events.onResponse` present): workers are started without waiting. Returns `Null` immediately. Progress updates are delivered to `events.onData` as percentage objects (see [`_xls_rs_Controller`](_xls_rs_Controller.md)). In async mode the `-#` progress-bar flag is prepended automatically.

**Task array element types** — each task is a flat collection where elements are interpreted by type:

| Element type | Behaviour |
| --- | --- |
| Text | Shell-escaped and appended as-is, except for the special values below |
| Real / Integer | Appended as a numeric string |
| Boolean / Null | Ignored |
| 4D.File / 4D.Folder | Platform path is shell-escaped and appended |
| Object with `.data` | Value stored as the per-command context, accessible in callbacks via `SYSTEM_WORKER_CONTEXT` |
| Object with `.file` | Blob or Text posted to worker stdin (streaming mode) |

**Special text values:**

| Value | Effect |
| --- | --- |
| `"-#"` | Suppressed (added automatically in async mode) |
| `"-o"` / `"--output"` | Marks output as going to a file; `Null` is pushed to results instead of stdout |
| `"@-"` / `"-"` | Activates streaming mode; stdin payload is posted from `.file` |

### events object properties

| Property | Type | Description |
| --- | --- | --- |
| onResponse | 4D.Function | Required for async mode; called when each command completes |
| onData | 4D.Function | Optional; receives `{percentage, context}` progress objects |
| onError | 4D.Function | Optional; called on worker error |
| onTerminate | 4D.Function | Optional; called when the worker terminates |

## Examples

### Convert CSV to XLSX (async)

```4d
var $xls_rs : cs.xls_rs.xls_rs
$xls_rs:=cs.xls_rs.xls_rs.new(Null)

var $in : 4D.File
var $out : 4D.File
$in:=Folder(Temporary folder; fk platform path).folder(Generate UUID).file("data.csv")
$in.parent.create()
$in.setText("Name,Score\nAlice,95\nBob,87\n")
$out:=Folder(fk desktop folder).file("data.xlsx")

var $events : Object
$events:={}
$events.onResponse:=Formula(ALERT("Conversion complete"))
$events.onError:=Formula(ALERT("error!"))

var $tasks : Collection
$tasks:=[]
$tasks.push(["convert"; "--input"; $in; "--output"; $out; {data: $out; file: Null}])

$xls_rs.execute($tasks; $events)
```

### Convert CSV to XLSX (sync)

```4d
var $xls_rs : cs.xls_rs.xls_rs
$xls_rs:=cs.xls_rs.xls_rs.new(Null)

var $tasks : Collection
$tasks:=[]
$tasks.push(["convert"; "--input"; $in; "--output"; $out; {data: $out; file: Null}])

var $results : Collection
$results:=$xls_rs.execute($tasks; Null)
```

### Multiple conversions in one call

```4d
$tasks:=[]
$tasks.push(["convert"; "--input"; $file1; "--output"; $out1; {data: $out1; file: Null}])
$tasks.push(["convert"; "--input"; $file2; "--output"; $out2; {data: $out2; file: Null}])

$xls_rs.execute($tasks; $events)
```

## See also

- [`_CLI`](_CLI.md) — parent class providing executable resolution and shell escaping
- [`_xls_rs_Controller`](_xls_rs_Controller.md) — default controller; handles progress parsing and event forwarding
- [`_CLI_Controller`](_CLI_Controller.md) — base controller providing the command queue
