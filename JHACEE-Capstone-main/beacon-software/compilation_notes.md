# Programming for the Nordic nRF52840 dev kit

*this was painful*

*note: this is a MacOS installation process. Compilation works only with POSIX
but should (hopefully) be similar on Windows*

- to start off, the instructions provided with the development kit were
initially followed.
  - this primarily entails following
  [this](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/nrf/ug_nrf52_gs.html)
  guide and installing the *Nordic Connector for Desktop*.
  - at this point, the *Bluetooth Low Energy*, *Programmer* and *Toolchain
  Manager* were installed through the aforementioned application.
  - this installs the necessary software to flash software as necessary through
  a GUI interface and through VSCode.
  - with the VSCode extension this provides, additional examples can be drawn
  from, compiled and flashed directly to the board without any effort.

However, as a custom board is being developed, it is uncertain whether the
software will flash to an entirely custom board. The same chipset and MCU will
be used, however for the sake of "just in case", a method to compile and flash
the software onto the pcb will be found.

### Utilizing the command-line

*Necessary Software*

- [The ARM GNU Toolchain](https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain)
- [nRF Command Line Tools](https://www.nordicsemi.com/Products/Development-tools/nrf-command-line-tools/download)
  - This includes `nrfjprog`
- `pip3 install nrfutil`

*Necessary Firmware*

- [The nRF5 SDK](https://www.nordicsemi.com/Products/Development-software/nRF5-SDK/Download#infotabs)
  - this contains the same example files as provided through the VSCode
  extension, but everything is a lot less abstracted
  - it is important to install the softdevice compatible with your chip. This
  can be found [here](https://infocenter.nordicsemi.com/index.jsp?topic=%2Fug_gsg_ses%2FUG%2Fgsg%2Fsoftdevices.html)

Within the download, there are two compressed archives of importance. The SDK
itself (`nRF5_SDK_XX.x.x_ddde560.zip`, `XX.x.x` being the version number.
`ddde560` may be a different value Idk) and the softdevice (probably
`s140nrf52720.zip`, maybe `s340nrf52720.zip`). Both of these are important and
both should be unzipped.

After decompressing `nRF5_SDK_XX.x.x_ddde560.zip`, the contained file structure
is as shown:

```sh
$ tree -L 1 nRF5_SDK_17.1.0_ddde560
nRF5_SDK_17.1.0_ddde560
├── components
├── config
├── documentation
├── examples
├── external
├── external_tools
├── integration
├── license.txt
├── modules
└── nRF_MDK_8_40_3_IAR_BSDLicense.msi
```

The example projects, including a "blinky" app, can be found within
`nRF5_SDK_17.1.0_ddde560/examples/ble_central/ble_app_blinky_c/`. Within each of
these folders, the file structure is as so:

```sh
$ tree ble_app_blinky_c -L 2
ble_app_blinky_c
├── ble_app_blinky_c.eww
├── hex
│   ├── ble_app_blinky_c_pca10040_s132.hex
│   ├── ble_app_blinky_c_pca10056_s140.hex
│   └── license.txt
├── main.c
├── pca10040
│   └── s132
└── pca10056
    └── s140
```

`./main.c` is the code itself. The ones within the provided examples are
extremely lengthy and seem to initialize more than they need to.

Files within the `./hex/` folder contains hex files that can be directly flashed
onto the board. 

> A side note: flashing through the command line will be discussed later, but
  these hex files can be flashed onto the board using the Programmer installed
  above. For the nRF52840dk, `ble_app_blinky_c_pca10056_s140.hex` must be used, as
  the chipset is labelled `PCA10056`.

***Knowing which chipset the board uses is important, as it dictates which
compiler process to use!!!***

Notice directories `./pca10040/` and `./pca10056/`. These directories correspond
to the chipset the MCU has (I believe). The nRF52840 dk has a PCA10056 MCU chip,
as such the software flashed onto the chip must be compatible with it.

> This is the same reason why `./hex/ble_app_blinky_c_pca10056_s140.hex` must be
  used if the hex files themselves are to be used.

Digging further into the `./pca10056/s140/` shows the tool chain necessary to
compile the application.

```sh
$ tree pca10056/ -L 3
pca10056/
└── s140
    ├── arm5_no_packs
    │   ├── ble_app_beacon_pca10056_s140.uvoptx
    │   └── ble_app_beacon_pca10056_s140.uvprojx
    ├── armgcc
    │   ├── Makefile
    │   ├── _build
    │   └── ble_app_beacon_gcc_nrf52.ld
    ├── config
    │   └── sdk_config.h
    ├── iar
    │   ├── ble_app_beacon_iar_nRF5x.icf
    │   ├── ble_app_beacon_pca10056_s140.ewd
    │   └── ble_app_beacon_pca10056_s140.ewp
    └── ses
        ├── ble_app_beacon_pca10056_s140.emProject
        ├── ble_app_beacon_pca10056_s140.emSession
        └── flash_placement.xml
```

A lot of things here are just fuff and can be ignored. the main thing to focus
on is the `./pca10056/s140/armgcc/Makefile`. Opening the file, two things stand
out:

```
SDK_ROOT := ../../../../../..
PROJ_DIR := ../../..
```

and

```
# Source files common to all targets
SRC_FILES += \
  $(SDK_ROOT)/modules/nrfx/mdk/gcc_startup_nrf52840.S \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_backend_rtt.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_backend_serial.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_backend_uart.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_default_backends.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_frontend.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_str_formatter.c \
  $(SDK_ROOT)/components/libraries/button/app_button.c \
  $(SDK_ROOT)/components/libraries/util/app_error.c \
  $(SDK_ROOT)/components/libraries/util/app_error_handler_gcc.c \
  $(SDK_ROOT)/components/libraries/util/app_error_weak.c \
# ...
  $(PROJ_DIR)/main.c \
# ...
```


The former allows for compilation of the project with the rest of the SDK. the
latter shows all files (header and source) that `main.c` *can* use.

anyways, the `Makefile` also uses another Makefile as specified below.

```
TEMPLATE_PATH := $(SDK_ROOT)/components/toolchain/gcc

include $(TEMPLATE_PATH)/Makefile.common
```

to skip ahead, this Makefile *then* invokes either `Makefile.posix` or
`Makefile.windows`, depending on the operating system. To properly use the
Makefile, variables must be set within `Makefile.posix` for MacOS/Linux. I
assume the process for the Windows one is similar.

`GNU_INSTALL_ROOT` can be set to the path where the ARM toolchain was installed.
All binaries associated with the ARM toolchain start with `arm-none-eabi` (on
MacOS at least). A new folder,
`/usr/local/gcc-arm-none-eabi-9-2020-q2-update/bin/` *can* be created, but
it's easier to point the variable to the directory housing the binary
itself. for me it was `/usr/local/bin/`. Additional changes may be made here if
necessary.

Now, assuming everything is set up properly, ***particularly the file
structure***, running `make` ***within*** `./pca10056/s140/armgcc/` will create
a `_build/` folder containing the *application* hex file.

**IT IS SO IMPORTANT TO NOTE THAT THIS IS *NOT* READY TO FLASH**

### Flashing the Application

For the program to be properly flashed onto the device, the generated `.hex`
file must be merged with the nRF52840's bootloader and softdevice. The
softdevice for the board was located earlier within `./s140nrf52720.zip`, now the
bootloader must be generated for the device.

The bootloader can be generated via the installed `nrfutil` command-line binary.

```sh
$ nrfutil settings generate --family NRF52840 --application ./path/to/file.hex --application-version 3 --bootloader-version 2 --bl-settings-version 1 bootloader.hex
```

The hex file to flash can now be generated using `mergehex`.

```sh
$ mergehex -m bootloader.hex s140_nrf52_7.3.0_softdevice.hex nrf52840_xxaa.hex -o hex_to_flash.hex
#             ^              ^                               ^- The generated application hex file
#             |              +- The softdevice retrieved from ./s140nrf52720.zip
#             +- The bootloader hex generated above.
```

lastly the board can be flashed using `nrfjprog`!

```sh
$ nrfjprog --family nrf52 -e
> Erasing user available code and UICR flash areas.
> Applying system reset.

$ nrfjprog --family nrf52 --program hex_to_flash.hex --verify 
> [ #################### ]   1.200s | Program file - Done programming
> [ #################### ]   1.228s | Verify file - Done verifying

$ nrfjprog --family nrf52 -r
> Applying system reset.
> Run.
```

after running `nrfjprog --family nrf52 -r`, the board should be reset and
running the flashed program!
