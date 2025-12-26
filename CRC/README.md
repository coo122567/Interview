# 3-Clock-Domain CRC-5/CRC-8 Engine
## Introduction
- Overview: Designed a 3-Clock-Domain CRC-5/CRC-8 Engine in Verilog and synthesized it with Design Compiler, with SpyGlass Lint/CDC check and Formality logic equivalence checking.
  
- Optimized the architecture(Unfolding) for 46% latency reduction. 

- Block diagram:
  
  <img width="800" height="600" alt="image" src="https://github.com/user-attachments/assets/70473ad4-21e4-4a42-a1c4-3d64075c66c1" />


- Spec. and Circuits
  - clk1 period: 14.1ns
  - clk2 period: 2.5ns
  - clk3 period: 2.7ns
  - CRC-5/CRC-8 engine: CRC generation (encoding) and CRC checking (verification).  
  - Pulse synchronizer: Synchronizes control pulse signals across clock domains(clk1->clk2, clk2->clk3).
  - Reset synchronizer: Reset with asynchronous assertion and synchronous de-assertion.

## Simulation Result
- Gate-level simulation result


- CRC with 2-unfolding 
  <img width="100" alt="image" src="https://github.com/user-attachments/assets/62910fdb-dfb0-43d5-9de6-c715300333dd" />
  
- CDC issue
  - slow to fast (clk1 to clk2)
  - fast to slow (clk2 to clk3)

- Comparison
  
  <img width="600" height="140" alt="image" src="https://github.com/user-attachments/assets/199f2b2c-c687-4236-ac29-27f7e34549a1" />



