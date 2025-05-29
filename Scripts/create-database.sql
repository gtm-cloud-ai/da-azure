IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'saasdb')
  BEGIN
    CREATE DATABASE [DataBase]
  END
GO
USE [DataBase]
GO
