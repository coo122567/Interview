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
- CRC is computed in the clk2 domain and starts when start_crc is asserted (high).
  <img width="1976" height="325" alt="image" src="https://github.com/user-attachments/assets/20784686-2113-478b-98ae-d5cd17fca88e" />




- Architecture Optimized
  - Base CRC step(design compiler)
    <img width="800" height="500" alt="image" src="https://github.com/user-attachments/assets/a19ea9a9-507e-445d-9aad-345708482868" />
  - CRC step w/ 2-unfolding(design compiler)
    <img width="800" height="500" alt="image" src="https://github.com/user-attachments/assets/10dd5fa0-0ed8-42eb-9af1-04dd7d8e474f" />



- CDC issue
  - Slow to Fast (clk1 to clk2)
    - Using pulse synchronizer to synchronize control signal.
    - Waveform: <img width="2000" height="300" alt="image" src="https://github.com/user-attachments/assets/71f960f8-8d95-492e-b6c5-313bd0fb0649" />

  - Fast to Slow (clk2 to clk3)
    - Using pulse synchronizer to synchronize control signal.
    - Waveform:<img width="2000" height="300" alt="image" src="https://github.com/user-attachments/assets/62068664-6479-42f4-bcc4-2812fdb9783e" />


- Reset synchronizer
  - waveform: <img width="2000" height="300" alt="image" src="https://github.com/user-attachments/assets/c38338ef-16cf-4b63-9acf-5cbbb24c04fe" />


- SpyGlass results
  - CDC check(No Warning, Error)
    <img width="2000" height="552" alt="image" src="https://github.com/user-attachments/assets/94da686a-1c05-49e2-9dad-27e78e5c7929" />
  - Lint check(No Warning, Error)
    <img width="2000" height="137" alt="image" src="https://github.com/user-attachments/assets/ea3f8a44-7612-42af-9140-953577602097" />
    
- Formality result
  - RTL vs Netlist LEC(Logic Equivalence Checking) 
    <img width="800" height="200" alt="image" src="https://github.com/user-attachments/assets/db8337bc-471e-4987-8af9-3e714fd07b1d" />


- Comparison

  <img width="600" height="140" alt="image" src="https://github.com/user-attachments/assets/199f2b2c-c687-4236-ac29-27f7e34549a1" />



