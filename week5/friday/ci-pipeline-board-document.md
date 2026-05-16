## CI Pipeline Flow Diagram

flowchart TD

A[Developer Push to GitHub] --> B[Jenkins Triggered]

B --> C[Checkout SCM]

C --> D[Lint Stage]

D -->|FAIL| X1[Stop Pipeline - Lint Failure]
D -->|PASS| E[Build Stage]

E --> F[Create Artifact in dist/]

F --> G[Parallel Verification]

G --> G1[Test Stage]
G --> G2[Security Audit]

G1 -->|FAIL| X2[Stop Pipeline - Test Failure]
G2 -->|FAIL| X3[Stop Pipeline - Security Failure]

G1 -->|PASS| H[Archive Artifact]
G2 -->|PASS| H

H --> I[Versioning Stage]

I -->|FAIL| X4[Stop Pipeline - Versioning Error]
I -->|PASS| J[Generate VERSION (build + commit SHA)]

J --> K[Publish to Nexus Repository]

K -->|FAIL| X5[Stop Pipeline - Nexus Upload Failure]
K -->|PASS| L[Artifact Stored in Nexus]

L --> M[Post Actions]

M --> M1[Pipeline Summary]
M --> M2[Clean Workspace]

M --> N[SUCCESS]


