. $(atf_get_srcdir)/utils.subr

atf_test_case racct_max_proc cleanup
racct_max_proc_head()
{
	atf_set "descr" "Tests maxproc for a jail racct."
	atf_set "require.user" "root"
}
racct_max_proc_body()
{
	racct_mkjail myjail
	rctl -a "jail:myjail:maxproc:deny=5"

	atf_check -s exit:0 "$(atf_get_srcdir)/manyforks"
}
racct_max_proc_cleanup()
{
	rctl -r "jail:myjail:maxproc:deny=5"
	racct_cleanup
}

atf_init_test_cases()
{
	atf_add_test_case racct_max_proc
}
