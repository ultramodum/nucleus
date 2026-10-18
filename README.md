# Nucleus

Nucleus is a command-line utility that automates the process of counting the unique lines of code effectively in use when a software artifact (e.g. the Linux kernel) is built with a specific configuration for a specific architecture. It generates fine-grained measurements of the code that actually runs on a given system, based on the configuration of the software and architecture of the system. These estimates serve as an alternative to the widely adopted lines of code (LOC) metric and can provide a more realistic representation of the attack surface of your system.

*This project was originally developed as part of a master's thesis at ETH Zürich.* <!-- TODO: add thesis title and link -->

---

## Contents

- [Motivation](#motivation)
- [Pipeline](#pipeline)
- [Layout](#layout)
- [Needs](#needs)
- [Usage](#usage)
- [Support](#support)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
<!--
- [Background](#background)
- [Acknowledgments](#acknowledgments)
- [License](#license)
-->

---

## Motivation

Think of any piece of software running on your computer - a web browser, a code editor, or a music player. For most of these software artifacts, large codebases are managed by their developers, to accommodate a plethora of users and the myriad of systems on which they run the software.

In academic circles, the size of a codebase is often used as a proxy for its complexity. There is a legitimate correlation here: the more code in a repository, the more complex it *tends to be*. Moreover, the entire codebase of a software artifact is often included in a trusted computing base (TCB) assessment of the system it runs on. The usual measure in both of these contexts is the total number of lines in the source repository — lines of code (LOC).

For large, configurable software this number can be misleading and detrimental to an accurate attack surface measurement. A user who deploys the Linux kernel is not running the millions of lines in the full source tree of that version; they run only the lines that are compiled in for their configuration (e.g. `tinyconfig` or `defconfig`) and for their architecture (e.g. x86 or ARM). Two users of the same kernel version can differ in relevant code size by orders of magnitude.

While it makes sense to take the entire codebase of a software artifact into account when quantifying the *software's* attack surface, using this same base in an assessment of your *system's* attack surface is a fundamentally flawed approach. For example, counting all ~30 million lines of the Linux kernel fails to paint a realistic picture when assessing its genuine impact on your system's TCB.

Nucleus solves this by going straight for the core and number that really matters for a given system: the code that actually ends up in use for that combination of software, configuration and architecture.

## Pipeline

You choose a software artifact, a configuration and an architecture. The tool then runs a pipeline over the build:

```
   software  +  configuration  +  architecture
                       │
                       ▼
   ┌───────────────────────────────────────────────────────┐
   │  1. Build          build with the chosen setup        │
   │   - Initiate       initiate build of chosen software  │
   │   - Prepare        prepare files during/after build   │
   ├───────────────────────────────────────────────────────┤
   |  2. Process        process build-generated files      |
   │   - Deduplicate    remove identical code              │
   │   - Normalize      bring code to common form          │
   │   - Prune          remove excess leftover code        │
   ├───────────────────────────────────────────────────────┤
   │  3. Count          measure the remaining lines        │
   └───────────────────────────────────────────────────────┘
                       │
                       ▼
        lines in use on this specific system
```

The Bash scripts handle building and file bookkeeping. The Python modules handle the processing and measurement of the resulting code. A single entry point, `run.sh`, ties the stages together.

## Layout

```
nucleus/
├── README.md
├── run.sh                      # main entry point: runs the full pipeline
│
├── build/
|   ├── prepare/
|   |   ├── enter.sh            # enter correct directories during build
|   |   ├── preserve.sh         # preserve complete paths of build files
|   |   └── traverse.sh         # traverse directories during build
|   |
|   └── software/
|       ├── bootloaders/        # grub, ...
|       ├── cryptolib/          # openssl, ...
│       ├── firmware/           # coreboot, ...
|       └── kernels/            # linux, ...
│
├── process/
│   ├── deduplicate.py
│   ├── normalize.py
│   └── prune.py
|
└── visualize/
```

The layout follows the pipeline: `software/` says _what_ to build and contains per-software build instructions, `prepare/` keeps track of the files, and `process/` turns the result into a number.

## Needs

- Bash + Python
- The software artifact you're interested in (e.g. the Linux kernel)
- The build dependencies of the software you want to measure. For the Linux kernel this typically means `gcc`, `make`, `flex`, `bison` and related development packages, plus a cross-compiler toolchain for non-native architectures such as ARM or RISC-V.

## Usage

Fetch the source of the software you want to measure, then run the main script from the repository root:

```bash
git clone https://github.com/ultramodum/nucleus.git
cd nucleus
./run.sh
```

The script asks for the three inputs that define a system:

1. Software: e.g. `linux` or `grub`
2. Architecture: e.g. `x86`, `arm` or `riscv`
3. Configuration: e.g. `tinyconfig`, `defconfig` or `allyesconfig`

It then builds the software, processes the result and reports the number of lines in use.

<!-- TODO: replace with the real ./run.sh invocation (currently several command-line arguments are needed), accepted values, interactive prompts, and an example of the output -->

<!-- See `examples/` for complete sample runs. -->

## Support

| Category                | Software  | Architectures                |
| ----------------------- | --------- | ---------------------------- |
| Kernels                 | Linux     | x86 (tiny, def), ARM, RISC-V |
|                         | Unikraft  | x86, ARM                     |
|                         | Genode    | x86, ARM, RISC-V             |
|                         | Zephyr    | x86, ARM, RISC-V             |
| Firmware                | Coreboot  | x86, ARM, RISC-V             |
|                         | Libreboot | x86                          |
|                         | Tianocore | x86, ARM                     |
| Bootloaders             | GRUB      | x86, ARM, RISC-V             |
|                         | Barebox   | x86, ARM, RISC-V, MIPS       |
| Cryptographic libraries | OpenSSL   | x86, ARM, RISC-V, MIPS       |
|                         | WolfSSL   | x86, ARM, RISC-V             |
|                         | MbedTLS   | x86, ARM, RISC-V, MIPS       |

Where a configuration is given in parentheses, those configurations are supported for that architecture. Everywhere else, only the default configuration is supported.

## Roadmap

While the tool is functional with currently supported software versions, it is being cleaned up and developed further. Planned work is listed below.

- Support for:
	- Other types of software
	- More configurations and architectures
	- Newer versions of already-supported software
	- Additional kernels, firmware, bootloaders and cryptolibs
- Automated tests and a reproducible example run
- Packaging, so the Python modules can be installed with `pip`

Suggestions and contributions are welcome. Please open an issue to discuss larger changes first.

## Contributing

Adding support for other software is fairly straightforward: software-specific build knowledge lives in `software/`, kept separate from the rest of the build pipeline. For example, instructions for Linux is provided in `software/kernels/linux.sh`. Therefore, to add another target, simply create `software/<category>/<software>.sh` and describe how to build the software for the configurations and architectures you want to support. Use `linux.sh` as a template.

<!-- TODO:
## Background
...

## Acknowledgments
...

## License
...
-->
