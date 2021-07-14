#-
# SPDX-License-Identifier: BSD-2-Clause-FreeBSD
#
# Copyright (c) 2021 The FreeBSD Foundation
#
# This software was developed by Cyril Zhang under sponsorship from
# the FreeBSD Foundation.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

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
