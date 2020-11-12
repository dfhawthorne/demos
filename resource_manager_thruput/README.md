Overview
========

During a recent webinar (2020-11-05), [Craig Shallahamer](https://www.orapub.com/) wondered if the use of [resource manager](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/managing-resources-with-oracle-database-resource-manager.html#GUID-2BEF5482-CF97-4A85-BD90-9195E41E74EF) can increase the throughput rate when a system is running at 100% CPU.

Previous Investigation
======================

The previous investigation concentrated on showing the scheduling effect of having a [CDB](https://docs.oracle.com/en/database/oracle/oracle-database/19/multi/introduction-to-the-multitenant-architecture.html#GUID-267F7D12-D33F-4AC9-AA45-E9CD671B6F22) resoure plan. The summary of this investigation can be found [here](https://yaocm.wordpress.com/2019/12/17/high-cpu-usage-with-a-cdb-resource-plan/).

The [AWR Difference Report](https://github.com/dfhawthorne/demos/blob/master/high_cpu_and_cdb_resource_plans/awr_diff_report_172_173_179_180.html) showed:
| Resource Plan | Avg Active Users | Elapsed Time (min) | DB time (min) |
| ------------- | ---------------- | ------------------:| -------------:|
| None          |              4.9 |               16.0 |          77.9 |
| JAR\_CDB\_PLAN |             4.8 |               14.1 |          67.6 |
| %Diff         |             -1.2 |              -12.2 |         -13.2 |

There is some improvement shown. However, is this difference statistically significant?

Proposed Investigation
======================

I think I should restrict myself to the simplest test case:
1. Oracle Enterprise Edition 19C.
2. Single PDB
3. No CDB Resource Plan
4. Running on VirtualBox
5. Vary CPUs on VirtualBox from one (1) to six (6) (restricted by underlying hardware)
6. No RAC
7. Whether to use HammerORA to generate load
8. Whether to use Ansible to generate test case
