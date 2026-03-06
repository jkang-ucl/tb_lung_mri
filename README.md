
# Lung qMRI Repository

## Data & Folder Structure

This repository separates raw DICOM data, imported data, and analysis outputs.
The goal is to keep raw data unchanged while allowing analyses to be rerun without re-importing DICOM files.

Key principles:

1. Raw data is never modified or deleted.
2. DICOM import is performed once per acquisition.
3. Analysis outputs are stored separately from imported data.
4. The pipeline detects new acquisitions automatically and processes only those that are missing.

---

## Raw Data Structure

The raw data directory must follow this structure:

RawDICOM/
PatientID/
TP1/
T2_Dixon_TE30/
T2_Dixon_TE50/
GRE6pt_Dixon/
TP2/
T2_Dixon_TE30/
T2_Dixon_TE50/
GRE6pt_Dixon/

Example:

RawDICOM/
Patient001/
TP1/
T2_Dixon_TE30/
T2_Dixon_TE50/
GRE6pt_Dixon/
TP2/
T2_Dixon_TE30/
T2_Dixon_TE50/
GRE6pt_Dixon/

Notes:

* PatientID should be a unique participant identifier.
* Timepoints should be labelled clearly (for example TP1, TP2).
* Acquisition folders should have consistent descriptive names.
* Each acquisition folder should contain only DICOM slices from a single acquisition.

Example acquisition folder:

T2_Dixon_TE30/
IM0001.dcm
IM0002.dcm
IM0003.dcm

---

## Processed Data Structure

Imported data is stored separately from raw data.

Processed/
PatientID/
TP1/
imports/
T2_Dixon_TE30/
acquisition.mat
T2_Dixon_TE50/
acquisition.mat
GRE6pt_Dixon/
acquisition.mat

Each acquisition is converted into a single MATLAB file called acquisition.mat.

This file contains all image data and metadata from the original DICOM folder.

Importing does not filter or select specific image types.
All Dixon outputs (water, fat, in-phase, opposed-phase) are preserved.

---

## Analysis Outputs

Analysis outputs are stored separately from imports.

Processed/
PatientID/
TP1/
analyses/
T2_map/
R2star_map/

This allows analyses to be rerun without re-importing DICOM data.

---

## Import Pipeline Logic

The import pipeline performs the following steps:

1. Scan RawDICOM for all available acquisitions.
2. Scan Processed for already imported acquisitions.
3. Compare the two lists.
4. Import only acquisitions that have not yet been processed.
5. Report which acquisitions were processed or skipped.

An acquisition is considered processed if the following file exists:

Processed/PatientID/Timepoint/imports/Acquisition/acquisition.mat

---

## Configuration

Paths to the raw and processed directories are defined in:

config/config_local.m

This file is not tracked in version control so that local data paths and sensitive information are not stored in the repository.

Example:

function cfg = config_local()

```
cfg.paths.rawData = '/path/to/RawDICOM';
cfg.paths.processed = '/path/to/Processed';
```

end

---

## Running the Import Pipeline

The import pipeline is executed via:

run/import_dicoms.m

This script:

* loads the configuration
* scans raw acquisitions
* detects missing imports
* processes new acquisitions automatically
