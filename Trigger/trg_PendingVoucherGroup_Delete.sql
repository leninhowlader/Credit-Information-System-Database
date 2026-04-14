SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Alter TRIGGER trg_PendingVoucherGroup_Delete 
   ON  PendingVoucherGroup
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	Declare @GroupId Int;
	Set @GroupId = (Select GroupId From Deleted);
	
	Declare @RefList Table(VchrRef Numeric(5,0));
	Insert into @RefList (VchrRef)
	Select VchrRef From Deleted
	Union
	Select VchrRef From PendingVoucherGroup
	Where GroupId = @GroupId;
	
	If Exists(Select VchrRef From PendingVoucher Where VchrRef in (Select VchrRef From @RefList))
		Begin
		Set Xact_abort On;
		Begin Tran DelRecord
		Delete From PendingVoucherDetail 
		Where VchrRef in (Select VchrRef From @RefList);
		
		Delete From PendingVoucher
		Where VchrRef in (Select VchrRef From @RefList);
		Commit Tran DelRecord
		Set Xact_abort Off;
		
		Delete From PendingVoucherGroup
		Where GroupId = (Select GroupId From Deleted);
		End
END
GO
