exec load_stg_dim_tiempo;

exec load_stg_dim_geografia;

exec load_stg_dim_products;

exec load_stg_dim_geografia;

exec load_stg_dim_shippers;

exec load_stg_dim_customers;

exec load_stg_dim_employees;

exec load_stg_fact_orders('19950101','30000101');

commit;