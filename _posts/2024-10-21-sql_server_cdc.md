---
date: 2024-10-21 15:51:52
layout: post
title: "CDC in SQL Server"
subtitle: "Overview of Change Data Capture (CDC) in SQL Server: Efficiently Tracking Data Changes for Enhanced Data Management and Integration"
description: "Overview of Change Data Capture (CDC) in SQL Server: Efficiently Tracking Data Changes for Enhanced Data Management and Integration"
image: /assets/img/CDC_SQL_Server/cdc-diagram.png
optimized_image:
category: code
tags:
author:
paginate: false
---


# SQL Server Change Data Capture (CDC) 

Change Data Capture (CDC) is a powerful feature in SQL Server that enables the tracking of changes (inserts, updates, and deletes) made to a table. By capturing these changes directly from the transaction log, CDC provides a reliable and efficient mechanism for monitoring data alterations over time. This functionality is particularly valuable for data integration, real-time analytics, and maintaining an audit trail, making it easier to synchronize data between systems without significant performance overhead on the source database.

## Key Concepts of CDC:

### Capture Changes:
- CDC captures changes made to data in specific tables, recording them in change tables that mirror the structure of the source tables.
- It logs details such as what change was made (insert, update, delete), the time of the change, and the specific data before and after the change (for updates).

### Change Tracking Mechanism:
- CDC uses the transaction log to track changes rather than triggers, minimizing performance overhead.

### Change Tables:
- For each table with CDC enabled, a corresponding change table is created to store change data. The change table includes metadata like:
  - The type of operation (`__$operation`: Insert, Update, Delete)
  - The data columns that were modified.

### Polling Changes:
- Changes are read from the change tables via CDC functions like `sys.fn_cdc_get_all_changes_<capture_instance>` and `sys.fn_cdc_get_net_changes_<capture_instance>`.

### Retention and Cleanup:
- Change data is automatically cleaned up after a configurable retention period, managed by a background cleanup process.

## Enabling CDC in SQL Server:

### CDC needs to be enabled for each individual table inside the database.

#### Enabling CDC for the database:
```sql
USE YourDatabaseName; 
EXEC sys.sp_cdc_enable_db;
```
Enabling CDC for each individual table in the database:
```sql
sql
Copy code
-- Declare a variable to hold the dynamic SQL command
DECLARE @SQL NVARCHAR(MAX);

-- Initialize the variable to an empty string
SET @SQL = N'';

-- Generate the dynamic SQL for each user table
SELECT @SQL = @SQL + 
'EXEC sys.sp_cdc_enable_table @source_schema = ''' + s.name + ''', @source_name = ''' + t.name + ''', @role_name = NULL; ' + CHAR(13)
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.is_ms_shipped = 0  -- Only include user tables, exclude system tables
AND t.is_tracked_by_cdc = 0;  -- Ensure that CDC is not already enabled for this table

-- Print the generated SQL (for debugging purposes)
PRINT @SQL;

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;
```
>Note: SQL Server Agent needs to be active for CDC stored procedures to execute and capture changes.

### CDC Schema Changes in SQL Server
When Change Data Capture (CDC) is enabled on a table in SQL Server, several system tables and functions are created within the cdc schema in the database. These tables and functions help store and manage change data captured from the source tables.

Key Tables in the CDC Schema
1. cdc.change_tables
Stores metadata about all tables that are enabled for CDC in the database.
Each row represents one source table being tracked by CDC.
2. cdc.captured_columns
Contains metadata about the columns in the source tables that are being tracked for changes.
Lists all captured columns with their column attributes for each CDC-enabled table.
3. cdc.index_columns
Stores metadata about columns that are part of the primary key or unique index of the source tables.
CDC uses this information to uniquely identify rows in the change data.
4. cdc.lsn_time_mapping
Maps Log Sequence Numbers (LSNs) to corresponding transaction commit times.
Useful for querying changes based on time intervals by providing the relationship between LSNs and transaction times.
5. cdc.<capture_instance>_CT (Change Table)
For each CDC-enabled table, SQL Server creates a separate change table to store changes made to the source table.
The format is cdc.<capture_instance>_CT, where <capture_instance> is a unique identifier for the source table (typically schema_table).
The structure mirrors the source table, with additional metadata columns.

### Important Columns in CDC Change Tables

- **__$start_lsn**: LSN when the change was made.
- **__$end_lsn**: LSN when the change was committed.
- **__$seqval**: Sequence value for ordering operations within a transaction.
- **__$operation**: Type of change:
  - 1 = Delete
  - 2 = Insert
  - 3 = Update (Before)
  - 4 = Update (After)
- **__$update_mask**: Binary mask indicating which columns were updated.

In addition to the above columns, the change table has one column for each tracked column in the source table. The column names in the change table will match the source table.

### Benefits of CDC

- CDC captures changes asynchronously from the transaction log, ensuring minimal impact on the database's performance.It typically leads to additional 5-15% overhead assuming 40% typical usage for the sql server.
- It's useful for real-time data integration, ETL processes, or data synchronization (dependent on the job schedule for capture).
- Provides an audit trail for understanding what data changed and when.
- Can track hard deletes aswell.

### Shortcomings of CDC

- Lack of schema change capture:
  - Adding new columns or deleting existing columns will not change the schema of the tracking CDC table associated with the main table.
  - Deleted columns will be populated with `NULL` for new records.
  - New columns will not be present in the CDC table.
- Managing schema changes for each table could be complex (heavy development work and prone to failure; manual intervention may be needed from time to time).
- CDC would need to be disabled and enabled again for the concerned table, which may result in data loss from the previous CDC table.
- The process would involve backing up the data into an intermediary table, disabling CDC, re-enabling it, and restoring the data from the intermediary table to the new table (assuming no datatype changes to the new table).

