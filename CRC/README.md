# 3-Clock-Domain CRC-5/CRC-8 Engine
## Introduction
- Overview: Designed a 3-Clock-Domain CRC-5/CRC-8 Engine in Verilog and synthesized it with Design Compiler, with SpyGlass Lint/CDC check and Formality logic equivalence checking.
  
- Optimized the architecture(Unfolding) for 46% latency reduction. 

- Block diagram:
  
  <img width="800" height="600" alt="image" src="https://github.com/user-attachments/assets/70473ad4-21e4-4a42-a1c4-3d64075c66c1" />


- Spec. and Circuits
  - Clock periods: clk1 = 14.1ns, clk2 = 2.5ns, clk3 = 2.7ns
  - Clock-domain roles: clk1 (input), clk2 (CRC compute), clk3 (output)
  - CRC-5/CRC-8 engine: CRC generation (encoding) and CRC checking (verification).  
  - Pulse synchronizer: Synchronizes control pulse signals across clock domains(clk1->clk2, clk2->clk3).
  - Reset synchronizer: Reset with asynchronous assertion and synchronous de-assertion.

## Simulation Result
- Gate-level simulation result



- Architecture Optimized
  - Base CRC step(design compiler)
    <img width="1024" height="695" alt="image" src="https://github.com/user-attachments/assets/a19ea9a9-507e-445d-9aad-345708482868" />
  - CRC step w/ 2-unfolding(design compiler)
    <img width="1527" height="780" alt="image" src="https://github.com/user-attachments/assets/10dd5fa0-0ed8-42eb-9af1-04dd7d8e474f" />



- CDC issue
  - slow to fast (clk1 to clk2)
    - using pulse synchronizer to synchronize control signal.
    - waveform: 
  - fast to slow (clk2 to clk3)
    - using pulse synchronizer to synchronize control signal.
    - waveform:

- Reset synchronizer
  - waveform: 


- Comparison
  <img width="600" height="140" alt="image" src="https://github.com/user-attachments/assets/199f2b2c-c687-4236-ac29-27f7e34549a1" />



