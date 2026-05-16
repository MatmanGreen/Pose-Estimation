# Door Segmentation and Pose Estimation

## Overview

This project focuses on detecting and segmenting a door from an image using classical computer vision techniques in MATLAB.

The goal was to:
- detect door gap structures,
- extract line features,
- classify door edges,
- estimate door corner positions.

The project was developed as part of a university laboratory exercise in Machine Vision at THWS. :contentReference[oaicite:0]{index=0}

---

## Features

- Image preprocessing
- Noise reduction with binomial filtering
- Sobel gradient extraction
- Morphological image processing
- Door gap segmentation
- Hough line detection
- Line classification
- Door corner estimation

---

## Techniques Used

### Image Processing
- Grayscale conversion
- Contrast enhancement
- Noise filtering
- Gradient computation

### Feature Extraction
- Sobel operators
- Gradient magnitude analysis
- Thresholding
- Morphological operations

### Geometry
- Hough Transform
- Line intersection
- Corner classification

---

## Technologies

- MATLAB
- Image Processing Toolbox

---

## Example Pipeline

1. Preprocess image
2. Extract gradients
3. Detect door gap candidates
4. Segment vertical and horizontal structures
5. Detect lines using Hough transform
6. Compute corner intersections
7. Classify door corners

---

## Notes

This repository is based on a provided university framework and task description.

The following parts were mainly predefined:
- overall task structure,
- project specification,
- processing pipeline idea,
- provided helper code and evaluation environment.

The implementation, parameter tuning, image processing steps, filtering logic, segmentation pipeline, and result generation were implemented and extended by myself.

The goal of this repository is to document practical experience with:
- classical computer vision,
- image segmentation,
- feature extraction,
- geometric image analysis,
- MATLAB-based prototyping.

---

## Related Topics

- Computer Vision
- Machine Vision
- Robotics
- Image Segmentation
- Hough Transform
- Edge Detection

---

## Reference

THWS laboratory exercise:
"Matlab Praktikum – Maschinelles Sehen – Testat" :contentReference[oaicite:1]{index=1}
