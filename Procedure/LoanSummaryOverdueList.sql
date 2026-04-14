-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
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
CREATE Procedure LoanSummaryOverdueList
				@LoanNo Varchar(13)
With Encryption
AS
Begin
Set NoCount On;
Select Year(A.[Date]) [Year], A.[Type], Count(*) NoOfOverdue, Sum(B.InterestPart + B.PrincipalPart) OverdueAmount
From LoanSummaryOverdueHistory(@LoanNo) A Join tbl_PaymentSchedule B 
	on A.ScheduleId = B.ScheduleId 
Group By Year(A.[Date]), A.[Type];
End