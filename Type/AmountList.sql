USE [FIMISDB]
GO

/****** Object:  UserDefinedTableType [dbo].[AmountList]    Script Date: 03/25/2012 20:39:28 ******/
CREATE TYPE [dbo].[AmountList] AS TABLE(
	[LoanNo] [varchar](13) NOT NULL,
	[Amount] [varchar](30) NULL,
	PRIMARY KEY CLUSTERED 
(
	[LoanNo] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO

