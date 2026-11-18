/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

If Object_id ('bronze.crm_cust_info' , 'u') is not null
drop table bronze.crm_cust_info


Create Table bronze.crm_cust_info
(
 cst_id Int,
 cst_key NVARCHAR(50),
 cst_firstname NVARCHAR(50),
 cst_lastname NVARCHAR(50),
 cst_marital_status NVARCHAR(50),
 cst_gndr NVARCHAR(50),
 cst_create_date DATE

)

If Object_id ('bronze.crm_prd_info' , 'u') is not null
drop table bronze.crm_prd_info

Create Table bronze.crm_prd_info
(
prd_id INT,
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt Datetime,
prd_end_dt Datetime

)

If Object_id ('bronze.crm_sales_details' , 'u') is not null
drop table bronze.crm_sales_details

Create Table bronze.crm_sales_details
(
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT


)

If Object_id ('bronze.erp_loc_a101' , 'u') is not null
drop table bronze.erp_loc_a101

Create Table bronze.erp_loc_a101
(
CID NVARCHAR(50),
CNTRY NVARCHAR(50)

)

If Object_id ('bronze.erp_cust_az12' , 'u') is not null
drop table bronze.erp_cust_az12

Create Table bronze.erp_cust_az12
(
CID NVARCHAR(50),
BDATE DATE,
GEN NVARCHAR(50)

)

If Object_id ('bronze.erp_px_cat_g1v2' , 'u') is not null
drop table bronze.erp_px_cat_g1v2

Create Table bronze.erp_px_cat_g1v2
(
ID NVARCHAR(50),
CAT NVARCHAR(50),
SUBCAT NVARCHAR(50),
MAINTENANCE NVARCHAR(50)

)
