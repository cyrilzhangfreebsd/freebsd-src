atf_test_case racct_shm_count cleanup
atf_test_case racct_shm_size cleanup

racct_shm_count_head()
{
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

racct_shm_size_head()
{
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
	jailname=$1
	max=$2
	i=1
	while [ $i -le $max ]
	do
		jexec $jailname posixshmcontrol create "/$jailname$i"
		if [ $? -ne 0 ]
		then
			atf_fail "Could not create /$jailname$i"
		fi
		i=$((${i}+1))
	done
}

racct_make_forbidden_object()
{
	jailname=$1
	i=$2
	jexec $jailname posixshmcontrol create "/$jailname$i"
	if [ $? -eq 0 ]
	then
		atf_fail "Created /$jailname$i"
	fi
}

racct_truncate_objects()
{
	jailname=$1
	max=$2
	size=$3
	i=1
	while [ $i -le $max ]
	do
		jexec $jailname posixshmcontrol truncate -s $size "/$jailname$i"
		if [ $? -ne 0 ]
		then
			atf_fail "Could not truncate /$jailname$i to $size"
		fi
		i=$((${i}+1))
	done
}

racct_truncate_forbidden_object()
{
	jailname=$1
	i=$2
	size=$3
	jexec $jailname posixshmcontrol truncate -s $size "/$jailname$i"
	if [ $? -eq 0 ]
	then
		atf_fail "Truncated /$jailname$i to $size"
	fi
}

racct_remove_objects()
{
	jailname=$1
	max=$2
	i=1
	while [ $i -le $max ]
	do
		jexec $jailname posixshmcontrol rm "/$jailname$i"
		i=$((${i}+1))
	done
}

atf_init_test_cases()
{
	atf_add_test_case racct_shm_count
	atf_add_test_case racct_shm_size
}
