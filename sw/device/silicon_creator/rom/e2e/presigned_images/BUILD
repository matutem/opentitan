# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules/opentitan:legacy.bzl", "scramble_flash_vmem", "vmem_file")

package(default_visibility = ["//visibility:public"])

# Empty test binaries and aliases.
_EMPTY_TEST_DEVICES = [
    "sim_dv",
    "sim_verilator",
    "fpga_cw310",
]

# ROM self hash test binaries and aliases.
vmem_file(
    name = "rom_e2e_self_hash_sim_dv_vmem64",
    src = "rom_e2e_self_hash_sim_dv.signed.bin",
    word_size = 64,
)

scramble_flash_vmem(
    name = "rom_e2e_self_hash_sim_dv_scr_vmem64",
    src = ":rom_e2e_self_hash_sim_dv_vmem64",
    otp = "//hw/top_earlgrey/data/otp:img_test_unlocked0",
)

[
    filegroup(
        name = "rom_e2e_self_hash_{}".format(dev),
        srcs = [
            "rom_e2e_self_hash_{}.signed.bin".format(dev),
        ] + [] if dev == "fpga_cw310" else [
            ":rom_e2e_self_hash_sim_dv.logs.txt",
            ":rom_e2e_self_hash_sim_dv.rodata.txt",
            ":rom_e2e_self_hash_sim_dv_scr_vmem64",
            ":rom_e2e_self_hash_sim_dv_vmem64",
        ],
    )
    for dev in [
        "sim_dv",
        "fpga_cw310",
    ]
]

alias(
    name = "rom_e2e_self_hash_fpga_cw310_bin",
    actual = ":rom_e2e_self_hash_fpga_cw310",
)
