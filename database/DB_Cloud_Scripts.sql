CREATE TABLE public.users
(
    user_id       UUID NOT NULL,
    first_name    character varying(255),
    last_name     character varying(255),
    email_address character varying(255),
    passwd        character varying(255),
    phone_number  character varying(255),
    address       character varying(255),
    gender        character varying(1),
    dob           date    NOT NULL,
    enabled       character(1),
    CONSTRAINT users_pkey PRIMARY KEY (user_id),
    CONSTRAINT unique_email UNIQUE (email_address),
    CONSTRAINT unique_phone UNIQUE (phone_number)
);


CREATE TABLE public.role
(
    role_id   integer NOT NULL,
    role_desc character varying(10),
    CONSTRAINT role_pkey PRIMARY KEY (role_id)
);


CREATE TABLE public.role_mapping
(
    user_id       UUID NOT NULL,
    role_id       integer NOT NULL,
    isactive      character varying(1),
    create_date   date,
    end_date      date,
    modified_date date,
    CONSTRAINT role_mapping_pkey PRIMARY KEY (user_id, role_id),
    CONSTRAINT add_users FOREIGN KEY (user_id)
        REFERENCES public.users (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT role_mapping_constraints FOREIGN KEY (role_id)
        REFERENCES public.role (role_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);


CREATE TABLE public.supplier
(
    supplier_id   integer                NOT NULL,
    supplier_name character varying(50)  NOT NULL,
    address       character varying(255) NOT NULL,
    phone_number  character varying(20)  NOT NULL,
    email_address character varying(20)  NOT NULL,
    CONSTRAINT supplier_pkey PRIMARY KEY (supplier_id),
    CONSTRAINT unique_email_addr UNIQUE (email_address),
    CONSTRAINT unique_phone_nbr UNIQUE (phone_number)
);


CREATE TABLE public.medicine
(
    medicine_id   integer                NOT NULL,
    medicine_name character varying(255) NOT NULL,
    medicine_desc character varying(255) NOT NULL,
    CONSTRAINT medicine_pkey PRIMARY KEY (medicine_id)
);


CREATE TABLE public.category
(
    category_id   integer               NOT NULL,
    category_name character varying(20) NOT NULL,
    lower_age     character varying(10) NOT NULL,
    upper_age     character varying(10) NOT NULL,
    gender        character varying(2)  NOT NULL,
    CONSTRAINT category_pkey PRIMARY KEY (category_id)
);


CREATE TABLE public.medicine_category
(
    category_id integer NOT NULL,
    medicine_id integer NOT NULL,
    CONSTRAINT medicine_category_pkey PRIMARY KEY (category_id, medicine_id),
    CONSTRAINT category_details FOREIGN KEY (category_id)
        REFERENCES public.category (category_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT medicine_category_medicine_id_fkey FOREIGN KEY (medicine_id)
        REFERENCES public.medicine (medicine_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT medicine_details FOREIGN KEY (medicine_id)
        REFERENCES public.medicine (medicine_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);


CREATE TABLE public.stock
(
    stock_id integer NOT NULL,
    supply_date date NOT NULL,
    overhead_pct double precision NOT NULL,
    total_cost numeric(20,10) NOT NULL DEFAULT 0,
    supplier_id integer NOT NULL,
    CONSTRAINT stock_pkey PRIMARY KEY (stock_id),
    CONSTRAINT supplier_stock_details FOREIGN KEY (supplier_id)
        REFERENCES public.supplier (supplier_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE public.has_stock_supply
(
    stock_id integer NOT NULL,
    supplier_id integer NOT NULL,
    unit_cost_price numeric(7,4) NOT NULL DEFAULT 0,
    medicine_id integer NOT NULL,
    manufacture_date date NOT NULL,
    expiry_date date NOT NULL,
    quantity integer NOT NULL DEFAULT 0,
    total_cost numeric(20,10) NOT NULL DEFAULT 0,
    CONSTRAINT has_stock_supply_pkey PRIMARY KEY (stock_id, supplier_id, medicine_id),
    CONSTRAINT med_details FOREIGN KEY (medicine_id)
        REFERENCES public.medicine (medicine_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT stock_details FOREIGN KEY (stock_id)
        REFERENCES public.stock (stock_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT supplier_details FOREIGN KEY (supplier_id)
        REFERENCES public.supplier (supplier_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE public.orders
(
    order_id   integer         NOT NULL,
    total_amt  numeric(20, 10) NOT NULL,
    order_date date            NOT NULL,
    user_id    integer         NOT NULL,
    store_id   integer         NOT NULL,
    CONSTRAINT orders_pkey PRIMARY KEY (order_id),
    CONSTRAINT user_orders FOREIGN KEY (user_id)
        REFERENCES public.users (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);


CREATE TABLE public.order_items
(
    order_id           integer         NOT NULL,
    medicine_id        integer         NOT NULL,
    stock_id           integer         NOT NULL,
    unit_selling_price numeric(7, 4)   NOT NULL DEFAULT 0,
    quantity           integer         NOT NULL DEFAULT 0,
    total_amt          numeric(20, 10) NOT NULL DEFAULT 0,
    CONSTRAINT order_items_pkey PRIMARY KEY (order_id, medicine_id),
    CONSTRAINT orders_order_items FOREIGN KEY (order_id)
        REFERENCES public.orders (order_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE medicine_category_price AS 
(
SELECT DISTINCT m.medicine_id, 
medicine_name, 
ROUND(hss.unit_cost_price, 2),
c.category_name
FROM medicine m INNER JOIN medicine_category mc
ON m.medicine_id = mc.medicine_id
INNER JOIN category c
ON mc.category_id = c.category_id
INNER JOIN has_stock_supply hss
ON m.medicine_id = hss.medicine_id
ORDER BY medicine_id
);

ALTER TABLE medicine_category_price ADD COLUMN picture text;

--------------------------------------------------------------------------------------


CREATE EXTENSION pgcrypto;



INSERT INTO public.role(role_id, role_desc)
VALUES (1, 'MANAGER');

INSERT INTO public.role(role_id, role_desc)
VALUES (2, 'STAFF');

INSERT INTO public.role(role_id, role_desc)
VALUES (3, 'CUSTOMER');


-- INSERTING STAFF DETAILS

INSERT INTO public.users(user_id, first_name, last_name, email_address, passwd, phone_number, address, gender, dob,
                         enabled)
VALUES (201, 'Rosta', 'Farzan', 'rosta.farzan@pitt.edu', crypt('1234567890', gen_salt('bf', 10)), '4129987654',
        'Pittsburgh', 'F', '1980-07-08', 'Y');

INSERT INTO public.role_mapping(user_id, role_id, isactive, create_date, modified_date)
VALUES (201, 2, 'Y', NOW(), NOW());





----------------------------------------------------------------------------------------

-- UPDATE QUERIES

UPDATE medicine_category_price
SET picture = 'Ibuprofen_200_mg.jpeg'
WHERE medicine_id = 1001;

UPDATE medicine_category_price
SET picture = 'Acetaminophen_325mg.jpeg'
WHERE medicine_id = 1002;

UPDATE medicine_category_price
SET picture = 'Pediatric_Acetaminophen'
WHERE medicine_id = 1003;

UPDATE medicine_category_price
SET picture = 'Naproxen_200mg.jpg'
WHERE medicine_id = 1004;

UPDATE medicine_category_price
SET picture = 'Aspirin_81_mg_EC.jpeg'
WHERE medicine_id = 1005;





	





