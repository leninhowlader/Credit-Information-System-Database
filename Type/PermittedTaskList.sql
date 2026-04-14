USE [FIMISDB]
GO

/****** Object:  UserDefinedTableType [dbo].[PermittedTaskList]    Script Date: 03/27/2012 13:59:56 ******/
CREATE TYPE [dbo].[PermittedTaskList] AS TABLE(
	[TaskId] [int] NOT NULL,
	[CanForward] [bit] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[TaskId] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO


