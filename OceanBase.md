
```sql
-- 获取集群中的 Zone 信息
SELECT * FROM oceanbase.DBA_OB_ZONES;
-- 获取集群中的所有节点信息
SELECT * FROM oceanbase.DBA_OB_SERVERS;
-- 查看集群配置项
SELECT * FROM GV$OB_PARAMETERS WHERE NAME LIKE '%syslog_level%';

-- 创建租户的流程
-- 1. 创建资源规格
-- 2. 创建资源池 绑定 资源规格
-- 3. 创建租户 绑定 资源池

-- 获取已有的资源规格信息
SELECT * FROM oceanbase.DBA_OB_UNIT_CONFIGS;
-- 删除资源规格
DROP RESOURCE UNIT S1_unit_config;
-- 创建一个名称为 S1_unit_config 的资源规格
CREATE RESOURCE UNIT S1_unit_config
                MEMORY_SIZE = '2G',
                MAX_CPU = 3, MIN_CPU = 3,
                LOG_DISK_SIZE = '2G',
                MAX_IOPS = 10000, MIN_IOPS = 10000, IOPS_WEIGHT=1;
-- 修改资源单元 unit1 的示例如下
ALTER RESOURCE UNIT test_unit MAX_CPU 3, MIN_CPU 3, MEMORY_SIZE '2G', LOG_DISK_SIZE '2G', IOPS_WEIGHT 3, NET_BANDWIDTH_WEIGHT 3;

-- 获取资源池的配置信息
SELECT * from oceanbase.DBA_OB_RESOURCE_POOLS;
-- 创建一个名为 mq_pool_01 的资源池
CREATE RESOURCE POOL mq_pool_01 
                UNIT='S1_unit_config', 
                UNIT_NUM=1, 
                ZONE_LIST=('zone1'); 
-- 删除资源池
DROP RESOURCE POOL mq_pool_01;

-- 查看所有的租户信息
SELECT * FROM oceanbase.DBA_OB_TENANTS;
-- 删除租户
DROP TENANT test;
-- 创建租户
CREATE TENANT IF NOT EXISTS mq_t1 
                PRIMARY_ZONE='zone1', 
                RESOURCE_POOL_LIST=('mq_pool_01')
                set OB_TCP_INVITED_NODES='%';

-- 登录 mq_t1 租户的 root 用户 (docker mini 模式部署时 -u参数不需要加 #cluster )
obclient -h127.0.0.1 -P2881 -uroot@mq_t1#cluster -A
-- 修改 root 用户的密码
ALTER USER root IDENTIFIED BY 'xxxx'; -- xxxx 为新密码
-- 密码登录 mq_t1 租户的 root 用户
obclient -h127.0.0.1 -P2881 -uroot@mq_t1#cluster -pxxxx  -- xxxx 为刚刚的新密码
```
