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
Alter FUNCTION OverdueManipulationRecord(@LoanNo Varchar(13), @Mode Varchar(5))
RETURNS 
@Table TABLE ([Check] Bit, InstlNo Int, SdlType Varchar(30), DueDate Datetime, Amount Money, ScheduleId Varchar(11))
With Encryption
AS
BEGIN
	If @Mode = 'Clear'
		Begin
		Insert into @Table([Check], InstlNo, SdlType, DueDate, Amount, ScheduleId)
		Select 0, A.InstlNo, C.Purpose, B.DueDate, B.InterestPart + B.PrincipalPart Amount, A.ScheduleId
		From tbl_ChequeSchedule A join tbl_PaymentSchedule B on A.ScheduleId = B.ScheduleId
								  join dmn_ChequePurpose C on A.Purpose = C.Code
		Where B.SdlStatus = 4 And A.LoanNo = @LoanNo;
		End
	Else If @Mode = 'Add'
		Begin
		Insert into @Table([Check], InstlNo, SdlType, DueDate, Amount, ScheduleId)
		Select 0, A.InstlNo, C.Purpose, B.DueDate, B.InterestPart + B.PrincipalPart Amount, A.ScheduleId
		From tbl_ChequeSchedule A join tbl_PaymentSchedule B on A.ScheduleId = B.ScheduleId
								  join dmn_ChequePurpose C on A.Purpose = C.Code
		Where B.SdlStatus = 3 And A.LoanNo = @LoanNo;
		End

	RETURN 
END
GO