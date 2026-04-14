Create Procedure EditSingleCheque
				 @ChequeId Varchar(11),
				 @ChequeDate Datetime,
				 @Amount Money,
				 @ChqNumber Varchar(30),
				 @Bank Varchar(50),
				 @Branch Varchar(50),
				 @ACNumber Varchar(30),
				 @SessionId Int,
				 @UpdateBy Varchar(15)
-- 313
With Encryption
As
Begin
Set nocount on;
Declare @Return Int, @Detail Varchar(200);
Set @Return = 0;

Set @Detail = 'Cheque having id ' + @ChequeId + ' has been updated.';

Begin Tran t1
	Update tbl_Cheque Set ChqDate = @ChequeDate,
						  Amount = @Amount,
						  ChequeNo = @ChqNumber,
						  Bank = @Bank,
						  Branch = @Branch,
						  BankAccNumber = @ACNumber 
	Where ChequeId = @ChequeId;
	
	Insert into tbl_UserLog(SessionId, UserId, TaskId, AccomplishDatetime, Detail)
	Values(@SessionId, @UpdateBy, 313, sysdatetime(), @Detail);
	
	Set @Return = 1;
Commit Tran t1

Select @Return;
End