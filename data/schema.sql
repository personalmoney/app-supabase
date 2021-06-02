/* Delete Trigger function Start */

CREATE 
OR Replace FUNCTION trigger_record_delete() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
   -- trigger logic
   IF OLD.id > 0 THEN
		 INSERT INTO deleted_records(user_id,record_id,record_type,created_time)
		 VALUES(OLD.user_id,OLD.id,TG_TABLE_NAME,now());
	END IF;

	RETURN OLD;

END;
$$;

/* Delete Trigger function End */

/* Account Types table Start */

create table account_types (
  id bigint generated by default as identity primary key,
  user_id uuid references auth.users not null,
  name text check (char_length(name) > 3) check (char_length(name) < 100) not null,
  icon text check (char_length(icon) > 3) check (char_length(icon) < 100) not null,
  created_time timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_time timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table account_types ADD CONSTRAINT account_types_unique_name UNIQUE ("name",user_id);
alter table account_types enable row level security;

create policy "Users can create account types." on account_types for
    insert with check (auth.uid() = user_id);

create policy "Users can view their own account types. " on account_types for
    select using (auth.uid() = user_id);

create policy "Users can update their own account types." on account_types for
    update using (auth.uid() = user_id);

create policy "Users can delete their own account types." on account_types for
    delete using (auth.uid() = user_id);

CREATE TRIGGER trigger_log_account_types_deletes AFTER DELETE ON account_types FOR EACH ROW EXECUTE PROCEDURE trigger_record_delete();

/* Account Types table End */

/* Accounts table Start */

create table accounts (
  id bigint generated by default as identity primary key,
  user_id uuid references auth.users not null,
  account_type_id bigint references public.account_types not null,
  name text check (char_length(name) > 3) check (char_length(name) < 100) not null,
  is_active boolean default true,
  include_in_balance boolean default true,
  exclude_from_dashboard boolean default false,
  initial_balance decimal default 0,
  minimum_balance decimal default 0,
  credit_limit decimal default 0,
  interest_rate decimal default 0,
  notes text check (char_length(name) < 500),
  payment_date timestamp with time zone default timezone('utc'::text, now()),
  created_time timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_time timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table accounts ADD CONSTRAINT accounts_unique_name UNIQUE ("name",user_id);
alter table accounts enable row level security;

create policy "Users can create accounts." on accounts for
    insert with check (auth.uid() = user_id);

create policy "Users can view their own accounts. " on accounts for
    select using (auth.uid() = user_id);

create policy "Users can update their own accounts." on accounts for
    update using (auth.uid() = user_id);

create policy "Users can delete their own accounts." on accounts for
    delete using (auth.uid() = user_id);

CREATE TRIGGER trigger_log_accounts_deletes AFTER DELETE ON accounts FOR EACH ROW EXECUTE PROCEDURE trigger_record_delete();

/* Accounts table End */


/* Tags table Start */

create table tags (
  id bigint generated by default as identity primary key,
  user_id uuid references auth.users not null,
  name text check (char_length(name) > 2) check (char_length(name) < 100) not null,
  created_time timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_time timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table tags ADD CONSTRAINT tags_unique_name UNIQUE ("name",user_id);
alter table tags enable row level security;

create policy "Users can create tags." on tags for
    insert with check (auth.uid() = user_id);

create policy "Users can view their own tags. " on tags for
    select using (auth.uid() = user_id);

create policy "Users can update their own tags." on tags for
    update using (auth.uid() = user_id);

create policy "Users can delete their own tags." on tags for
    delete using (auth.uid() = user_id);

CREATE TRIGGER trigger_log_tags_deletes AFTER DELETE ON tags FOR EACH ROW EXECUTE PROCEDURE trigger_record_delete();

/* Tags table End */

/* Payees table Start */

create table payees (
  id bigint generated by default as identity primary key,
  user_id uuid references auth.users not null,
  name text check (char_length(name) > 2) check (char_length(name) < 100) not null,
  created_time timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_time timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table payees ADD CONSTRAINT payees_unique_name UNIQUE ("name",user_id);
alter table payees enable row level security;

create policy "Users can create payees." on payees for
    insert with check (auth.uid() = user_id);

create policy "Users can view their own payees. " on payees for
    select using (auth.uid() = user_id);

create policy "Users can update their own payees." on payees for
    update using (auth.uid() = user_id);

create policy "Users can delete their own payees." on payees for
    delete using (auth.uid() = user_id);

CREATE TRIGGER trigger_log_payees_deletes AFTER DELETE ON payees FOR EACH ROW EXECUTE PROCEDURE trigger_record_delete();

/* Payees table End */

/* Categories table Start */

create table categories (
  id bigint generated by default as identity primary key,
  user_id uuid references auth.users not null,
  name text check (char_length(name) > 2) check (char_length(name) < 100) not null,
  created_time timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_time timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table categories ADD CONSTRAINT categories_unique_name UNIQUE ("name",user_id);
alter table categories enable row level security;

create policy "Users can create categories." on categories for
    insert with check (auth.uid() = user_id);

create policy "Users can view their own categories. " on categories for
    select using (auth.uid() = user_id);

create policy "Users can update their own categories." on categories for
    update using (auth.uid() = user_id);

create policy "Users can delete their own categories." on categories for
    delete using (auth.uid() = user_id);

CREATE TRIGGER trigger_log_categories_deletes AFTER DELETE ON categories FOR EACH ROW EXECUTE PROCEDURE trigger_record_delete();

/* Categories table End */

/* Sub-Categories table Start */

create table sub_categories (
  id bigint generated by default as identity primary key,
  user_id uuid references auth.users not null,
  name text check (char_length(name) > 2) check (char_length(name) < 100) not null,
  category_id bigint references public.categories not null,
  created_time timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_time timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table sub_categories ADD CONSTRAINT sub_categories_unique_name UNIQUE ("name",category_id,user_id);
alter table sub_categories enable row level security;

create policy "Users can create sub_categories." on sub_categories for
    insert with check (auth.uid() = user_id);

create policy "Users can view their own sub_categories. " on sub_categories for
    select using (auth.uid() = user_id);

create policy "Users can update their own sub_categories." on sub_categories for
    update using (auth.uid() = user_id);

create policy "Users can delete their own sub_categories." on sub_categories for
    delete using (auth.uid() = user_id);

CREATE TRIGGER trigger_log_sub_categories_deletes AFTER DELETE ON sub_categories FOR EACH ROW EXECUTE PROCEDURE trigger_record_delete();

/* Sub-Categories table End */

/* Transactions table Start */

create table transactions (
  id bigint generated by default as identity primary key,
  user_id uuid references auth.users not null,
  amount decimal not null,
  trans_type text check (char_length(status) > 2) check (char_length(status) < 20),
  trans_date date not null,
  to_amount decimal,
  account_id bigint references public.accounts not null,
  to_account_id bigint references public.accounts,
  sub_category_id bigint references public.sub_categories,
  payee_id bigint references public.payees,
  status text check (char_length(status) > 0) check (char_length(status) < 20),
  trans_number text check (char_length(status) > 0) check (char_length(status) < 50),
  notes text check (char_length(status) > 0) check (char_length(status) < 500),
  created_time timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_time timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table transactions enable row level security;

create policy "Users can create transactions." on transactions for
    insert with check (auth.uid() = user_id);

create policy "Users can view their own transactions. " on transactions for
    select using (auth.uid() = user_id);

create policy "Users can update their own transactions." on transactions for
    update using (auth.uid() = user_id);

create policy "Users can delete their own transactions." on transactions for
    delete using (auth.uid() = user_id);

CREATE TRIGGER trigger_log_transactions_deletes AFTER DELETE ON transactions FOR EACH ROW EXECUTE PROCEDURE trigger_record_delete();

/* Transactions table End */

/* Transaction Tags table Start */

create table transaction_tags (
  id bigint generated by default as identity primary key,
  user_id uuid references auth.users not null,
  transaction_id bigint references public.transactions not null,
  tag_id bigint references public.tags not null,
  created_time timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_time timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table transaction_tags enable row level security;

create policy "Users can create transaction_tags." on transaction_tags for
    insert with check (auth.uid() = user_id);

create policy "Users can view their own transaction_tags. " on transaction_tags for
    select using (auth.uid() = user_id);

create policy "Users can update their own transaction_tags." on transaction_tags for
    update using (auth.uid() = user_id);

create policy "Users can delete their own transaction_tags." on transaction_tags for
    delete using (auth.uid() = user_id);

CREATE TRIGGER trigger_log_transaction_tags_deletes AFTER DELETE ON transaction_tags FOR EACH ROW EXECUTE PROCEDURE trigger_record_delete();

/* Transaction Tags table End */

/* Audit Log table Start */

create table deleted_records (
  id bigint generated by default as identity primary key,
  user_id uuid references auth.users not null,
  record_id bigint not null,
  record_type text check (char_length(record_type) > 2) check (char_length(record_type) < 50),
  created_time timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table deleted_records enable row level security;

create policy "Users can create deleted_records." on deleted_records for
    insert with check (auth.uid() = user_id);

create policy "Users can view their own deleted_records. " on deleted_records for
    select using (auth.uid() = user_id);

create policy "Users can update their own deleted_records." on deleted_records for
    update using (auth.uid() = user_id);

create policy "Users can delete their own deleted_records." on deleted_records for
    delete using (auth.uid() = user_id);

/* Audit Log table End */

/* Procedure for Transactions Start */

CREATE
OR Replace FUNCTION save_transactions(record JSON) RETURNS JSON LANGUAGE plpgsql AS $$
DECLARE t_id int;
BEGIN
  
  t_id = (record->>'id')::integer;

  if(t_id > 0) THEN

    update transactions set 
    amount = (record->>'amount')::numeric, trans_type=(record->>'trans_type')::varchar, trans_date=(record->>'trans_date')::date, to_amount=(record->>'to_amount')::decimal, account_id=(record->>'account_id')::integer, to_account_id=(record->>'to_account_id')::integer, sub_category_id=(record->>'sub_category_id')::integer, payee_id=(record->>'payee_id')::integer, status=(record->>'status')::varchar, trans_number=(record->>'trans_number')::varchar, notes=(record->>'notes')::varchar,  updated_time=timezone('utc'::text, now())
    where id = t_id;

    RETURN(Select json_agg(t) from transactions as t where id=t_id);
  
  else
      INSERT INTO transactions
      (user_id, amount, trans_type, trans_date, to_amount, account_id, to_account_id, sub_category_id, payee_id, status, trans_number, notes, created_time, updated_time)
    VALUES((record->>'user_id')::uuid, (record->>'amount')::numeric, (record->>'trans_type')::varchar,(record->>'trans_date')::date, (record->>'to_amount')::decimal, (record->>'account_id')::integer, (record->>'to_account_id')::integer, (record->>'sub_category_id')::integer, (record->>'payee_id')::integer, (record->>'status')::varchar, (record->>'trans_number')::varchar, (record->>'notes')::varchar, timezone('utc'::text, now()), timezone('utc'::text, now())) RETURNING id INTO t_id;
    
    RETURN(Select json_agg(t) from transactions as t where id=t_id);
  END if;

END
$$;

/* Procedure for Transactions End */

/* Accounts View Start */

CREATE
OR replace function function_accounts_view() RETURNS TABLE (
  balance decimal,
  id bigint,
  user_id uuid,
  account_type_id bigint,
  name text,
  is_active boolean,
  include_in_balance boolean,
  exclude_from_dashboard boolean,
  initial_balance decimal,
  minimum_balance decimal,
  credit_limit decimal,
  interest_rate decimal,
  notes text,
  payment_date timestamp with time zone,
  created_time timestamp with time zone,
  updated_time timestamp with time zone
) LANGUAGE plpgsql SECURITY INVOKER AS $$
BEGIN
RETURN QUERY select
  (
    a.initial_balance + (
      select
        COALESCE(sum(amount), 0)
      from
        transactions t
      where
        (
          t.account_id = a.id
          and t.trans_type = 'Deposit'
        )
        OR (
          t.to_account_id = a.id
          and t.trans_type = 'Transfer'
        )
    ) - (
      select
        COALESCE(sum(amount), 0)
      from
        transactions t
      where
        (
          t.account_id = a.id
          and (
            t.trans_type = 'Withdraw'
            OR t.trans_type = 'Transfer'
          )
        )
    )
  ) balance,
  a.id,a.user_id,a.account_type_id,a.name,a.is_active,a.include_in_balance,a.exclude_from_dashboard,a.initial_balance,a.minimum_balance,a.credit_limit,a.interest_rate,a.notes,a.payment_date,a.created_time,a.updated_time
from
  accounts as a;

END
$$;
CREATE
OR replace VIEW accounts_view AS
select
  *
from
  function_accounts_view();

/* Accounts View End */


/* Transactions View Start */

CREATE
OR replace function function_transactions_view() RETURNS TABLE (
  account_name text,
  to_account_name text,
  sub_category_name text,
  category_name text,
  payee_name text,
  id bigint,
  user_id uuid,
  amount decimal,
  trans_type text,
  trans_date date,
  to_amount decimal,
  account_id bigint,
  to_account_id bigint,
  sub_category_id bigint,
  payee_id bigint,
  status text,
  trans_number text,
  notes text,
  created_time timestamp with time zone,
  updated_time timestamp with time zone
) LANGUAGE plpgsql SECURITY INVOKER AS $$
BEGIN
RETURN QUERY select
  fa.name as account_name,
  ta.name as to_account_name,
  sc.name as sub_category_name,
  c.name as category_name,
  p.name as payee_name,
  t.id,t.user_id,t.amount,t.trans_type,t.trans_date,t.to_amount,t.account_id,t.to_account_id,t.sub_category_id,t.payee_id,t.status,t.trans_number,t.notes,t.created_time,t.updated_time
from
  transactions as t
  left join accounts fa on t.account_id = fa.id
  left join accounts ta on t.to_account_id = ta.id
  left join sub_categories sc on t.sub_category_id = sc.id
  left join categories c on sc.category_id = c.id
  left join payees p on t.payee_id = p.id;

END
$$;
CREATE
OR replace VIEW transactions_view AS
select
  *
from
  function_transactions_view();

  /* Transactions View End */


  /* Transactions Details function Start */

CREATE
OR replace function function_transactions_details(
  from_account_id bigint,
  start_index int,
  page_size int
) RETURNS TABLE (
  balance decimal,
  account_name text,
  to_account_name text,
  sub_category_name text,
  category_name text,
  payee_name text,
  id bigint,
  user_id uuid,
  amount decimal,
  trans_type text,
  trans_date date,
  to_amount decimal,
  account_id bigint,
  to_account_id bigint,
  sub_category_id bigint,
  payee_id bigint,
  status text,
  trans_number text,
  notes text,
  created_time timestamp with time zone,
  updated_time timestamp with time zone
) LANGUAGE plpgsql SECURITY INVOKER AS $$
BEGIN
RETURN QUERY select
(select
        SUM(case t2.trans_type
        when 'Withdraw' then -1 * t2.amount
        when 'Deposit' then t2.amount
        when 'Transfer' then case t2.to_account_id when from_account_id then t2.amount else -1 * t2.amount end
        else t2.amount END)
    from
        transactions t2
    where
        (t2.trans_date < t.trans_date OR (t2.trans_date = t.trans_date and t2.id <= t.id))
        and t2.user_id = t.user_id
        and (t.account_id = t2.account_id or t.to_account_id = t2.account_id or t.account_id = t2.to_account_id or t.to_account_id = t2.to_account_id)
		  AND (from_account_id = t2.account_id or from_account_id = t2.to_account_id))+(case when from_account_id = fa.id then fa.initial_balance else ta.initial_balance end) as balance,
  fa.name as account_name,
  ta.name as to_account_name,
  sc.name as sub_category_name,
  c.name as category_name,
  p.name as payee_name,
  t.id,t.user_id,t.amount,t.trans_type,t.trans_date,t.to_amount,t.account_id,t.to_account_id,t.sub_category_id,t.payee_id,t.status,t.trans_number,t.notes,t.created_time,t.updated_time
from
  transactions as t
  left join accounts fa on t.account_id = fa.id
  left join accounts ta on t.to_account_id = ta.id
  left join sub_categories sc on t.sub_category_id = sc.id
  left join categories c on sc.category_id = c.id
  left join payees p on t.payee_id = p.id
  where (t.account_id = from_account_id OR t.to_account_id = from_account_id)
  order by t.trans_date desc, t.id desc
  offset start_index limit page_size;  

END
$$;

  /* Transactions Details function End */
