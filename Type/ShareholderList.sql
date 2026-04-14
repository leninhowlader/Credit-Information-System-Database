-- ================================
-- Create User-defined Table Type
-- ================================
USE FIMISDB 
GO

-- Create the data type
CREATE TYPE ListOfShareholder AS TABLE 
(
	Id Varchar(12),
	IsCompany bit,
	[Role] Int,
	PRIMARY KEY (Id)
)
GO
