--–еализаци€ задач по sql несЄт поверхностный характер, без рассмотрени€ и оценки работы по оптимизации, типов, хранении€, индексации и подобных вещей.
--DDL
----------------------------------------------------------------------------------------------------------
--######################################################################################################--
----------------------------------------------------------------------------------------------------------
--create table client

create table public.c (
	client_id int4 not null,
	gender varchar(1) not null,
	age int2 not null,
	constraint c_pkey primary key (client_id)
);

----------------------------------------------------------------------------------------------------------
--######################################################################################################--
----------------------------------------------------------------------------------------------------------
--create table merchant

create table public.m (
	merchant_id int4 not null,
	latitude float4 not null,
	longitude float4 not null,
	mcc_id int2 not null,
	constraint m_pkey primary key (merchant_id)
);

----------------------------------------------------------------------------------------------------------
--######################################################################################################--
----------------------------------------------------------------------------------------------------------
--create table transaction

create table public.t (
	merchant_id int4 not null,
	client_id int4 not null,
	transaction_dttm timestamp not null,
	transaction_amt float4 not null,
	constraint t_client_id_fkey foreign key (client_id) references public.c(client_id),
	constraint t_merchant_id_fkey foreign key (merchant_id) references public.m(merchant_id)
);

----------------------------------------------------------------------------------------------------------
--######################################################################################################--
----------------------------------------------------------------------------------------------------------
--create table agg

create table public.agg (
	gender varchar(1) not null,
	range varchar(30) not null,
	year int2 not null,
	month int2 not null,
	industry int2 not null,
	sum float4 not null,
	avg float4 not null,
	cnt float4 not null
);

--DML
----------------------------------------------------------------------------------------------------------
--######################################################################################################--
----------------------------------------------------------------------------------------------------------
--SQL for insert test data client

insert
	into
	public.c(client_id,
	gender,
	age)
select
	id as client_id,
	case
		when (round((random()* 10))::int % 2) = 0 then 'm'
		else 'f'
	end as gender,
	round(random()* 100) as age
from
	generate_series(1, 100) id;

----------------------------------------------------------------------------------------------------------
--######################################################################################################--
----------------------------------------------------------------------------------------------------------
--SQL for insert test data merchant

insert
	into
	public.m(merchant_id,
	latitude,
	longitude,
	mcc_id)
select
	id as merchant_id,
	round( cast((random()*(180-(-180)+ 1)+(-180)) as numeric), 5) as latitude,
	round( cast((random()*(180-(-180)+ 1)+(-180)) as numeric), 5) as longitude,
	round(random()*(9999-(1000)+ 1)+(1000)) as mcc_id
from
	generate_series(1, 100) id;

----------------------------------------------------------------------------------------------------------
--######################################################################################################--
----------------------------------------------------------------------------------------------------------
--SQL for insert test data transaction

insert
	into
	public.t(merchant_id,
	client_id,
	transaction_dttm,
	transaction_amt)
select
	round(random()*(100-(1)+ 1)+(1)) as merchant_id,
	round(random()*(100-(1)+ 1)+(1)) as client_id,
	NOW() - '3 year'::interval - '1 day'::interval * (RANDOM()::int * 100) transaction_dttm,
	round(random()*(100000-(1)+ 1)+(1)) as transaction_amt
from
	generate_series(1, 100) id;

----------------------------------------------------------------------------------------------------------
--######################################################################################################--
----------------------------------------------------------------------------------------------------------
--SQL for insert agg data 
-- стоит отметить что данна€ реализаци€ не содержит 
-- версионности, обновлени€ данных и манипул€ции дл€ поддержани€ актульных обновлЄнных агрегатов,
-- а только выполн€ет разовый insert agg данным
-- sql аgg дл€ всех комбинаций в одной таблицы звучит не очень корретно(у агрегатов разное кол-во измерений и в комбинации где их меньше будут просто пустые пол€),
-- создать такую таблицу конечно же можно, но обычно такой необходимости нет.
-- но дл€ решени€ задачи вз€ть агрегаты по всем измерени€ уже звучит логичнее - оно и реализовано.

insert
	into
	public.agg(gender,
	range,
	year,
	month,
	industry,
	sum,
	avg,
	cnt)
with tbl as (
select
	*
from
	public.t as t
join public.m as m
on
	m.merchant_id = t.merchant_id
join public.c as c
on
	c.client_id = t.client_id)
	select
		gender,
	case
		when age < 18 then '18'
		when age between 19 and 31 then 'from 19 to 31'
		else 'older  60'
	end as range,
	extract(year
from
	transaction_dttm)::int2 as year,
	extract(month
from
	transaction_dttm) as month,
	mcc_id as industry,
	sum(transaction_amt) as sum,
	round(cast(avg(transaction_amt) as numeric), 2) as avg ,
	count(*) as cnt
from
	tbl
group by
	gender,
	range,
	year,
	month,
	industry

	----------------------------------------------------------------------------------------------------------
--######################################################################################################--
----------------------------------------------------------------------------------------------------------
--SQL check agg
	
	
select sum(sum) from public.agg
where year = 2020 
	
select sum(sum) from public.agg
where year = 2020 and month = 5
	
select sum(sum) from public.agg
where gender = 'm' and year = 2020 

select sum(sum) from public.agg
where (range = 'from 19 to 31' or range = '18') and year = 2020 

	

	