# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:linker.bzl", "ld_library")
load(
    "//rules/opentitan:defs.bzl",
    "OPENTITAN_CPU",
    "fpga_params",
    "opentitan_test",
)
load(
    "//sw/device/silicon_creator/manuf/base:provisioning_inputs.bzl",
    "EARLGREY_OTP_CFGS",
)

package(default_visibility = ["//visibility:public"])

ld_library(
    name = "sram_program_linker_script",
    # We want to avoid page alignment since the SRAM program is not loaded at the beginning of the
    # SRAM and we the generated ELF segment should not contain any headers (as this could overwrite
    # some SRAM content)
    non_page_aligned_segments = True,
    script = "sram_program.ld",
    deps = [
        "//hw/top_earlgrey/sw/autogen:top_earlgrey_memory",
        "//sw/device:info_sections",
        "//sw/device/silicon_creator/lib/base:static_critical_sections",
    ],
)

cc_library(
    name = "sram_start_headers",
    hdrs = ["sram_start.h"],
)

cc_library(
    name = "sram_start",
    srcs = ["sram_start.S"],
    target_compatible_with = [OPENTITAN_CPU],
    deps = [
        ":ast_program",
        ":sram_start_headers",
        "//hw/top:csrng_c_regs",
        "//hw/top:edn_c_regs",
        "//hw/top:entropy_src_c_regs",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/crt",
        "//sw/device/lib/testing/test_framework:ottf_isrs",
    ],
)

cc_library(
    name = "sram_start_no_ast_init",
    srcs = ["sram_start_no_ast_init.S"],
    target_compatible_with = [OPENTITAN_CPU],
    deps = [
        ":ast_program",
        ":sram_start_headers",
        "//hw/top:csrng_c_regs",
        "//hw/top:edn_c_regs",
        "//hw/top:entropy_src_c_regs",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/crt",
        "//sw/device/lib/testing/test_framework:ottf_isrs",
    ],
)

cc_library(
    name = "flash_info_fields",
    srcs = ["flash_info_fields.c"],
    hdrs = ["flash_info_fields.h"],
    deps = [
        "//hw/top:ast_c_regs",
        "//hw/top:flash_ctrl_c_regs",
        "//hw/top:otp_ctrl_c_regs",
        "//sw/device/lib/base:status",
        "//sw/device/lib/dif:flash_ctrl",
        "//sw/device/lib/testing:flash_ctrl_testutils",
        "//sw/device/silicon_creator/lib:attestation",
    ],
)

cc_library(
    name = "otp_fields",
    srcs = ["otp_fields.c"],
    hdrs = ["otp_fields.h"],
    deps = [
        "//hw/top:otp_ctrl_c_regs",
        "//sw/device/lib/base:bitfield",
    ],
)

cc_library(
    name = "otp_img_types",
    hdrs = ["otp_img_types.h"],
)

cc_library(
    name = "util",
    srcs = ["util.c"],
    hdrs = ["util.h"],
    deps = [
        "//hw/top:otp_ctrl_c_regs",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/base:status",
        "//sw/device/lib/crypto/impl:sha2",
        "//sw/device/lib/crypto/impl:sha3",
        "//sw/device/lib/crypto/include:datatypes",
        "//sw/device/lib/dif:otp_ctrl",
        "//sw/device/lib/testing:otp_ctrl_testutils",
    ],
)

cc_library(
    name = "individualize",
    srcs = ["individualize.c"],
    hdrs = ["individualize.h"],
    deps = [
        ":flash_info_fields",
        ":otp_fields",
        ":util",
        "//sw/device/lib/base:bitfield",
        "//sw/device/lib/base:multibits",
        "//sw/device/lib/base:status",
        "//sw/device/lib/crypto/drivers:entropy",
        "//sw/device/lib/crypto/include:datatypes",
        "//sw/device/lib/dif:flash_ctrl",
        "//sw/device/lib/dif:lc_ctrl",
        "//sw/device/lib/dif:otp_ctrl",
        "//sw/device/lib/testing:flash_ctrl_testutils",
        "//sw/device/lib/testing:lc_ctrl_testutils",
        "//sw/device/lib/testing:otp_ctrl_testutils",
        "//sw/device/lib/testing/json:provisioning_data",
        "//sw/device/lib/testing/test_framework:check",
    ],
)

opentitan_test(
    name = "individualize_functest",
    srcs = ["individualize_functest.c"],
    exec_env = {
        "//hw/top_earlgrey:fpga_hyper310_rom_with_fake_keys": None,
        "//hw/top_earlgrey:fpga_cw340_sival": None,
    },
    fpga = fpga_params(
        changes_otp = True,
        otp = "//hw/top_earlgrey/data/otp:img_test_unlocked1",
        tags = ["manuf"],
    ),
    deps = [
        ":flash_info_fields",
        ":individualize",
        ":otp_fields",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/base:status",
        "//sw/device/lib/dif:flash_ctrl",
        "//sw/device/lib/dif:lc_ctrl",
        "//sw/device/lib/dif:otp_ctrl",
        "//sw/device/lib/dif:rstmgr",
        "//sw/device/lib/testing:flash_ctrl_testutils",
        "//sw/device/lib/testing:lc_ctrl_testutils",
        "//sw/device/lib/testing:rstmgr_testutils",
        "//sw/device/lib/testing/json:provisioning_data",
        "//sw/device/lib/testing/test_framework:ottf_main",
    ],
)

cc_library(
    name = "individualize_sw_cfg",
    srcs = [
        "individualize_sw_cfg.c",
        "individualize_sw_cfg.h",
    ],
    deps = [
        ":flash_info_fields",
        ":otp_img_types",
        ":util",
        "//hw/top:otp_ctrl_c_regs",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/base:macros",
        "//sw/device/lib/base:memory",
        "//sw/device/lib/base:status",
        "//sw/device/lib/crypto/include:datatypes",
        "//sw/device/lib/dif:flash_ctrl",
        "//sw/device/lib/dif:otp_ctrl",
        "//sw/device/lib/testing:flash_ctrl_testutils",
        "//sw/device/lib/testing:otp_ctrl_testutils",
    ],
)

# As more SKUs are created with different OTP configurations, libraries can be
# added by updating EARLGREY_OTP_CFGS accordingly.
[
    cc_library(
        name = "individualize_sw_cfg_{}".format(cfg),
        deps = [
            ":individualize_sw_cfg",
            "{}".format(target),
        ],
    )
    for cfg, target in EARLGREY_OTP_CFGS.items()
]

opentitan_test(
    name = "individualize_sw_cfg_functest",
    srcs = ["individualize_sw_cfg_functest.c"],
    exec_env = {
        "//hw/top_earlgrey:fpga_hyper310_rom_with_fake_keys": None,
        "//hw/top_earlgrey:fpga_cw340_rom_with_fake_keys": None,
    },
    fpga = fpga_params(
        changes_otp = True,
        otp = "//hw/top_earlgrey/data/otp:img_test_unlocked1",
        tags = ["manuf"],
        test_cmd = """
            --bootstrap={firmware}
        """,
        test_harness = "//sw/host/tests/manuf/individualize_sw_cfg_functest",
    ),
    deps = [
        ":flash_info_fields",
        # Testing sival SKU only should be sufficient.
        ":individualize_sw_cfg_sival",
        "//hw/top:otp_ctrl_c_regs",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/base:status",
        "//sw/device/lib/crypto/drivers:entropy",
        "//sw/device/lib/dif:flash_ctrl",
        "//sw/device/lib/dif:otp_ctrl",
        "//sw/device/lib/dif:rstmgr",
        "//sw/device/lib/runtime:hart",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing:flash_ctrl_testutils",
        "//sw/device/lib/testing:otp_ctrl_testutils",
        "//sw/device/lib/testing:rstmgr_testutils",
        "//sw/device/lib/testing/test_framework:ottf_main",
    ],
)

cc_library(
    name = "personalize",
    srcs = ["personalize.c"],
    hdrs = ["personalize.h"],
    deps = [
        ":flash_info_fields",
        ":otp_fields",
        ":util",
        "//sw/device/lib/base:multibits",
        "//sw/device/lib/base:status",
        "//sw/device/lib/crypto/drivers:entropy",
        "//sw/device/lib/dif:flash_ctrl",
        "//sw/device/lib/dif:lc_ctrl",
        "//sw/device/lib/dif:otp_ctrl",
        "//sw/device/lib/testing:flash_ctrl_testutils",
        "//sw/device/lib/testing:lc_ctrl_testutils",
        "//sw/device/lib/testing:otp_ctrl_testutils",
        "//sw/device/lib/testing/json:provisioning_data",
        "//sw/device/lib/testing/test_framework:check",
        "//sw/device/silicon_creator/lib:attestation",
    ],
)

opentitan_test(
    name = "personalize_functest",
    srcs = ["personalize_functest.c"],
    ecdsa_key = {"//sw/device/silicon_creator/rom/keys/fake/ecdsa:dev_key_0_ecdsa_p256": "dev_key_0"},
    exec_env = {
        "//hw/top_earlgrey:fpga_hyper310_rom_with_fake_keys": None,
    },
    fpga = fpga_params(
        changes_otp = True,
        needs_jtag = True,
        otp = "//hw/top_earlgrey/data/otp/emulation:otp_img_dev_manuf_individualized",
        tags = [
            "lc_dev",
            "manuf",
        ],
        test_cmd = """
            --bootstrap={firmware}
        """,
        test_harness = "//sw/host/tests/manuf/personalize_functest",
    ),
    spx_key = {"//sw/device/silicon_creator/rom/keys/fake/spx:dev_key_0_spx": "dev_key_0"},
    deps = [
        ":flash_info_fields",
        ":personalize",
        "//hw/top:flash_ctrl_c_regs",
        "//hw/top:lc_ctrl_c_regs",
        "//hw/top:otp_ctrl_c_regs",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/base:status",
        "//sw/device/lib/dif:flash_ctrl",
        "//sw/device/lib/dif:lc_ctrl",
        "//sw/device/lib/dif:otp_ctrl",
        "//sw/device/lib/dif:rstmgr",
        "//sw/device/lib/testing:rstmgr_testutils",
        "//sw/device/lib/testing/json:command",
        "//sw/device/lib/testing/json:provisioning_data",
        "//sw/device/lib/testing/test_framework:ottf_main",
        "//sw/device/lib/testing/test_framework:ujson_ottf",
        "//sw/device/silicon_creator/lib:attestation",
        "//sw/device/silicon_creator/lib/drivers:retention_sram",
    ],
)

cc_library(
    name = "ast_program",
    srcs = ["ast_program.c"],
    deps = [
        ":flash_info_fields",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/base:status",
        "//sw/device/lib/dif:flash_ctrl",
        "//sw/device/lib/dif:pinmux",
        "//sw/device/lib/dif:uart",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/runtime:print",
    ],
)

opentitan_test(
    name = "ast_program_functest",
    srcs = [
        "ast_program.c",
        "ast_program_functest.c",
    ],
    defines = [
        "AST_PROGRAM_UNITTEST=1",
    ],
    exec_env = {
        "//hw/top_earlgrey:fpga_hyper310_rom_with_fake_keys": None,
    },
    fpga = fpga_params(
        tags = ["manuf"],
    ),
    deps = [
        ":flash_info_fields",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/base:crc32",
        "//sw/device/lib/base:status",
        "//sw/device/lib/dif:flash_ctrl",
        "//sw/device/lib/dif:pinmux",
        "//sw/device/lib/dif:uart",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/runtime:print",
        "//sw/device/lib/testing:flash_ctrl_testutils",
        "//sw/device/lib/testing/test_framework:ottf_main",
    ],
)
