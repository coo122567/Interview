# MBIST
## Highlights
- Designed MBIST using the March X algorithm to detect common SRAM fault models.
- Verified with RTL and Gate-Level simulations.
- Implemented DFT and generated ATPG patterns to validate the MBIST logic and ensure testability.

## Introduction
- Designed MBIST using the March X algorithm to detect common SRAM fault models(Stuck-at fault).
- Implemented DFT and generated ATPG patterns to validate the MBIST logic and ensure testability.

### Block diagram
<img width="1200" alt="image" src="https://github.com/user-attachments/assets/8f4775f7-a296-40f5-a99e-2f0739e2cb4d" />



### Specifications
- Clock periods: clk = 10ns
- Functions: MBIST using the March X algorithm to detect common SRAM fault models(Stuck-at fault).
- March X algorithm : { ↕(w0); ↑(r0, w1); ↓(r1, w0); ↕(r0) }


## Simulation Results
  - Performs test when `bist_start` is asserted.
  - MBIST test SRAM w/o stuck-at fault.


  - MBIST test SRAM w/ stuck-at fault, inject a stuck-at-1 fault to bit #1 of the SRAM word #5

## DFT & ATPG
- Purpose: Inserted scan chain into MBIST logic to detect manufacturing defects.
- Using ATPG Pattern to execute VCS simulation (w/o fault) 
<img width="2228" alt="image" src="https://github.com/user-attachments/assets/2995ca74-fb92-4b4c-93d5-54f565371901" />
 
- Using ATPG Pattern to execute VCS simulation (w/ extra inject fault) 
<img width="1535" alt="image" src="https://github.com/user-attachments/assets/cdb49339-d601-4654-b905-bd403a0fab32" />

### Comparison
  - Scan chain: 10% area overhead, but enable ATPG-based testing to detect manufacturing defects. (w/o scan chain vs. w/ scan chain).
<img width="600" alt="image" src="https://github.com/user-attachments/assets/613ec2da-1658-4d93-9569-5625ad4f22b8" />


