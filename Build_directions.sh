#!/bin/bash

# copy the cheyenne template files
cp /glade/u/home/pegion/OM4_config/cheyenne*mk src/mkmf/templates
mkdir -p build/intel
cd       build/intel
# copy my environment file for chyenne
cp /glade/u/home/pegion/OM4_config/OM4_cheyenne.intel.env env
source env
mkdir  -p shared/repro
cd        shared/repro

# now build FMS
../../../../src/mkmf/bin/list_paths -l ../../../../src/FMS
../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/cheyenne-intel.mk -p libfms.a -c "-Duse_libMPI -Duse_netCDF" path_names
make NETCDF=3 REPRO=1 libfms.a -j

#
cd ../../
mkdir -p ice_ocean_SIS2/repro/
cd       ice_ocean_SIS2/repro/
../../../../src/mkmf/bin/list_paths -l ./ ../../../../src/stochastic_physics ../../../../src/MOM6/config_src/{infra/FMS1,memory/dynamic_symmetric,drivers/FMS_cap,external} ../../../../src/MOM6/src/{*,*/*}/ ../../../../src/{atmos_null,coupler,land_null,ice_param,icebergs,SIS2,FMS/coupler,FMS/include}/
# since I don't understand how to exclude certain files from list_paths, you will need to edit the path_names file
# by removing the following lines:
# ../../../../src/stochastic_physics/plumes.F90
# ../../../../src/stochastic_physics/cellular_automata_global.F90
# ../../../../src/stochastic_physics/cellular_automata_sgs.F90
# ../../../../src/stochastic_physics/unit_tests/compare_ca_output.F90
# ../../../../src/stochastic_physics/unit_tests/standalone_ca.F90
# ../../../../src/stochastic_physics/unit_tests/fv_arrays_stub.F90
# ../../../../src/stochastic_physics/unit_tests/compare_output.F90
# ../../../../src/stochastic_physics/unit_tests/fv_mp_stub_mod.F90
# ../../../../src/stochastic_physics/unit_tests/standalone_stochy.F90
# ../../../../src/stochastic_physics/unit_tests/fv_control_stub.F90
# ../../../../src/stochastic_physics/unit_tests/atmosphere_stub.F90
# ../../../../src/stochastic_physics/lndp_apply_perts.F90
# ../../../../src/stochastic_physics/halo_exchange.fv3.F90
mv path_names path_names.orig
grep -v 'stochastic_physics/unit_tests' path_names.orig | grep -v cellular_automata |grep -v update_ca |grep -v plumes.F90 |grep -v halo_exchange.fv3.F90 |grep -v lndp_apply_perts.F90 > path_names
rm path_names.orig

../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/cheyenne-intel.mk -o '-I../../shared/repro' -p MOM6 -l '-L../../shared/repro -L${ESMF_LIBDIR} -lfms -lesmf' -c '-Duse_AM3_physics -D_USE_LEGACY_LAND_' path_names
make NETCDF=3 REPRO=1 MOM6 -j

# executable will be build/intel/shared/repro/MOM6
