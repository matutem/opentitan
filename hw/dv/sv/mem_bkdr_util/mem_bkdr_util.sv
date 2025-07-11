// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Provides a mechanism to manipulate and access a memory instance in the design via backdoor.
//
// This is a class based implementation, which on initialization (`new()`) takes the path to the
// memory hierarchy, the size in bits, the depth, integrity protection and scrambling needs as
// arguments. All memory specifics are set / computed at runtime. There are no parameterizations, so
// that the implementation is flexible, extensible, and easy to use.
//
// Create an instance of this class in the testbench module itself, so that the hierarchical path to
// the memory element and its size and depth information is available. Pass the instance to the UVM
// side via uvm_config_db.
class mem_bkdr_util extends uvm_object;
  // Hierarchical path to the memory.
  protected string path;

  // If set to a value different to "", a path to the tile memory, based on path and tiling_path,
  // is used to perform the backdoor access
  protected string tiling_path;

  // Format string to provide the tiling suffix. Must contain a %d for the tile and %s for the
  // tiling_path path. Can be overwritten for different hierarchies, ie., when DFT is enabled.
  protected string tiling_suffix_fmt_str;

  // The depth of the memory.
  protected uint32_t depth;

  // The depth of a single SRAM tile.
  protected uint32_t tile_depth;

  // The logical width of the memory in bits, not including extra bits added by the row adapter.
  protected uint32_t width;

  // The number of subword entries in the whole memory
  protected uint32_t num_entries;

  // Indicates the error detection scheme implemented for this memory.
  protected err_detection_e err_detection_scheme = ErrDetectionNone;

  // Adapter to access the underlying memory organization
  // Integrators can provide a custom row adapter for their SRAM primitives
  protected mem_bkdr_util_row_adapter row_adapter;

  // Convenience macro to check if ECC / parity is enabled.
  `define HAS_ECC (!(err_detection_scheme inside {ErrDetectionNone, ParityEven, ParityOdd}))
  `define HAS_PARITY (err_detection_scheme inside {ParityEven, ParityOdd})

  // Other memory specifics derived from the settings above.
  protected uint32_t data_width;  // ignoring ECC bits
  protected uint32_t byte_width;
  protected uint32_t bytes_per_word;  // addressable bytes
  protected uint32_t size_bytes;  // addressable bytes
  protected uint32_t addr_lsb;
  protected uint32_t addr_width;
  protected uint32_t byte_addr_width;

  // Address range of this memory in the system address map.
  protected addr_range_t addr_range;

  // Indicates the maximum number of errors that can be injected.
  //
  // If parity is enabled, this limit applies to a single byte in the memory width. We cannot inject
  // more than 1 error per each byte of data. In case of ECC, it applies to the entire width.
  protected uint32_t max_errors;

  // File operations.
  //
  // We unfortunately cannot use the system tasks $readmemh and $writememh due to class based
  // implementation. This is done externally in the testbench module where the class instance is
  // created instead. The following signals and events are used by the testbench to know when to
  // read or write the memory with the contents of the file.
  protected string file;
  event readmemh_event;
  event writememh_event;

  // Number of PRINCE half rounds for scrambling, can be [1..5].
  protected uint32_t num_prince_rounds_half;

  // Construct an instance called name.
  //
  // Required arguments:
  //
  //   path:                 A hierarchical HDL path to the memory.
  //
  //   depth:                The number memory rows.
  //
  //   n_bits:               The total size of the memory in bits.
  //
  //   err_detection_scheme  The error detection scheme that is implemented for the memory.
  //
  // Optional arguments:
  //
  //  row_adapter              Adapter to access the internal row of a memory. Integrators can
  //                           provide a custom adapter for a different memory architecture.
  //
  //  num_prince_rounds_half   The number of rounds of PRINCE used to scramble the memory. This is
  //                           used for scrambled memories. This defaults to 3.
  //
  //  extra_bits_per_subword   When ECC is enabled, the words of the memory are divided into
  //                           separate subwords that are used for ECC checks. This gives the number
  //                           of extra bits added to each subword (to contain additional SECDED
  //                           metadata). This defaults to zero.
  //
  //  system_base_addr         The memory words accessed through this backdoor would normally be
  //                           indexed from zero. If this value is non-zero, the backdoor starts at
  //                           some higher index.
  //
  //  tiling_path              A path used for constructing HDL paths to individual tiles (used
  //                           when tile_depth < depth). By default this is empty because there are
  //                           no tiles that would need paths at all.
  //
  //  tiling_suffix_fmt_str    Format string to provide the tiling suffix. Must contain a %d for the
  //                           tile and %s for the tiling_path path. If the testbench uses a
  //                           different path, i.e., in a DFT environment, you can pass a different
  //                           format string to construct the tiling path.
  //
  //  tile_depth               The number of rows of a single tle. By default, this is the entire
  //                           memory.
  function new(string name = "", string path, int unsigned depth,
               longint unsigned n_bits, err_detection_e err_detection_scheme,
               mem_bkdr_util_row_adapter row_adapter = null,
               uint32_t num_prince_rounds_half = 3,
               uint32_t extra_bits_per_subword = 0, uint32_t system_base_addr = 0,
               string tiling_path = "", string tiling_suffix_fmt_str = ".gen_ram_inst[%0d].%s",
               uint32_t tile_depth = depth);
    super.new(name);
    `DV_CHECK_FATAL(!(n_bits % depth), "n_bits must be divisible by depth.")

    if (row_adapter != null) begin
      this.row_adapter = row_adapter;
    end else begin
      this.row_adapter = new();
    end

    this.path                   = path;
    this.tiling_path            = tiling_path;
    this.depth                  = depth;
    this.tile_depth             = tile_depth;
    this.tiling_suffix_fmt_str  = tiling_suffix_fmt_str;
    this.width                  = (n_bits / depth) - this.row_adapter.get_num_extra_bits();
    this.err_detection_scheme   = err_detection_scheme;
    this.num_prince_rounds_half = num_prince_rounds_half;

    // Check if the inferred path to each tile (or the whole memory) really exist
    for (int i = 0; i < (depth + tile_depth - 1) / tile_depth; i++) begin
      string full_path = get_full_path(i);
      `DV_CHECK_FATAL(uvm_hdl_check_path(get_full_path(i)) == 1,
                      $sformatf("Hierarchical path %0s appears to be invalid.", full_path))
    end

    if (`HAS_ECC) begin
      import prim_secded_pkg::prim_secded_e;
      import prim_secded_pkg::get_ecc_data_width;
      import prim_secded_pkg::get_ecc_parity_width;

      prim_secded_e secded_eds = prim_secded_e'(err_detection_scheme);
      int non_ecc_bits_per_subword = get_ecc_data_width(secded_eds);
      int ecc_bits_per_subword = get_ecc_parity_width(secded_eds);
      int bits_per_subword = non_ecc_bits_per_subword + ecc_bits_per_subword +
                             extra_bits_per_subword;
      int subwords_per_word;

      // We shouldn't truncate the actual data word. This check ensures that err_detection_scheme
      // and width are related sensibly. This only checks we've got enough space for one data word
      // and at least one check bit. The next check will make sure that we don't truncate if there
      // are multiple subwords.
      `DV_CHECK_FATAL(non_ecc_bits_per_subword < this.width)

      // Normally, we'd want width to be divisible by bits_per_subword, which means that we get a
      // whole number of subwords in a word. As a special case, we also allow a having exactly one
      // subword and only keeping some of the bits. This is used by the flash controller.
      `DV_CHECK_FATAL((this.width < bits_per_subword) || (this.width % bits_per_subword == 0),
                      "With multiple subwords, mem width must be a multiple of the ECC width")

      subwords_per_word = (width + bits_per_subword - 1) / bits_per_subword;
      this.data_width = subwords_per_word * non_ecc_bits_per_subword;
      this.num_entries = depth * subwords_per_word;
    end else begin
      this.data_width = width;
      this.num_entries = depth;
    end

    byte_width = `HAS_PARITY ? 9 : 8;
    bytes_per_word = data_width / byte_width;
    `DV_CHECK_LE_FATAL(bytes_per_word, 32, "data width > 32 bytes is not supported")
    size_bytes = depth * bytes_per_word;
    addr_lsb   = $clog2(bytes_per_word);
    addr_width = $clog2(depth);
    byte_addr_width = addr_width + addr_lsb;
    addr_range.start_addr = system_base_addr;
    addr_range.end_addr = system_base_addr + size_bytes - 1;
    max_errors = width;
    if (name == "") set_name({path, "::mem_bkdr_util"});
    `uvm_info(`gfn, this.convert2string(), UVM_MEDIUM)
  endfunction

  virtual function string convert2string();
    return {"\n",
            $sformatf("path = %0s\n", path),
            $sformatf("depth = %0d\n", depth),
            $sformatf("width = %0d\n", width),
            $sformatf("err_detection_scheme = %0s\n", err_detection_scheme.name),
            $sformatf("data_width = %0d\n", data_width),
            $sformatf("byte_width = %0d\n", byte_width),
            $sformatf("bytes_per_word = %0d\n", bytes_per_word),
            $sformatf("size_bytes = 0x%0h\n", size_bytes),
            $sformatf("addr_lsb = %0d\n", addr_lsb),
            $sformatf("addr_width = %0d\n", addr_width),
            $sformatf("byte_addr_width = %0d\n", byte_addr_width),
            $sformatf("max_errors = %0d\n", max_errors),
            $sformatf("addr_range.start_addr = 0x%0h\n", addr_range.start_addr),
            $sformatf("addr_range.end_addr = 0x%0h\n", addr_range.end_addr)};
  endfunction

  function string get_path();
    return path;
  endfunction

  function string get_full_path(int unsigned tile);
    string base = get_path();
    string tile_suffix = "";

    `DV_CHECK_FATAL(tile > 0 -> tiling_path.len() > 0,
                    $sformatf("Positive tile index (%0d) with empty tiling path.", tile))

    if (tiling_path != "") begin
      tile_suffix = $sformatf(tiling_suffix_fmt_str, tile, tiling_path);
    end

    return {base, tile_suffix};
  endfunction

  function uint32_t get_depth();
    return depth;
  endfunction

  function uint32_t get_tile_depth();
    return tile_depth;
  endfunction

  function uint32_t get_width();
    return width;
  endfunction

  function err_detection_e get_err_detection_scheme();
    return err_detection_scheme;
  endfunction

  function int get_num_prince_rounds_half();
    return num_prince_rounds_half;
  endfunction

  function uint32_t get_data_width();
    return data_width;
  endfunction

  function uint32_t get_byte_width();
    return byte_width;
  endfunction

  function uint32_t get_bytes_per_word();
    return bytes_per_word;
  endfunction

  function uint32_t get_size_bytes();
    return size_bytes;
  endfunction

  function uint32_t get_addr_lsb();
    return addr_lsb;
  endfunction

  function uint32_t get_addr_width();
    return addr_width;
  endfunction

  function uint32_t get_byte_addr_width();
    return byte_addr_width;
  endfunction

  function bit is_valid_addr(int unsigned system_addr);
    return system_addr inside {[addr_range.start_addr:addr_range.end_addr]};
  endfunction

  function string get_file();
    return file;
  endfunction

  // Returns 1 if the given address falls within the memory's range, else 0.
  //
  // If addr is invalid, it throws UVM error before returning 0.
  protected virtual function bit check_addr_valid(bit [bus_params_pkg::BUS_AW-1:0] addr);
    if (addr >= size_bytes) begin
      `uvm_error(`gfn, $sformatf("addr %0h is out of bounds: size = %0h", addr, size_bytes))
      return 1'b0;
    end
    return 1'b1;
  endfunction

  // Read the entire word at the given address.
  //
  // addr is the byte address starting at offset 0. Mask the upper address bits as needed before
  // invocation.
  //
  // Returns the entire width of the memory at the given address, including the ECC bits. The data
  // returned is 'raw' i.e. it includes the parity bits. It also does not de-scramble the data if
  // encryption is enabled.
  virtual function uvm_hdl_data_t read(bit [bus_params_pkg::BUS_AW-1:0] addr);
    bit res;
    uint32_t index, ram_tile;
    uvm_hdl_data_t encoded_row, data;
    if (!check_addr_valid(addr)) return 'x;
    index    = addr >> addr_lsb;
    ram_tile = index / tile_depth;
    res      = uvm_hdl_read($sformatf("%0s[%0d]", get_full_path(ram_tile), index), encoded_row);
    `DV_CHECK_EQ(res, 1, $sformatf("uvm_hdl_read failed at index %0d", index))
    data     = row_adapter.decode_row(encoded_row);
    return data;
  endfunction

  // Convenience macro to check the addr for each flavor of read and write functions.
  `define _ACCESS_CHECKS(_ADDR, _DW) \
    `DV_CHECK_EQ_FATAL(_ADDR % (_DW / 8), 0, $sformatf("addr 0x%0h not ``_DW``-bit aligned", _ADDR))

  // Read a single byte at specified address.
  //
  // The data returned does not include the parity bits.
  virtual function logic [7:0] read8(bit [bus_params_pkg::BUS_AW-1:0] addr);
    uvm_hdl_data_t data = read(addr);
    int byte_offset = addr % bytes_per_word;
    return (data >> (byte_offset * byte_width)) & 8'hff;
  endfunction

  virtual function logic [15:0] read16(bit [bus_params_pkg::BUS_AW-1:0] addr);
    `_ACCESS_CHECKS(addr, 16)
    return {read8(addr + 1), read8(addr)};
  endfunction

  virtual function logic [31:0] read32(bit [bus_params_pkg::BUS_AW-1:0] addr);
    `_ACCESS_CHECKS(addr, 32)
    return {read16(addr + 2), read16(addr)};
  endfunction

  // this is used to read 32bit of data plus 7 raw integrity bits.
  virtual function logic [38:0] read39integ(bit [bus_params_pkg::BUS_AW-1:0] addr);
    `_ACCESS_CHECKS(addr, 32) // this is essentially an aligned 32bit access.
    return read(addr) & 39'h7fffffffff;
  endfunction

  virtual function logic [63:0] read64(bit [bus_params_pkg::BUS_AW-1:0] addr);
    `_ACCESS_CHECKS(addr, 64)
    return {read32(addr + 4), read32(addr)};
  endfunction

  virtual function logic [127:0] read128(bit [bus_params_pkg::BUS_AW-1:0] addr);
    `_ACCESS_CHECKS(addr, 128)
    return {read64(addr + 8), read64(addr)};
  endfunction

  virtual function logic [255:0] read256(bit [bus_params_pkg::BUS_AW-1:0] addr);
    `_ACCESS_CHECKS(addr, 256)
    return {read128(addr + 16), read128(addr)};
  endfunction

  // Returns data with correctly computed ECC.
  virtual function uvm_hdl_data_t get_ecc_computed_data(uvm_hdl_data_t data);
    case (err_detection_scheme)
      ErrDetectionNone: ;
      Ecc_22_16: begin
        data = prim_secded_pkg::prim_secded_22_16_enc(data[15:0]);
      end
      EccHamming_22_16: begin
        data = prim_secded_pkg::prim_secded_hamming_22_16_enc(data[15:0]);
      end
      Ecc_39_32: begin
        data = prim_secded_pkg::prim_secded_39_32_enc(data[31:0]);
      end
      EccHamming_39_32: begin
        data = prim_secded_pkg::prim_secded_hamming_39_32_enc(data[31:0]);
      end
      Ecc_72_64: begin
        data = prim_secded_pkg::prim_secded_72_64_enc(data[63:0]);
      end
      EccHamming_72_64: begin
        data = prim_secded_pkg::prim_secded_hamming_72_64_enc(data[63:0]);
      end
      EccHamming_76_68: begin
        data = prim_secded_pkg::prim_secded_hamming_76_68_enc(data[67:0]);
      end
      EccInv_22_16: begin
        data = prim_secded_pkg::prim_secded_inv_22_16_enc(data[15:0]);
      end
      EccInvHamming_22_16: begin
        data = prim_secded_pkg::prim_secded_inv_hamming_22_16_enc(data[15:0]);
      end
      EccInv_39_32: begin
        data = prim_secded_pkg::prim_secded_inv_39_32_enc(data[31:0]);
      end
      EccInvHamming_39_32: begin
        data = prim_secded_pkg::prim_secded_inv_hamming_39_32_enc(data[31:0]);
      end
      EccInv_72_64: begin
        data = prim_secded_pkg::prim_secded_inv_72_64_enc(data[63:0]);
      end
      EccInvHamming_72_64: begin
        data = prim_secded_pkg::prim_secded_inv_hamming_72_64_enc(data[63:0]);
      end
      EccInvHamming_76_68: begin
        data = prim_secded_pkg::prim_secded_inv_hamming_76_68_enc(data[67:0]);
      end
      default: begin
        `uvm_fatal(`gfn, $sformatf("ECC scheme %0s is unsupported.", err_detection_scheme))
      end
    endcase
    return data;
  endfunction

  // Write the entire word at the given address with the specified data.
  //
  // addr is the byte address starting at offset 0. Mask the upper address bits as needed before
  // invocation.
  //
  // Updates the entire width of the memory at the given address, including the ECC bits.
  virtual function void write(bit [bus_params_pkg::BUS_AW-1:0] addr, uvm_hdl_data_t data);
    bit res;
    uvm_hdl_data_t encoded_row;
    uint32_t index, ram_tile;
    if (!check_addr_valid(addr)) return;
    index       = addr >> addr_lsb;
    ram_tile    = index / tile_depth;
    encoded_row = row_adapter.encode_row(data);
    res         = uvm_hdl_deposit($sformatf("%0s[%0d]", get_full_path(ram_tile), index),
                                  encoded_row);
    `DV_CHECK_EQ(res, 1, $sformatf("uvm_hdl_deposit failed at index %0d", index))
  endfunction

  // Write a single byte at specified address.
  //
  // Does a read-modify-write on the whole word. It updates the byte at the given address and
  // computes the parity and ECC bits as applicable.
  virtual function void write8(bit [bus_params_pkg::BUS_AW-1:0] addr, logic [7:0] data);
    uvm_hdl_data_t rw_data;
    uint32_t word_idx;
    uint32_t byte_idx;

    if (!check_addr_valid(addr)) return;

    rw_data  = read(addr);
    word_idx = addr >> addr_lsb;
    byte_idx = addr - (word_idx << addr_lsb);

    if (`HAS_PARITY) begin
      bit parity = (err_detection_scheme == ParityOdd) ? ~(^data) : (^data);
      rw_data[byte_idx * 9 +: 9] = {parity, data};
      write(addr, rw_data);
      return;
    end

    // Update the byte index with the new value.
    rw_data[byte_idx * 8 +: 8] = data;

    // Compute & set the new ECC value.
    rw_data = get_ecc_computed_data(rw_data);

    // Write the whole array back to the memory.
    write(addr, rw_data);
  endfunction

  virtual function void write16(bit [bus_params_pkg::BUS_AW-1:0] addr, logic [15:0] data);
    `_ACCESS_CHECKS(addr, 16)
    if (!check_addr_valid(addr)) return;
    write8(addr, data[7:0]);
    write8(addr + 1, data[15:8]);
  endfunction

  virtual function void write32(bit [bus_params_pkg::BUS_AW-1:0] addr, logic [31:0] data);
    `_ACCESS_CHECKS(addr, 32)
    if (!check_addr_valid(addr)) return;
    write16(addr, data[15:0]);
    write16(addr + 2, data[31:16]);
  endfunction

  // this is used to write 32bit of data plus 7 raw integrity bits.
  virtual function void write39integ(bit [bus_params_pkg::BUS_AW-1:0] addr, logic [38:0] data);
    uvm_hdl_data_t rw_data;
    `_ACCESS_CHECKS(addr, 32) // this is essentially an aligned 32bit access.
    if (!check_addr_valid(addr)) return;
    // Perform a read-modify-write to access the underlying memory architecture
    rw_data = read(addr);
    rw_data = row_adapter.write_row_data_39b(addr, data, rw_data);
    // Note the write function takes care of interleaving, if used.
    write(addr, rw_data);
  endfunction

  virtual function void write64(bit [bus_params_pkg::BUS_AW-1:0] addr, logic [63:0] data);
    `_ACCESS_CHECKS(addr, 64)
    if (!check_addr_valid(addr)) return;
    write32(addr, data[31:0]);
    write32(addr + 4, data[63:32]);
  endfunction

  virtual function void write128(bit [bus_params_pkg::BUS_AW-1:0] addr, logic [127:0] data);
    `_ACCESS_CHECKS(addr, 128)
    if (!check_addr_valid(addr)) return;
    write64(addr, data[63:0]);
    write64(addr + 8, data[127:63]);
  endfunction

  virtual function void write256(bit [bus_params_pkg::BUS_AW-1:0] addr, logic [255:0] data);
    `_ACCESS_CHECKS(addr, 256)
    if (!check_addr_valid(addr)) return;
    write128(addr, data[127:0]);
    write128(addr + 16, data[255:128]);
  endfunction

  `undef _ACCESS_CHECKS

  /////////////////////////////////////////////////////////
  // Wrapper functions for memory reads with ECC enabled //
  /////////////////////////////////////////////////////////
  // Some notes:
  // - ECC isn't supported for 8-bit wide memories
  // - (28, 22) and (64, 57) ECC configurations aren't supported

  // Intended for use with memories which have data width of 16 bits and 6 ECC bits.
  virtual function secded_22_16_t ecc_read16(bit [bus_params_pkg::BUS_AW-1:0] addr);
    uvm_hdl_data_t data;
    if (!check_addr_valid(addr)) return 'x;
    data = read(addr);
    case (err_detection_scheme)
      Ecc_22_16: begin
        return prim_secded_pkg::prim_secded_22_16_dec(data);
      end
      EccHamming_22_16: begin
        return prim_secded_pkg::prim_secded_hamming_22_16_dec(data);
      end
      EccInv_22_16: begin
        return prim_secded_pkg::prim_secded_inv_22_16_dec(data);
      end
      EccInvHamming_22_16: begin
        return prim_secded_pkg::prim_secded_inv_hamming_22_16_dec(data);
      end
      default: return 'x;
    endcase
  endfunction

  // Intended for use with memories which have data width of 32 bits and 7 ECC bits.
  virtual function secded_39_32_t ecc_read32(bit [bus_params_pkg::BUS_AW-1:0] addr);
    uvm_hdl_data_t data;
    if (!check_addr_valid(addr)) return 'x;
    data = read(addr);
    case (err_detection_scheme)
      Ecc_39_32: begin
        return prim_secded_pkg::prim_secded_39_32_dec(data);
      end
      EccHamming_39_32: begin
        return prim_secded_pkg::prim_secded_hamming_39_32_dec(data);
      end
      EccInv_39_32: begin
        return prim_secded_pkg::prim_secded_inv_39_32_dec(data);
      end
      EccInvHamming_39_32: begin
        return prim_secded_pkg::prim_secded_inv_hamming_39_32_dec(data);
      end
      default: return 'x;
    endcase
  endfunction

  // Intended for use with memories which have data width of 64 bits and 8 ECC bits.
  virtual function secded_72_64_t ecc_read64(bit [bus_params_pkg::BUS_AW-1:0] addr);
    uvm_hdl_data_t data;
    if (!check_addr_valid(addr)) return 'x;
    data = read(addr);
    case (err_detection_scheme)
      Ecc_72_64: begin
        return prim_secded_pkg::prim_secded_72_64_dec(data);
      end
      EccHamming_72_64: begin
        return prim_secded_pkg::prim_secded_hamming_72_64_dec(data);
      end
      EccInv_72_64: begin
        return prim_secded_pkg::prim_secded_inv_72_64_dec(data);
      end
      EccInvHamming_72_64: begin
        return prim_secded_pkg::prim_secded_inv_hamming_72_64_dec(data);
      end
      default: return 'x;
    endcase
  endfunction

  // check if input file is read/writable
  virtual function void check_file(string file, string mode);
    int fh = $fopen(file, mode);
    if (!fh) begin
      `uvm_fatal(`gfn, $sformatf("file %0s could not be opened for %0s mode", file, mode))
    end
    $fclose(fh);
  endfunction

  // load mem from file
  virtual task load_mem_from_file(string file, bit recompute_ecc = 0);
    check_file(file, "r");
    this.file = file;
    ->readmemh_event;
    // The delay below avoids a race condition between this mem backdoor load and a subsequent
    // backdoor write to a particular location.
    #0;

    // Recompute ECC if indicated (this allows to load an image that does not have ECC present).
    if (recompute_ecc) begin
      case (err_detection_scheme)
        Ecc_22_16, EccHamming_22_16, EccInv_22_16, EccInvHamming_22_16: begin
          for (int addr = 0; addr < depth; addr += bytes_per_word) begin
            write16(addr, read(addr));
          end
        end
        Ecc_39_32, EccHamming_39_32, EccInv_39_32, EccInvHamming_39_32: begin
          for (int addr = 0; addr < depth; addr += bytes_per_word) begin
            write32(addr, read(addr));
          end
        end
        Ecc_72_64, EccHamming_72_64, EccInv_72_64, EccInvHamming_72_64: begin
          for (int addr = 0; addr < depth; addr += bytes_per_word) begin
            write64(addr, read(addr));
          end
        end
        // Nothing to recompute
        default: ;
      endcase
    end
  endtask

  // save mem contents to file
  virtual function void write_mem_to_file(string file);
    check_file(file, "w");
    this.file = file;
    ->writememh_event;
  endfunction

  // Print the contents of the memory.
  virtual function void print_mem();
    `uvm_info(`gfn, "Print memory", UVM_LOW)
    for (int i = 0; i < depth; i++) begin
      uvm_hdl_data_t data = read(i * bytes_per_word);
      `uvm_info(`gfn, $sformatf("mem[%0d] = 0x%0h", i, data), UVM_LOW)
    end
  endfunction

  // Clear the memory to all 0s.
  virtual function void clear_mem();
    `uvm_info(`gfn, "Clear memory", UVM_LOW)
    for (int i = 0; i < depth; i++) begin
      uvm_hdl_data_t data = '{default:0};
      write(i * bytes_per_word, data);
    end
  endfunction

  // Set the memory to all 1s.
  virtual function void set_mem();
    `uvm_info(`gfn, "Set memory", UVM_LOW)
    for (int i = 0; i < depth; i++) begin
      uvm_hdl_data_t data = '{default:1};
      write(i * bytes_per_word, data);
    end
  endfunction

  // Randomize the memory with correct ECC.
  virtual function void randomize_mem();
    `uvm_info(`gfn, "Randomizing mem contents", UVM_LOW)
    for (int i = 0; i < depth; i++) begin
      uvm_hdl_data_t data;
      `DV_CHECK_STD_RANDOMIZE_FATAL(data, "Randomization failed!", path)
      if (`HAS_PARITY) begin
        uvm_hdl_data_t raw_data = data;
        for (int byte_idx = 0; byte_idx < bytes_per_word; byte_idx++) begin
          bit raw_byte = raw_data[byte_idx * 8 +: 8];
          bit parity = (err_detection_scheme == ParityOdd) ? ~(^raw_byte) : (^raw_byte);
          data[byte_idx * 9 +: 9] = {parity, raw_byte};
        end
      end else begin
        data = get_ecc_computed_data(data);
      end
      write(i * bytes_per_word, data);
    end
  endfunction

  // Invalidate the memory.
  virtual function void invalidate_mem();
    `uvm_info(`gfn, "Invalidating (Xs) mem contents", UVM_LOW)
    for (int i = 0; i < depth; i++) begin
      uvm_hdl_data_t data;
      write(i * bytes_per_word, data);
    end
  endfunction

  // Inject ECC or parity errors to the memory word at the given address.
  virtual function void inject_errors(bit [bus_params_pkg::BUS_AW-1:0] addr,
                                      uint32_t inject_num_errors);
    uvm_hdl_data_t rw_data, err_mask;
    if (!check_addr_valid(addr)) return;
    `DV_CHECK_LE_FATAL(inject_num_errors, max_errors)
    `DV_CHECK_STD_RANDOMIZE_WITH_FATAL(err_mask,
                                       $countones(err_mask) == inject_num_errors;
                                       (err_mask >> width) == '0;)
    rw_data = read(addr);
    write(addr, rw_data ^ err_mask);
    `uvm_info(`gfn, $sformatf(
              "Addr: %0h, original data: %0h, error_mask: %0h, backdoor inject data: %0h",
              addr, rw_data, err_mask, rw_data ^ err_mask), UVM_HIGH)
  endfunction

  `undef HAS_ECC
  `undef HAS_PARITY

endclass

// Convenience macro to enable file operations on the memory.
//
// The class based approach prevents us from invoking the system tasks $readmemh and $writememh
// directly. This macro is invoked in the top level testbench where the instance of the backdoor
// accessor is created, within an initial block. It forks off two threads that monitor separately
// events when the UVM sequences invoke either the task `load_mem_from_file()` to write to the
// memory with the contents of the file and `write_mem_to_file()` methods, to read the contents of
// the memory into the file.
//
// inst is the mem_bkdr_util instance created in the testbench module.
// path is the raw path to the memory element in the design.
`define MEM_BKDR_UTIL_FILE_OP(inst, path) \
  fork \
    forever begin \
      string file; \
      @(inst.readmemh_event); \
      file = inst.get_file(); \
      `uvm_info(inst.`gfn, $sformatf("Loading mem from file:\n%0s", file), UVM_LOW) \
      $readmemh(file, path); \
    end \
    forever begin \
      string file; \
      @(inst.writememh_event); \
      file = inst.get_file(); \
      `uvm_info(inst.`gfn, $sformatf("Writing mem to file:\n%0s", file), UVM_LOW) \
      $writememh(file, path); \
    end \
  join_none
