
```sql

/*
https://github.com/dongxuyang1985/thinking_in_mysql
*/

use ytx;

-- 创建 4 个示例表和索引
CREATE TABLE department
    ( dept_id    INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '部门编号，自增主键'
    , dept_name  VARCHAR(50) NOT NULL COMMENT '部门名称'
    ) ENGINE=InnoDB COMMENT '部门信息表';

CREATE TABLE job
    ( job_id     INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '职位编号，自增主键'
    , job_title  VARCHAR(50) NOT NULL COMMENT '职位名称'
	, min_salary NUMERIC(8,2) NOT NULL COMMENT '最低月薪'
	, max_salary NUMERIC(8,2) NOT NULL COMMENT '最高月薪'
    ) ENGINE=InnoDB COMMENT '职位信息表';

CREATE TABLE job_test
    ( job_id     INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '职位编号，自增主键'
    , job_title  VARCHAR(50) NOT NULL COMMENT '职位名称'
    ) ENGINE=InnoDB COMMENT '职位信息测试表';

CREATE TABLE employee
    ( emp_id    INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '员工编号，自增主键'
    , emp_name  VARCHAR(50) NOT NULL COMMENT '员工姓名'
    , sex       VARCHAR(10) NOT NULL COMMENT '性别'
    , dept_id   INTEGER NOT NULL COMMENT '部门编号'
    , manager   INTEGER COMMENT '上级经理'
    , hire_date DATE NOT NULL COMMENT '入职日期'
    , job_id    INTEGER NOT NULL COMMENT '职位编号'
    , salary    NUMERIC(8,2) NOT NULL COMMENT '月薪'
    , bonus     NUMERIC(8,2) COMMENT '年终奖金'
    , email     VARCHAR(100) NOT NULL COMMENT '电子邮箱'
	, comments  VARCHAR(500) COMMENT '备注信息'
	, create_by VARCHAR(50) NOT NULL COMMENT '创建者'
	, create_ts TIMESTAMP NOT NULL COMMENT '创建时间'
	, update_by VARCHAR(50) COMMENT '修改者'
	, update_ts TIMESTAMP COMMENT '修改时间'
    , CONSTRAINT ck_emp_sex CHECK (sex IN ('男', '女'))
    , CONSTRAINT ck_emp_salary CHECK (salary > 0)
    , CONSTRAINT uk_emp_email UNIQUE (email)
    , CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES department(dept_id)
    , CONSTRAINT fk_emp_job FOREIGN KEY (job_id) REFERENCES job(job_id)
    , CONSTRAINT fk_emp_manager FOREIGN KEY (manager) REFERENCES employee(emp_id)
    ) ENGINE=InnoDB COMMENT '员工信息表';
CREATE INDEX idx_emp_name ON employee(emp_name);
CREATE INDEX idx_emp_dept ON employee(dept_id);
CREATE INDEX idx_emp_job ON employee(job_id);
CREATE INDEX idx_emp_manager ON employee(manager);

CREATE TABLE job_history
    ( history_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '工作历史编号，自增主键'
	, emp_id     INTEGER NOT NULL COMMENT '员工编号'
	, dept_id    INTEGER NOT NULL COMMENT '部门编号'
    , job_id     INTEGER NOT NULL COMMENT '职位编号'
	, start_date DATE NOT NULL COMMENT '开始日期'
	, end_date   DATE NOT NULL COMMENT '结束日期'
	, CONSTRAINT fk_job_history_emp FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
	, CONSTRAINT fk_job_history_dept FOREIGN KEY (dept_id) REFERENCES department(dept_id)
	, CONSTRAINT fk_job_history_job FOREIGN KEY (job_id) REFERENCES job(job_id)
	, CONSTRAINT check_job_history_date CHECK (end_date >= start_date)
    ) ENGINE=InnoDB COMMENT '员工工作历史记录表';
CREATE INDEX idx_job_history_emp ON job_history(emp_id);
CREATE INDEX idx_job_history_dept ON job_history(dept_id);
CREATE INDEX idx_job_history_job ON job_history(job_id);


-- 生成 MySQL 初始化数据
INSERT INTO department(dept_name) VALUES ('行政管理部');
INSERT INTO department(dept_name) VALUES ('人力资源部');
INSERT INTO department(dept_name) VALUES ('财务部');
INSERT INTO department(dept_name) VALUES ('研发部');
INSERT INTO department(dept_name) VALUES ('销售部');
INSERT INTO department(dept_name) VALUES ('保卫部');

INSERT INTO job(job_title, min_salary, max_salary) VALUES ('总经理', 24000, 50000);
INSERT INTO job(job_title, min_salary, max_salary) VALUES ('副总经理', 20000, 30000);
INSERT INTO job(job_title, min_salary, max_salary) VALUES ('人力资源总监', 20000, 30000);
INSERT INTO job(job_title, min_salary, max_salary) VALUES ('人力资源专员', 5000, 10000);
INSERT INTO job(job_title, min_salary, max_salary) VALUES ('财务经理', 10000, 20000);
INSERT INTO job(job_title, min_salary, max_salary) VALUES ('会计', 5000, 8000);
INSERT INTO job(job_title, min_salary, max_salary) VALUES ('开发经理', 12000, 20000);
INSERT INTO job(job_title, min_salary, max_salary) VALUES ('程序员', 5000, 12000);
INSERT INTO job(job_title, min_salary, max_salary) VALUES ('销售经理', 8000, 20000);
INSERT INTO job(job_title, min_salary, max_salary) VALUES ('销售人员', 4000, 8000);

INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('刘备', '男', 1, NULL, '2000-01-01', 1, 30000, 10000, 'liubei@shuguo.com', NULL, 'Admin', '2000-01-01 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('关羽', '男', 1, 1, '2000-01-01', 2, 26000, 10000, 'guanyu@shuguo.com', NULL, 'Admin', '2000-01-01 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('张飞', '男', 1, 1, '2000-01-01', 2, 24000, 10000, 'zhangfei@shuguo.com', NULL, 'Admin', '2000-01-01 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('诸葛亮', '男', 2, 1, '2006-03-15', 3, 24000, 8000, 'zhugeliang@shuguo.com', NULL, 'Admin', '2006-03-15 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('黄忠', '男', 2, 4, '2008-10-25', 4, 8000, NULL, 'huangzhong@shuguo.com', NULL, 'Admin', '2008-10-25 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('魏延', '男', 2, 4, '2007-04-01', 4, 7500, NULL, 'weiyan@shuguo.com', NULL, 'Admin', '2007-04-01 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('孙尚香', '女', 3, 1, '2002-08-08', 5, 12000, 5000, 'sunshangxiang@shuguo.com', NULL, 'Admin', '2002-08-08 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('孙丫鬟', '女', 3, 7, '2002-08-08', 6, 6000, NULL, 'sunyahuan@shuguo.com', NULL, 'Admin', '2002-08-08 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('赵云', '男', 4, 1, '2005-12-19', 7, 15000, 6000, 'zhaoyun@shuguo.com', NULL, 'Admin', '2005-12-19 10:00:00', 'Admin', '2006-12-31 10:00:00');
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('廖化', '男', 4, 9, '2009-02-17', 8, 6500, NULL, 'liaohua@shuguo.com', NULL, 'Admin', '2009-02-17 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('关平', '男', 4, 9, '2011-07-24', 8, 6800, NULL, 'guanping@shuguo.com', NULL, 'Admin', '2011-07-24 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('赵氏', '女', 4, 9, '2011-11-10', 8, 6600, NULL, 'zhaoshi@shuguo.com', NULL, 'Admin', '2011-11-10 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('关兴', '男', 4, 9, '2011-07-30', 8, 7000, NULL, 'guanxing@shuguo.com', NULL, 'Admin', '2011-07-30 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('张苞', '男', 4, 9, '2012-05-31', 8, 6500, NULL, 'zhangbao@shuguo.com', NULL, 'Admin', '2012-05-31 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('赵统', '男', 4, 9, '2012-05-03', 8, 6000, NULL, 'zhaotong@shuguo.com', NULL, 'Admin', '2012-05-03 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('周仓', '男', 4, 9, '2010-02-20', 8, 8000, NULL, 'zhoucang@shuguo.com', NULL, 'Admin', '2010-02-20 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('马岱', '男', 4, 9, '2014-09-16', 8, 5800, NULL, 'madai@shuguo.com', NULL, 'Admin', '2014-09-16 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('法正', '男', 5, 2, '2017-04-09', 9, 10000, 5000, 'fazheng@shuguo.com', NULL, 'Admin', '2017-04-09 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('庞统', '男', 5, 18, '2017-06-06', 10, 4100, 2000, 'pangtong@shuguo.com', NULL, 'Admin', '2017-06-06 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('蒋琬', '男', 5, 18, '2018-01-28', 10, 4000, 1500, 'jiangwan@shuguo.com', NULL, 'Admin', '2018-01-28 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('黄权', '男', 5, 18, '2018-03-14', 10, 4200, NULL, 'huangquan@shuguo.com', NULL, 'Admin', '2018-03-14 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('糜竺', '男', 5, 18, '2018-03-27', 10, 4300, NULL, 'mizhu@shuguo.com', NULL, 'Admin', '2018-03-27 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('邓芝', '男', 5, 18, '2018-11-11', 10, 4000, NULL, 'dengzhi@shuguo.com', NULL, 'Admin', '2018-11-11 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('简雍', '男', 5, 18, '2019-05-11', 10, 4800, NULL, 'jianyong@shuguo.com', NULL, 'Admin', '2019-05-11 10:00:00', NULL, NULL);
INSERT INTO employee(emp_name, sex, dept_id, manager, hire_date, job_id, salary, bonus, email, comments, create_by, create_ts, update_by, update_ts) VALUES ('孙乾', '男', 5, 18, '2018-10-09', 10, 4700, NULL, 'sunqian@shuguo.com', NULL, 'Admin', '2018-10-09 10:00:00', NULL, NULL);

INSERT INTO job_history(emp_id, dept_id, job_id, start_date, end_date) VALUES (9, 4, 8, '2005-12-19', '2006-12-31');


-- ====================================================================== 

select version();

select e.emp_id, e.emp_name, e.manager
from ytx.employee e 
where 1=1
and emp_id < 10 
and (manager is null or manager = '1')
;

select 0=null; -- null代表空值, 既不是true也不是false

select * from ytx.employee e where emp_name like '%张_'; 
-- %: 匹配0个或多个
-- _: 匹配一个
-- 内容中包含通配符时需要转义
select * from ytx.employee e where e.emp_name like '%#%%' escape '#';
select * from ytx.employee e where e.emp_name like '%\%%';

-- 异或运算  两个操作数中，如果有且仅有一个为真，则结果为真；如果两个操作数相同，则结果为假
select 1=1 xor 1=1;
select 1=1 xor 0=1

-- 去重
select distinct sex from ytx.employee e ;
select sex from ytx.employee e group by e.sex ;

-- 排序
select * from ytx.employee e order by e.dept_id asc, e.emp_id desc;
select * from ytx.employee e order by e.salary*12+ coalesce(e.bonus,0) desc;
-- 拼音排序
select e.emp_id, e.emp_name from ytx.employee e order by convert(e.emp_name using gbk); 

-- 分页
select e.emp_id, e.emp_name from ytx.employee e 
order by e.emp_id
limit 5 offset 2;

select e.emp_id, e.emp_name from ytx.employee e 
order by e.emp_id
limit 2, 5; -- offset在前,limit在后 


select 
abs(-1),abs(0),abs(1)
,ceil(1.1),ceil(1.9) -- 上取整
,FLOOR(1.1),floor(1.9) -- 下取整
,round(1.18,1),round(1.91, 1) -- 四舍五入
,mod(7, 3) -- 取余
,rand() -- 随机数 (0,1)
,rand(1),rand(1)
;

-- 字符串拼接
select concat('hallo', ' ', 'world');
select concat_ws(' ', 'hallo', 'world'); -- 第一个为分隔符

select CHAR_LENGTH('数据库'),OCTET_LENGTH('数据库'),LENGTH('数据库'); -- 字符/字节长度

select lower('LOWER'), upper('upper'); -- 转大小写

select SUBSTR('数据库', 2, 1); -- 字符串剪切
select SUBSTR('数据库', -2, 1);

select INSTR('hello world', 'wor'); -- 字符串查找定位

select replace('hello world', 'world', 'mysql'); -- 字符串替换

select trim(' ' from '  hello world  '); -- 字符串截取
select trim('  hello world  '); -- 字符串截取


select emp_name
,CONCAT(left(emp_name, if(CHAR_LENGTH(emp_name) <= 2, 0, 1)), '*', right(emp_name, 1)) as n2
from ytx.employee e ;


select CURRENT_DATE(), CURRENT_TIME(), CURRENT_TIMESTAMP();

select NOW(), utc_timestamp();

-- 日期提取
select 
 extract(year from now())
,extract(month from now())
,extract(day from now())
,extract(hour from now())
,extract(minute from now())
,extract(second from now())
;
select 
 year(now()),
 month(now()),
 day(now()),
 hour(now()),
 MINUTE(now()),
 second(now());


select DATEDIFF(now(), '2026-01-01');

select now() + interval '1' month + interval '7' day;

select last_day(now());

select now(), DATE_FORMAT(now(), '%Y-%m-%d %H:%i:%s.%f');


select emp_name, salary,
case 
	when salary >= 10000 then 'A'
	when salary >= 5000 then 'B'
	else 'C' end as l
from ytx.employee e; 

select emp_name, salary,
case dept_id 
	when 1 then 'A'
	when 2 then 'B'
	else 'C' end as l
from ytx.employee e;


select
 count(1),SUM(salary ),max(salary ),min(salary ),avg(salary )
,COUNT(distinct dept_id)
from ytx.employee e 

-- 字符串聚合合并
select 
 GROUP_CONCAT(email, '$')
,GROUP_CONCAT(email order by email separator '$')
from ytx.employee
where dept_id = 1;

select sex, COUNT(1), any_value(emp_name)
from ytx.employee e 
group by sex;

select dept_id, avg(salary) a
from ytx.employee e 
group by dept_id 
having a > 10000

-- 分组小计/合计
select dept_id, sex, count(1), grouping(sex), grouping(dept_id)
from ytx.employee e 
group by dept_id, e.sex with rollup;

select 
 if(grouping(dept_id)=1, '所有部门', dept_id) dept_id
,if(grouping(sex)=1, '所有性别', sex) sex
,count(1)
from ytx.employee e 
group by dept_id, e.sex with rollup;

-- 空值
select null = null, null != null, null <=> null;

select * 
from ytx.employee e 
where bonus not in ('2000', null);

select concat('ob', null, 'mysql');

select emp_name, COALESCE(bonus, 0)
from ytx.employee e;

select nullif(1,1), nullif(3,0);

select ifnull(0, 1), ifnull(null, 3); -- 同 COALESCE

-- 内连接
select emp_name, e.dept_id, d.dept_name 
from ytx.employee e , ytx.department d 
where e.dept_id = d.dept_id;

select emp_name, e.dept_id, d.dept_name 
from ytx.employee e 
inner join ytx.department d on e.dept_id = d.dept_id;

select emp_name, e.dept_id, d.dept_name 
from ytx.employee e 
inner join ytx.department d using(dept_id); -- 相同字段简写, full outer join 不适用


-- 左外连接
select emp_name, e.dept_id, d.dept_name 
from ytx.employee e 
left join ytx.department d on e.dept_id = d.dept_id;

-- 右外连接
select emp_name, e.dept_id, d.dept_name 
from ytx.employee e 
right join ytx.department d on e.dept_id = d.dept_id;

-- 全外连接
select emp_name, e.dept_id, d.dept_name 
from ytx.employee e 
full outer join ytx.department d on e.dept_id = d.dept_id;

-- 交叉连接
select * 
from ytx.department d 
cross join ytx.department d2

-- 标量子查询 (一行一列)
select *
from ytx.employee e 
where salary > (
	select avg(salary)
	from ytx.employee
);

-- 行子查询 (一行多列)
select *
from ytx.employee e 
where (dept_id, job_id) = (
	select dept_id, job_id
	from ytx.employee e2 
	where emp_id = 1
);

-- 表子查询 (多行多列)
select *
from ytx.employee e 
where emp_id in (
	select emp_id 
	from ytx.employee e2 
	where dept_id = 1
);

select *
from ytx.employee e 
where (dept_id, job_id) in (
	select dept_id, job_id
	from ytx.employee e2 
	where dept_id = 1
);

select *
from ytx.employee e 
where salary >  all(
	select salary 
	from ytx.employee e2 
	where dept_id = 3
);

select *
from ytx.employee e 
where salary > any(
	select salary 
	from ytx.employee e2 
	where dept_id = 3
);

-- 派生表
select d.dept_id, d.dept_name, ee.c
from ytx.department d 
left join (
	select e.dept_id, COUNT(1) c
	from ytx.employee e 
	group by e.dept_id 
) ee on d.dept_id = ee.dept_id;

-- 关联子查询
select d.dept_id, d.dept_name, (
	select COUNT(1) from ytx.employee e where d.dept_id = e.dept_id 
	-- 逻辑上每一个dept_id都会执行一次, 实际使用中数据库会优化查询
) c
from ytx.department d 
order by d.dept_id;

-- 横向子查询
select d.dept_name, t.emp_name, t.salary
from ytx.department d 
join lateral (
	select e.dept_id, e.emp_name, e.salary 
	from ytx.employee e 
	where e.dept_id = d.dept_id 
	order by e.salary desc
	limit 2
) t on d.dept_id = t.dept_id; -- on 可以省略, 可以换成 cross join


select d.dept_id, d.dept_name
from ytx.department d 
where exists (select 0 -- 0可以替换其他值, 只要有返回行数据就行 
              from ytx.employee e 
			  where e.sex = '女' and e.dept_id =d.dept_id);


-- 交集求同
select manager, salary
from ytx.employee
where bonus = 10000
intersect -- 效果同 inner join, 但是 intersect 要求两边字段数量/类型匹配或兼容
select manager, salary
from ytx.employee
where bonus = 8000;


-- 并集存异
select manager, salary
from ytx.employee
where bonus = 10000
union -- 效果同 full outer join, 但是 union 要求两边字段数量/类型匹配或兼容
select manager, salary
from ytx.employee
where bonus = 8000;

-- 差集排他
select manager, salary
from ytx.employee
where bonus = 10000
except -- 效果同 a left join b 且 b.column is null, 但是 union 要求两边字段数量/类型匹配或兼容
select manager, salary
from ytx.employee
where bonus = 8000;

-- 变量
with t1(n) as(
	select 1
)
,t2(n) as(
	select n+1 from t1
)
select * from t1, t2;


-- 递归
with recursive t(n) as (
	select 1 -- 初始化
	union all
	select n+1 from t -- where n < 5 -- 递归
)
select * from t;

-- 设置递归的最大层级
set @@cte_max_recursion_depth = 2000;

-- 递归获取员工上下级关系
with recursive emp_path as (
	select emp_id, emp_name, emp_name as path from ytx.employee e where e.emp_id in (2,9)  -- 初始化
	union all
	select e2.emp_id, e2.emp_name, CONCAT(m.path, '->', e2.emp_name) from ytx.employee e2 
		join emp_path m on m.emp_id = e2.manager
)
select * from emp_path;


-- 窗口函数
select emp_name, salary, dept_id, sum(salary) over (partition by dept_id) as dept_salary
from ytx.employee e ;

select emp_name, salary, dept_id
, sum(salary) over (
	partition by dept_id 
	order by salary
	rows between 1 preceding and current row -- 前一行到当前行
	) as dept_salary
from ytx.employee e ;

select emp_name, salary, dept_id
, sum(salary) over (
	partition by dept_id 
	order by salary
	rows between current row and 1 following -- 当前行到后一行
	) as dept_salary
from ytx.employee e ;

select emp_name, salary, dept_id
, sum(salary) over (
	partition by dept_id order by salary
	rows between unbounded preceding and unbounded following -- 从首行到尾行
	) as dept_salary
from ytx.employee e ;

select emp_name, salary, dept_id , hire_date
, sum(salary) over (
	partition by dept_id 
	order by hire_date
	range between interval '2' month preceding and interval '2' month following -- 日期范围,与order by 绑定
	) as s
from ytx.employee e where dept_id = 5;

select emp_name, salary, dept_id
	,avg(salary) over (partition by dept_id) as dept_salary
from ytx.employee e ;

-- 排名窗口函数
select emp_name, salary, dept_id
	,row_number() over (partition by dept_id order by salary desc) as num
	,rank() over w as r -- 有跳跃
	,dense_rank() over w as dr -- 无跳跃
	,percent_rank() over w as pr -- 有跳跃
from ytx.employee e where dept_id in (3, 4)
window w as (partition by dept_id order by salary desc);


select emp_name, salary, dept_id
	,cume_dist() over (order by salary desc) -- 累积分布
	,ntile(10) over (order by salary desc)   -- 等分
from ytx.employee e;

select emp_name, salary, dept_id
	,lag(salary, 1) over w as before_row -- 取上一行的salary
	,lead(salary, 1) over w as after_row -- 取下一行的salary
	, (salary - lag(salary, 1) over w) / lag(salary, 1) over w as hb
from ytx.employee e
window w as (partition by dept_id order by salary desc);

select emp_name, salary, dept_id
	,FIRST_VALUE(salary) over w -- 取窗口第一个值
	,last_VALUE(salary) over w  -- 取窗口最后一个值
from ytx.employee e
window w as (partition by dept_id order by salary desc);



select * from ytx.department d ;
-- 插入数据
insert into ytx.department(dept_id, dept_name) value (10, '其他');
insert into ytx.department value (11, '其他11');
insert into ytx.department value (12, '其他12'), (13, '其他13');


select * from ytx.job_test;
-- 查询结果插入新表
insert into ytx.job_test(job_id,job_title)
select job_id,job_title from ytx.job j 
on duplicate key update -- 主键重复则更新
job_title=j.job_title;

-- 主键重复则替换其余字段的值
replace into ytx.job_test(job_id,job_title)
select job_id,job_title from ytx.job j;

select emp_id, emp_name, salary, bonus  from ytx.employee e where emp_id =10 ;
-- 修改
update ytx.employee d set salary=7500, bonus=200 where emp_id = 10;

-- 使用 emp_id = 1 的 salary,bonus 更新 emp_id = 10 的 salary,bonus
update ytx.employee d 
join ytx.employee e on e.emp_id = 1
set d.salary = e.salary, d.bonus = e.bonus
where d.emp_id = 10;

-- 删除
delete 
from ytx.job_test 
where job_id > 5;

delete 
from ytx.job_test 
where job_id in (select job_id from ytx.job_test where job_id < 3)

delete t
from ytx.job_test t 
join ytx.job j on j.job_id = t.job_id and j.job_id in (3,4);

truncate table ytx.job_test; -- 快速删除数据  drop table + create table
```
