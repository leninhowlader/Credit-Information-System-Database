-- ================================================
-- Template generated from Template Explorer using:
-- Create Multi-Statement Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

Alter Function LoanChequeList(@LoanNo Varchar(13))
Returns @ChequeList Table(
					ChequeId Varchar(11),
					[Type] Int,
					ChequeNo Varchar(30),
					Bank Varchar(50),
					Branch Varchar(50),
					BankAccNumber Varchar(30),
					ChqDate Datetime,
					Amount Money,
					ChqStatus Int,
					ReceivedBy Varchar(15),
					ReceiveDate Datetime,
					ScheduleId Varchar(200)
					)
With Encryption
AS
BEGIN
	Declare @ChqList Table(ndx Int, ChequeId Varchar(11));
	Insert Into @ChqList(ndx, chequeId)
	Select row_number() over (order by ChequeId), ChequeId From tbl_Cheque Where LoanNo = @LoanNo;
	Declare @SidList table (ndx Int, ScheduleId Varchar(11));

	Declare @ChequeSchedule Table(ChequeId Varchar(11), ScheduleId Varchar(11));
	Insert into @ChequeSchedule(ChequeId, ScheduleId)
	Select ChequeId, ScheduleId 
	From tbl_ChequeSchedule 
	Where ChequeId In (Select ChequeId From @ChqList);

	Declare @SidTextList Table (ChequeId Varchar(11), SidText Varchar(200));

	Declare @ChequeId Varchar(11), @ScheduleId Varchar(11), @sidText Varchar(200), @SidTextLength Int,
			@ndx Int, @ndx1 Int;
	
	Set @sidText = '';
	Set @ndx = 1;
	Set @ChequeId = (Select ChequeId From @ChqList Where ndx = @ndx);
	While @ChequeId Is Not Null
		Begin
		Insert into @SidList(ndx, ScheduleId)
		Select row_number() over (order by ScheduleId), ScheduleId From @ChequeSchedule 
		Where ChequeId = @ChequeId;
		
		Set @ndx1 = 1
		Set @ScheduleId = (Select ScheduleId From @SidList Where ndx = @ndx1);
		While @ScheduleId Is Not Null
			Begin
			Set @sidText += @ScheduleId + ',';
			Set @ndx1 += 1;
			Set @ScheduleId = (Select ScheduleId From @SidList Where ndx = @ndx1);
			End
		
		Set @SidTextLength = Len(@SidText);
		If @SidTextLength < 1 Set @SidTextLength = 1;
		
		Insert into @SidTextList(ChequeId, SidText)
		Values (@ChequeId, IsNull(Left(@sidText, @SidTextLength-1),''));
					
		Delete From @SidList;
		Set @sidText = '';
		Set @ndx += 1;
		Set @ChequeId = (Select ChequeId From @ChqList Where ndx = @ndx);
		End

	Insert Into @ChequeList(ChequeId, [Type], ChequeNo, Bank, Branch, BankAccNumber, ChqDate, Amount, 
							ChqStatus, ReceivedBy, ReceiveDate, ScheduleId)
	Select A.ChequeId, IsNull(A.[Type],0), IsNull(A.ChequeNo,''), IsNull(A.Bank,''), IsNull(A.Branch,''),
		   IsNull(A.BankAccNumber,''), IsNull(A.ChqDate,'01/01/1900'), IsNull(A.Amount,0),
		   IsNull(A.ChqStatus,1), IsNull(A.ReceivedBy,''), IsNull(A.ReceiveDate,'01/01/2012'), IsNull(B.SidText,'')
	From tbl_Cheque A join @SidTextList B on A.ChequeId = B.ChequeId;
	
	RETURN 
END
GO

-- Select * from dbo.LoanChequeList('4100');