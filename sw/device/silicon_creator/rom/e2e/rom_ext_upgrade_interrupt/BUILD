# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load(
    "//rules/opentitan:defs.bzl",
    "cw310_params",
    "ecdsa_key_for_lc_state",
    "fpga_params",
    "opentitan_test",
)
load("//rules/opentitan:keyutils.bzl", "ECDSA_ONLY_KEY_STRUCTS")
load(
    "//rules:const.bzl",
    "CONST",
    "get_lc_items",
    "hex",
)
load("//rules:manifest.bzl", "manifest")
load(
    "//rules:otp.bzl",
    "STD_OTP_OVERLAYS",
    "otp_hex",
    "otp_image",
    "otp_json",
    "otp_partition",
)
load("//rules:rom_e2e.bzl", "maybe_skip_in_ci")

package(default_visibility = ["//visibility:public"])

manifest(d = {
    "name": "manifest_rom_ext_upgrade_interrupt",
    "address_translation": hex(CONST.HARDENED_FALSE),
    "identifier": hex(CONST.ROM_EXT),
    "security_version": hex(10),
})

otp_json(
    name = "otp_json_rom_ext_upgrade_interrupt",
    partitions = [
        otp_partition(
            name = "CREATOR_SW_CFG",
            items = {
                "CREATOR_SW_CFG_DEFAULT_BOOT_DATA_IN_PROD_EN": otp_hex(CONST.HARDENED_TRUE),
            },
        ),
    ],
)

[
    otp_image(
        name = "otp_img_rom_ext_upgrade_interrupt_{}".format(lc_state),
        src = "//hw/top_earlgrey/data/otp:otp_json_{}".format(lc_state),
        overlays = STD_OTP_OVERLAYS + [":otp_json_rom_ext_upgrade_interrupt"],
        visibility = ["//visibility:private"],
    )
    for lc_state, _ in get_lc_items()
]

[
    opentitan_test(
        name = "rom_ext_upgrade_interrupt_{}".format(lc_state),
        srcs = ["rom_ext_upgrade_interrupt.c"],
        ecdsa_key = ecdsa_key_for_lc_state(
            ECDSA_ONLY_KEY_STRUCTS,
            lc_state_val,
        ),
        exec_env = {
            "//hw/top_earlgrey:fpga_cw310_rom_with_fake_keys": None,
        },
        fpga = fpga_params(
            otp = ":otp_img_rom_ext_upgrade_interrupt_{}".format(lc_state),
            tags = maybe_skip_in_ci(lc_state_val),
            test_cmd = """
                --exec="transport init"
                --exec="fpga clear-bitstream"
                --exec="fpga load-bitstream {bitstream}"
                --exec="bootstrap --clear-uart=true {firmware}"
                --exec="console --non-interactive --exit-success='{exit_success}' --exit-failure='{exit_failure}'"
                --exec="fpga clear-bitstream"
                no-op
            """,
        ),
        manifest = ":manifest_rom_ext_upgrade_interrupt",
        deps = [
            "//sw/device/lib/testing:flash_ctrl_testutils",
            "//sw/device/lib/testing:nv_counter_testutils",
            "//sw/device/lib/testing/test_framework:check",
            "//sw/device/lib/testing/test_framework:ottf_main",
            "//sw/device/silicon_creator/lib:boot_data",
            "//sw/device/silicon_creator/lib/drivers:lifecycle",
            "//sw/device/silicon_creator/lib/drivers:rstmgr",
        ],
    )
    for lc_state, lc_state_val in get_lc_items()
]

test_suite(
    name = "rom_e2e_rom_ext_upgrade_interrupt",
    tags = ["manual"],
    tests = ["rom_ext_upgrade_interrupt_{}".format(lc_state) for lc_state, _ in get_lc_items()],
)
