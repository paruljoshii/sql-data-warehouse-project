/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver as
BEGIN
		DECLARE @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;

			BEGIN TRY

			SET @batch_start_time = GETDATE();
			PRINT '====================================================================';
			PRINT ' LOADING SILVER LAYER';
			PRINT '====================================================================';


			PRINT '--------------------------------------------------------------------';
			PRINT 'LOADING CRM TABLES';
			PRINT '---------------------------------------------------------------------';

			-- LOADING CRM silver.crm_cust_info
			SET @start_time = GETDATE();

			PRINT '<< TRUNCATING TABLE : silver.crm_cust_info';
			TRUNCATE TABLE silver.crm_cust_info;
			PRINT '<< INSERT INTO : silver.crm_cust_info';
			Insert into silver.crm_cust_info
			(cst_id,cst_key,cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)

			Select
			cst_id,
			cst_key,
			Trim(cst_firstname) as cst_firstname,
			Trim(cst_lastname) as cst_lastname,
			CASE
			 when Upper(Trim(cst_marital_status)) = 'M' then 'Married'
			 when Upper(Trim(cst_marital_status)) = 'S' then 'Single'
			 else 'n/a'
			 End cst_marital_status,

			CASE
			 when Upper(trim(cst_gndr))= 'M' then 'Male'
			 when Upper(trim(cst_gndr))= 'F' then 'Female'
			 else 'n/a'
			 End cst_gndr,

			cst_create_date from 
			(
			Select
			*,
			Row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
			from bronze.crm_cust_info
			where cst_id is not null )t
			where flag_last = 1;

			SET @end_time = GETDATE();
			PRINT '<<LOAD DURATION:' + CAST(DATEDIFF(second,@start_time, @end_time) as VARCHAR) + 'seconds';

			-------------------------------------------------------------------------------------------

			SET @start_time = GETDATE();

			PRINT '<< TRUNCATING TABLE : silver.crm_prd_info';
			TRUNCATE TABLE silver.crm_prd_info;
			PRINT '<< INSERT INTO : silver.crm_prd_info';
			Insert into silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
			)

			Select
			prd_id,
			Replace(Substring(prd_key, 1,5),'-', '_') as cat_id,
			Substring(prd_key, 7, len(prd_key)) as prd_key,
			prd_nm,
			isnull(prd_cost, 0) as prd_cost,
			CASE Upper(trim(prd_line))
			 when 'R' then 'Road'
			 when 'M' then 'Mountain'
			 when 'S' then 'Othersales'
			 when 'T' then 'Touring'
			 else 'n/a'
			End as prd_line,
			cast(prd_start_dt as date) as prd_start_dt,
			cast(Lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
			from bronze.crm_prd_info


			SET @end_time = GETDATE();
			PRINT '<<LOAD DURATION:' + CAST(DATEDIFF(second,@start_time, @end_time) as VARCHAR) + 'seconds';
			--------------------------------------------------------------------------------------------------------------

			SET @start_time = GETDATE();

			PRINT '<< TRUNCATING TABLE : silver.crm_sales_details';
			TRUNCATE TABLE silver.crm_sales_details;
			PRINT '<< INSERT INTO : silver.crm_sales_details';
			Insert into silver.crm_sales_details
			(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
			)

			Select
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE
			   When sls_order_dt = 0 or Len(sls_order_dt) !=8 then Null
			   Else CAST(CAST(sls_order_dt as VARCHAR) as Date)
			END as sls_order_dt,
			CASE
			   When sls_ship_dt = 0 or Len(sls_ship_dt) !=8 then Null
			   Else CAST(CAST(sls_ship_dt as VARCHAR) as Date)
			END as sls_ship_dt,
			CASE
			   When sls_due_dt = 0 or Len(sls_due_dt) !=8 then Null
			   Else CAST(CAST(sls_due_dt as VARCHAR) as Date)
			END as sls_due_dt,
			CASE
			  when sls_sales is NULL  or sls_sales <= 0  or sls_sales != sls_quantity * ABS(sls_price)
			  then sls_quantity * ABS(sls_price)
			  else sls_Sales
			END as sls_Sales,
			sls_quantity,
			CASE
			  when sls_price <= 0 or sls_price is null
			  then sls_sales / Nullif(sls_quantity,0)
			  else sls_price
			End as sls_price

			from bronze.crm_sales_details


			SET @end_time = GETDATE();
			PRINT '<<LOAD DURATION:' + CAST(DATEDIFF(second,@start_time, @end_time) as VARCHAR) + 'seconds';

			-------------------------------------------------------------------------------------------------

			PRINT '--------------------------------------------------------------------';
			PRINT 'LOADING ERP TABLES';
			PRINT '---------------------------------------------------------------------';


			SET @start_time = GETDATE();

			PRINT '<< TRUNCATING TABLE : silver.erp_cust_az12';
			TRUNCATE TABLE silver.erp_cust_az12;
			PRINT '<< INSERT INTO : silver.erp_cust_az12';
			Insert into silver.erp_cust_az12 
			(
			CID,
			BDATE,
			GEN
			)


			select
			CASE 
			 when CID like 'NAS%' then substring(CID, 4,len(CID))
			 else CID
			END as CID,
			CASE
			  when BDATE > Getdate() then NULL
			  else BDATE
			END as BDATE,
			CASE
			 when GEN IN ( 'F', 'Female') then 'Female'
			 when GEN IN ( 'M', 'Male') then 'Male'
			 else 'n/a'
			End as GEN
			from bronze.erp_cust_az12

			SET @end_time = GETDATE();
			PRINT '<<LOAD DURATION:' + CAST(DATEDIFF(second,@start_time, @end_time) as VARCHAR) + 'seconds';
			--------------------------------------------------------------------------------

			SET @start_time = GETDATE();

			PRINT '<< TRUNCATING TABLE : silver.erp_loc_a101';
			TRUNCATE TABLE silver.erp_loc_a101;
			PRINT '<< INSERT INTO : silver.erp_loc_a101';

			Insert into silver.erp_loc_a101
			(
			CID,
			CNTRY
			)

			Select
			Replace(CID, '-', '') as CID,
			CASE 
			 When trim(CNTRY) = 'DE' then 'Germany'
			 when trim(CNTRY) IN ('US', 'USA') then 'United States'
			 when trim(CNTRY) is NULL or CNTRY = '' then 'n/a'
			 else trim(CNTRY)

			END as CNTRY

			from bronze.erp_loc_a101

			SET @end_time = GETDATE();
			PRINT '<<LOAD DURATION:' + CAST(DATEDIFF(second,@start_time, @end_time) as VARCHAR) + 'seconds';
			------------------------------------------------------------------------------------------

			SET @start_time = GETDATE();

			PRINT '<< TRUNCATING TABLE : silver.erp_px_cat_g1v2';
			TRUNCATE TABLE silver.erp_px_cat_g1v2;
			PRINT '<< INSERT INTO : silver.erp_px_cat_g1v2';


			Insert into silver.erp_px_cat_g1v2
			(
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
			)

			Select
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
			from bronze.erp_px_cat_g1v2

			SET @end_time = GETDATE();
			PRINT '<<LOAD DURATION:' + CAST(DATEDIFF(second,@start_time, @end_time) as VARCHAR) + 'seconds';
			PRINT '<<---------------------------';

			SET @batch_end_time = GETDATE();
			PRINT '=========================================================';
			PRINT 'LOADING SILVER LAYER IS COMPLETED';
			PRINT '<<TOTAL LOAD DURATION:' +CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) as VARCHAR) + 'seconds';
			PRINT '==========================================================;'

			END TRY
		BEGIN CATCH

			PRINT '=================================================';
			PRINT 'ERROR occurred during loading Silver Layer';
			PRINT 'ERROR MESSAGE:' +ERROR_MESSAGE();
			PRINT 'ERROR MESSAGE:' + CAST(ERROR_STATE() AS NVARCHAR);
			PRINT 'ERROR MESSAGE:' + CAST(ERROR_NUMBER() AS NVARCHAR);
			PRINT 'ERROR MESSAGE:' + ERROR_LINE();
			PRINT '========================================================='


		END CATCH

END
