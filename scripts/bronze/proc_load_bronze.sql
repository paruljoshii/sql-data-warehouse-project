/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

Exec bronze.load_bronze

Create or Alter Procedure bronze.load_bronze AS
BEGIN
 DECLARE @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;
BEGIN TRY
    SET @batch_start_time = Getdate();
	PRINT '==============================================================================================';
	PRINT 'LOADING BRONZE LAYER';
	PRINT '==============================================================================================';

	PRINT '----------------------------------------------------------------------------------------------';
	PRINT 'LOADING CRM TABLES';
	PRINT '----------------------------------------------------------------------------------------------';
	
	SET @start_time = Getdate();
	PRINT '>> TRUNCATING TABLE: bronze.crm_cust_info';
	Truncate table bronze.crm_cust_info

	PRINT 'INSERTING DATA INTO : bronze.crm_cust_info';
	Bulk Insert bronze.crm_cust_info
	from 'C:\Users\DELL\Downloads\sql-ultimate-course-main\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	with
	(
	 Firstrow = 2,
	 Fieldterminator = ',',
	 Tablock
	);

	SET @end_time = Getdate();
	PRINT '>> Load duration : ' + CAST(Datediff(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';


	SET @start_time = Getdate();

	PRINT '>> TRUNCATING TABLE: bronze.crm_prd_info';
	Truncate table bronze.crm_prd_info

	PRINT 'INSERTING DATA INTO : bronze.crm_prd_info';
	Bulk Insert bronze.crm_prd_info
	from 'C:\Users\DELL\Downloads\sql-ultimate-course-main\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	with
	(
	 Firstrow = 2,
	 Fieldterminator = ',',
	 Tablock
	);
	SET @end_time = Getdate();
	PRINT '>> Load duration : ' + CAST(Datediff(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';


	SET @start_time = Getdate();
    PRINT '>> TRUNCATING TABLE: bronze.crm_sales_details';
	Truncate table bronze.crm_sales_details

	PRINT 'INSERTING DATA INTO : bronze.crm_sales_details';

	Bulk Insert bronze.crm_sales_details
	from 'C:\Users\DELL\Downloads\sql-ultimate-course-main\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	with
	(
	 Firstrow = 2,
	 Fieldterminator = ',',
	 Tablock
	);
	SET @end_time = Getdate();
	PRINT '>> Load duration : ' + CAST(Datediff(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';


	PRINT '----------------------------------------------------------------------------------------------';
	PRINT 'LOADING ERP TABLES';
	PRINT '----------------------------------------------------------------------------------------------';
	
	SET @start_time = Getdate();

	PRINT '>> TRUNCATING TABLE: bronze.erp_cust_az12';
	Truncate table bronze.erp_cust_az12

	PRINT 'INSERTING DATA INTO : bronze.erp_cust_az12';
	Bulk Insert bronze.erp_cust_az12
	from 'C:\Users\DELL\Downloads\sql-ultimate-course-main\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
	with
	(
	 Firstrow = 2,
	 Fieldterminator = ',',
	 Tablock
	);
	SET @end_time = Getdate();
	PRINT '>> Load duration : ' + CAST(Datediff(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';




	SET @start_time = Getdate();
	PRINT '>> TRUNCATING TABLE: bronze.erp_loc_a101';
	Truncate table bronze.erp_loc_a101

	PRINT 'INSERTING DATA INTO : bronze.erp_loc_a101';
	Bulk Insert bronze.erp_loc_a101
	from 'C:\Users\DELL\Downloads\sql-ultimate-course-main\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
	with
	(
	 Firstrow = 2,
	 Fieldterminator = ',',
	 Tablock
	);
	SET @end_time = Getdate();
	PRINT '>> Load duration : ' + CAST(Datediff(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';



	SET @start_time = Getdate();
    PRINT '>> TRUNCATING TABLE: bronze.erp_px_cat_g1v2';
	Truncate table bronze.erp_px_cat_g1v2

	PRINT 'INSERTING DATA INTO : bronze.px_cat_g1v2';
	Bulk Insert bronze.erp_px_cat_g1v2
	from 'C:\Users\DELL\Downloads\sql-ultimate-course-main\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
	with
	(
	 Firstrow = 2,
	 Fieldterminator = ',',
	 Tablock
	);

	SET @end_time = Getdate();
	PRINT '>> Load duration : ' + CAST(Datediff(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';

	
	Set @batch_end_time = Getdate();
	PRINT '==============================================================';
	PRINT 'LOADING BRONZE LAYER IS COMPLETED';
	PRINT 'TOTAL LOAD DURATION:' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR)+ 'seconds';
END TRY

	BEGIN CATCH
	PRINT '=================================================================================================';
	PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER ';
	PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
	PRINT 'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
	PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
	PRINT '=================================================================================================';

END CATCH
END
