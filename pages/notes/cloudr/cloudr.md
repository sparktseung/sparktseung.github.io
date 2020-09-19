# Running R on Google Cloud Platform

**Author**: [Spark Tseung](https://sparktseung.com)

**Last Modified**: Sept 18, 2020

Introduction
------------

Recently, I have been learning how to use the Google Cloud Platform ([GCP](https://cloud.google.com/)) for moderate-scale computing problems. It took me about an hour to set up (not for the first time) an R environment on GCP for running some code for a research paper. Yes, I know we have access to computing resources offered by the university, but sometimes everyone is using it, or sometimes I just need to use more than allocated to each individual students.

Anyways, I will jot down some notes on the steps to get an environment ready for running R on GCP. Naturally, Google is a good friend for a tech rookie such as myself. In addition, without the help of [LeXtudio](https://www.lextudio.com), it would probably have taken much longer for me to figure out everything alone.

In this note, I will briefly go through the following key steps:

* Establishing a virtual machine (VM) and install R;
* Connect to the VM via Secured Shell (SSH) using [Bitvise](https://www.bitvise.com/); and
* Running an R script on the background.

Data Simulation
---------------