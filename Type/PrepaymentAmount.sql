USE [FIMISDB]
GO

/****** Object:  UserDefinedTableType [dbo].[PrepaymentAmount]    Script Date: 03/27/2012 14:07:25 ******/
CREATE TYPE [dbo].[PrepaymentAmount] AS TABLE(
	[GlName] [varchar](200) NOT NULL,
	[Amount] [money] NULL,
	PRIMARY KEY CLUSTERED 
(
	[GlName] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO


