. $(atf_get_srcdir)/utils.subr

atf_test_case vmm_cred_jail_host cleanup
vmm_cred_jail_host_head()
{
	atf_set "descr" "Tests deleting the host's VM from within a jail"
	atf_set "require.user" "root"
}
vmm_cred_jail_host_body()
{
	if ! kldstat -qn vmm; then
		atf_skip "vmm is not loaded"
	fi
	bhyvectl --vm=testvm --create
	vmm_mkjail myjail
	atf_check -s exit:1 -e ignore jexec myjail bhyvectl --vm=testvm --destroy
}
vmm_cred_jail_host_cleanup()
{
	bhyvectl --vm=testvm --destroy
	vmm_cleanup
}

atf_test_case vmm_cred_jail_other cleanup
vmm_cred_jail_other_head()
{
	atf_set "descr" "Tests deleting a jail's VM from within another jail"
	atf_set "require.user" "root"
}
vmm_cred_jail_other_body()
{
	if ! kldstat -qn vmm; then
		atf_skip "vmm is not loaded"
	fi
	vmm_mkjail myjail1
	vmm_mkjail myjail2
	atf_check -s exit:0 jexec myjail1 bhyvectl --vm=testvm --create
	atf_check -s exit:1 -e ignore jexec myjail2 bhyvectl --vm=testvm --destroy
}
vmm_cred_jail_other_cleanup()
{
	bhyvectl --vm=testvm --destroy
	vmm_cleanup
}

atf_init_test_cases()
{
	atf_add_test_case vmm_cred_jail_host
	atf_add_test_case vmm_cred_jail_other 
}
