# Time-varying sinusoidal demodulation for non-stationary modeling of speech
Speech signals contain a fairly rich time-evolving spectral content. Accurate analysis of this time-evolving spectrum is an open challenge in signal processing. Towards this, we visit time varying sinusoidal modeling of speech and propose an alternate model estimation approach to analyse speech. The estimation operates on the whole signal without any short-time analysis. The technique is effective for:
- analysis and synthesis
- time-scale modification
- pitch-scale modification
- voice manipulation
- modulation filtering

This repository contains the manuscript explaining the approach in detail, and the code to implement the approach. The manuscript is shared for academic and personal use only. Any other use requires prior permission of the authors.

#### Code details
- ./code contains MATLAB codes
- ./manuscript contains the paper copy
- ./sound contains the sound samples used by the codes
- ./code/data/ stores the resulting sound samples 
- Run ./code/demo_analy_syn.m to see analysis-synthesis example
- Run ./code/demo_voice_manip.m to see voice manipulation example

#### Relevant publication
If you find the approach useful, we will be very happy to see the following cited in your work: "Time-varying sinusoidal demodulation for non-stationary modeling of speech", in Speech Communication (vol. 105), 2018.
Link: https://www.sciencedirect.com/science/article/pii/S0167639318300773

#### Additional demos
Link: https://neerajww.github.io/preprint/demo/modeling/tvnm.html

#### Contributors
Neeraj Kumar Sharma, T. V. Sreenivas

#### Acknowledgement
The code also makes use of the vocoder https://github.com/HidekiKawahara/legacy_STRAIGHT to obtain pitch estimates. This is bundled in the current repository (with its license file).

The work was done at the Indian Institute of Science, Bangalore.
###### To see where am I currently:
Go to: https://neerajww.github.io/
