# dolphinscheduler-project
This purpose of this repo is to record some tricks and solutions during the process of
the ds-cluster building.

<center>
   <img src="pic/ds_logo.png" width="80%">
</center>

___
## Catalogue
- [dolphinscheduler-project](#dolphinscheduler-project)
  - [Catalogue](#catalogue)
  - [Main DS Service Composition](#main-ds-service-composition)
  - [Important Glossary](#important-glossary)
  - [Build a Cluster](#build-a-cluster)
    - [Configuration Information](#configuration-information)
      - [1. Test Servers Info](#1-test-servers-info)
      - [2. zookeeper](#2-zookeeper)
      - [3. mysql](#3-mysql)
      - [4. dolphin scheduler project](#4-dolphin-scheduler-project)
      - [5. others](#5-others)


## Main DS Service Composition
DolphinScheduler mainly consists of five services: 
- MasterServer：Mainly responsible for DAG segmentation and task status monitoring
- WorkerServer/LoggerServer：Mainly responsible for the submission, execution and update of task status. LoggerServer is used for Rest Api to view logs through RPC
- ApiServer：Provides the Rest Api service for the UI to call
- AlertServer：Provide alarm service
- UI: Front page display

## Important Glossary
- __Priority__: Support the priority of process instances and task instances, if the priority of process instances and task instances is not set, the default is __first-in-first-out__.
- __Task/Process Priority__: When the number of __worker/process threads__ is insufficient, high-level tasks will be executed first in the execution queue, and tasks/process with the same priority will be executed in the order of first in, first out.
- __Failure Strategy__: notification strategy, process priority, worker group, notification group, recipient, and CC are the same as workflow running parameters.
- __SubProcess__: The sub-process node is to execute a certain external workflow definition as a task node.

## Build a Cluster
### Configuration Information
#### 1. Test Servers Info
- backend-pulsar-101
- backend-pulsar-102
- backend-pulsar-103

#### 2. zookeeper

version：3.7.1
- leader: backend-pulsar-102
- follower: backend-pulsar-101, backend-pulsar-103


#### 3. mysql
version：8.0
Depoy on the docker on the _backend-pulsar-101_ server. 

> Due to ds meta data are stored in the database, it's recommended that the mysql database should be built in the cluster server or the server which owns the __low latency__ to the ds cluster. Otherwise, the io, ui and so on of ds cluster will be badly affected.
<center>
   <img src="pic/stat_mysql.png" width="80%">
</center>

#### 4. dolphin scheduler project

ds version: 2.0.5

<center>
   <img src="pic/ds_services.png" width="80%">
</center>

#### 5. others
configuration:
```shell
# The directory to install DolphinScheduler for all machine we config above. It will automatically be created by `install.sh` script if not exists.
# Do not set this configuration same as the current path (pwd)
installPath="/data1_1T/dolphinscheduler"

# Log path
logpath="/data1_1T/dolphinscheduler/logs"

# The directory to store local data for all machine we config above. Make sure user `deployUser` have permissions to read and write this directory.
dataBasedirPath="/tmp/dolphinscheduler"

# resource store on HDFS/S3 path, resource file will store to this hdfs path, self configuration, please make sure the directory exists on hdfs and has read write permissions. "/dolphinscheduler" is recommended
resourceUploadPath="/dolphinscheduler"
```

### _aso-alert_ project deployment test
1. worker group
   
DS is allowed to divide workers to organize as work group, and appoint related task executed on specific group.

User need to configure the required environment (such as JAVA_HOME, PYTHON_HOME and so on) in the group to support the program.

   
2. environment manage

    alert项目需要相关python环境，需要在项目运行服务器上配置python解释器与相关第三方库（利用pyenv与virtualenv）。
   
    在ds的ui中，安全中心->环境管理->创建环境，export 相关的python home，如图所示:

   <center>
      <img src="pic/stat_ds_env.png" width="80%">
   </center>

3. 资源中心
   需要上传相关任务依赖文件，资源中心->上传文件。

>   __注意__:
> 
> 1. ds仅文件级上传，目前不支持批上传, 如果选用本地存储，直接复制到本地的文件不会映射到资源中心中，hdfs未知
> 
> 2. 在ds2.0.5版本中，上传的文件在服务器中存储路径可能会出现错误，倒是导入资源时无法找到相关文件。需重新上传，同时在服务器中个确保文件存在。

   - 服务器：
      <center>
         <img src="pic/stat_store_local.png" width="80%">
      </center>
   - ui：
   <center>
      <img src="pic/stat_store_ui.png" width="80%">
   </center>

4. 构建，运行工作流

   - DAG
      <center>
         <img src="pic/stat_dags.png" width="80%">
      </center>

   - 上线任务
      <center>
         <img src="pic/stat_online.png" width="80%">
      </center>
   
   - 运行结果，日志
      <center>
         <img src="pic/stat_run_log.png" width="80%">
      </center>

钉钉收到相关信息，至此alert aso排名预警任务完成迁徙部署。