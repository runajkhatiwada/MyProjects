use trmtracker_dev

/*
if object_id('trmtracker_dev..test1') is not null
	drop table trmtracker_dev.dbo.test1

create table trmtracker_dev.dbo.test1 (
	id int identity(1,1),
	name1 varchar(50)
)

if object_id('trmtracker_dev..test2') is not null
	drop table trmtracker_dev.dbo.test2

create table trmtracker_dev.dbo.test2 (
	id int identity(1,1),
	name2 varchar(50)
)

if object_id('trmtracker_dev..test3') is not null
	drop table trmtracker_dev.dbo.test3

create table trmtracker_dev.dbo.test3 (
	id int identity(1,1),
	name3 varchar(50)
)

if object_id('trmtracker_dev..error') is not null
	drop table trmtracker_dev.dbo.error

create table trmtracker_dev.dbo.error (
	id int identity(1,1),
	error varchar(50)
)
-----*/

if object_id('spa_test') is not null
    drop procedure spa_test
go

create procedure spa_test 
@flag char(1)=null,
@name1 varchar(max)=null,
@name2 varchar(max)=null,
@name3 varchar(max)=null,
@error varchar(max)=null
as

if @flag = 'a'
begin
	insert into test1 (name1)
	values (@name1)
end

if @flag = 'b'
begin
	insert into test2 (name2)
	values (@name2)
end

if @flag = 'c'
begin
	insert into test3 (name3)
	values (@name3)
end

if @flag = 'd'
begin
	insert into error (error)
	values (@error)
end
--exec trmtracker_dev.dbo.spa_test @flag='a', @name1='TEST1'
--exec trmtracker_dev.dbo.spa_test @flag='b', @name2='TEST2'
--exec trmtracker_dev.dbo.spa_test @flag='c', @name3='TEST3'


--select * from test1
--select * from test2
--select * from test3