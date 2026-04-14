SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Alter PROCEDURE AddPaymentAdjustment
					@LoanNo Varchar(13),
					@Date Datetime,
					@PaymentType Int,
					@PaymentMode Varchar(3),
					@PaymentTokenId Varchar(11),
					@Amount Money,
					@UserId Varchar(15)
With Encryption
AS
BEGIN
	SET NOCOUNT ON;
	Declare @SerialNo Int, @return int;
	Set @return = 0;
	Set @SerialNo = (Select IsNull(Max(SlNo),0) Serial From tbl_Payment Where LoanNo = @LoanNo) + 1;
	
	Set Xact_abort On;
	Begin Tran t1
    Insert into tbl_Payment(LoanNo, SlNo, [Date], [Type], Mode, PayTokenId, Amount, UserId, EntryDate)
    Values (@LoanNo, @SerialNo, @Date, @PaymentType, @PaymentMode, @PaymentTokenId, @Amount, @UserId, Sysdatetime());
    
    Set @return = 1;
    Commit Tran t1
    
    Select @return;
END
GO
