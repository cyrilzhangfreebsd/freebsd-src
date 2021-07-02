. $(atf_get_srcdir)/utils.subr

atf_test_case racct_shm_count cleanup
racct_shm_count_head()
{
	atf_set "descr" "Tests nshm for a jail racct."
	atf_set "require.user" "root"
}
racct_shm_count_body()
{
	racct_mkjail myjail
	rctl -a "jail:myjail:nshm:deny=20"

	racct_make_objects myjail 20
	racct_make_forbidden_object myjail 21
	racct_remove_objects myjail 20
	racct_make_objects myjail 20
	racct_make_forbidden_object myjail 21
}
racct_shm_count_cleanup()
{
	rctl -r "jail:myjail:nshm:deny=20"
	# This is due to a bug in posix shared memory objects, and
	# is subject for removal.
	# Removing the shared memory objects should not be necessary.
	racct_remove_objects myjail 21
	racct_cleanup
}

atf_test_case racct_shm_size cleanup
racct_shm_size_head()
{
	atf_set "descr" "Tests shmsize for a jail racct."
	atf_set "require.user" "root"
}
racct_shm_size_body()
{
	racct_mkjail myjail
	rctl -a "jail:myjail:shmsize:deny=10000"

	racct_make_objects myjail 20
	racct_truncate_objects myjail 19 512
	racct_truncate_forbidden_object myjail 20 512
	racct_truncate_objects myjail 19 0
	racct_truncate_objects myjail 19 512
	racct_truncate_forbidden_object myjail 20 512
}
racct_shm_size_cleanup()
{
	rctl -r "jail:myjail:shmsize:deny=10000"
	# This is due to a bug in posix shared memory objects, and
	# is subject for removal.
	# Removing the shared memory objects should not be necessary.
	racct_remove_objects myjail 20
	racct_cleanup
}

racct_mkjail()
{
	jailname=$1
	jail -c name=${jailname} persist
	echo $jailname >> created_jails.lst
}
racct_cleanup()
{
	if [ -f created_jails.lst ]
	then
		for jailname in `cat created_jails.lst`
		do
			jail -r ${jailname}
		done
		rm created_jails.lst
	fi
}

racct_make_objects()
{
	local jailname max
	jailname=$1
	max=$2
	for i in $(seq 1 $max); do
		atf_check -s exit:0 jexec "$jailname" posixshmcontrol create "/$jailname$i"
	done
}

racct_make_forbidden_object()
{
	local jailname i
	jailname=$1
	i=$2
	atf_check -s exit:1 -e ignore jexec "$jailname" posixshmcontrol create "/$jailname$i"
}

racct_truncate_objects()
{
	local jailname max size
	jailname=$1
	max=$2
	size=$3
	for i in $(seq 1 $max); do
		atf_check -s exit:0 jexec "$jailname" posixshmcontrol truncate -s "$size" "/$jailname$i"
	done
}

racct_truncate_forbidden_object()
{
	local jailname i size
	jailname=$1
	i=$2
	size=$3
	atf_check -s exit:1 -e ignore jexec "$jailname" posixshmcontrol truncate -s "$size" "/$jailname$i"
}

racct_remove_objects()
{
	local jailname max
	jailname=$1
	max=$2
	for i in $(seq 1 $max); do
		jexec $jailname posixshmcontrol rm "/$jailname$i"
	done
}

atf_init_test_cases()
{
	atf_add_test_case racct_shm_count
	atf_add_test_case racct_shm_size
}
