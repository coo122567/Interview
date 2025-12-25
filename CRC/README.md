# CRC5/8 in three clock domain 
## Introduction
- Overview: Use Verilog and Design Compiler to design 3-Clock Domain CRC-5/8 Engine from RTL to Synthesis.
- Designed 3-Clock Domain CRC-5/8 Engine by verilog and using unfolding to reduce latency by XX %.
- Spec. and external circuits
  1. clk1: 14.1ns
  2. clk2: 2.5ns
  3. clk3: 2.7ns
  4. message: 60-bit
  5. Pulse synchronizer for control singal in_valid & done_en synchornize 
  6. reset synchronizer
  
## Simulation Result
- Gate-level simulation result

- CRC with 2-unfolding 
  <img width="3199" height="449" alt="image" src="https://github.com/user-attachments/assets/62910fdb-dfb0-43d5-9de6-c715300333dd" />

- Comparison
