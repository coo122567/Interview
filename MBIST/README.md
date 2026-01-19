# MBIST
## Highlights
- Designed MBIST using the March X algorithm to detect common SRAM fault models.
- Verified with RTL and Gate-Level simulations.
- Implemented DFT and generated ATPG patterns to validate the MBIST logic and ensure testability.

## Introduction
- Implemented March X algorithm : { ↕(w0); ↑(r0, w1); ↓(r1, w0); ↕(r0) }.
- Built MBIST blocks (controller / address generator / pattern generator / comparator/ buffer).
- Performed ATPG + pattern simulation (w/o fault-injected vs. w/ fault-injected) for DFT validation.


### Block diagram
<img width="800" alt="image" src="https://github.com/user-attachments/assets/8f4775f7-a296-40f5-a99e-2f0739e2cb4d" />



### Specifications
- Clock periods: clk = 10ns
- March algorithm: March X
- Target faults: stuck-at faults (e.g., SA0/SA1)


## Simulation Results
  - Performs test when `bist_start` is asserted.
  - Pass case: SRAM without injected fault.


  - Fail case: Inject a stuck-at-1 fault to bit #1 of the SRAM word #5
  <img width="1500" alt="image" src="https://github.com/user-attachments/assets/b019cd5d-df3f-416f-99e5-5dda39736640" />

## DFT & ATPG
- Purpose: Inserted scan chain into MBIST logic to detect manufacturing defects.
- Pattern simulation(Pass case): Run VCS pattern simulation with ATPG patterns w/o fault injection.
   
  <img width="600" alt="image" src="https://github.com/user-attachments/assets/8391b28d-0558-4e38-b591-10de4887bc5f" />




- Pattern simulation(Fail case): Run VCS pattern simulation with ATPG patterns w/ fault injection by forcing net `n1`.
   
  <img width="600" alt="image" src="https://github.com/user-attachments/assets/cdb49339-d601-4654-b905-bd403a0fab32" />


- Fault summary
  <img width="400" alt="image" src="https://github.com/user-attachments/assets/6f50e7a0-ca30-42f5-97db-8ac59880adee" />

### Comparison
  - Scan chain: 10% area overhead, but enable ATPG-based testing to detect manufacturing defects. (w/o scan chain vs. w/ scan chain).
  <img width="600" alt="image" src="https://github.com/user-attachments/assets/613ec2da-1658-4d93-9569-5625ad4f22b8" />


