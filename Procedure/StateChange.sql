Alter Procedure StateChange
					@LoanNo Varchar(13),
					@OldState Int,
					@NewState Int,
					@EffectDate Datetime,
					@ChangedBy Varchar(15)
With Encryption
As 
Begin
	Set NoCount on;
	Declare @Return Int;

	Set @Return = 0;
	Set Xact_Abort On;
	Begin Tran t1
		Update tbl_Loan Set LoanStatus = @NewState Where LoanNo = @LoanNo;

		Insert Into history_StateChange (LoanNo, [EffectDate], OldState, NewState, ChangeBy, EntryDate)
		Values (@LoanNo, @EffectDate, @OldState, @NewState, @ChangedBy, Sysdatetime());
		
		If @NewState = 8 --(Select StatusCode From dmn_LoanStatus Where StatusName = 'Legal Action')
			Begin
			Update tbl_PaymentSchedule Set SdlStatus = 7 -- (Select Code From dmn_ScheduleStatus Where [Status] = 'Stopped')
			Where ScheduleId in (Select ScheduleId From tbl_ChequeSchedule Where LoanNo = @LoanNo)
				  And SdlStatus = 1; -- (Select Code From dmn_ScheduleStatus Where [Status] = 'Not Due')
			
			
			End
		/*
		Else If (@NewState = 10   -- (Select StatusCode From dmn_LoanStatus Where StatusName = 'Write Off')
				Or @NewState = 7) -- (Select StatusCode From dmn_LoanStatus Where StatusName = 'Closed')
			Begin
			Update tbl_PaymentSchedule Set SdlStatus = 6 -- (Select Code From dmn_ScheduleStatus Where [Status] = 'Canceled')
			Where ScheduleId in (Select ScheduleId From tbl_ChequeSchedule Where LoanNo = @LoanNo)
				  And SdlStatus = 1; -- (Select Code From dmn_ScheduleStatus Where [Status] = 'Not Due')
			End
		*/
		Else If (@NewState = 2  -- (Select StatusCode From dmn_LoanStatus Where StatusName = 'EMI')
				Or @NewState = 3) -- (Select StatusCode From dmn_LoanStatus Where StatusName = 'Executed')
			Begin
			/*
			Update tbl_PaymentSchedule Set SdlStatus = 6 -- (Select Code From dmn_ScheduleStatus Where [Status] = 'Canceled')
			Where ScheduleId in (Select ScheduleId From tbl_ChequeSchedule Where LoanNo = @LoanNo)
				  And SdlStatus = 1; -- (Select Code From dmn_ScheduleStatus Where [Status] = 'Not Due')
			*/
			Update tbl_Disbursement Set IsPEMI = 0 Where LoanNo = @LoanNo And IsPEMI = 1;
			End
		
		If @OldState in (8, 10)
			Begin
			Update tbl_Loan Set EMIStartDate = Null, InstallmentSize = Null
			Where LoanNo = @LoanNo;
			End
		
		Set @Return = 1;
	Commit Tran t1
	Set Xact_Abort Off;

	Select @Return;
End