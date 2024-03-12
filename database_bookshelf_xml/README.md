# Demonstration of Loading Database Bookshelf into XE Database

## Ansible

This folder (`ansible`) contains the Ansible playbook, `setup_demo_env.yml`, which builds the demonstration schema as described in [Demonstration of Loading Database Bookshelf into XE Database](https://github.com/dfhawthorne/demos/wiki/database_bookshelf_xml). To invoke this playbook, you must:

1. Install [Ansible](https://www.ansible.com/)
1. Install [Oracle XE](https://docs.oracle.com/en/database/oracle/oracle-database/21/xeinl/installing-oracle-database-free.html#GUID-728E4F0A-DBD1-43B1-9837-C6A460432733). I have created an Ansible playbook for installing Oracle XE, [install_XE_database.yml](https://github.com/dfhawthorne/oracle-db-build/blob/main/install_XE_database.yml), in my [oracle-db-build](https://github.com/dfhawthorne/oracle-db-build) GIT repository.
1. Run the following commands:

```bash
cd demos/database_bookshelf_xml/ansible
mkdir --parents logs
ansible-playbook setup_demo_env.yml
```

## SQL Modeller

There are two (2) models in the folder, `SQL_Modeller`:

1. `xml_demo` for the XML document exported from Google Books
1. `db_books` for the final Oracle schema

## Wiki

There is a report in the Wiki at [Demonstration of Loading Database Bookshelf into XE Database](https://github.com/dfhawthorne/demos/wiki/database_bookshelf_xml).
