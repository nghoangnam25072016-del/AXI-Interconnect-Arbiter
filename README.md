# AXI Interconnect / Round-Robin Arbiter

A 2-master to 1-slave AXI-lite interconnect with round-robin arbitration.


## Arbitration and Data Routing Verification

The interconnect correctly performs round-robin arbitration when both masters request simultaneously.

Slave outputs alternate between Master 0 and Master 1:

- Address: 2000 → 1000 → 2000 → 1000
- Data: BBBB → AAAA → BBBB → AAAA

This confirms both fairness and correct data routing.

sim/interconnect_waveform.png


## Stress Test
The arbiter was tested under simultaneous master requests and randomized slave backpressure. Grant counters confirmed fair round-robin behavior with no starvation.
