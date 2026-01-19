# MBIST
## Highlights
- Designed MBIST using the March X algorithm to detect common SRAM fault models.
- Verified with RTL and Gate-Level simulations.
- Implemented DFT and generated ATPG patterns to validate the MBIST logic and ensure testability.

## Introduction
Designed MBIST using the March X algorithm to detect common SRAM fault models(Stuck-at fault).
Implemented DFT and generated ATPG patterns to validate the MBIST logic and ensure testability.

### Block diagram
<img width="1400" alt="image" src="https://github.com/user-attachments/assets/8f4775f7-a296-40f5-a99e-2f0739e2cb4d" />



### Specifications
- Clock periods: clk = 10ns
- Functions: .


## Simulation Results
  - Performs test when `bist_start` is asserted.
<img width="2000" height="218" alt="image" src="https://github.com/user-attachments/assets/10b11c4f-4be1-41f3-a9c2-ab22319f707a" />


### Comparison
  - Scan chain: 10% area overhead, but design can detect to manufacturing defects. (design w/o scan chain vs. design w/ scan chain).
<img width="800" alt="image" src="https://github.com/user-attachments/assets/613ec2da-1658-4d93-9569-5625ad4f22b8" />


