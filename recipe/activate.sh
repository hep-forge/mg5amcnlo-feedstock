#!/usr/bin/env bash

# preserve the existing setting
if [[ -n "${FFLAGS+x}" ]]; then
    export _CONDA_BACKUP_FFLAGS="${FFLAGS}"
fi
if [[ -n "${FORTRANFLAGS+x}" ]]; then
    export _CONDA_BACKUP_FORTRANFLAGS="${FORTRANFLAGS}"
fi
if [[ -n "${DEBUG_FFLAGS+x}" ]]; then
    export _CONDA_BACKUP_DEBUG_FFLAGS="${DEBUG_FFLAGS}"
fi
if [[ -n "${DEBUG_FORTRANFLAGS+x}" ]]; then
    export _CONDA_BACKUP_DEBUG_FORTRANFLAGS="${DEBUG_FORTRANFLAGS}"
fi

# https://github.com/conda-forge/mg5amcnlo-feedstock/issues/11
export FFLAGS="${FFLAGS} -std=legacy"
export FORTRANFLAGS="${FORTRANFLAGS} -std=legacy"
export DEBUG_FFLAGS="${DEBUG_FFLAGS} -std=legacy"
export DEBUG_FORTRANFLAGS="${DEBUG_FORTRANFLAGS} -std=legacy"
