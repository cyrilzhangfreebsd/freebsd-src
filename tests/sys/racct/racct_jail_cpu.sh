. $(atf_get_srcdir)/utils.subr

atf_test_case racct_cpu cleanup
racct_cpu_head()
{
	atf_set "descr" "Tests pcpu and cputime for a jail racct."
	atf_set "require.user" "root"
}
racct_cpu_body()
{
	# This test checks pctcpu and cputime at once,
	# in order to avoid running the 3s loop twice.
	racct_mkjail myjail
	jexec myjail $(atf_get_srcdir)/loop &
	sleep 2
	pcpu=$(rctl -u jail:myjail | grep "pcpu" | sed 's/.*=//')
	sleep 2
	cputime=$(rctl -u jail:myjail | grep "cputime" | sed 's/.*=//')
	# We'll give a very large tolerance for pcpu,
	# due to the decay factor involved in its calculation.
	# cputime may be rounded down to 2 but should
	# not exceed 3.
	if [ $cputime -lt 2 ] || [ $cputime -gt 3 ] || [ $pcpu -lt 60 ] || [ $pcpu -gt 140 ]; then
		atf_fail "expected pcpu: ~100, actual: $pcpu | expected cputime: ~3, actual: $cputime"
	fi

}
racct_cpu_cleanup()
{
	racct_cleanup
}

atf_init_test_cases()
{
	atf_add_test_case racct_cpu
}
