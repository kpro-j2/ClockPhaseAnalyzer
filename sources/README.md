## Design files

### [defPhase.vhd](defPhase.vhd)

Defines the shared phase measurement constants, data widths, sampling threshold, and `clog2` helper used by the analyzer modules.
It also specifies the averaged phase representation in fractions of one clock period and the wider signed representation used for accumulated drift.

### [DdmtdSampler.vhd](DdmtdSampler.vhd)

Samples an input clock through three registers using the slightly offset DDMTD clock to produce a slow beat signal.
A saturating counter and state machine filter this signal using the configurable `kDetTh` threshold and provide a rising-edge indication for phase measurement.

### [DdmtdReference.vhd](DdmtdReference.vhd)

Uses `DdmtdSampler` to detect reference clock beat edges and restarts a counter at each detected rising edge.
It supplies this counter as `phaseRef` in the DDMTD clock domain and asserts `ready` once the first reference edge has been detected.

### [DdmtdDetector.vhd](DdmtdDetector.vhd)

Uses `DdmtdSampler` to detect beat edges of a link's modulation clock and captures the shared `phaseRef` counter at each rising edge.
It outputs the captured count with `validPhase` in the DDMTD clock domain only when the link is up and the reference is ready.

### [PhaseReference.vhd](PhaseReference.vhd)

Wraps `DdmtdReference` with the `mmcm_ddmtd` clock generator to create the DDMTD sampling clock from the system clock.
It synchronizes the system reset into that domain, holds the reference logic in reset while the MMCM is unlocked, and exposes the sampling clock and reference signals for multiple detectors to share.

### [PhaseDetector.vhd](PhaseDetector.vhd)

Wraps `DdmtdDetector` to connect a link's modulation clock to the shared DDMTD reference while presenting measurement outputs in the system clock domain.
It uses Xilinx XPM clock domain crossing components to synchronize link status and reset into the DDMTD domain and transfer the captured phase and validity back to the system domain.

### [PhaseAverage.vhd](PhaseAverage.vhd)

Collects valid phase measurements in batches defined by `defPhase` and centers samples around the batch's first measurement to handle phase wraparound.
It outputs an averaged phase value normalized to one clock period with `validAvgPhase`, and restarts collection on reset or link loss.

### [PhaseAccumulator.vhd](PhaseAccumulator.vhd)

Accumulates signed differences between consecutive averaged phase measurements, correcting wraparound to track drift across clock period boundaries.
The first measurement after reset or a rising edge on `clear` establishes the baseline and asserts `ready`, while `phaseShift` reports the accumulated change from that baseline.

### [PhaseStepGenerator.vhd](PhaseStepGenerator.vhd)

Tracks changes between averaged phase measurements and emits single-cycle `plus` or `minus` requests when the accumulated change crosses a step threshold with hysteresis.
The clock period, adjustment step, and hysteresis are configurable in picoseconds, and reset or a rising edge on `clear` clears the residual change and starts a new baseline.

## Simulation files

The `sim/` directory contains stimulus-driven testbenches for waveform inspection; they do not include automatic pass/fail assertions.

### [sim/sim_DdmtdSampler.vhd](sim/sim_DdmtdSampler.vhd)

Drives `DdmtdSampler` with input and sampling clocks whose periods are slightly different.
It exposes the filtered rising-edge indication for inspecting beat detection with a threshold of eight.

### [sim/sim_DdmtdBase.vhd](sim/sim_DdmtdBase.vhd)

Instantiates `DdmtdReference` with separate reference and DDMTD clocks, despite the testbench's historical `Base` name.
It exposes `ready` and the phase counter for observing reference acquisition and counter restarts.

### [sim/sim_DdmtdDetector.vhd](sim/sim_DdmtdDetector.vhd)

Connects `DdmtdReference` and `DdmtdDetector` to a shared DDMTD clock and drives the detector with a delayed modulation clock.
It provides a minimal example of the reference-to-detector interface and exposes the resulting phase values and validity for waveform inspection.

### [sim/sim_PhaseAverage.vhd](sim/sim_PhaseAverage.vhd)

Applies a short sequence of phase counts around a common center to `PhaseAverage`, with separate validity pulses for each measurement.
It illustrates the input interface and initial accumulation behavior; observing a completed average requires enough samples to fill the batch configured in `defPhase`.

### [sim/sim_PhaseAccumulator.vhd](sim/sim_PhaseAccumulator.vhd)

Feeds `PhaseAccumulator` normalized phase values that cross the clock period boundary in both directions, with a clear operation between the sequences.
It reports the accumulated shift and readiness to the simulator log to support inspection of baseline initialization, clearing, and wraparound handling.

### [sim/sim_PhaseStepGenerator.vhd](sim/sim_PhaseStepGenerator.vhd)

Drives `PhaseStepGenerator` with increasing and decreasing encoded phase values, including a transition across the phase boundary.
It exposes the `plus` and `minus` outputs for inspecting adjustment requests with the configured step and hysteresis parameters.
