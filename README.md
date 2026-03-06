```markdown
# Data & Folder Structure

This repository separates **raw DICOM data**, **imported data**, and **analysis outputs**.  
The design goal is to keep raw data immutable and make the processing pipeline reproducible.

## Key Principles

1. **Raw data is never modified or deleted.**
2. **DICOM import is performed only once per acquisition.**
3. **Analysis outputs are stored separately from imported data.**
4. The pipeline detects new acquisitions automatically and only processes missing ones.

---

# Raw Data Structure

The raw data directory must follow this structure:

```

RawDICOM/ <PatientID>/ <Timepoint>/
T2_Dixon_TE30/
T2_Dixon_TE50/
GRE6pt_Dixon/

```

Example:

```

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

```

### Notes

- `<PatientID>` should be a unique participant identifier.
- `<Timepoint>` should be labelled explicitly (e.g. `TP1`, `TP2`).
- Acquisition folders should use **consistent descriptive names**.
- Each acquisition folder should contain **only DICOM slices from a single acquisition**.

Example acquisition folder:

```

T2_Dixon_TE30/
IM0001.dcm
IM0002.dcm
IM0003.dcm

```

---

# Processed Data Structure

Imported data is stored in a separate directory:

```

Processed/ <PatientID>/ <Timepoint>/
imports/
T2_Dixon_TE30/
acquisition.mat
T2_Dixon_TE50/
acquisition.mat
GRE6pt_Dixon/
acquisition.mat

```

### Import Files

Each acquisition is converted into a single MATLAB file:

```

acquisition.mat

```

This file contains all image data and metadata from the original DICOM folder.

Importing does **not filter or select specific image types**.  
All Dixon outputs (water/fat/IP/OP) are preserved.

---

# Analysis Outputs

Quantitative outputs are stored separately from imports:

```

Processed/ <PatientID>/ <Timepoint>/
analyses/
T2_map/
R2star_map/

```

This allows analyses to be re-run without re-importing DICOM data.

---

# Import Pipeline Logic

The import pipeline performs the following steps:

1. Scan `RawDICOM` for all available acquisitions.
2. Scan `Processed` for already-imported acquisitions.
3. Compare the two lists.
4. Import only acquisitions that have not yet been processed.
5. Report which acquisitions were processed or skipped.

An acquisition is considered **processed** if the following file exists:

```

Processed/<PatientID>/<Timepoint>/imports/<Acquisition>/acquisition.mat

```

---

# Configuration

Paths to the raw and processed directories are defined in:

```

config/config_local.m

````

This file is **not tracked in version control** to avoid storing sensitive data paths.

Example:

```matlab
function cfg = config_local()

cfg.paths.rawData = '/path/to/RawDICOM';
cfg.paths.processed = '/path/to/Processed';

end
````

---

# Running the Import Pipeline

The import pipeline is executed via:

```
run/import_dicoms.m
```

This script:

* loads the configuration
* scans raw acquisitions
* detects missing imports
* processes new acquisitions automatically

```
```
