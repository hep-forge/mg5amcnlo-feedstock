#!/usr/bin/env csh

if ($?FFLAGS) then
	setenv _CONDA_BACKUP_FFLAGS "${FFLAGS}"
endif
if ($?FORTRANFLAGS) then
	setenv _CONDA_BACKUP_FORTRANFLAGS "${FORTRANFLAGS}"
endif
if ($?DEBUG_FFLAGS) then
	setenv _CONDA_BACKUP_DEBUG_FFLAGS "${DEBUG_FFLAGS}"
endif
if ($?DEBUG_FORTRANFLAGS) then
	setenv _CONDA_BACKUP_DEBUG_FORTRANFLAGS "${DEBUG_FORTRANFLAGS}"
endif

# https://github.com/conda-forge/mg5amcnlo-feedstock/issues/11
setenv FFLAGS "${FFLAGS} -std=legacy"
setenv FORTRANFLAGS "${FORTRANFLAGS} -std=legacy"
setenv DEBUG_FFLAGS "${DEBUG_FFLAGS} -std=legacy"
setenv DEBUG_FORTRANFLAGS "${DEBUG_FORTRANFLAGS} -std=legacy"
