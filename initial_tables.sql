create table public.c (
	client_id int4 not null,
	gender varchar(1) not null,
	age int2 not null,
	constraint c_pkey primary key (client_id)
);

create table public.m (
	merchant_id int4 not null,
	latitude float4 not null,
	longitude float4 not null,
	mcc_id int2 not null,
	constraint m_pkey primary key (merchant_id)
);

create table public.t (
	merchant_id int4 not null,
	client_id int4 not null,
	transaction_dttm timestamp not null,
	transaction_amt float4 not null,
	constraint t_client_id_fkey foreign key (client_id) references public.c(client_id),
	constraint t_merchant_id_fkey foreign key (merchant_id) references public.m(merchant_id)
);

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


