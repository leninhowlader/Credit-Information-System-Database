Alter Procedure AddCompanyShareholder
					@CompanyId Varchar(12),
					@ListOfShareholder ListOfShareholder ReadOnly
With Encryption
As
Begin
Set nocount on;
Declare @Return Int;
Set @Return = 0;

Begin Tran t1
	Merge Into tbl_Shareholder A
	Using @ListOfShareholder B
	On (A.CompanyId = @CompanyId And
		A.ShareholderId = B.Id)
	When Matched Then Update Set
		A.[Role] = B.[Role],
		A.IsCompany = B.IsCompany
	When Not Matched Then Insert (CompanyId, ShareholderId, [Role], IsCompany)
		Values(@CompanyId, B.Id, B.[Role], B.IsCompany);
		
	Delete From tbl_Shareholder 
	Where CompanyID = @CompanyId 
	And ShareholderID not in (Select Id From @ListOfShareholder);
	
	Set @Return = 1;
Commit Tran t1

Select @Return;
End