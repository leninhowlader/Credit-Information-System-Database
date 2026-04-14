
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE OverdueManipulation
				@LoanNo Varchar(13),
				@ListOfSchedule VarcharList ReadOnly,
				@Mode Varchar(10),
				@Cause Varchar(20),
				@Date Datetime,
				@UserId Varchar(15)
AS
BEGIN
	Set nocount on;
	Declare @return int;

	Set @return = 0;
	
	Set xact_abort on;
	If @Mode = 'Clear'
		Begin
		Begin Tran t1
		Update tbl_PaymentSchedule Set SdlStatus = 3
		Where ScheduleId in (Select Value From @ListOfSchedule);
		
		Insert into history_OverdueManipulation(LoanNo, ScheduleId, Mode, Cause, [Date], EntryBy, EntryDate)
		Select @LoanNo, A.Value ScheduleId, @Mode, @Cause, @Date, @UserId, sysdatetime()
		From @ListOfSchedule A;
		
		Set @return = 1;
		Commit Tran t1
		End
	Else If @Mode = 'Add'
		Begin
		Begin Tran t2
		Update tbl_PaymentSchedule Set SdlStatus = 4
		Where ScheduleId in (Select Value From @ListOfSchedule);
		
		Insert into history_OverdueManipulation(LoanNo, ScheduleId, Mode, Cause, [Date], EntryBy, EntryDate)
		Select @LoanNo, A.Value ScheduleId, @Mode, @Cause, @Date, @UserId, sysdatetime()
		From @ListOfSchedule A;
		
		Set @return = 1;
		Commit Tran t2
		End	
	Set xact_abort off;

	Select @return;	
END
GO
