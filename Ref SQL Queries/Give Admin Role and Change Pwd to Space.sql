--Run this script to create the user with password as Space [ ] and application admin role.
DECLARE @user_name VARCHAR(200) = 'runaj', --TO DO: Changes user name
		@email_id VARCHAR(200) = 'rkhatiwada@pioneersolutionsglobal.com', --TO DO: Changes user email
		@first_name VARCHAR(200) = 'Runaj',
		@last_name VARCHAR(200) = 'Khatiwada'

BEGIN TRY
	EXEC ('DROP USER [' + @user_name + ']') 	
END TRY
BEGIN CATCH
	PRINT 'User not present in Database'
END CATCH

BEGIN TRY
	EXEC ('DROP LOGIN [' + @user_name + ']') 	
END TRY
BEGIN CATCH
	PRINT 'Login not present in Database'
END CATCH


DELETE b
FROM application_ui_filter a 
INNER JOIN application_ui_filter_details b ON a.application_ui_filter_id = b.application_ui_filter_id 
WHERE user_login_id = @user_name
	
DELETE FROM application_ui_filter WHERE user_login_id = @user_name
DELETE FROM application_users WHERE user_login_id = @user_name	

EXEC [spa_application_users]  @expire_date='11/26/2019',@pwd_raw='WfP8pzBP',@user_db_pwd='Admin2929',@user_pwd='ruJq5urgIB7Mc',@theme_value_id='',@lock_account='n',
							  @user_active='y',@user_fax_tel='',@user_main_tel='',@user_mobile_tel='',@user_zipcode='',@state_value_id='',@city_value_id='',@user_address2='',
							  @user_address1='',@user_title='',@user_address3='',@entity_id='',@menu_type_role_id='-100',@region_id='1',@timezone_id='23',
							  @user_l_name=@last_name,@user_m_name='',@user_f_name=@first_name,@user_emal_add=@email_id,@user_login_id=@user_name,@flag='i'

UPDATE application_users 
SET user_pwd = 'ruPedGrVqikY6', --Decoded password ' ' [Space]
	expire_date = '2025-12-03 00:00:00.000',
	temp_pwd= 'n',
	create_user = 'farrms_admin'
WHERE user_login_id = @user_name

IF NOT EXISTS (SELECT 1 FROM application_role_user WHERE role_id = 103 AND user_login_id = @user_name)
BEGIN
	INSERT INTO application_role_user (role_id, user_login_id, user_type)
	SELECT 103 role_id, @user_name, NULL
END
GO