# AES-Encryption-Algorithm
The project involved designing, coding, and simulating the AES algorithm to ensure reliable performance for cryptographic applications
Overview
This project implements a modified AES (Advanced Encryption Standard) encryption block in Verilog. The design is tailored for educational purposes and demonstrates the core operations of the AES algorithm, including key expansion, substitution bytes, shift rows, mix columns, and add round key operations.

Features
Encryption Algorithm: AES (128-bit block size).
Components Implemented:
  SubBytes
  ShiftRows
  MixColumns
  AddRoundKey
Configurations:
  128-bit key and plaintext inputs.
  Multiple rounds of encryption (10 rounds for AES-128).
Module Description
aes_modified
This module performs AES encryption. It uses the following inputs and outputs:

Inputs:
  clk (clock): The clock signal.
  rst (reset): Asynchronous reset signal.
  start (start): Signal to initiate the encryption process.
  in (128-bit input): The plaintext data to be encrypted.
  encrypkey (128-bit key): The key used for encryption.

Outputs:
  out (128-bit output): The encrypted data.

Internal Registers
  plaintext, key: Store the plaintext and encryption key in a 4x4 matrix format.
  s_box: 16x16 substitution box for the SubBytes step.
  rijandael, rcon: Rijndael and round constant matrices used in the key expansion process.
  mem_reg, mem_next: Memory registers for intermediate data storage during encryption.

States
  IDLE: The initial state where the module waits for the start signal.
  ROUND_INI: Initializes the round with the input data XORed with the key.
  SUBBYTES: Applies the SubBytes transformation using the S-box.
  SHIFTROW: Performs the ShiftRows transformation.
  MIXCOL: Applies the MixColumns transformation (partially implemented).
  ROUNDKEY: Adds the round key to the data.
  RESULT: Outputs the encrypted data.
  
How to Use
Instantiation:
verilog
Copy code
aes_modified aes_inst (
  .clk(clk),
  .rst(rst),
  .start(start),
  .in(plaintext),
  .encrypkey(key),
  .out(encrypted_data)
);
Initialization:

Provide a 128-bit plaintext and a 128-bit key.
Assert the start signal to begin encryption.
Execution:

The module will perform AES encryption over multiple clock cycles.
The result will be available at the out port after encryption is complete.
File Structure
aes_modified.v: Verilog source file containing the AES encryption block implementation.
testbench.v: Optional testbench file to simulate and verify the functionality of the AES module.
