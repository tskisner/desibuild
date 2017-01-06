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

normal_rules = \
conda_root \
conda_pkgs \
pip_pkgs \
mpi4py \
cfitsio \
fftw \
boost \
harp

confs_normal := $(wildcard conf/*)

confs_docker := $(wildcard conf/docker-*)

.PHONY : all clean docker normal


all : docker normal



docker : $(foreach cf,$(confs_docker),Dockerfile_$(subst conf/docker-,,$(cf)))

normal : $(foreach cf,$(confs_normal),install_$(subst conf/,,$(cf)).sh)


Dockerfile_% : conf/docker-% Dockerfile.template
	@./tools/apply_conf.sh $< Dockerfile.template $@


install_%.sh : conf/% install.template
	@./tools/apply_conf.sh $< install.template $@; \
	chmod +x $@


Dockerfile.template : Dockerfile.in $(foreach rl,$(docker_rules),rules/$(rl).sh)
	@./tools/gen_template.sh $< $@ "$(docker_rules)" RUN


install.template : install.in $(foreach rl,$(normal_rules),rules/$(rl).sh)
	@./tools/gen_template.sh $< $@ "$(normal_rules)"


clean :
	@rm -f Dockerfile_* Dockerfile.template install_* install.template

