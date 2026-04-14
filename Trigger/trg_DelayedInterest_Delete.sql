SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Alter TRIGGER trg_DelayedInterest_Delete 
   ON  system_DelayedInterest With Encryption
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	Declare @Date Datetime;
	Set @Date = (Select AccountingDate From Deleted);
	Set Xact_abort On;
	Begin Tran t1
		Delete From tbl_DelayedInterest Where PostDate = @Date;
	Commit Tran t1
	Set Xact_abort Off;
END
GO
