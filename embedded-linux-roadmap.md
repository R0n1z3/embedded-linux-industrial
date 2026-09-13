# Embedded Linux for Industrial Automation — Project Roadmap

**Goal:** Transition from controls engineer (industrial automation) to embedded SWE role building products used in industrial automation (IIoT gateways, remote I/O modules, HMI panels, protocol converters, edge controllers).

**Your unfair advantage:** You already understand the OT side (PLCs, fieldbus, control loops, HMI/SCADA) that most CS-background embedded candidates don't. This roadmap closes the Linux/systems gap while leaning hard into that advantage instead of ignoring it.

---

## Hardware you'll need

| Item | Why | Approx cost |
|---|---|---|
| Raspberry Pi 4/5 or CM4, **or** BeagleBone Black | Main dev board — BBB is closer to "real" industrial SBCs (has PRU, more raw GPIO control); Pi has better docs/community | $35–80 |
| MCP23017 or similar GPIO expander + a few relays | Build a small "remote I/O" rig | $15–25 |
| MCP3008 (SPI ADC) + a potentiometer or analog sensor | Analog input, like a PLC analog card | $5–10 |
| MCP2515 CAN controller module or USB-CAN adapter | CAN bus work | $10–20 |
| USB-to-RS485 adapter | Real Modbus RTU testing | $10 |
| (Optional) A second cheap board or a Modbus simulator running on your PC | Acts as a "PLC" to talk to | $0–35 |

Total: under $150, and every piece maps to something you already recognize from panel-building — this is intentional. You're building a miniature remote I/O node, not a toy.

---

## Phase 0 — Foundation (1–2 weeks)

**Objective:** Get comfortable cross-compiling and flashing a board before touching kernel code.

- Set up a Linux dev environment (native Linux or a VM — don't fight WSL for this).
- Install a cross-compilation toolchain, cross-compile a trivial C++ program, and run it on the board over SSH.
- Get comfortable with `dmesg`, `journalctl`, serial console access (UART-to-USB cable to the board), and basic U-Boot interaction (interrupt boot, print env, boot manually).

**Why it matters:** Every embedded Linux job assumes you're fluent in cross-compilation and serial/console debugging. This is table stakes, not a skill line — get it out of the way fast.

---

## Phase 1 — Custom Embedded Linux Image (2–4 weeks)

**Objective:** Build your own minimal Linux image, not use a stock Raspbian/Debian SD card image.

1. Build a minimal image with **Buildroot** first (faster feedback loop, easier mental model).
2. Once comfortable, rebuild the same image with **Yocto** (this is the name that actually appears on job postings — don't skip it).
3. Add: your own hostname, a systemd service that starts one of your own binaries on boot, SSH key-only login, and a read-only root filesystem (common in industrial devices to survive power loss).

**Deliverable:** A GitHub repo with your Buildroot **and** Yocto configs, a README explaining image size, boot time, and what you customized and why.

---

## Phase 2 — Build "IO-Node": a remote I/O module (3–5 weeks)

This replaces the old Tank-Project as your hardware testbed — same spirit (real hardware, real I/O) but framed explicitly as an industrial device, and built from scratch.

**What it is:** A small board that looks and acts like a PLC remote I/O rack: digital outputs (relays), digital inputs, and analog input, controlled from embedded Linux instead of a microcontroller.

- Wire up the relay board (digital out), some buttons/switches (digital in), and the MCP3008 (analog in) to the board's GPIO/SPI.
- Write a **Linux kernel driver** (character device) for at least one of these — the relay board is the easiest starting point.
- Write the matching **device tree overlay** so the driver binds correctly on boot.
- Expose a simple `/dev/io-node0` interface that userspace can read/write to control relays and read analog values.

**Why it matters:** This is the single most job-posting-relevant skill in the whole roadmap — kernel driver + device tree work is what separates "embedded Linux engineer" from "Linux app developer." Very few candidates at your career stage can show this.

**Deliverable:** A repo with kernel driver source, device tree overlay, wiring diagram/photo, and a short userspace test utility.

---

## Phase 3 — Give it a voice: Modbus stack in C++20 (3–4 weeks)

**Objective:** Make IO-Node speak the protocol you already know cold from controls work — but build the library yourself instead of using `libmodbus`.

- Implement a Modbus **RTU** master and slave (serial, via your USB-RS485 adapter) from the spec directly.
- Implement Modbus **TCP** as well (it's a simpler framing layer over the same PDU logic).
- Make IO-Node run as a Modbus **slave**, exposing its relays as coils and its analog input as an input register.
- Write a small master utility (or point an existing SCADA/Modbus test tool at it) to poll and control it end-to-end.

**Why it matters:** This is your biggest resume differentiator. Anyone can call a Modbus library. Almost nobody applying for these jobs can explain register mapping, CRC16, and PDU framing from having implemented it — and you can, because you've configured this stuff in the field.

**Deliverable:** Standalone Modbus library repo (master + slave, RTU + TCP), with IO-Node as the reference integration.

---

## Phase 4 — CAN bus (1–2 weeks, can run in parallel with Phase 3)

- Get the MCP2515 module talking over SocketCAN (`can0` interface).
- Write a small C++ app using the SocketCAN API to send/receive frames, and decode a simple made-up frame format (or a real DBC file if you want to go further).

**Why it matters:** CAN comes up constantly in industrial and automotive-adjacent postings; SocketCAN is a very learnable, contained skill that shows up disproportionately often relative to how long it takes to learn.

---

## Phase 5 — Real-time Linux (2–3 weeks)

- Apply/enable the **PREEMPT_RT** patch on your board (or use a Yocto layer that includes it).
- Write a small C++ program that toggles a GPIO on a fixed period and measures actual vs. intended timing (a homemade `cyclictest`).
- Compare jitter with and without PREEMPT_RT, and document it with a chart.
- Optional stretch: turn IO-Node's analog input + a relay into a simple bang-bang or PID control loop, and use this to talk concretely about determinism in a way that connects directly to your PLC scan-cycle experience.

**Why it matters:** This is where your controls background becomes a superpower in an interview — you already know *why* jitter matters for a control loop; most embedded candidates only know it abstractly.

---

## Phase 6 — Capstone: Industrial IoT Gateway (4–6 weeks)

Bring everything together into one deployable product:

- Your custom Yocto image (Phase 1) boots on the board.
- IO-Node (Phase 2) runs as a Modbus slave (Phase 3), representing a "field device."
- A gateway service on the same or a second board polls it (and optionally other real/simulated Modbus devices) and logs to **SQLite** (you already know this).
- The gateway publishes data northbound over **MQTT** or a minimal **OPC-UA** server (pick one — OPC-UA is more "real industrial," MQTT is faster to implement).
- A **Qt** dashboard (local touchscreen HMI style, or just a desktop app) shows live values and lets you toggle relays — tying your GUI skills back in.
- Package it properly: systemd services, a versioned release, and a real README with an architecture diagram.

**This project, on its own, is a plausible answer to "tell me about a project" in an interview for almost any industrial embedded Linux role** — it touches BSP/image work, kernel drivers, protocol implementation, real-time awareness, and a UI, all in a context an industrial automation employer will immediately recognize.

---

## Running thread: GNU Make (through every phase)

**Objective:** Go from zero to writing and reading real Makefiles, by hand. No CMake until Phase 6.

**Why it matters:** Make is the build language of embedded Linux itself. The kernel's build system (Kbuild) and Buildroot are both written in Make. If you can read those Makefiles instead of just running `make`, you can debug a broken build instead of guessing.

| Phase | Make skill | What you write |
|---|---|---|
| 0 | Rules (target, prerequisites, a tab-indented recipe), variables (`CXX`, `CXXFLAGS`), `clean`, `.PHONY`, overriding a variable from the command line | A Makefile for your hello-world that builds for the host with `make` and for the BBB with `make CROSS_COMPILE=arm-linux-gnueabihf-` (the same convention the kernel uses) |
| 1 | Reading someone else's Make: Buildroot's `make menuconfig`, `.config`, and package `.mk` files | A Buildroot package (`.mk` + `Config.in`) for your own binary, kept in a `BR2_EXTERNAL` tree |
| 2 | Kbuild, the kernel's own Make conventions: `obj-m`, `make -C <kernel dir> M=$(PWD)`, `ARCH` / `CROSS_COMPILE` | The out-of-tree Makefile for the IO-Node driver, plus a rule that compiles the device tree overlay with `dtc` |
| 3 | Multi-file projects: pattern rules, automatic variables (`$@`, `$<`, `$^`), auto-generated header dependencies (`-MMD -MP`), a static library with `ar`, a separate `build/` directory, `debug` / `asan` / `test` targets | The Modbus library's Makefile |
| 4–5 | Reusing what you know, plus per-target flags (e.g. an optimized, sanitizer-free build for the RT timing code) | Makefiles for the CAN app and the latency tester |
| 6 | CMake, Qt 6's standard build system. Learning it last means you'll understand the Makefiles it generates for you. | The Qt dashboard's `CMakeLists.txt` |

**Reference:** the [GNU Make manual](https://www.gnu.org/software/make/manual/). Read chapter 2 ("An Introduction to Makefiles") first. Chapters 4–6 and 10 cover nearly everything through Phase 3.

---

## Suggested pacing

- **Total: roughly 4–6 months** at a sustainable side-project pace (5–8 hrs/week), faster if you can dedicate more time.
- You don't need to finish everything before applying. **Phases 0–3 alone** (custom image + kernel driver + Modbus stack) make you a credible candidate for junior/mid embedded roles at industrial vendors.
- Document as you go — a GitHub org or pinned repos with clear READMEs matters more than a single monster repo.

## How to frame this in interviews / resume

Lead with the combination, not either half alone: *"I'm a controls engineer who's spent the last N months building the embedded Linux side — I've written kernel drivers, built custom Yocto images, and implemented Modbus and CAN stacks from the protocol spec up, because I already understood the OT side of these devices from the field."* That story is rare and exactly what industrial embedded teams struggle to hire for.
