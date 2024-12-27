select * from v$session order by lockwait asc ;
select * from v$session where SID=1521;
alter system kill session '3779,17839' immediate;
select * from v$lock;

select * from GNMT_batch_EXE_TRACE;

select * from gnmm_batch_list order by 1;

select * from dba_blockers;

select * from dba_waiters;

6781
19
1521
6790