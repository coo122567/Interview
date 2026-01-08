# Gravity Center Calculator

## Highlights
- Designed a Gravity Center Calculator with rounding and farthest-point replacement.
- Verified with RTL and Gate-Level simulations.
- Achieved a 3% Area reduction via multiplier reuse.

## Introduction
Designed a Gravity Center Calculator with rounding and farthest-point replacement in Verilog and synthesized it with Design Compiler.
Optimized the architecture(multiplier reuse) for 3% area reduction. 

### Block diagram
<img width="2145"  alt="image" src="https://github.com/user-attachments/assets/fcf12a53-5372-4c85-8ee6-a807f41a56c1" />



### Specifications
- Clock periods: CLK = 33ns
- Functions: Maintains up to 6 weighted points (Xi, Yi, Wi) and outputs the rounded weighted center (Xc, Yc). When the buffer is full, each new incoming point replaces the stored point farthest from the current center.


## Simulation Results
  - Performs calculation when `READY_` is asserted.
<img width="2000" height="218" alt="image" src="https://github.com/user-attachments/assets/10b11c4f-4be1-41f3-a9c2-ab22319f707a" />



  - Architecture Optimized
    Baseline recomputes all six Xi·Wi and Yi·Wi products every cycle (12 multiplications). I cache the products in a 6-entry window and update only on shift/replace, reducing weighted-sum multipliers from 12 to 2.

### Comparison
  - Area: 3% reduction (baseline vs. multiplier-reuse optimized design).
<img width="1475" height="269" alt="image" src="https://github.com/user-attachments/assets/657bec24-19df-4350-b4be-fdf29538f772" />
