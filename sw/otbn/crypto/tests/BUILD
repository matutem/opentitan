# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:otbn.bzl", "otbn_consttime_test", "otbn_library", "otbn_sim_test", "otbn_sim_test_suite")

package(default_visibility = ["//visibility:public"])

otbn_sim_test(
    name = "ed25519_ext_add_test",
    srcs = [
        "ed25519_ext_add_test.s",
    ],
    exp = "ed25519_ext_add_test.exp",
    deps = [
        "//sw/otbn/crypto:ed25519",
        "//sw/otbn/crypto:field25519",
    ],
)

otbn_consttime_test(
    name = "ed25519_ext_add_consttime",
    subroutine = "ext_add",
    deps = [
        ":ed25519_ext_add_test",
    ],
)

otbn_sim_test(
    name = "ed25519_scalar_test",
    srcs = [
        "ed25519_scalar_test.s",
    ],
    exp = "ed25519_scalar_test.exp",
    deps = [
        "//sw/otbn/crypto:ed25519_scalar",
    ],
)

otbn_sim_test(
    name = "div_large_test",
    srcs = [
        "div_large_test.s",
    ],
    exp = "div_large_test.exp",
    deps = [
        "//sw/otbn/crypto:div",
    ],
)

otbn_sim_test(
    name = "div_medium_test",
    srcs = [
        "div_medium_test.s",
    ],
    exp = "div_medium_test.exp",
    deps = [
        "//sw/otbn/crypto:div",
    ],
)

otbn_sim_test(
    name = "div_small_test",
    srcs = [
        "div_small_test.s",
    ],
    exp = "div_small_test.exp",
    deps = [
        "//sw/otbn/crypto:div",
    ],
)

otbn_consttime_test(
    name = "div_consttime",
    # All secrets are stored in DMEM; timing is permitted to depend on the
    # number of limbs.
    secrets = ["dmem"],
    subroutine = "div",
    deps = [
        ":div_small_test",
    ],
)

otbn_sim_test(
    name = "field25519_test",
    srcs = [
        "field25519_test.s",
    ],
    exp = "field25519_test.exp",
    deps = [
        "//sw/otbn/crypto:field25519",
    ],
)

otbn_consttime_test(
    name = "field25519_fe_inv_consttime",
    subroutine = "fe_inv",
    deps = [
        ":field25519_test",
    ],
)

otbn_consttime_test(
    name = "field25519_fe_mul_consttime",
    subroutine = "fe_mul",
    deps = [
        ":field25519_test",
    ],
)

otbn_consttime_test(
    name = "field25519_fe_square_consttime",
    subroutine = "fe_square",
    deps = [
        ":field25519_test",
    ],
)

otbn_sim_test(
    name = "gcd_small_test",
    srcs = [
        "gcd_small_test.s",
    ],
    exp = "gcd_small_test.exp",
    deps = [
        "//sw/otbn/crypto:gcd",
    ],
)

otbn_sim_test(
    name = "gcd_large_test",
    srcs = [
        "gcd_large_test.s",
    ],
    exp = "gcd_large_test.exp",
    deps = [
        "//sw/otbn/crypto:gcd",
    ],
)

otbn_consttime_test(
    name = "gcd_consttime",
    # All inputs are in DMEM; no registers are secret.
    secrets = ["dmem"],
    subroutine = "gcd",
    deps = [
        ":gcd_small_test",
    ],
)

otbn_sim_test(
    name = "lcm_test",
    srcs = [
        "lcm_test.s",
    ],
    exp = "lcm_test.exp",
    deps = [
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:mul",
    ],
)

otbn_consttime_test(
    name = "lcm_consttime",
    # All inputs are in DMEM; no registers are secret.
    secrets = ["dmem"],
    subroutine = "lcm",
    deps = [
        ":lcm_test",
    ],
)

otbn_sim_test(
    name = "mul_test",
    srcs = [
        "mul_test.s",
    ],
    dexp = "mul_test.dexp",
    deps = [
        "//sw/otbn/crypto:mul",
    ],
)

otbn_consttime_test(
    name = "mul_consttime",
    # All inputs are in DMEM; no registers are secret.
    secrets = ["dmem"],
    subroutine = "bignum_mul",
    deps = [
        ":mul_test",
    ],
)

otbn_sim_test(
    name = "p256_base_mult_test",
    srcs = [
        "p256_base_mult_test.s",
    ],
    exp = "p256_base_mult_test.exp",
    deps = [
        "//sw/otbn/crypto:p256_base",
    ],
)

otbn_consttime_test(
    name = "p256_base_mult_consttime",
    subroutine = "p256_base_mult",
    deps = [
        "//sw/otbn/crypto:run_p256",
    ],
)

otbn_consttime_test(
    name = "p256_isoncurve_consttime",
    subroutine = "p256_isoncurve",
    deps = [
        "//sw/otbn/crypto:run_p256",
    ],
)

otbn_consttime_test(
    name = "p256_key_from_seed_consttime",
    subroutine = "p256_key_from_seed",
    deps = [
        "//sw/otbn/crypto:run_p256",
    ],
)

otbn_sim_test(
    name = "p256_key_from_seed_test",
    srcs = [
        "p256_key_from_seed_test.s",
    ],
    exp = "p256_key_from_seed_test.exp",
    deps = [
        "//sw/otbn/crypto:p256_base",
    ],
)

otbn_sim_test(
    name = "p256_mul_modp_test",
    srcs = [
        "p256_mul_modp_test.s",
    ],
    exp = "p256_mul_modp_test.exp",
    deps = [
        "//sw/otbn/crypto:p256_base",
    ],
)

otbn_consttime_test(
    name = "p256_proj_add_consttime",
    subroutine = "proj_add",
    deps = [
        "//sw/otbn/crypto:run_p256",
    ],
)

otbn_consttime_test(
    name = "p256_shared_key_consttime",
    subroutine = "p256_shared_key",
    deps = [
        "//sw/otbn/crypto:run_p256",
    ],
)

# TODO: Add more fine-grained DMEM tracing to the constant-time checker. This
# test fails because p256_sign branches based on some non-secret values from
# DMEM. However, since there are also secret values in DMEM, it's not safe to
# mark DMEM non-secret, and the constant-time checker doesn't currently have
# the ability to track different DMEM regions separately.
#
# otbn_consttime_test(
#   name = "p256_sign_consttime",
#   deps = [
#       "//sw/otbn/crypto:run_p256"
#   ],
#   subroutine = "p256_sign",
# )

otbn_sim_test(
    name = "p256_ecdsa_sign_test",
    srcs = [
        "p256_ecdsa_sign_test.s",
    ],
    exp = "p256_ecdsa_sign_test.exp",
    deps = [
        "//sw/otbn/crypto:p256_base",
        "//sw/otbn/crypto:p256_sign",
    ],
)

otbn_sim_test(
    name = "p256_ecdsa_verify_test",
    srcs = [
        "p256_ecdsa_verify_test.s",
    ],
    exp = "p256_ecdsa_verify_test.exp",
    deps = [
        "//sw/otbn/crypto:p256_base",
        "//sw/otbn/crypto:p256_isoncurve",
        "//sw/otbn/crypto:p256_verify",
    ],
)

otbn_sim_test(
    name = "p256_isoncurve_test",
    srcs = [
        "p256_isoncurve_test.s",
    ],
    exp = "p256_isoncurve_test.exp",
    deps = [
        "//sw/otbn/crypto:p256_base",
        "//sw/otbn/crypto:p256_isoncurve",
    ],
)

otbn_sim_test(
    name = "p256_proj_add_test",
    srcs = [
        "p256_proj_add_test.s",
    ],
    exp = "p256_proj_add_test.exp",
    deps = [
        "//sw/otbn/crypto:p256_base",
    ],
)

otbn_sim_test(
    name = "p256_proj_double_test",
    srcs = [
        "p256_proj_double_test.s",
    ],
    exp = "p256_proj_double_test.exp",
    deps = [
        "//sw/otbn/crypto:p256_base",
    ],
)

otbn_sim_test(
    name = "p256_scalar_mult_test",
    srcs = [
        "p256_scalar_mult_test.s",
    ],
    exp = "p256_scalar_mult_test.exp",
    deps = [
        "//sw/otbn/crypto:p256_base",
    ],
)

otbn_sim_test(
    name = "p256_ecdh_shared_key_test",
    srcs = [
        "p256_ecdh_shared_key_test.s",
    ],
    exp = "p256_ecdh_shared_key_test.exp",
    deps = [
        "//sw/otbn/crypto:p256_base",
        "//sw/otbn/crypto:p256_shared_key",
    ],
)

otbn_sim_test(
    name = "p256_arithmetic_to_boolean_test",
    srcs = [
        "p256_arithmetic_to_boolean_test.s",
    ],
    exp = "p256_arithmetic_to_boolean_test.exp",
    deps = [
        "//sw/otbn/crypto:p256_base",
        "//sw/otbn/crypto:p256_shared_key",
    ],
)

otbn_sim_test(
    name = "p256_arithmetic_to_boolean_mod_test",
    srcs = [
        "p256_arithmetic_to_boolean_mod_test.s",
    ],
    exp = "p256_arithmetic_to_boolean_mod_test.exp",
    deps = [
        "//sw/otbn/crypto:p256_base",
        "//sw/otbn/crypto:p256_shared_key",
    ],
)

otbn_sim_test_suite(
    name = "p256_test",
    binary = "//sw/otbn/crypto:run_p256",
    tests = [
        "p256_check_public_key_not_on_curve.hjson",
        "p256_check_public_key_valid.hjson",
        "p256_check_public_key_x_too_large.hjson",
        "p256_check_public_key_y_too_large.hjson",
        "p256_isoncurve_valid.hjson",
    ],
)

otbn_sim_test(
    name = "p384_base_mult_test",
    srcs = [
        "p384_base_mult_test.s",
    ],
    exp = "p384_base_mult_test.exp",
    deps = [
        "//sw/otbn/crypto:p384_base",
        "//sw/otbn/crypto:p384_base_mult",
        "//sw/otbn/crypto:p384_internal_mult",
    ],
)

otbn_sim_test(
    name = "p384_boolean_to_arithmetic_test",
    srcs = [
        "p384_boolean_to_arithmetic_test.s",
    ],
    exp = "p384_boolean_to_arithmetic_test.exp",
    deps = [
        "//sw/otbn/crypto:p384_b2a",
    ],
)

otbn_sim_test(
    name = "p384_arithmetic_to_boolean_test",
    srcs = [
        "p384_arithmetic_to_boolean_test.s",
    ],
    exp = "p384_arithmetic_to_boolean_test.exp",
    deps = [
        "//sw/otbn/crypto:p384_a2b",
        "//sw/otbn/crypto:p384_base",
    ],
)

otbn_sim_test(
    name = "p384_arithmetic_to_boolean_mod_test",
    srcs = [
        "p384_arithmetic_to_boolean_mod_test.s",
    ],
    exp = "p384_arithmetic_to_boolean_mod_test.exp",
    deps = [
        "//sw/otbn/crypto:p384_a2b",
        "//sw/otbn/crypto:p384_base",
    ],
)

otbn_sim_test(
    name = "p384_ecdh_shared_key_test",
    srcs = [
        "p384_ecdh_shared_key_test.s",
    ],
    exp = "p384_ecdh_shared_key_test.exp",
    deps = [
        "//sw/otbn/crypto:p384_a2b",
        "//sw/otbn/crypto:p384_base",
        "//sw/otbn/crypto:p384_internal_mult",
        "//sw/otbn/crypto:p384_scalar_mult",
    ],
)

otbn_sim_test(
    name = "p384_ecdsa_sign_test",
    srcs = [
        "p384_ecdsa_sign_test.s",
    ],
    exp = "p384_ecdsa_sign_test.exp",
    deps = [
        "//sw/otbn/crypto:p384_base",
        "//sw/otbn/crypto:p384_internal_mult",
        "//sw/otbn/crypto:p384_modinv",
        "//sw/otbn/crypto:p384_sign",
    ],
)

otbn_sim_test(
    name = "p384_ecdsa_verify_test",
    srcs = [
        "p384_ecdsa_verify_test.s",
    ],
    dexp = "p384_ecdsa_verify_test.dexp",
    exp = "p384_ecdsa_verify_test.exp",
    deps = [
        "//sw/otbn/crypto:p384_base",
        "//sw/otbn/crypto:p384_isoncurve",
        "//sw/otbn/crypto:p384_modinv",
        "//sw/otbn/crypto:p384_verify",
    ],
)

otbn_sim_test(
    name = "p384_isoncurve_test",
    srcs = [
        "p384_isoncurve_test.s",
    ],
    exp = "p384_isoncurve_test.exp",
    deps = [
        "//sw/otbn/crypto:p384_base",
        "//sw/otbn/crypto:p384_isoncurve",
    ],
)

otbn_sim_test(
    name = "p384_curve_point_valid_test",
    srcs = [
        "p384_curve_point_valid_test.s",
    ],
    exp = "p384_curve_point_valid_test.exp",
    deps = [
        "//sw/otbn/crypto:p384_base",
        "//sw/otbn/crypto:p384_isoncurve",
    ],
)

otbn_sim_test(
    name = "p384_keygen_test",
    srcs = [
        "p384_keygen_test.s",
    ],
    exp = "p384_keygen_test.exp",
    deps = [
        "//sw/otbn/crypto:p384_base",
        "//sw/otbn/crypto:p384_keygen",
    ],
)

otbn_sim_test(
    name = "p384_keygen_from_seed_test",
    srcs = [
        "p384_keygen_from_seed_test.s",
    ],
    exp = "p384_keygen_from_seed_test.exp",
    deps = [
        "//sw/otbn/crypto:p384_b2a",
        "//sw/otbn/crypto:p384_base",
        "//sw/otbn/crypto:p384_keygen_from_seed",
    ],
)

otbn_sim_test(
    name = "p384_proj_add_test",
    srcs = [
        "p384_proj_add_test.s",
    ],
    exp = "p384_proj_add_test.exp",
    deps = [
        "//sw/otbn/crypto:p384_base",
    ],
)

otbn_sim_test(
    name = "p384_scalar_mult_test",
    srcs = [
        "p384_scalar_mult_test.s",
    ],
    exp = "p384_scalar_mult_test.exp",
    deps = [
        "//sw/otbn/crypto:p384_base",
        "//sw/otbn/crypto:p384_internal_mult",
        "//sw/otbn/crypto:p384_scalar_mult",
    ],
)

otbn_sim_test(
    name = "p384_mulmod448x128_test",
    srcs = [
        "p384_mulmod448x128_test.s",
    ],
    exp = "p384_mulmod448x128_test.exp",
    deps = [
        "//sw/otbn/crypto:p384_base",
    ],
)

otbn_consttime_test(
    name = "p384_base_mult_consttime",
    subroutine = "p384_base_mult",
    deps = [
        ":p384_base_mult_test",
    ],
)

otbn_consttime_test(
    name = "p384_scalar_mult_consttime",
    subroutine = "p384_scalar_mult",
    deps = [
        ":p384_scalar_mult_test",
    ],
)

otbn_consttime_test(
    name = "p384_mulmod_p_consttime",
    subroutine = "p384_mulmod_p",
    deps = [
        ":p384_ecdsa_sign_test",
    ],
)

otbn_consttime_test(
    name = "p384_mulmod_n_consttime",
    subroutine = "p384_mulmod_n",
    deps = [
        ":p384_ecdsa_sign_test",
    ],
)

# TODO: Add more fine-grained DMEM tracing to the constant-time checker. This
# test fails because p384_sign branches based on some non-secret values from
# DMEM. However, since there are also secret values in DMEM, it's not safe to
# mark DMEM non-secret, and the constant-time checker doesn't currently have
# the ability to track different DMEM regions separately.
#
# otbn_consttime_test(
#   name = "p384_sign_consttime",
#   deps = [
#       ":p384_ecdsa_sign_test"
#   ],
#   subroutine = "p384_sign",
# )

otbn_consttime_test(
    name = "proj_add_p384_consttime",
    initial_constants = [
        "x22:10",
        "x23:11",
        "x24:16",
        "x25:17",
    ],
    subroutine = "proj_add_p384",
    deps = [
        ":p384_ecdsa_sign_test",
    ],
)

otbn_library(
    name = "fake_primality",
    srcs = [
        "fake_primality.s",
    ],
)

otbn_sim_test(
    name = "primality_test",
    timeout = "long",
    srcs = [
        "primality_test.s",
    ],
    exp = "primality_test.exp",
    deps = [
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:primality",
    ],
)

otbn_sim_test(
    name = "primality_test_witness_test",
    timeout = "long",
    srcs = [
        "primality_test_witness_test.s",
    ],
    exp = "primality_test_witness_test.exp",
    deps = [
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:primality",
    ],
)

otbn_sim_test(
    name = "primality_test_witness_negative_test",
    timeout = "long",
    srcs = [
        "primality_test_witness_negative_test.s",
    ],
    exp = "primality_test_witness_negative_test.exp",
    deps = [
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:primality",
    ],
)

otbn_sim_test(
    name = "primality_negative_test",
    timeout = "long",
    srcs = [
        "primality_negative_test.s",
    ],
    exp = "primality_negative_test.exp",
    deps = [
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:primality",
    ],
)

# Miller-Rabin with 1024-bit primes (as in RSA-2048).
otbn_consttime_test(
    name = "miller_rabin_consttime_1024",
    # 4 limbs, x30 = n and x31 = n -1
    initial_constants = [
        "x30:4",
        "x31:3",
    ],
    # All secrets are stored in DMEM; timing is permitted to depend on the
    # number of limbs.
    secrets = ["dmem"],
    subroutine = "miller_rabin",
    deps = [
        ":primality_test",
    ],
)

# Miller-Rabin with 1536-bit primes (as in RSA-3072).
otbn_consttime_test(
    name = "miller_rabin_consttime_1536",
    # 6 limbs, x30 = n and x31 = n -1
    initial_constants = [
        "x30:6",
        "x31:5",
    ],
    # All secrets are stored in DMEM; timing is permitted to depend on the
    # number of limbs.
    secrets = ["dmem"],
    subroutine = "miller_rabin",
    deps = [
        ":primality_test",
    ],
)

# Miller-Rabin with 2048-bit primes (as in RSA-4096).
otbn_consttime_test(
    name = "miller_rabin_consttime_2048",
    # 8 limbs, x30 = n and x31 = n -1
    initial_constants = [
        "x30:8",
        "x31:7",
    ],
    # All secrets are stored in DMEM; timing is permitted to depend on the
    # number of limbs.
    secrets = ["dmem"],
    subroutine = "miller_rabin",
    deps = [
        ":primality_test",
    ],
)

otbn_sim_test(
    name = "modinv_f4_test",
    srcs = [
        "modinv_f4_test.s",
    ],
    exp = "modinv_f4_test.exp",
    deps = [
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:primality",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_consttime_test(
    name = "modinv_f4_consttime_test",
    initial_constants = [
        "x20:20",
        "x21:21",
    ],
    # All secrets are stored in DMEM; timing is permitted to depend on the
    # number of limbs.
    secrets = ["dmem"],
    subroutine = "modinv_f4",
    deps = [
        ":modinv_f4_test",
    ],
)

otbn_sim_test(
    name = "relprime_f4_test",
    srcs = [
        "relprime_f4_test.s",
    ],
    exp = "relprime_f4_test.exp",
    deps = [
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:primality",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_consttime_test(
    name = "relprime_f4_consttime_test",
    # All secrets are stored in DMEM; timing is permitted to depend on the
    # number of limbs.
    secrets = ["dmem"],
    subroutine = "relprime_f4",
    deps = [
        ":relprime_f4_test",
    ],
)

otbn_sim_test(
    name = "relprime_small_primes_multiple_of_3_test",
    srcs = [
        "relprime_small_primes_multiple_of_3_test.s",
    ],
    exp = "relprime_small_primes_multiple_of_3_test.exp",
    deps = [
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:primality",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_sim_test(
    name = "relprime_small_primes_multiple_of_5_test",
    srcs = [
        "relprime_small_primes_multiple_of_5_test.s",
    ],
    exp = "relprime_small_primes_multiple_of_5_test.exp",
    deps = [
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:primality",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_sim_test(
    name = "relprime_small_primes_multiple_of_7_test",
    srcs = [
        "relprime_small_primes_multiple_of_7_test.s",
    ],
    exp = "relprime_small_primes_multiple_of_7_test.exp",
    deps = [
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:primality",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_sim_test(
    name = "relprime_small_primes_multiple_of_11_test",
    srcs = [
        "relprime_small_primes_multiple_of_11_test.s",
    ],
    exp = "relprime_small_primes_multiple_of_11_test.exp",
    deps = [
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:primality",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_sim_test(
    name = "relprime_small_primes_multiple_of_17_test",
    srcs = [
        "relprime_small_primes_multiple_of_17_test.s",
    ],
    exp = "relprime_small_primes_multiple_of_17_test.exp",
    deps = [
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:primality",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_sim_test(
    name = "relprime_small_primes_multiple_of_31_test",
    srcs = [
        "relprime_small_primes_multiple_of_31_test.s",
    ],
    exp = "relprime_small_primes_multiple_of_31_test.exp",
    deps = [
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:primality",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_sim_test(
    name = "relprime_small_primes_negative_test",
    srcs = [
        "relprime_small_primes_negative_test.s",
    ],
    exp = "relprime_small_primes_negative_test.exp",
    deps = [
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:primality",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_library(
    name = "rsa_keygen_checkpq_test_data",
    srcs = [
        "rsa_keygen_checkpq_test_data.s",
    ],
)

otbn_sim_test(
    name = "rsa_keygen_checkp_good_test",
    timeout = "long",  # runs a primality test
    srcs = [
        "rsa_keygen_checkp_good_test.s",
    ],
    exp = "rsa_keygen_checkp_good_test.exp",
    tags = ["nightly"],  # slow, do not run in CI
    deps = [
        ":rsa_keygen_checkpq_test_data",
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:primality",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_sim_test(
    name = "rsa_keygen_checkp_not_relprime_test",
    srcs = [
        "rsa_keygen_checkp_not_relprime_test.s",
    ],
    exp = "rsa_keygen_checkp_not_relprime_test.exp",
    deps = [
        ":fake_primality",
        ":rsa_keygen_checkpq_test_data",
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_sim_test(
    name = "rsa_keygen_checkp_not_prime_test",
    timeout = "long",  # runs a primality test
    srcs = [
        "rsa_keygen_checkp_not_prime_test.s",
    ],
    exp = "rsa_keygen_checkp_not_prime_test.exp",
    deps = [
        ":rsa_keygen_checkpq_test_data",
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:primality",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_sim_test(
    name = "rsa_keygen_checkq_good_test",
    timeout = "long",  # runs a primality test
    srcs = [
        "rsa_keygen_checkq_good_test.s",
    ],
    exp = "rsa_keygen_checkq_good_test.exp",
    tags = ["nightly"],  # slow, do not run in CI
    deps = [
        ":rsa_keygen_checkpq_test_data",
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:primality",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_sim_test(
    name = "rsa_keygen_checkq_not_prime_test",
    timeout = "long",  # runs a primality test
    srcs = [
        "rsa_keygen_checkq_not_prime_test.s",
    ],
    exp = "rsa_keygen_checkq_not_prime_test.exp",
    deps = [
        ":rsa_keygen_checkpq_test_data",
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:primality",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_sim_test(
    name = "rsa_keygen_checkq_not_relprime_test",
    srcs = [
        "rsa_keygen_checkq_not_relprime_test.s",
    ],
    exp = "rsa_keygen_checkq_not_relprime_test.exp",
    deps = [
        ":fake_primality",
        ":rsa_keygen_checkpq_test_data",
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_sim_test(
    name = "rsa_keygen_checkq_too_close_test",
    srcs = [
        "rsa_keygen_checkq_too_close_test.s",
    ],
    exp = "rsa_keygen_checkq_too_close_test.exp",
    deps = [
        ":fake_primality",
        ":rsa_keygen_checkpq_test_data",
        "//sw/otbn/crypto:div",
        "//sw/otbn/crypto:gcd",
        "//sw/otbn/crypto:lcm",
        "//sw/otbn/crypto:montmul",
        "//sw/otbn/crypto:mul",
        "//sw/otbn/crypto:rsa_keygen",
    ],
)

otbn_sim_test(
    name = "rsa_1024_dec_test",
    timeout = "long",
    srcs = [
        "rsa_1024_dec_test.s",
    ],
    exp = "rsa_1024_dec_test.exp",
    deps = [
        "//sw/otbn/crypto:modexp",
        "//sw/otbn/crypto:montmul",
    ],
)

otbn_sim_test(
    name = "rsa_1024_enc_test",
    srcs = [
        "rsa_1024_enc_test.s",
    ],
    exp = "rsa_1024_enc_test.exp",
    deps = [
        "//sw/otbn/crypto:modexp",
        "//sw/otbn/crypto:montmul",
    ],
)

otbn_sim_test(
    name = "rsa_2048_dec_test",
    timeout = "eternal",
    srcs = [
        "rsa_2048_dec_test.s",
    ],
    exp = "rsa_2048_dec_test.exp",
    deps = [
        "//sw/otbn/crypto:modexp",
        "//sw/otbn/crypto:montmul",
    ],
)

otbn_sim_test(
    name = "rsa_2048_enc_test",
    srcs = [
        "rsa_2048_enc_test.s",
    ],
    exp = "rsa_2048_enc_test.exp",
    deps = [
        "//sw/otbn/crypto:modexp",
        "//sw/otbn/crypto:montmul",
    ],
)

otbn_sim_test(
    name = "rsa_3072_dec_test",
    timeout = "eternal",
    srcs = [
        "rsa_3072_dec_test.s",
    ],
    exp = "rsa_3072_dec_test.exp",
    tags = ["nightly"],  # slow, do not run in CI
    deps = [
        "//sw/otbn/crypto:modexp",
        "//sw/otbn/crypto:montmul",
    ],
)

otbn_sim_test(
    name = "rsa_3072_enc_test",
    srcs = [
        "rsa_3072_enc_test.s",
    ],
    exp = "rsa_3072_enc_test.exp",
    deps = [
        "//sw/otbn/crypto:modexp",
        "//sw/otbn/crypto:montmul",
    ],
)

otbn_sim_test(
    name = "rsa_4096_enc_test",
    srcs = [
        "rsa_4096_enc_test.s",
    ],
    exp = "rsa_4096_enc_test.exp",
    deps = [
        "//sw/otbn/crypto:modexp",
        "//sw/otbn/crypto:montmul",
    ],
)

otbn_sim_test(
    name = "rsa_verify_test",
    srcs = [
        "rsa_verify_test.s",
    ],
    exp = "rsa_verify_test.exp",
    deps = [
        "//sw/otbn/crypto:rsa_verify",
    ],
)

otbn_sim_test(
    name = "rsa_verify_exp3_test",
    srcs = [
        "rsa_verify_exp3_test.s",
    ],
    exp = "rsa_verify_exp3_test.exp",
    deps = [
        "//sw/otbn/crypto:rsa_verify",
    ],
)

otbn_sim_test(
    name = "rsa_verify_3072_consts_test",
    srcs = [
        "rsa_verify_3072_consts_test.s",
    ],
    exp = "rsa_verify_3072_consts_test.exp",
    deps = [
        "//sw/otbn/crypto:rsa_verify_3072",
        "//sw/otbn/crypto:rsa_verify_3072_m0inv",
        "//sw/otbn/crypto:rsa_verify_3072_rr",
    ],
)

otbn_sim_test(
    name = "rsa_verify_3072_test",
    srcs = [
        "rsa_verify_3072_test.s",
    ],
    exp = "rsa_verify_3072_test.exp",
    deps = [
        "//sw/otbn/crypto:rsa_verify_3072",
    ],
)

otbn_sim_test(
    name = "sha256_test",
    srcs = [
        "sha256_test.s",
    ],
    exp = "sha256_test.exp",
    deps = [
        "//sw/otbn/crypto:sha256",
    ],
)

otbn_consttime_test(
    name = "sha256_consttime",
    # All secrets are stored in DMEM; timing is permitted to depend on the
    # number of message chunks.
    secrets = ["dmem"],
    subroutine = "sha256",
    deps = [
        ":sha256_test",
    ],
)

otbn_sim_test(
    name = "sha512_test",
    srcs = [
        "sha512_test.s",
    ],
    exp = "sha512_test.exp",
    deps = [
        "//sw/otbn/crypto:sha512",
    ],
)

otbn_sim_test(
    name = "sha512_compact_test",
    srcs = [
        "sha512_compact_test.s",
    ],
    exp = "sha512_compact_test.exp",
    deps = [
        "//sw/otbn/crypto:sha512_compact",
    ],
)

otbn_sim_test(
    name = "sha384_test",
    srcs = [
        "sha384_test.s",
    ],
    exp = "sha384_test.exp",
    deps = [
        "//sw/otbn/crypto:sha512",
    ],
)

otbn_sim_test(
    name = "sha3_shake_test",
    srcs = [
        "sha3_shake_test.s",
    ],
    exp = "sha3_shake_test.exp",
    deps = [
        "//sw/otbn/crypto:sha3_shake",
    ],
)

otbn_sim_test(
    name = "x25519_test1",
    srcs = [
        "x25519_test1.s",
    ],
    exp = "x25519_test1.exp",
    deps = [
        "//sw/otbn/crypto:field25519",
        "//sw/otbn/crypto:x25519",
    ],
)

otbn_sim_test(
    name = "x25519_test2",
    srcs = [
        "x25519_test2.s",
    ],
    exp = "x25519_test2.exp",
    deps = [
        "//sw/otbn/crypto:field25519",
        "//sw/otbn/crypto:x25519",
    ],
)

otbn_consttime_test(
    name = "x25519_consttime",
    subroutine = "X25519",
    deps = [
        ":x25519_test1",
    ],
)

otbn_sim_test_suite(
    name = "boot_test",
    binary = "//sw/otbn/crypto:boot",
    tests = [
        "boot_key_endorse_valid.hjson",
        "boot_key_save_valid.hjson",
        "boot_keygen_valid.hjson",
        "boot_mode_invalid.hjson",
        "boot_sigverify_valid.hjson",
    ],
)
