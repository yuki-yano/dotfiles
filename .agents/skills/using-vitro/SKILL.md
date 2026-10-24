---
name: using-vitro
description: Run commands, builds and tests inside disposable Windows, macOS or Linux VMs with the vitro CLI. Use when a question can only be answered on another operating system ("does this build on Windows?", "do the tests pass on macOS?"), when something should be done to a throwaway machine rather than the host, or when the user mentions vitro, a golden image, or a guest VM.
allowed-tools: Bash(vitro *)
---

# Driving guests with vitro

vitro builds a golden image of an operating system once, then starts
throwaway VMs from it in seconds. A VM is a copy-on-write overlay: destroying
it costs nothing, and nothing done inside it reaches the host.

## Start by asking vitro

```console
$ vitro status --json
```

It lists running VMs, the images that can be run or built, and a `next` array
of commands worth running now. Lume images are offered for `run` only when
lume confirms the golden VM exists. Prefer it to guessing image names. When a
command fails for a reason outside vitro (QEMU missing, no key, no firmware),
`vitro doctor` names the fix.

## The one-shot form — use this by default

To answer one question on a fresh machine, start a VM, run the command, and
destroy the VM in one step:

```console
$ vitro run --rm --sync . windows -- cargo test
```

- The exit code is the guest command's own, so failure means the command
  failed in the guest.
- `--sync <dir>` copies the directory in first (minus what `.gitignore`
  excludes) and runs the command inside it.
- `--rm` destroys the VM afterwards, even when the command fails or is
  interrupted.
- stdout carries only the guest command's output; vitro's own messages go to
  stderr.

If the project has a `vitro.toml`, `vitro test` does the same for every image
it lists and prints one verdict per image. `vitro test windows -- --nocapture`
restricts it to one image and appends arguments.

## Keeping a VM across several commands

```console
$ vitro run windows                    # prints the VM's name
$ vitro exec windows cargo build       # the image name reaches its one VM
$ vitro exec --sync . --cwd app windows cargo test
$ vitro cp :app/target/debug/app.exe . # ":" alone means the only running VM
$ vitro destroy windows
```

- A VM can be named by its full name, by its image, or by a unique prefix.
- While only one VM is running, the name can be left out:
  `vitro exec cargo test`.
- `--cwd` and `--env NAME=VALUE` are written in the guest shell's syntax.
- Always destroy what you started. `vitro status` flags a VM that has been up
  for more than a day.

## Windows guests

- The command runs in **Windows PowerShell 5.1**, not cmd and not sh. Write
  PowerShell (`Get-ChildItem`, `$env:PATH`). It has no `&&` or `||`: chain
  with `;` and check `$LASTEXITCODE`.
- `exit` straight after a cmdlet that prints a table discards the table: write
  `Get-Location | Out-String; exit 7`, not `Get-Location; exit 7`.
- Each `exec` sees PATH as the registry holds it now, so a tool you installed
  earlier in the session is found as it is. Do not prefix `$env:PATH` by hand.
- `launch` starts a GUI program on the logged-in desktop, and `screenshot`
  shows whether it appeared; `exec` runs outside that desktop. Run
  `vitro wait --desktop` first: auto-logon reaches the desktop after SSH does.

## Waiting instead of sleeping

Never poll a guest with `sleep`.

- To restart a guest, use `vitro restart <vm>` rather than `Restart-Computer`
  or `reboot`: it returns only once the guest has booted again, where a wait
  started right after asking would see the old session still answering.
- `vitro wait <vm>` returns once the VM answers over SSH, for a guest that went
  away on its own or for a reboot a script asked for.
- `vitro wait --desktop <vm>` (or `restart --desktop`) returns once somebody is
  logged in to the desktop (Windows, macOS).
- `--timeout 10m` bounds any of them.

## Anything longer than one line: `--script`

Pipelines, loops, hashtables and multi-line logic do not survive being passed
as words through `exec`. Write them to a file on the host and run it:

```console
$ vitro exec --script ./collect.ps1 windows -Since 1h   # .ps1/.cmd/.bat on Windows
$ vitro exec --script ./setup.sh linux --fast           # any file on Unix
```

vitro copies the script in, runs it with the arguments after the VM, removes
it, and exits with its code. Do not hand-roll `vitro cp` + `powershell -File`.
It is also the way round a sandbox that refuses `vitro exec <vm> sh -c …` or a
command naming `git`.

## Setting a guest up once

- A guest starts with nothing but the OS. Before installing a toolchain by
  hand, check whether the image already has it (`vitro exec windows cargo
  --version`).
- vitro ships provision scripts for native builds in its repository's
  `examples/provision/` (Git, a C toolchain, Rust; on Windows also the MSVC
  build tools and LLVM). They run on a live VM through `--script` and leave
  installed tools alone.
- Setup that took more than a few minutes is worth keeping: `vitro promote
  <vm> --as <name>` turns the VM into a golden image, and `vitro run --golden
  <name> <image>` starts from it later. Ask the user before promoting.
- Builds that take more than a few minutes: start them as a job, so a dropped
  connection or an interrupted session loses nothing.

  ```console
  $ job=$(vitro exec --detach --sync . windows cargo build --release)
  $ vitro attach "$job"     # output from the start; exits with the build's code
  $ vitro jobs windows      # what is running, what ended with which code
  ```

  Run `vitro attach` in a background task if you need to do something else
  meanwhile. Do not hand-roll `nohup` or `Start-Process` with a log file.

## Things to avoid

- Do not run `vitro build` unless asked: it takes from seconds (Linux) to
  tens of minutes (Windows) and may need an installer the user must download.
- For a macOS build failure, `--keep-failed` keeps the staging VM for
  inspection if lume has not already deleted it. `build_timeout` covers the
  installation and provisioning together; failure cleanup can take longer.
- Do not use `destroy --all` unless every VM is yours to destroy.
- Do not pass `--graceful` to `destroy`; the default forced stop is intended.
- GUI commands (`screenshot`, `key`, `click`, `scroll`, `hover`, `drag`,
  `launch`) are for checking something on the guest's screen; prefer `exec`
  for anything a shell can do.
- Do not run `vitro key shift` before a `click` or `scroll` to hold a
  modifier: `key` lets go at once. Pass `--with shift` (or `ctrl`, `alt`, …)
  to the mouse command; `scroll … down --with shift` scrolls sideways.
- On a macOS guest, do not script windows with `osascript` and System Events:
  it is refused for Accessibility (-1719). Take a `screenshot`, then `drag`
  the window's corner to resize it or its title bar to move it.
- On a macOS guest, `scroll … up` moves content the other way from a Linux or
  Windows guest: natural scrolling is on. Take a screenshot to see which way
  it went rather than assuming.
