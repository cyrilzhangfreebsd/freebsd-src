PACKAGE=	tests

TESTSDIR=	${TESTSBASE}/sys/racct

BINDIR=		${TESTSDIR}

ATF_TESTS_SH+=	racct_jail_shm \
		racct_jail_cpu \
		racct_jail_proc

PROGS+=		loop \
		manyforks

${PACKAGE}FILES+=	utils.subr

.include <bsd.test.mk>
