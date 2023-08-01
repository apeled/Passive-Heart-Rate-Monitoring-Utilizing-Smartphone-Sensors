# Passive Heart Rate Monitoring Utilizing Smartphone Sensors

## Table of Contents
- [Project Overview](#project-overview)
- [Repository Structure](#repository-structure)
- [Problem Statement](#problem-statement)
- [Design Specifications](#design-specifications)
- [Design Description](#design-description)
- [Engineering Analysis and Test Data](#engineering-analysis-and-test-data)
- [Conclusions](#conclusions)
- [Future Work](#future-work)

## Project Overview
The Healthy Pocket Project aims to transform the way cardiovascular health monitoring is done for individuals working from home. We have designed a smartphone application that utilizes a phone's camera and flashlight to passively record and analyze heart rate data. Our application reduces the need for constant user input and wearable devices, making heart rate monitoring more accessible and less intrusive.

## Repository Structure
This repository is organized as follows:

- `src/`: This directory contains the source code for the project.
  - `android/`: Contains the Android application code.
  - `backend/`: Contains the backend server code.

- `test/`: Contains the test code for the project.

- `data/`: Contains data used for testing and development.

- `docs/`: Contains documentation about the project, including design documents and user manuals.

- `tools/`: Contains various scripts and tools for building, deploying, and testing the project.

- `LICENSE`: This file contains the license under which the project is released.

- `README.md`: This file.

## Problem Statement
The COVID-19 pandemic has dramatically increased the number of people working from home. With this change, sedentary behaviors and related health issues such as poor posture and lack of physical activity are on the rise, increasing the risk of heart disease. Current health monitoring devices and applications are not ideal as they require constant user input or are abandoned soon after purchase. Our goal is to provide a passive heart rate monitoring solution that is easy to use and requires minimal user interaction.

## Design Specifications
We are developing a smartphone application that measures, records, and presents heart rate data while the phone is sitting passively in a user's pocket. Our design constraints include:
- Utilizing only the built-in hardware of a smartphone.
- Collecting cardiovascular health metrics passively, requiring no user input.
- Adapting to different pocket fabrics, phone orientations, and user demographics.

## Design Description
Our solution comprises a front-end Android application connected to a signal processing backend. The app records a video capturing the luminosity changes due to blood flow in the skin, which is converted to luma values and processed into a Photoplethysmography (PPG) waveform. An FFT is applied to this waveform to extract heart rate data, which is compared against a ground truth measurement taken by a pulse oximeter.

## Engineering Analysis and Test Data
We tested our application against a commercial pulse oximeter with over 280 trials across 20 participants, considering different trouser fabrics (cotton, denim, polyester). Our initial trials showed high average errors in heart rate measurement (>20 BPM). However, the error was significantly reduced in subsequent trials (<6 BPM). This promising result indicates potential, although it should be noted that further improvements are needed for consistent accuracy.

## Conclusions
Our project has demonstrated potential in passive heart rate monitoring using smartphone technology. However, we acknowledge that the current version of the application has limitations. High deviation from actual heart rate measurements in some conditions and the discrepancy in results obtained from different test phases underline the need for more rigorous testing and improvements in signal processing.

## Future Work
In future iterations, we aim to improve our signal processing algorithms for higher accuracy, incorporate multiple peak predictions in the FFT analysis, and develop metrics for heart rate variability and stress levels. Additionally, we plan to extend the application to iOS devices and enable passive heart rate detection and recording while reducing battery usage.
