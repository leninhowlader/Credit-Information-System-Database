
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
alter TRIGGER trg_PaymentSchedule_Update
   ON  tbl_PaymentSchedule With Encryption
   AFTER UPDATE
   
AS 
BEGIN
	Set nocount on;
	If Exists(Select * From Inserted Where SdlStatus = 6)
		Begin
		Declare @List Table (ScheduleId Varchar(11));
		Insert into @List(ScheduleId)
		Select A.ScheduleId
		From Inserted A join tbl_ChequeSchedule B on A.ScheduleId = B.ScheduleId
		Where A.SdlStatus = 6 And B.ChequeId is Null;
		
		Delete From tbl_ChequeSchedule 
		Where ScheduleId in (Select ScheduleId From @List);
		
		Delete From tbl_PaymentSchedule 
		Where ScheduleId in (Select ScheduleId From @List);
		End
	
	If Exists(Select * From Inserted Where SdlStatus = 4) Or Exists(Select * From Deleted Where SdlStatus = 4)
		Begin
		Declare @ListOfSchedule Table(LoanNo Varchar(13), ScheduleId Varchar(11), NewStatus Int, OldStatus Int);
		Insert into @ListOfSchedule(LoanNo, ScheduleId, NewStatus, OldStatus)
		Select C.LoanNo, A.ScheduleId, A.SdlStatus, B.SdlStatus
		From Inserted A join Deleted B on A.ScheduleId = B.ScheduleId
						join tbl_ChequeSchedule C on A.ScheduleId = C.ScheduleId
		Where (A.SdlStatus = 4 Or B.SdlStatus = 4);
		
		Declare @OverdueList Table(LoanNo Varchar(13), OverdueNumber Int);
		Declare @OverdueType Table(ScheduleId Varchar(11), OverdueType Int);
		Declare @OverdueLimit Table(LoanNo Varchar(13), OverdueLimit Int);
		
		Insert into @OverdueLimit(LoanNo, OverdueLimit)
		Select LoanNo, Case When Left(ProductId,3) in ('HML', 'CML', 'PML') Then 8 
							Else Case When LoanTerm > 60 Then 5 Else 2 End
					   End OverdueLimit
		From tbl_Loan 
		Where LoanNo in (Select Distinct LoanNo From @ListOfSchedule);
		
		Declare @MultipleSchedule Table(LoanNo Varchar(13), ScheduleId Varchar(11), NewStatus Int, OldStatus Int);
		
		If Exists(Select LoanNo From @ListOfSchedule Group By LoanNo Having Count(*) > 1)
			Begin
			Insert Into @Multipleschedule(LoanNo, ScheduleId, NewStatus, OldStatus)
			Select LoanNo, ScheduleId, NewStatus, OldStatus
			From @ListOfSchedule
			Where LoanNo in (Select LoanNo From @ListOfSchedule Group By LoanNo Having Count(*) > 1);
			
			Delete From @ListOfSchedule Where LoanNo in (Select LoanNo From @MultipleSchedule);
			End
		
		If Exists(Select * From @ListOfSchedule) 
			Begin
			Insert into @OverdueList(LoanNo, OverdueNumber)
			Select A.LoanNo, IsNull(Count(*),0) OverdueNumber
			From tbl_ChequeSchedule A join tbl_PaymentSchedule B on A.ScheduleId = B.ScheduleId
			Where B.SdlStatus = 4 And A.LoanNo in (Select Distinct LoanNo From @ListOfSchedule)
			Group By A.LoanNo;
			End
			
		If Exists(Select * From @ListOfSchedule Where NewStatus = 4)
			Begin
			Insert Into @OverdueType(ScheduleId, OverdueType)
			Select A.ScheduleId, Case When (A.ChequeId Is Null Or A.CashPaymentId Is Null) Then 2 Else 1 End OverdueType
			From tbl_ChequeSchedule A join @ListOfSchedule B on A.ScheduleId = B.ScheduleId
			Where B.NewStatus = 4;
			
			Insert into tbl_OverdueHistory(ScheduleId, [Date], isPaid, OverdueType, isSuspended)
			Select A.ScheduleId, sysdatetime(), 0, B.OverdueType, 
				   Case When C.OverdueNumber + 1 > D.OverdueLimit Then 1 Else 0 End isSuspended
			From @ListOfSchedule A join @OverdueType B on A.ScheduleId = B.ScheduleId
								   Left join @OverdueList C on A.LoanNo = C.LoanNo
								   Left join @OverdueLimit D on C.LoanNo = D.LoanNo
			Where A.NewStatus = 4;
			
			Delete From @OverdueType;
			End

		If Exists(Select * From @ListOfSchedule Where OldStatus = 4 and NewStatus <> 4)
			Begin
			Insert into tbl_OverdueHistory(ScheduleId, [Date], isPaid, isSuspended)
			Select A.ScheduleId, sysdatetime(), 1,  
				   Case When B.OverdueNumber - 1 >= C.OverdueLimit Then 1 Else 0 End isSuspended
			From @ListOfSchedule A Left join @OverdueList B on A.LoanNo = B.LoanNo
								   Left join @OverdueLimit C on C.LoanNo = B.LoanNo
			Where A.OldStatus = 4;
			End
		
		If Exists(Select * From @MultipleSchedule)
			Begin
			Declare @ListOfLoan Table (SlNo Int, LoanNo Varchar(13));
			Insert Into @ListOfLoan(SlNo, LoanNo)
			Select row_number() over (order by A.LoanNo) SlNo, A.LoanNo
			From (Select Distinct LoanNo From @MultipleSchedule) A;
			
			Delete From @OverdueLimit;
			Insert into @OverdueLimit(LoanNo, OverdueLimit)
			Select LoanNo, Case When Left(ProductId,3) in ('HML', 'CML', 'PML') Then 8 
								Else Case When LoanTerm > 60 Then 5 Else 2 End
						   End OverdueLimit
			From tbl_Loan 
			Where LoanNo in (Select Distinct LoanNo From @MultipleSchedule);
		
			Declare @ndxLoan Int, @ndxLoanLimit Int;
			
			Set @ndxLoanLimit = (Select Max(SlNo) From @ListOfLoan);
			Set @ndxLoan = 1
			While @ndxLoan <= @ndxLoanLimit
				Begin
				Declare @LoanNo Varchar(13);
				Set @LoanNo = (Select LoanNo From @ListOfLoan Where SlNo = @ndxLoan);
				
				Declare @SdlList Table(SlNo Int, ScheduleId Varchar(11));
				Insert Into @SdlList(SlNo, ScheduleId)
				Select row_number() over (order by ScheduleId) SlNo, ScheduleId
				From @MultipleSchedule Where LoanNo = @LoanNo;
				
				Insert into @OverdueType(ScheduleId, OverdueType)
				Select ScheduleId, Case When ChequeId Is Null Or CashPaymentId Is Null Then 2 
										Else 0 End OverdueType
				From tbl_ChequeSchedule Where LoanNo = @LoanNo;
				
				Declare @LoanOverdueLimit int;
				Set @LoanOverdueLimit = (Select OverdueLimit From @OverdueLimit Where LoanNo = @LoanNo);
				
				Declare @ndxSdl int, @ndxSdlLimit Int;
				Set @ndxSdl = 1;
				Set @ndxSdlLimit = (Select Count(*) From @SdlList);
				
				While @ndxSdl <= @ndxSdlLimit
					Begin
					Declare @ScheduleId Varchar(11);
					Set @ScheduleId = (Select ScheduleId From @SdlList Where SlNo = @ndxSdl);
					
					Declare @SdlNewStatus Int, @SdlOldStatus Int;
					Set @SdlNewStatus = (Select NewStatus From @MultipleSchedule Where ScheduleId = @ScheduleId)
					
					Declare @OverdueNumber Int;
					Set @OverdueNumber = (Select Count(*) From tbl_PaymentSchedule 
										  Where ScheduleId In (Select ScheduleId From @OverdueType)
												And SdlStatus = 4);
					Declare @SdlOverdueType Int;
					Set @SdlOverdueType = (Select OverdueType From @OverdueType Where ScheduleId = @ScheduleId);
					If @SdlNewStatus = 4
						Begin
						Insert into tbl_OverdueHistory(ScheduleId, [Date], isPaid, OverdueType, isSuspended)
						Values (@ScheduleId, sysdatetime(), 0, @SdlOverdueType, 
								Case When @OverdueNumber + 1 > @LoanOverdueLimit Then 1 Else 0 End);
						End
					Else
						Begin
						Set @SdlNewStatus = (Select NewStatus From @MultipleSchedule Where ScheduleId = @ScheduleId);
						If @SdlNewStatus = 3 Or @SdlNewStatus = 5
							Begin
							Declare @Suspended Bit;
							If @OverdueNumber - 1 >= @LoanOverdueLimit Set @Suspended = 1;
							Else Set @Suspended = 0;
							
							Insert into tbl_OverdueHistory(ScheduleId, [Date], isPaid, isSuspended)
							Values(@ScheduleId, sysdatetime(), 1, @Suspended);
							End
						End
					
					Set @ndxSdl = @ndxSdl + 1;
					End
				Delete From @SdlList;
				Delete From @OverdueType;
				Set @ndxLoan = @ndxLoan + 1;
				End
			End
		End
END
GO
