# MBIST
## Highlights
- Designed MBIST using the March X algorithm to detect common SRAM fault models.
- Verified with RTL and Gate-Level simulations.
- Implemented DFT and generated ATPG patterns to validate the MBIST logic and ensure testability.

## Introduction
- Designed MBIST using the March X algorithm to detect common SRAM fault models(Stuck-at fault).
- Implemented DFT and generated ATPG patterns to validate the MBIST logic and ensure testability.

### Block diagram
<img width="1400" alt="image" src="https://github.com/user-attachments/assets/8f4775f7-a296-40f5-a99e-2f0739e2cb4d" />



### Specifications
- Clock periods: clk = 10ns
- Functions: MBIST using the March X algorithm to detect common SRAM fault models(Stuck-at fault).
- March X algorithm : 


## Simulation Results
  - Performs test when `bist_start` is asserted.
  - MBIST test SRAM w/o stuck-at fault.

  - MBIST test SRAM w/ stuck-at fault, inject a stuck-at-1 falut to bit #1 of the SRAM word #5

## DFT & ATPG
- Functions: Insert scan chain in MBIST logic to detect manufacturing defects.

### Comparison
  - Scan chain: 10% area overhead, but enable ATPG-based testing to detect manufacturing defects. (w/o scan chain vs. w/ scan chain).
<img width="600" alt="image" src="https://github.com/user-attachments/assets/613ec2da-1658-4d93-9569-5625ad4f22b8" />


