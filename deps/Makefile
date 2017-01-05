# This constructs the Dockerfile and also the "normal" install script
# from rules for each dependency and the compiler options in use.

docker_rules = \
conda_root \
conda_pkgs \
pip_pkgs \
mpich \
mpi4py \
cfitsio \
fftw \
boost \
harp

nersc_rules = \
conda_root \
conda_pkgs \
pip_pkgs \
mpi4py \
cfitsio \
fftw \
boost \
harp

confs := $(wildcard conf_*)

.PHONY : all clean docker nersc


all : docker nersc


docker : $(foreach cf,$(confs),$(shell root=`echo $(cf) | sed -e "s#conf_\(.*\)#\1#"`; echo Dockerfile_$${root}))

nersc : $(foreach cf,$(confs),$(shell root=`echo $(cf) | sed -e "s#conf_\(.*\)#\1#"`; echo install_$${root}.sh))


Dockerfile_% : conf_% Dockerfile.template
	@./apply_conf.sh $< Dockerfile.template $@


install_%.sh : conf_% install.template
	@./apply_conf.sh $< install.template $@


Dockerfile.template : Dockerfile.in $(foreach rl,$(docker_rules),rules/$(rl).sh)
	@./gen_template.sh $< $@ "$(docker_rules)" RUN


install.template : install.in $(foreach rl,$(nersc_rules),rules/$(rl).sh)
	@./gen_template.sh $< $@ "$(nersc_rules)"


clean :
	@rm -f Dockerfile_* Dockerfile.template install_* install.template

