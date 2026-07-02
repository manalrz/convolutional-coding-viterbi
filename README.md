# Convolutional Coding & Viterbi Decoding: Channel Coding Performance Analysis

A MATLAB study of convolutional codes for error correction in noisy digital communication channels, covering encoding, Viterbi decoding, and performance evaluation across code memory, encoder structure, and prediction methods.

## Overview

This project implements a full coded transmission chain — convolutional encoding, transmission over an AWGN channel, and Viterbi decoding — to evaluate how coding choices affect bit error rate (BER) performance.

## Key Components

- **Convolutional encoder**: trellis-based encoding with proper termination (return to the zero state), built from generator polynomials
- **Viterbi decoder**: maximum-likelihood sequence decoding using Hamming-distance path metrics and trellis backtracking
- **Performance evaluation**: BER simulated via Monte Carlo across Eb/N0 from -2 dB to 10 dB, for codes of increasing memory: (2,3), (5,7), (13,15), (133,171) in octal notation

## Experiments

1. **Impact of code memory** — Higher-memory codes (e.g. (133,171), minimum distance 36) significantly outperform lower-memory codes, at the cost of exponentially higher decoding complexity (state count = 2^memory). The best code achieved a 3.2 dB coding gain over uncoded BPSK.

2. **Recursive vs. non-recursive encoding** — Recursive systematic encoders ((1,5/7), (1,13/15)) consistently outperformed their non-recursive counterparts at the same rate, particularly at low Eb/N0, at the cost of increased implementation complexity.

3. **Performance prediction via the impulse method** — An analytical technique estimating packet error rate from the code's distance spectrum, avoiding lengthy Monte Carlo simulation. Results were consistent with simulated performance at moderate-to-high Eb/N0, with expected divergence at low SNR due to the method's simplifying assumptions.

## Tech Stack

MATLAB (Communications Toolbox: `poly2trellis`, `cc_encode`, `viterbi_decode`, `distspec`)

## Team

Manâl Rhazza, Kenzo Vaudé — ENSEIRB-MATMECA
