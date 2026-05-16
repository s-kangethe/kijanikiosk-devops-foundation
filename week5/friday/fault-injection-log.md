# Fault Injection Log – KijaniKiosk CI Pipeline

## Stage 1: Git Failure Simulation
**Fault Injected:**
Removed `.git` directory or invalid repo state

**Observed Behaviour:**
Pipeline failed during checkout or versioning with git errors.

**Design Rationale:**
Ensures pipeline validates SCM integrity before build steps proceed.

---

## Stage 2: Dependency Failure Simulation
**Fault Injected:**
Removed Docker image locally or changed image tag

**Observed Behaviour:**
Pipeline failed at Docker container startup stage.

**Design Rationale:**
Ensures build environment is reproducible and version-controlled.

---

## Stage 3: Build Artifact Failure
**Fault Injected:**
Removed `dist/` folder before archiving

**Observed Behaviour:**
Tar command failed or produced empty artifact.

**Design Rationale:**
Ensures build outputs are generated before packaging.

---

## Stage 4: Nexus Upload Failure
**Fault Injected:**
Incorrect Nexus URL or wrong credentials

**Observed Behaviour:**
curl upload failed with HTTP 401 or 404 error.

**Design Rationale:**
Ensures artifact repository authentication and endpoint correctness.
