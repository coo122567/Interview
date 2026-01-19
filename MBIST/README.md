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
- Functions: Maintains up to 6 weighted points (Xi, Yi, Wi) and outputs the rounded weighted center (Xc, Yc). When the buffer is full, each new incoming point replaces the stored point farthest from the current center.


## Simulation Results
  - Performs calculation when `READY_` is asserted.
<img width="2000" height="218" alt="image" src="https://github.com/user-attachments/assets/10b11c4f-4be1-41f3-a9c2-ab22319f707a" />



  - Architecture Optimized
    Baseline recomputes all six Xi·Wi and Yi·Wi products every cycle (12 multiplications). I cache the products in a 6-entry buffers and update only on shift/replace, reducing weighted-sum multipliers from 12 to 2.

### Comparison
  - Area: 3% reduction (baseline vs. multiplier-reuse optimized design).
<img width="800" alt="image" src="https://github.com/user-attachments/assets/76341082-954f-4708-8549-e7bb2db7b9c8" />


