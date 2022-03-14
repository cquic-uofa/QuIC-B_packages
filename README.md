# QuIC-B_packages

A collection of useful MATLAB utilities for quantum simulation

gellmann.m contains a collection of code to handle generalized GellMann matrices

get_project_fit.m is a function to retreive the best waveform from a file structure like is produced in GRAPE_generic

quic_const.m contains collection of constants in the lab that do not change such as the Hilbert space dimension of the analog quantum simulator

quic_fit.m contains a collection of code to fit Stern-Gerlach signals as measured on the QuIC B analog quantum simulator

spin_utils.m contains a collection of functions to calculate spin matrices and spin coherent states

ST_cvx.m contains a collection of functions to do convex optimization in the context of quantum state tomography

super_op.m contains a collection of code to deal with super operators inteded for use alongside convex optimization and quantum state tomography

waveform_concat.m contains a collection of functions intended to standardize concatenation of waveforms meant to be run on QuIC B analog quantum simulator

Environment Variables used by the code
QuICMATROOT is the path to the folder containing QuIC-B_packages
QuICDATA is the path to the folder where data from the QuIC B analog quantum simulator is stored

