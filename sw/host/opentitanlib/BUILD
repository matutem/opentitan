# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@rules_rust//rust:defs.bzl", "rust_doc", "rust_library", "rust_test")
load("//rules:ujson.bzl", "ujson_rust")

package(default_visibility = ["//visibility:public"])

ujson_rust(
    name = "e2e_command",
    srcs = ["//sw/device/lib/testing/json:command"],
    defines = ["opentitanlib=crate"],
)

ujson_rust(
    name = "gpio",
    srcs = ["//sw/device/lib/testing/json:gpio"],
    defines = ["opentitanlib=crate"],
)

ujson_rust(
    name = "i2c_target",
    srcs = ["//sw/device/lib/testing/json:i2c_target"],
    defines = ["opentitanlib=crate"],
)

ujson_rust(
    name = "mem",
    srcs = ["//sw/device/lib/testing/json:mem"],
    defines = ["opentitanlib=crate"],
)

ujson_rust(
    name = "pinmux_config",
    srcs = ["//sw/device/lib/testing/json:pinmux_config"],
    defines = ["opentitanlib=crate"],
)

ujson_rust(
    name = "spi_passthru",
    srcs = ["//sw/device/lib/testing/json:spi_passthru"],
    defines = ["opentitanlib=crate"],
)

ujson_rust(
    name = "ottf",
    srcs = ["//sw/device/lib/testing/json:ottf"],
    defines = ["opentitanlib=crate"],
)

filegroup(
    name = "config",
    srcs = glob(["src/app/config/*.json"]),
)

rust_library(
    name = "opentitanlib",
    srcs = [
        "src/app/command.rs",
        "src/app/config/mod.rs",
        "src/app/config/structs.rs",
        "src/app/gpio.rs",
        "src/app/i2c.rs",
        "src/app/mod.rs",
        "src/app/spi.rs",
        "src/backend/chip_whisperer.rs",
        "src/backend/ftdi.rs",
        "src/backend/hyperdebug.rs",
        "src/backend/mod.rs",
        "src/backend/proxy.rs",
        "src/backend/ti50emulator.rs",
        "src/backend/ultradebug.rs",
        "src/backend/verilator.rs",
        "src/bootstrap/eeprom.rs",
        "src/bootstrap/legacy.rs",
        "src/bootstrap/legacy_rescue.rs",
        "src/bootstrap/mod.rs",
        "src/bootstrap/primitive.rs",
        "src/chip/alert.rs",
        "src/chip/autogen/mod.rs",
        "src/chip/boolean.rs",
        "src/chip/boot_log.rs",
        "src/chip/boot_svc.rs",
        "src/chip/device_id.rs",
        "src/chip/helper.rs",
        "src/chip/mod.rs",
        "src/chip/rom_error.rs",
        "src/console/mod.rs",
        "src/console/spi.rs",
        "src/crypto/ecdsa.rs",
        "src/crypto/mod.rs",
        "src/crypto/rsa.rs",
        "src/crypto/sha256.rs",
        "src/crypto/spx.rs",
        "src/debug/dmi.rs",
        "src/debug/elf_debugger.rs",
        "src/debug/mod.rs",
        "src/debug/openocd.rs",
        "src/dif/aon_timer.rs",
        "src/dif/lc_ctrl.rs",
        "src/dif/mod.rs",
        "src/dif/otp_ctrl.rs",
        "src/dif/rstmgr.rs",
        "src/dif/uart.rs",
        "src/image/image.rs",
        "src/image/manifest.rs",
        "src/image/manifest_def.rs",
        "src/image/manifest_ext.rs",
        "src/image/mod.rs",
        "src/io/console.rs",
        "src/io/eeprom.rs",
        "src/io/emu.rs",
        "src/io/gpio.rs",
        "src/io/i2c.rs",
        "src/io/ioexpander.rs",
        "src/io/jtag.rs",
        "src/io/mod.rs",
        "src/io/nonblocking_help.rs",
        "src/io/spi.rs",
        "src/io/uart.rs",
        "src/lib.rs",
        "src/otp/alert_handler.rs",
        "src/otp/alert_handler_regs.rs",
        "src/otp/lc_state.rs",
        "src/otp/mod.rs",
        "src/otp/otp_img.rs",
        "src/ownership/application_key.rs",
        "src/ownership/flash.rs",
        "src/ownership/flash_info.rs",
        "src/ownership/misc.rs",
        "src/ownership/mod.rs",
        "src/ownership/owner.rs",
        "src/ownership/rescue.rs",
        "src/proxy/errors.rs",
        "src/proxy/handler.rs",
        "src/proxy/mod.rs",
        "src/proxy/nonblocking_uart.rs",
        "src/proxy/protocol.rs",
        "src/proxy/socket_server.rs",
        "src/rescue/mod.rs",
        "src/rescue/serial.rs",
        "src/rescue/xmodem.rs",
        "src/spiflash/flash.rs",
        "src/spiflash/mod.rs",
        "src/spiflash/sfdp.rs",
        "src/test_utils/bitbanging/i2c.rs",
        "src/test_utils/bitbanging/mod.rs",
        "src/test_utils/bitbanging/pwm.rs",
        "src/test_utils/bitbanging/spi.rs",
        "src/test_utils/bitbanging/uart.rs",
        "src/test_utils/bootstrap.rs",
        "src/test_utils/e2e_command.rs",
        "src/test_utils/epmp.rs",
        "src/test_utils/gpio.rs",
        "src/test_utils/gpio_monitor.rs",
        "src/test_utils/i2c_target.rs",
        "src/test_utils/init.rs",
        "src/test_utils/lc.rs",
        "src/test_utils/lc_transition.rs",
        "src/test_utils/load_bitstream.rs",
        "src/test_utils/load_sram_program.rs",
        "src/test_utils/mem.rs",
        "src/test_utils/mod.rs",
        "src/test_utils/object.rs",
        "src/test_utils/otp_ctrl.rs",
        "src/test_utils/poll.rs",
        "src/test_utils/rpc.rs",
        "src/test_utils/spi_passthru.rs",
        "src/test_utils/status.rs",
        "src/test_utils/test_status.rs",
        "src/tpm/access.rs",
        "src/tpm/driver.rs",
        "src/tpm/mod.rs",
        "src/tpm/status.rs",
        "src/transport/chip_whisperer/board.rs",
        "src/transport/chip_whisperer/gpio.rs",
        "src/transport/chip_whisperer/mod.rs",
        "src/transport/chip_whisperer/spi.rs",
        "src/transport/chip_whisperer/usb.rs",
        "src/transport/common/fpga.rs",
        "src/transport/common/mod.rs",
        "src/transport/common/uart.rs",
        "src/transport/dediprog/gpio.rs",
        "src/transport/dediprog/mod.rs",
        "src/transport/dediprog/spi.rs",
        "src/transport/errors.rs",
        "src/transport/ftdi/chip.rs",
        "src/transport/ftdi/gpio.rs",
        "src/transport/ftdi/mod.rs",
        "src/transport/ftdi/spi.rs",
        "src/transport/hyperdebug/c2d2.rs",
        "src/transport/hyperdebug/dfu.rs",
        "src/transport/hyperdebug/gpio.rs",
        "src/transport/hyperdebug/i2c.rs",
        "src/transport/hyperdebug/mod.rs",
        "src/transport/hyperdebug/servo_micro.rs",
        "src/transport/hyperdebug/spi.rs",
        "src/transport/hyperdebug/ti50.rs",
        "src/transport/hyperdebug/uart.rs",
        "src/transport/ioexpander/mod.rs",
        "src/transport/ioexpander/sx1503.rs",
        "src/transport/mod.rs",
        "src/transport/proxy/emu.rs",
        "src/transport/proxy/gpio.rs",
        "src/transport/proxy/i2c.rs",
        "src/transport/proxy/mod.rs",
        "src/transport/proxy/spi.rs",
        "src/transport/proxy/uart.rs",
        "src/transport/ti50emulator/emu.rs",
        "src/transport/ti50emulator/gpio.rs",
        "src/transport/ti50emulator/i2c.rs",
        "src/transport/ti50emulator/mod.rs",
        "src/transport/ti50emulator/spi.rs",
        "src/transport/ti50emulator/uart.rs",
        "src/transport/ultradebug/gpio.rs",
        "src/transport/ultradebug/mod.rs",
        "src/transport/ultradebug/mpsse.rs",
        "src/transport/ultradebug/spi.rs",
        "src/transport/ultradebug/uart.rs",
        "src/transport/verilator/gpio.rs",
        "src/transport/verilator/mod.rs",
        "src/transport/verilator/subprocess.rs",
        "src/transport/verilator/transport.rs",
        "src/uart/console.rs",
        "src/uart/mod.rs",
        "src/util/bigint.rs",
        "src/util/bitbang.rs",
        "src/util/bitfield.rs",
        "src/util/file.rs",
        "src/util/hexdump.rs",
        "src/util/mod.rs",
        "src/util/num_de.rs",
        "src/util/parse_int.rs",
        "src/util/present.rs",
        "src/util/printer.rs",
        "src/util/raw_tty.rs",
        "src/util/rom_detect.rs",
        "src/util/serde.rs",
        "src/util/status.rs",
        "src/util/testing.rs",
        "src/util/unknown.rs",
        "src/util/usb.rs",
        "src/util/usr_access.rs",
        "src/util/vmem/mod.rs",
        "src/util/vmem/parser.rs",
        "src/util/voltage.rs",
    ] + select({
        "//sw/device:is_english_breakfast": [],
        "//conditions:default": [
            "src/chip/autogen/earlgrey.rs",
            "src/dif/clkmgr.rs",
            "src/test_utils/extclk.rs",
            "src/test_utils/pinmux_config.rs",
        ],
    }),
    compile_data = [
        ":config",
        ":gpio",
        ":i2c_target",
        ":mem",
        ":e2e_command",
        ":pinmux_config",
        ":spi_passthru",
        ":ottf",
        "@hyperdebug_firmware//:hyperdebug/ec.bin",
        "//third_party/openocd:jtag_cmsis_dap_adapter_cfg",
        "//util/openocd/target:lowrisc-earlgrey.cfg",
        "//util/openocd/target:lowrisc-earlgrey-lc.cfg",
        "//sw/host/opentitanlib/bindgen:rom_error_enum",
    ],
    crate_features = [
        "include_hyperdebug_firmware",
    ] + select({
        "//sw/device:is_english_breakfast": ["english_breakfast"],
        "//conditions:default": [],
    }),
    proc_macro_deps = [
        "//sw/host/opentitanlib/opentitantool_derive",
    ],
    rustc_env = {
        "e2e_command": "$(location :e2e_command)",
        "gpio": "$(location :gpio)",
        "i2c_target": "$(location :i2c_target)",
        "mem": "$(location :mem)",
        "pinmux_config": "$(location :pinmux_config)",
        "rom_error_enum": "$(location //sw/host/opentitanlib/bindgen:rom_error_enum)",
        "spi_passthru": "$(location :spi_passthru)",
        "ottf": "$(location :ottf)",
        "hyperdebug_firmware": "$(location @hyperdebug_firmware//:hyperdebug/ec.bin)",
        "openocd_riscv_target_cfg": "$(location //util/openocd/target:lowrisc-earlgrey.cfg)",
        "openocd_lc_target_cfg": "$(location //util/openocd/target:lowrisc-earlgrey-lc.cfg)",
        "openocd_cmsis_dap_adapter_cfg": "$(location //third_party/openocd:jtag_cmsis_dap_adapter_cfg)",
    },
    deps = [
        "//hw/top_earlgrey/sw/autogen/chip:top_earlgrey",
        "//sw/host/opentitanlib/bindgen",
        "//sw/host/sphincsplus",
        "@crate_index//:anyhow",
        "@crate_index//:arrayvec",
        "@crate_index//:bitflags",
        "@crate_index//:byteorder",
        "@crate_index//:chrono",
        "@crate_index//:clap",
        "@crate_index//:crc",
        "@crate_index//:deser-hjson",
        "@crate_index//:directories",
        "@crate_index//:ecdsa",
        "@crate_index//:embedded-hal",
        "@crate_index//:env_logger",
        "@crate_index//:erased-serde",
        "@crate_index//:ftdi",
        "@crate_index//:ftdi-embedded-hal",
        "@crate_index//:ftdi-mpsse",
        "@crate_index//:hex",
        "@crate_index//:humantime",
        "@crate_index//:humantime-serde",
        "@crate_index//:indicatif",
        "@crate_index//:log",
        "@crate_index//:memoffset",
        "@crate_index//:mio",
        "@crate_index//:mio-signals",
        "@crate_index//:num-bigint-dig",
        "@crate_index//:num-traits",
        "@crate_index//:object",
        "@crate_index//:once_cell",
        "@crate_index//:p256",
        "@crate_index//:pem-rfc7468",
        "@crate_index//:rand",
        "@crate_index//:regex",
        "@crate_index//:rsa",
        "@crate_index//:rusb",
        "@crate_index//:rustix",
        "@crate_index//:scopeguard",
        "@crate_index//:serde",
        "@crate_index//:serde_bytes",
        "@crate_index//:serde_json",
        "@crate_index//:serialport",
        "@crate_index//:sha2",
        "@crate_index//:shellwords",
        "@crate_index//:strum",
        "@crate_index//:thiserror",
        "@crate_index//:typetag",
        "@crate_index//:zerocopy",
        "@lowrisc_serde_annotate//serde_annotate",
    ],
)

rust_test(
    name = "opentitanlib_test",
    compile_data = [
        ":e2e_command",
        ":gpio",
        ":pinmux_config",
        "src/bootstrap/simple.bin",
        "src/spiflash/SFDP_MX66L1G.bin",
    ],
    crate = ":opentitanlib",
    data = glob(["testdata/**"]) + [
        ":e2e_command",
        ":gpio",
        ":pinmux_config",
    ],
    env = {
        "RUST_MIN_STACK": "4194304",
        "TESTDATA": "$(rootpath testdata/otp/lc_ctrl_state.hjson)",
    },
    rustc_env = {
        "e2e_command": "$(location :e2e_command)",
        "gpio": "$(location :gpio)",
        "pinmux_config": "$(location :pinmux_config)",
    },
)

rust_doc(
    name = "opentitanlib_doc",
    crate = ":opentitanlib",
)

filegroup(
    name = "doc_files",
    srcs = glob(["**/*.md"]),
)
