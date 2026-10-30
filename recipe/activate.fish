#!/usr/bin/env fish

if set -q FFLAGS
	set -gx _CONDA_BACKUP_FFLAGS "$FFLAGS"
end
if set -q FORTRANFLAGS
	set -gx _CONDA_BACKUP_FORTRANFLAGS "$FORTRANFLAGS"
end
if set -q DEBUG_FFLAGS
	set -gx _CONDA_BACKUP_DEBUG_FFLAGS "$DEBUG_FFLAGS"
end
if set -q DEBUG_FORTRANFLAGS
	set -gx _CONDA_BACKUP_DEBUG_FORTRANFLAGS "$DEBUG_FORTRANFLAGS"
end

# https://github.com/conda-forge/mg5amcnlo-feedstock/issues/11
set -gx FFLAGS "$FFLAGS -std=legacy"
set -gx FORTRANFLAGS "$FORTRANFLAGS -std=legacy"
set -gx DEBUG_FFLAGS "$DEBUG_FFLAGS -std=legacy"
set -gx DEBUG_FORTRANFLAGS "$DEBUG_FORTRANFLAGS -std=legacy"
