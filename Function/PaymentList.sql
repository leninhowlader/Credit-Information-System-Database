SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create FUNCTION PaymentList (@LoanNo Varchar(13))
RETURNS TABLE With Encryption
AS
RETURN 
(
Select A.PaymentSummaryId 'Receipt Id', A.PaymentDate 'Receive Date', Sum(B.Amount) Amount, C.UserName 'Received By'
From tbl_CashPaymentSummary A Join tbl_CashPayment B on A.PaymentSummaryId = B.SummaryId 
							  Left Join tbl_User C on A.ReceivedBy = C.UserId 
Where A.LoanNo = @LoanNo
Group By A.PaymentSummaryId, A.PaymentDate, C.UserName
)
GO


-- select * from paymentList('4100')