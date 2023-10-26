# minio 常用操作记录

> 版本说明:
>
> `minio`: `RELEASE.2021-02-24T18-44-45Z`
>
> `mc`: `RELEASE.2021-02-19T05-34-40Z`

1. 增加配置

    ```shell
    mc config host add {别名} http://127.0.0.1:9000 {username} {password} --api S3v4
    ```

2. 查看配置

    ```shell
    mc config host list
    ```

3. 查看`policy`规则
    ```shell
    mc policy list {别名}/{bucket_name}
    ```

4. 设置`policy`规则
    ```shell
    # bucket_name 下所有文件可无授权访问
    mc policy set download {别名}/{bucket_name}
    # bucket_name 下所有`a`开头的文件/目录文件可无授权访问
    mc policy set upload {别名}/{bucket_name}/a
    
    download: 无授权下载
    upload	: 无授权上传
    public	: 无授权上传/下载
    none	: 收回权限
    ```
     
5. 启动

     ```shell
     export MINIO_ACCESS_KEY={username}
     export MINIO_SECRET_KEY={password}
     minio server /opt/minio/files --address=0.0.0.0:9000
     ```
