
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
alter FUNCTION PaymentScheduleList(@LoanNo Varchar(13))
RETURNS @Table TABLE (SerialNo Int, 
					  InstlNo Int, 
					  Purpose Int,
					  DueDate Datetime, 
					  PrincipalPart Money,
					  InterestPart Money, 
					  Outstanding Money, 
					  [Status] Varchar(20),
					  ScheduleId Varchar(11),
					  ChequeId Varchar(11))
WITH ENCRYPTION
AS
BEGIN
	Declare @DisburseAmount Money, @OpeningOutstanding Money, @SerialNumber int, @LowerDateLimit Datetime,
			@UpperDateLimit Datetime, @AdjAmount Money, @AdjType Int, @Counter Int,
			@Outstanding Money, @PrincipalAmount Money;
	
	Set @DisburseAmount = (Select IsNull(Sum(Amount),0) From tbl_Disbursement Where LoanNo = @LoanNo);
	Set @OpeningOutstanding = (Select IsNull(Sum(Amount),0) From tbl_Payment Where LoanNo = @LoanNo And [Type] = 4);
	
	Declare @Adjustment Table(SerialNo Int, [Type] Int, PaymentDate Datetime, Amount Money);
	
	Insert into @Adjustment(SerialNo, [Type], PaymentDate, Amount)
	Select row_number() over (order by [Date] asc), [Type], [Date], Amount 
	From (Select [Type], [Date], Sum(Amount) Amount From tbl_Payment 
	Where LoanNo = @LoanNo and [Type] in (2,3)
	Group By [Type], [Date]) A;
	
	Declare @ndx Int;
	
	Set @SerialNumber = (Select Count(*) From @Adjustment);
	Set @Counter = 0;
	Set @ndx = 1;
	
	Set @LowerDateLimit = '06/01/1999';
	While @ndx <= @SerialNumber
		Begin
		Set @UpperDateLimit = (Select PaymentDate From @Adjustment Where SerialNo = @ndx);
		Set @AdjAmount = (Select Amount From @Adjustment Where SerialNo = @ndx);
		Set @AdjType = (Select [Type] From @Adjustment Where SerialNo = @ndx);
		
		Insert into @Table(SerialNo, InstlNo, Purpose, DueDate, PrincipalPart, InterestPart, [Status], ScheduleId, ChequeId)
		Select @Counter + row_number() over (order by B.DueDate) SerialNo, A.InstlNo, A.Purpose, B.DueDate, B.PrincipalPart, 
				B.InterestPart, B.SdlStatus, B.ScheduleId, IsNull(A.ChequeId,'')
		From tbl_ChequeSchedule A join tbl_PaymentSchedule B on A.ScheduleId = B.ScheduleId
		Where A.LoanNo = @LoanNo And (B.DueDate Between @LowerDateLimit And Dateadd(D, -1, @UpperDateLimit)) And A.Purpose = 1;
		
		
		Set @Counter = (Select Count(*) From @Table) + 1;
		--If @AdjType = 2 Set @AdjPurpose = 8;
		--Else If @AdjType = 3 Set @AdjPurpose = 7;
		
		Insert into @Table(SerialNo, InstlNo, Purpose, DueDate, PrincipalPart, InterestPart, [Status], ScheduleId, ChequeId)
		Values(@Counter, 0, @AdjType, @UpperDateLimit, @AdjAmount, 0, 3, '', '');
		
		Set @LowerDateLimit = @UpperDateLimit;
		
		Set @ndx += 1;
		End
		
		--Set @Counter = (Select Count(*) From @Table);
		
		Insert into @Table(SerialNo, InstlNo, Purpose, DueDate, PrincipalPart, InterestPart, [Status], ScheduleId, ChequeId)
		Select @Counter + row_number() over (order by B.DueDate) SerialNo, A.InstlNo, A.Purpose, B.DueDate, B.PrincipalPart, 
				B.InterestPart, B.SdlStatus, B.ScheduleId, IsNull(A.ChequeId,'')
		From tbl_ChequeSchedule A join tbl_PaymentSchedule B on A.ScheduleId = B.ScheduleId
		Where A.LoanNo = @LoanNo And (B.DueDate > @LowerDateLimit) And A.Purpose = 1;

	Set @Outstanding = @DisburseAmount - @OpeningOutstanding;
	
	Set @SerialNumber = 1;
	Set @Counter = (Select Count(*) From @Table);
	
	While @SerialNumber <= @Counter 
		Begin
		Set @PrincipalAmount = (Select PrincipalPart From @Table Where SerialNo = @SerialNumber);
		Set @Outstanding = @Outstanding - @PrincipalAmount;
		
		Update @Table Set Outstanding = @Outstanding Where SerialNo = @SerialNumber;
		
		Set @SerialNumber = @SerialNumber + 1;
		End
	RETURN 
END
GO

-- Select * From dbo.PaymentScheduleList('4000')