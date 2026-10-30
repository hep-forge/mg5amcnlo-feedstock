#!/usr/bin/env bash

# reinstate the backup from outside the environment
if [[ -n "${_CONDA_BACKUP_FFLAGS}" ]]; then
	export FFLAGS="${_CONDA_BACKUP_FFLAGS}"
	unset _CONDA_BACKUP_FFLAGS
# no backup, just unset
else
	unset FFLAGS
fi

if [[ -n "${_CONDA_BACKUP_FORTRANFLAGS}" ]]; then
	export FORTRANFLAGS="${_CONDA_BACKUP_FORTRANFLAGS}"
	unset _CONDA_BACKUP_FORTRANFLAGS
else
	unset FORTRANFLAGS
fi

if [[ -n "${_CONDA_BACKUP_DEBUG_FFLAGS}" ]]; then
	export DEBUG_FFLAGS="${_CONDA_BACKUP_DEBUG_FFLAGS}"
	unset _CONDA_BACKUP_DEBUG_FFLAGS
else
	unset DEBUG_FFLAGS
fi

if [[ -n "${_CONDA_BACKUP_DEBUG_FORTRANFLAGS}" ]]; then
	export DEBUG_FORTRANFLAGS="${_CONDA_BACKUP_DEBUG_FORTRANFLAGS}"
	unset _CONDA_BACKUP_DEBUG_FORTRANFLAGS
else
	unset DEBUG_FORTRANFLAGS
fi
