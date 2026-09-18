# examples/

Example simulation outputs included for reference and reproducibility verification.

Each subfolder contains the complete output of one simulation run, produced by
the scripts and configuration files in this repository. These outputs feed
directly into the
[fumd-ai-preprocessing-workflow](https://github.com/FUMD-AI/fumd-ai-preprocessing-workflow).

## Git LFS

Vector files (`*.vec`) are tracked by **Git LFS** because they can reach
hundreds of MB for full 1800-second runs. Install Git LFS before cloning:

```bash
# Install Git LFS (Ubuntu)
sudo apt install git-lfs
git lfs install

# Then clone normally — LFS files are downloaded automatically
git clone https://github.com/FUMD-AI/fumd-ai-simulation-workflow.git
```

## Available examples

| Folder | Config | Vehicles | Duration | Date |
|---|---|---|---|---|
| [`VoipDl-Urban-900_1_60s/`](VoipDl-Urban-900_1_60s/) | `VoipDl_900_1_60s` | 900 (30 active) | 60 s | 2026-08-31 |

Full 1800-second runs are available on the EOSC OneData storage at
`/mnt/oneclient/FUMD-AI/` on the EOSC node.

## Output file types

| File | Format | Description |
|---|---|---|
| `scalar-0.sca` | OMNeT++ scalar | Per-run summary statistics for all modules |
| `vector-0.vec` | OMNeT++ vector (LFS) | Time-series data for all recorded signals |
| `vector-0.vci` | OMNeT++ vector index | Index into `vector-0.vec`; lists all signal names and positions |
| `sumo_veins_mapping.txt` | Plain text | SUMO vehicle string ID ↔ OMNeT++ module index mapping |
