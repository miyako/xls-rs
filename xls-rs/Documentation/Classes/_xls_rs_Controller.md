# _xls_rs_Controller
### Extends `_CLI_Controller` with stdout/stderr accumulation and progress parsing.

> _xls_rs_Controller.new (CLI : cs.xls_rs._CLI)

| Parameter | Type | | Description |
| --- | --- | --- | --- |
| CLI | cs.xls_rs._CLI | -> | The owning `_CLI` instance |

## Description

`_xls_rs_Controller` is the default controller used by [`xls_rs`](xls_rs.md). It inherits all command-queue and worker-management behaviour from [`_CLI_Controller`](_CLI_Controller.md) and overrides the data and response event handlers to:

- Accumulate stdout into `stdOut` for synchronous callers.
- Parse `xls-rs` progress output from stderr and forward structured progress objects to `xls_rs.onData`.
- Forward `onResponse`, `onError`, and `onTerminate` events to the corresponding callbacks on the owning `xls_rs` instance.

### Properties

In addition to properties inherited from `_CLI_Controller`:

| Property | Type | Description |
| --- | --- | --- |
| stdOut | Text | Accumulated stdout text from the last command |
| stdErr | Text | Accumulated stderr text (consumed incrementally during progress parsing) |

### Methods

#### clear () → cs.xls_rs._xls_rs_Controller

Resets `stdOut` and `stdErr` to empty strings. Called automatically by the constructor and by `xls_rs.execute` between successive synchronous commands.

| Result | Type | Description |
| --- | --- | --- |
| Result | cs.xls_rs._xls_rs_Controller | `This` — enables chaining |

### Overridden event callbacks

#### onData ($worker : 4D.SystemWorker; $params : Object)

Appends `$params.data` to `stdOut`.

#### onDataError ($worker : 4D.SystemWorker; $params : Object)

Handles stderr output from the `xls-rs` process. When `xls_rs.onData` is set, appends incoming data to `stdErr` and scans it with a regex for progress entries of the form `###…  nn.nn%`. For each match found, calls `xls_rs.onData` with a context object:

| Property | Type | Description |
| --- | --- | --- |
| percentage | Real | Parsed progress percentage (0–100) |
| context | Object | Per-command context from `SYSTEM_WORKER_CONTEXT` keyed by worker PID |

Consumed characters are trimmed from `stdErr` after each scan pass, so partial lines are held until a complete match arrives. When `xls_rs.onData` is not set, stderr is silently discarded.

#### onResponse ($worker : 4D.SystemWorker; $params : Object)

Forwards to `xls_rs.onResponse` if set.

#### onError ($worker : 4D.SystemWorker; $params : Object)

Forwards to `xls_rs.onError` if set.

#### onTerminate ($worker : 4D.SystemWorker; $params : Object)

Forwards to `xls_rs.onTerminate` if set.

## See also

- [`_CLI_Controller`](_CLI_Controller.md) — parent class
- [`xls_rs`](xls_rs.md) — sets `onData`, `onResponse`, `onError`, `onTerminate` which this controller forwards to
