# Traffic Light Controller FSM Specification

## 1. Project Overview

The Traffic Light Controller is a synchronous finite state machine (FSM)
designed to control traffic signals at a two-road intersection.

The controller manages:

- North-South (NS) traffic lights
- East-West (EW) traffic lights

The controller uses a Moore FSM, meaning that the traffic-light outputs
depend only on the current FSM state.

## 2. Inputs

| Signal | Width | Description |
|---|---:|---|
| clk | 1 | System clock |
| reset | 1 | Synchronous active-high reset |

## 3. Outputs

### North-South Road

| Signal | Description |
|---|---|
| NS_RED | NS red light |
| NS_YELLOW | NS yellow light |
| NS_GREEN | NS green light |

### East-West Road

| Signal | Description |
|---|---|
| EW_RED | EW red light |
| EW_YELLOW | EW yellow light |
| EW_GREEN | EW green light |

## 4. FSM States

The controller contains six states.

| State | Binary Code | NS Signal | EW Signal | Duration |
|---|---|---|---|---:|
| NS_GREEN | 000 | Green | Red | 10 cycles |
| NS_YELLOW | 001 | Yellow | Red | 3 cycles |
| ALL_RED_1 | 010 | Red | Red | 2 cycles |
| EW_GREEN | 011 | Red | Green | 10 cycles |
| EW_YELLOW | 100 | Red | Yellow | 3 cycles |
| ALL_RED_2 | 101 | Red | Red | 2 cycles |

States `110` and `111` are unused and are handled by a default recovery
transition to `NS_GREEN`.

## 5. State Sequence

The normal operating sequence is:

NS_GREEN
    ↓
NS_YELLOW
    ↓
ALL_RED_1
    ↓
EW_GREEN
    ↓
EW_YELLOW
    ↓
ALL_RED_2
    ↓
NS_GREEN

The sequence repeats continuously.

## 6. State Transitions

| Current State | Condition | Next State |
|---|---|---|
| NS_GREEN | timer_done = 0 | NS_GREEN |
| NS_GREEN | timer_done = 1 | NS_YELLOW |
| NS_YELLOW | timer_done = 0 | NS_YELLOW |
| NS_YELLOW | timer_done = 1 | ALL_RED_1 |
| ALL_RED_1 | timer_done = 0 | ALL_RED_1 |
| ALL_RED_1 | timer_done = 1 | EW_GREEN |
| EW_GREEN | timer_done = 0 | EW_GREEN |
| EW_GREEN | timer_done = 1 | EW_YELLOW |
| EW_YELLOW | timer_done = 0 | EW_YELLOW |
| EW_YELLOW | timer_done = 1 | ALL_RED_2 |
| ALL_RED_2 | timer_done = 0 | ALL_RED_2 |
| ALL_RED_2 | timer_done = 1 | NS_GREEN |

## 7. Reset Behavior

When `reset = 1`, the FSM enters:

NS_GREEN

Therefore, after reset:

- NS Green = 1
- NS Yellow = 0
- NS Red = 0
- EW Red = 1
- EW Yellow = 0
- EW Green = 0

## 8. Moore Output Table

| State | NS_RED | NS_YELLOW | NS_GREEN | EW_RED | EW_YELLOW | EW_GREEN |
|---|---:|---:|---:|---:|---:|---:|
| NS_GREEN | 0 | 0 | 1 | 1 | 0 | 0 |
| NS_YELLOW | 0 | 1 | 0 | 1 | 0 | 0 |
| ALL_RED_1 | 1 | 0 | 0 | 1 | 0 | 0 |
| EW_GREEN | 1 | 0 | 0 | 0 | 0 | 1 |
| EW_YELLOW | 1 | 0 | 0 | 0 | 1 | 0 |
| ALL_RED_2 | 1 | 0 | 0 | 1 | 0 | 0 |

## 9. Safety Requirements

The following conditions must always hold:

1. NS_GREEN and EW_GREEN must never be HIGH simultaneously.
2. NS_GREEN and NS_YELLOW must never be HIGH simultaneously.
3. EW_GREEN and EW_YELLOW must never be HIGH simultaneously.
4. During ALL_RED states, both roads must have RED signals.
5. Every valid FSM state must produce a defined traffic-light output.
6. An invalid state must recover to NS_GREEN.

## 10. Timing

The simulation clock has a period of 10 ns.

Therefore:

- NS_GREEN = 10 clock cycles = 100 ns
- NS_YELLOW = 3 clock cycles = 30 ns
- ALL_RED_1 = 2 clock cycles = 20 ns
- EW_GREEN = 10 clock cycles = 100 ns
- EW_YELLOW = 3 clock cycles = 30 ns
- ALL_RED_2 = 2 clock cycles = 20 ns

Total nominal sequence duration:

10 + 3 + 2 + 10 + 3 + 2 = 30 clock cycles

At a 10 ns clock period:

30 × 10 ns = 300 ns

The actual RTL implementation and waveform will be used to verify the
precise state-duration behavior.

