# ClockPhaseAnalyzer

DDMTDC based clock phase analyzer for the modulated clock signal of the MIKUMARI link protocol.
This function measures the phase variation of the modulation clock-which is returned from the secondary node-relative to the reference clock at the primary MIKUMARI link node, calculates the average phase shift value, accumulates the total variation, and generates a phase adjustment request signal for the MIKUMARI link.

Stable version: 1.0.0

[Change log](ChangeLog.md)

## Device families

AMD Xilinx devices are expected.

Tested device

| FPGA              | Vender | Product number |
| ---               | ---    | ---            |
| Kintex-7          | AMD    | XC7K160T-2     |

## Toolchain

Only reproducible `.xci` configurations are tracked; generated IP and Vivado project artifacts are ignored.

### Expected Vivado version

The .xci files included in this repository were generated using the following versions of Vivado.

2023.1

## License

This project is dual licensed under the Apache License Version 2.0 and Mozilla Public License Version 2.0.

For details, see [the license notice](LICENSE.md).

## Credits
