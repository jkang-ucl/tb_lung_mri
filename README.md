
# Lung qMRI Repository

## Data Pipeline

This repository aims to help facilitate the analysis of lung MRI images, with regards to T2 mapping and R2* mapping in particular. 
There are two key functions of the repository: 

1. DICOM import - Raw DICOM data must be imported into a MATLAB-readable format for analysis
2. Quantitative analysis - T2 and R2* mapping

## Import Process

The raw data directory must follow this structure:

RawDICOM/
└── PatientID/
    ├── TP1/
    │   └── DICOM FILES ...
    └── TP2/
        └── DICOM FILES ...
  ...

Notes:

* PatientID should be a unique participant identifier.
* Timepoints should be labelled clearly (for example TP1, TP2).

---

Imported data is stored separately from raw data.

Processed/
└── PatientID/
    └── TP1/
        ├── imports/
        │   ├── T2_Dixon_TE30/
        │   │   ├── water/
        │   │   │   └── acquisition.mat
        │   │   ├── fat/
        │   │   │   └── acquisition.mat
        │   │   └── ...
        │   │
        │   ├── T2_Dixon_TE50/
        │   │   ├── water/
        │   │   │   └── acquisition.mat
        │   │   ├── fat/
        │   │   │   └── acquisition.mat
        │   │   └── ...
        │   │
        │   └── qDixon_raw/
        │       ├── TE_1p037/
        │       │   └── acquisition.mat
        │       ├── TE_1p817/
        │       │   └── acquisition.mat
        │       └── ...

Each acquisition is converted into a single MATLAB file called acquisition.mat.

This file contains all image data and metadata from the original DICOM folder.


---


The import pipeline performs the following steps:

1. Scan RawDICOM for all available acquisitions.
2. Scan Processed for already imported acquisitions.
3. Compare the two lists.
4. Import only acquisitions that have not yet been processed.

## Configuration

Paths to the raw and processed directories are defined in:

config/local_config.m

This file is not tracked in version control - the default_config.m can be modified to insert the relevant paths

Example:

```matlab
function cfg = config_local()
cfg.paths.rawData = '/path/to/RawDICOM';
cfg.paths.processedData = '/path/to/ProcessedData';
end
```
