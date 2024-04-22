SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

CREATE TABLE public.state (
  state_id integer PRIMARY KEY,
  state_name text NOT NULL,
  user_triggerable BOOLEAN NOT NULL
);

ALTER TABLE public.state OWNER TO tech_user;


COPY public.state (state_id, state_name, user_triggerable) FROM stdin WITH DELIMITER ',';
1,Submitted,false
2,Approved,false
3,Rejected,false
4,Canceled,true
5,In Preparation,false
6,In Delivery,false
7,Delivered,false
\.
CREATE TABLE public.next_state (
  state_id integer NOT NULL,
  next_state_id integer NOT NULL
);

ALTER TABLE public.state OWNER TO tech_user;

ALTER TABLE ONLY public.next_state
    ADD CONSTRAINT next_state_pkey PRIMARY KEY (state_id, next_state_id);
 
COPY public.next_state (state_id, next_state_id) FROM stdin WITH DELIMITER ' ';
1 2
1 3
1 4
2 4
2 5
5 6
6 7
\.
--
-- Name: user; Type: TABLE; Schema: public; Owner: tech_user
--
CREATE TABLE IF NOT EXISTS public.user (
    email text PRIMARY KEY,
    user_name text NOT NULL,
    firstname text NOT NULL,
    password_hash text NOT NULL
);

ALTER TABLE public.user OWNER TO tech_user;


--
-- Name: plate; Type: TABLE; Schema: public; Owner: tech_user
--

CREATE TABLE IF NOT EXISTS public.plate (
    plate_id integer NOT NULL,
    plate_name text NOT NULL,
    price double precision NOT NULL,
    picture text
);


ALTER TABLE public.plate OWNER TO tech_user;

--
-- Name: plate_plate_id_seq; Type: SEQUENCE; Schema: public; Owner: tech_user
--

CREATE SEQUENCE public.plate_plate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.plate_plate_id_seq OWNER TO tech_user;

--
-- Name: plate_plate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tech_user
--

ALTER SEQUENCE public.plate_plate_id_seq OWNED BY public.plate.plate_id;

--
-- Name: plate plate_id; Type: DEFAULT; Schema: public; Owner: tech_user
--

ALTER TABLE ONLY public.plate ALTER COLUMN plate_id SET DEFAULT nextval('public.plate_plate_id_seq'::regclass);

--
-- Name: plate plate_pkey; Type: CONSTRAINT; Schema: public; Owner: tech_user
--

ALTER TABLE ONLY public.plate
    ADD CONSTRAINT plate_pkey PRIMARY KEY (plate_id);

--
-- Name: order; Type: TABLE; Schema: public; Owner: tech_user
--

CREATE TABLE IF NOT EXISTS public."order" (
    order_id integer NOT NULL,
    order_time timestamp with time zone NOT NULL,
    "_Order__finish_time" timestamp with time zone NOT NULL,
    user_email text NOT NULL,
    state_id integer NOT NULL
);


ALTER TABLE public."order" OWNER TO tech_user;

--
-- Name: order_order_id_seq; Type: SEQUENCE; Schema: public; Owner: tech_user
--

CREATE SEQUENCE public.order_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_order_id_seq OWNER TO tech_user;

--
-- Name: order_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tech_user
--

ALTER SEQUENCE public.order_order_id_seq OWNED BY public."order".order_id;

--
-- Name: order order_id; Type: DEFAULT; Schema: public; Owner: tech_user
--

ALTER TABLE ONLY public."order" ALTER COLUMN order_id SET DEFAULT nextval('public.order_order_id_seq'::regclass);


--
-- Name: order order_pkey; Type: CONSTRAINT; Schema: public; Owner: tech_user
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (order_id);

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_user_email_fkey FOREIGN KEY (user_email) REFERENCES public."user"(email);

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_state_fkey FOREIGN KEY (state_id) REFERENCES public."state"(state_id);
--
-- Name: plate_order; Type: TABLE; Schema: public; Owner: tech_user
--
CREATE TABLE IF NOT EXISTS public.plate_order (
    plate_id integer NOT NULL,
    order_id integer NOT NULL,
    quantity integer NOT NULL
);



ALTER TABLE public.plate_order OWNER TO tech_user;

--
-- Name: plate_order plate_order_pkey; Type: CONSTRAINT; Schema: public; Owner: tech_user
--

ALTER TABLE ONLY public.plate_order
    ADD CONSTRAINT plate_order_pkey PRIMARY KEY (plate_id, order_id);

--
-- Name: plate_order plate_order_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tech_user
--

ALTER TABLE ONLY public.plate_order
    ADD CONSTRAINT plate_order_order_id_fkey FOREIGN KEY (order_id) REFERENCES public."order"(order_id);

--
-- Name: plate_order plate_order_plate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tech_user
--

ALTER TABLE ONLY public.plate_order
    ADD CONSTRAINT plate_order_plate_id_fkey FOREIGN KEY (plate_id) REFERENCES public.plate(plate_id);
CREATE TABLE IF NOT EXISTS public.review (
  plate_id integer NOT NULL,
  user_email text NOT NULL,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment text NOT NULL
);

ALTER TABLE public.review OWNER TO tech_user;

ALTER TABLE ONLY public.review
  ADD CONSTRAINT review_plate_id_fkey FOREIGN KEY (plate_id) REFERENCES public.plate(plate_id);

ALTER TABLE ONLY public.review
  ADD CONSTRAINT review_user_email_fkey FOREIGN KEY (user_email) REFERENCES public.user(email);
--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: tech_user
--

COPY public."user" (email, user_name, firstname, password_hash) FROM stdin WITH DELIMITER ',';
toto@gmail.com,Doe,John,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
tata@gmail.com,Wilson,Patrick,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
titi@gmail.com,Dupont,Titi,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
alice.johnson@gmail.com,Johnson,Alice,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
bob.smith@gmail.com,Smith,Bob,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
carol.williams@gmail.com,Williams,Carol,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
david.jones@gmail.com,Jones,David,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
emily.brown@gmail.com,Brown,Emily,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
frank.davis@gmail.com,Davis,Frank,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
grace.white@gmail.com,White,Grace,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
henry.anderson@gmail.com,Anderson,Henry,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
isabella.martin@gmail.com,Martin,Isabella,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
jack.thomas@gmail.com,Thomas,Jack,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
kate.wilson@gmail.com,Wilson,Kate,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
liam.miller@gmail.com,Miller,Liam,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
mia.jackson@gmail.com,Jackson,Mia,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
nathan.moore@gmail.com,Moore,Nathan,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
olivia.taylor@gmail.com,Taylor,Olivia,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
peter.harris@gmail.com,Harris,Peter,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
quinn.walker@gmail.com,Walker,Quinn,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
rachel.clark@gmail.com,Clark,Rachel,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
samuel.lewis@gmail.com,Lewis,Samuel,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
sophia.lee@gmail.com,Lee,Sophia,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
thomas.robinson@gmail.com,Robinson,Thomas,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
victoria.turner@gmail.com,Turner,Victoria,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
william.hall@gmail.com,Hall,William,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
zoe.garcia@gmail.com,Garcia,Zoe,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
adrian.baker@gmail.com,Baker,Adrian,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
bella.lopez@gmail.com,Lopez,Bella,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
carter.perez@gmail.com,Perez,Carter,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
daisy.cook@gmail.com,Cook,Daisy,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
elijah.collins@gmail.com,Collins,Elijah,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
fiona.sanchez@gmail.com,Sanchez,Fiona,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
gavin.morris@gmail.com,Morris,Gavin,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
hannah.brown@gmail.com,Brown,Hannah,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
ian.hall@gmail.com,Hall,Ian,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
jessica.roberts@gmail.com,Roberts,Jessica,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
kyle.barnes@gmail.com,Barnes,Kyle,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
lily.martinez@gmail.com,Martinez,Lily,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
michael.gonzalez@gmail.com,Gonzalez,Michael,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
natalie.hernandez@gmail.com,Hernandez,Natalie,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
oliver.allen@gmail.com,Allen,Oliver,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
pamela.wood@gmail.com,Wood,Pamela,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
quincy.rodriguez@gmail.com,Rodriguez,Quincy,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
riley.thompson@gmail.com,Thompson,Riley,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
samantha.cooper@gmail.com,Cooper,Samantha,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
theo.howard@gmail.com,Howard,Theo,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
umair.khan@gmail.com,Khan,Umair,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
violet.stewart@gmail.com,Stewart,Violet,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
william.morales@gmail.com,Morales,William,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
xavier.morales@gmail.com,Morales,Xavier,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
yasmine.hall@gmail.com,Hall,Yasmine,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
zachary.davis@gmail.com,Davis,Zachary,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
test@gmail.com,Doe,John,9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
\.

COPY public."order" (order_id, order_time, "_Order__finish_time", user_email, state_id) FROM stdin WITH DELIMITER ',';
1,2023-05-02 23:25:48.168407+00,2023-05-02 23:37:22.168469+00,alice.johnson@gmail.com,7
2,2023-05-03 14:45:18.987324+00,2023-05-03 15:15:33.987587+00,bob.smith@gmail.com,7
3,2023-05-04 10:10:10.546789+00,2023-05-04 10:35:45.547321+00,carol.williams@gmail.com,7
4,2023-05-05 09:20:33.223456+00,2023-05-05 09:45:44.223678+00,david.jones@gmail.com,7
5,2023-05-06 18:30:15.321111+00,2023-05-06 19:15:27.321654+00,emily.brown@gmail.com,7
6,2023-05-07 20:05:42.887111+00,2023-05-07 20:30:55.887655+00,frank.davis@gmail.com,7
7,2023-05-08 12:12:12.987654+00,2023-05-08 12:35:24.987876+00,grace.white@gmail.com,7
8,2023-05-09 16:40:21.546789+00,2023-05-09 17:00:33.547123+00,henry.anderson@gmail.com,7
9,2023-05-10 17:55:37.432123+00,2023-05-10 18:30:45.432786+00,isabella.martin@gmail.com,7
10,2023-05-11 08:35:29.345678+00,2023-05-11 09:05:40.345912+00,jack.thomas@gmail.com,7
11,2023-05-12 09:55:11.123456+00,2023-05-12 10:25:22.123890+00,kate.wilson@gmail.com,7
12,2023-05-13 14:30:25.987654+00,2023-05-13 15:00:36.987888+00,liam.miller@gmail.com,7
13,2023-05-14 17:45:31.876543+00,2023-05-14 18:15:45.876877+00,mia.jackson@gmail.com,7
14,2023-05-15 13:20:19.765432+00,2023-05-15 13:45:27.765665+00,nathan.moore@gmail.com,7
15,2023-05-16 11:30:35.432111+00,2023-05-16 12:00:48.432344+00,olivia.taylor@gmail.com,7
16,2023-05-17 09:20:33.223456+00,2023-05-17 09:45:44.223678+00,peter.harris@gmail.com,7
17,2023-05-18 20:05:42.887111+00,2023-05-18 20:30:55.887655+00,quinn.walker@gmail.com,7
18,2023-05-19 12:12:12.987654+00,2023-05-19 12:35:24.987876+00,rachel.clark@gmail.com,7
19,2023-05-20 16:40:21.546789+00,2023-05-20 17:00:33.547123+00,samuel.lewis@gmail.com,7
20,2023-05-21 17:55:37.432123+00,2023-05-21 18:30:45.432786+00,sophia.lee@gmail.com,7
21,2023-05-22 08:35:29.345678+00,2023-05-22 09:05:40.345912+00,thomas.robinson@gmail.com,7
22,2023-05-23 11:45:18.987324+00,2023-05-23 12:15:33.987587+00,victoria.turner@gmail.com,7
23,2023-05-24 10:10:10.546789+00,2023-05-24 10:35:45.547321+00,william.hall@gmail.com,7
24,2023-05-25 14:30:25.987654+00,2023-05-25 15:00:36.987888+00,zoe.garcia@gmail.com,7
25,2023-05-26 13:20:19.765432+00,2023-05-26 13:45:27.765665+00,adrian.baker@gmail.com,7
26,2023-05-27 09:55:11.123456+00,2023-05-27 10:25:22.123890+00,bella.lopez@gmail.com,7
27,2023-05-28 20:05:42.887111+00,2023-05-28 20:30:55.887655+00,carter.perez@gmail.com,7
28,2023-05-29 16:40:21.546789+00,2023-05-29 17:00:33.547123+00,daisy.cook@gmail.com,7
29,2023-05-30 11:30:35.432111+00,2023-05-30 12:00:48.432344+00,elijah.collins@gmail.com,7
30,2023-05-31 17:55:37.432123+00,2023-05-31 18:30:45.432786+00,fiona.sanchez@gmail.com,7
31,2023-06-01 09:55:11.123456+00,2023-06-01 10:25:22.123890+00,gavin.morris@gmail.com,7
32,2023-06-02 14:30:25.987654+00,2023-06-02 15:00:36.987888+00,hannah.brown@gmail.com,7
33,2023-06-03 17:45:31.876543+00,2023-06-03 18:15:45.876877+00,ian.hall@gmail.com,7
34,2023-06-04 13:20:19.765432+00,2023-06-04 13:45:27.765665+00,jessica.roberts@gmail.com,7
35,2023-06-05 11:30:35.432111+00,2023-06-05 12:00:48.432344+00,kyle.barnes@gmail.com,7
36,2023-06-06 09:20:33.223456+00,2023-06-06 09:45:44.223678+00,lily.martinez@gmail.com,7
37,2023-06-07 20:05:42.887111+00,2023-06-07 20:30:55.887655+00,oliver.allen@gmail.com,7
38,2023-06-08 12:12:12.987654+00,2023-06-08 12:35:24.987876+00,natalie.hernandez@gmail.com,7
39,2023-06-09 16:40:21.546789+00,2023-06-09 17:00:33.547123+00,oliver.allen@gmail.com,7
40,2023-06-10 17:55:37.432123+00,2023-06-10 18:30:45.432786+00,oliver.allen@gmail.com,7
41,2023-06-11 08:35:29.345678+00,2023-06-11 09:05:40.345912+00,oliver.allen@gmail.com,7
42,2023-06-12 09:55:11.123456+00,2023-06-12 10:25:22.123890+00,oliver.allen@gmail.com,7
43,2023-06-13 14:30:25.987654+00,2023-06-13 15:00:36.987888+00,oliver.allen@gmail.com,7
44,2023-06-14 17:45:31.876543+00,2023-06-14 18:15:45.876877+00,oliver.allen@gmail.com,7
45,2023-06-15 13:20:19.765432+00,2023-06-15 13:45:27.765665+00,oliver.allen@gmail.com,7
46,2023-06-16 11:30:35.432111+00,2023-06-16 12:00:48.432344+00,oliver.allen@gmail.com,7
47,2023-06-17 09:20:33.223456+00,2023-06-17 09:45:44.223678+00,oliver.allen@gmail.com,7
48,2023-06-18 20:05:42.887111+00,2023-06-18 20:30:55.887655+00,oliver.allen@gmail.com,7
49,2023-06-19 12:12:12.987654+00,2023-06-19 12:35:24.987876+00,oliver.allen@gmail.com,7
50,2023-06-20 16:40:21.546789+00,2023-06-20 17:00:33.547123+00,oliver.allen@gmail.com,7
51,2023-07-12 09:55:11.123456+00,2023-07-12 10:25:22.123890+00,alice.johnson@gmail.com,7
52,2023-07-13 14:30:25.987654+00,2023-07-13 15:00:36.987888+00,bob.smith@gmail.com,7
53,2023-07-14 17:45:31.876543+00,2023-07-14 18:15:45.876877+00,carol.williams@gmail.com,7
54,2023-07-15 13:20:19.765432+00,2023-07-15 13:45:27.765665+00,david.jones@gmail.com,7
55,2023-07-16 11:30:35.432111+00,2023-07-16 12:00:48.432344+00,emily.brown@gmail.com,7
56,2023-07-17 09:20:33.223456+00,2023-07-17 09:45:44.223678+00,frank.davis@gmail.com,7
57,2023-07-18 20:05:42.887111+00,2023-07-18 20:30:55.887655+00,grace.white@gmail.com,7
58,2023-07-19 12:12:12.987654+00,2023-07-19 12:35:24.987876+00,henry.anderson@gmail.com,7
59,2023-07-20 16:40:21.546789+00,2023-07-20 17:00:33.547123+00,isabella.martin@gmail.com,7
60,2023-07-21 17:55:37.432123+00,2023-07-21 18:30:45.432786+00,jack.thomas@gmail.com,7
61,2023-07-22 08:35:29.345678+00,2023-07-22 09:05:40.345912+00,kate.wilson@gmail.com,7
62,2023-07-23 11:45:18.987324+00,2023-07-23 12:15:33.987587+00,liam.miller@gmail.com,7
63,2023-07-24 10:10:10.546789+00,2023-07-24 10:35:45.547321+00,mia.jackson@gmail.com,7
64,2023-07-25 14:30:25.987654+00,2023-07-25 15:00:36.987888+00,nathan.moore@gmail.com,7
65,2023-07-26 13:20:19.765432+00,2023-07-26 13:45:27.765665+00,olivia.taylor@gmail.com,7
66,2023-07-27 09:55:11.123456+00,2023-07-27 10:25:22.123890+00,peter.harris@gmail.com,7
67,2023-07-28 20:05:42.887111+00,2023-07-28 20:30:55.887655+00,quinn.walker@gmail.com,7
68,2023-07-29 16:40:21.546789+00,2023-07-29 17:00:33.547123+00,rachel.clark@gmail.com,7
69,2023-07-30 11:30:35.432111+00,2023-07-30 12:00:48.432344+00,samuel.lewis@gmail.com,7
70,2023-07-31 17:55:37.432123+00,2023-07-31 18:30:45.432786+00,sophia.lee@gmail.com,7
71,2023-08-01 09:55:11.123456+00,2023-08-01 10:25:22.123890+00,thomas.robinson@gmail.com,7
72,2023-08-02 14:30:25.987654+00,2023-08-02 15:00:36.987888+00,victoria.turner@gmail.com,7
73,2023-08-03 17:45:31.876543+00,2023-08-03 18:15:45.876877+00,william.hall@gmail.com,7
74,2023-08-04 13:20:19.765432+00,2023-08-04 13:45:27.765665+00,zoe.garcia@gmail.com,7
75,2023-08-05 11:30:35.432111+00,2023-08-05 12:00:48.432344+00,adrian.baker@gmail.com,7
76,2023-08-06 09:20:33.223456+00,2023-08-06 09:45:44.223678+00,bella.lopez@gmail.com,7
77,2023-08-07 20:05:42.887111+00,2023-08-07 20:30:55.887655+00,carter.perez@gmail.com,7
78,2023-08-08 12:12:12.987654+00,2023-08-08 12:35:24.987876+00,daisy.cook@gmail.com,7
79,2023-08-09 16:40:21.546789+00,2023-08-09 17:00:33.547123+00,elijah.collins@gmail.com,7
80,2023-08-10 13:20:19.765432+00,2023-08-10 13:45:27.765665+00,fiona.sanchez@gmail.com,7
81,2023-08-11 11:30:35.432111+00,2023-08-11 12:00:48.432344+00,gavin.morris@gmail.com,7
82,2023-08-12 09:20:33.223456+00,2023-08-12 09:45:44.223678+00,hannah.brown@gmail.com,7
83,2023-08-13 10:10:10.546789+00,2023-08-13 10:35:45.547321+00,ian.hall@gmail.com,7
84,2023-08-14 14:30:25.987654+00,2023-08-14 15:00:36.987888+00,jessica.roberts@gmail.com,7
85,2023-08-15 17:45:31.876543+00,2023-08-15 18:15:45.876877+00,kyle.barnes@gmail.com,7
86,2023-08-16 13:20:19.765432+00,2023-08-16 13:45:27.765665+00,lily.martinez@gmail.com,7
87,2023-08-17 11:30:35.432111+00,2023-08-17 12:00:48.432344+00,michael.gonzalez@gmail.com,7
88,2023-08-18 09:20:33.223456+00,2023-08-18 09:45:44.223678+00,natalie.hernandez@gmail.com,7
89,2023-08-19 14:30:25.987654+00,2023-08-19 15:00:36.987888+00,oliver.allen@gmail.com,7
90,2023-08-20 17:45:31.876543+00,2023-08-20 18:15:45.876877+00,pamela.wood@gmail.com,7
91,2023-08-21 13:20:19.765432+00,2023-08-21 13:45:27.765665+00,quincy.rodriguez@gmail.com,7
92,2023-08-22 11:30:35.432111+00,2023-08-22 12:00:48.432344+00,riley.thompson@gmail.com,7
93,2023-08-23 09:20:33.223456+00,2023-08-23 09:45:44.223678+00,samantha.cooper@gmail.com,7
94,2023-08-24 12:12:12.987654+00,2023-08-24 12:35:24.987876+00,theo.howard@gmail.com,7
95,2023-08-25 16:40:21.546789+00,2023-08-25 17:00:33.547123+00,umair.khan@gmail.com,7
96,2023-08-26 14:30:25.987654+00,2023-08-26 15:00:36.987888+00,violet.stewart@gmail.com,7
97,2023-08-27 17:45:31.876543+00,2023-08-27 18:15:45.876877+00,william.morales@gmail.com,7
98,2023-08-28 13:20:19.765432+00,2023-08-28 13:45:27.765665+00,xavier.morales@gmail.com,7
99,2023-08-29 11:30:35.432111+00,2023-08-29 12:00:48.432344+00,yasmine.hall@gmail.com,7
100,2023-08-30 09:20:33.223456+00,2023-08-30 09:45:44.223678+00,zachary.davis@gmail.com,7
101,2023-09-01 14:15:32.123456+00,2023-09-01 14:45:44.123678+00,toto@gmail.com,4
102,2023-09-02 11:30:35.432111+00,2023-09-02 12:00:48.432344+00,tata@gmail.com,2
103,2023-09-03 09:20:33.223456+00,2023-09-03 09:45:44.223678+00,titi@gmail.com,5
104,2023-09-04 14:30:25.987654+00,2023-09-04 15:00:36.987888+00,alice.johnson@gmail.com,6
105,2023-09-05 17:45:31.876543+00,2023-09-05 18:15:45.876877+00,bob.smith@gmail.com,3
106,2023-09-06 13:20:19.765432+00,2023-09-06 13:45:27.765665+00,carol.williams@gmail.com,1
107,2023-09-07 11:30:35.432111+00,2023-09-07 12:00:48.432344+00,david.jones@gmail.com,2
108,2023-09-08 09:20:33.223456+00,2023-09-08 09:45:44.223678+00,emily.brown@gmail.com,4
109,2023-09-09 14:30:25.987654+00,2023-09-09 15:00:36.987888+00,frank.davis@gmail.com,6
110,2023-09-10 17:45:31.876543+00,2023-09-10 18:15:45.876877+00,grace.white@gmail.com,3
111,2023-09-11 13:20:19.765432+00,2023-09-11 13:45:27.765665+00,henry.anderson@gmail.com,1
112,2023-09-12 11:30:35.432111+00,2023-09-12 12:00:48.432344+00,isabella.martin@gmail.com,2
113,2023-09-13 09:20:33.223456+00,2023-09-13 09:45:44.223678+00,jack.thomas@gmail.com,5
114,2023-09-14 14:30:25.987654+00,2023-09-14 15:00:36.987888+00,kate.wilson@gmail.com,4
115,2023-09-15 17:45:31.876543+00,2023-09-15 18:15:45.876877+00,liam.miller@gmail.com,3
116,2023-09-16 13:20:19.765432+00,2023-09-16 13:45:27.765665+00,mia.jackson@gmail.com,1
117,2023-09-17 11:30:35.432111+00,2023-09-17 12:00:48.432344+00,nathan.moore@gmail.com,2
118,2023-09-18 09:20:33.223456+00,2023-09-18 09:45:44.223678+00,olivia.taylor@gmail.com,5
119,2023-09-19 14:30:25.987654+00,2023-09-19 15:00:36.987888+00,peter.harris@gmail.com,4
120,2023-09-20 17:45:31.876543+00,2023-09-20 18:15:45.876877+00,quinn.walker@gmail.com,3
121,2023-09-21 13:20:19.765432+00,2023-09-21 13:45:27.765665+00,rachel.clark@gmail.com,1
122,2023-09-22 11:30:35.432111+00,2023-09-22 12:00:48.432344+00,samuel.lewis@gmail.com,2
123,2023-09-23 09:20:33.223456+00,2023-09-23 09:45:44.223678+00,sophia.lee@gmail.com,5
124,2023-09-24 14:30:25.987654+00,2023-09-24 15:00:36.987888+00,thomas.robinson@gmail.com,4
125,2023-09-25 17:45:31.876543+00,2023-09-25 18:15:45.876877+00,victoria.turner@gmail.com,3
126,2023-09-26 13:20:19.765432+00,2023-09-26 13:45:27.765665+00,william.hall@gmail.com,1
127,2023-09-27 11:30:35.432111+00,2023-09-27 12:00:48.432344+00,zoe.garcia@gmail.com,2
128,2023-09-28 09:20:33.223456+00,2023-09-28 09:45:44.223678+00,adrian.baker@gmail.com,5
129,2023-09-29 14:30:25.987654+00,2023-09-29 15:00:36.987888+00,bella.lopez@gmail.com,4
130,2023-09-30 17:45:31.876543+00,2023-09-30 18:15:45.876877+00,carter.perez@gmail.com,3
131,2023-10-01 13:20:19.765432+00,2023-10-01 13:45:27.765665+00,daisy.cook@gmail.com,1
132,2023-10-02 11:30:35.432111+00,2023-10-02 12:00:48.432344+00,elijah.collins@gmail.com,2
133,2023-10-03 09:20:33.223456+00,2023-10-03 09:45:44.223678+00,fiona.sanchez@gmail.com,5
134,2023-10-04 14:30:25.987654+00,2023-10-04 15:00:36.987888+00,gavin.morris@gmail.com,4
135,2023-10-05 17:45:31.876543+00,2023-10-05 18:15:45.876877+00,hannah.brown@gmail.com,3
136,2023-10-06 13:20:19.765432+00,2023-10-06 13:45:27.765665+00,ian.hall@gmail.com,1
137,2023-10-07 11:30:35.432111+00,2023-10-07 12:00:48.432344+00,jessica.roberts@gmail.com,2
138,2023-10-08 09:20:33.223456+00,2023-10-08 09:45:44.223678+00,kyle.barnes@gmail.com,5
139,2023-10-09 14:30:25.987654+00,2023-10-09 15:00:36.987888+00,lily.martinez@gmail.com,4
140,2023-10-10 17:45:31.876543+00,2023-10-10 18:15:45.876877+00,michael.gonzalez@gmail.com,3
141,2023-10-11 13:20:19.765432+00,2023-10-11 13:45:27.765665+00,natalie.hernandez@gmail.com,1
142,2023-10-12 11:30:35.432111+00,2023-10-12 12:00:48.432344+00,oliver.allen@gmail.com,2
143,2023-10-13 09:20:33.223456+00,2023-10-13 09:45:44.223678+00,pamela.wood@gmail.com,5
144,2023-10-14 14:30:25.987654+00,2023-10-14 15:00:36.987888+00,quincy.rodriguez@gmail.com,4
145,2023-10-15 17:45:31.876543+00,2023-10-15 18:15:45.876877+00,riley.thompson@gmail.com,3
146,2023-10-16 13:20:19.765432+00,2023-10-16 13:45:27.765665+00,samantha.cooper@gmail.com,1
147,2023-10-17 11:30:35.432111+00,2023-10-17 12:00:48.432344+00,theo.howard@gmail.com,2
148,2023-10-18 09:20:33.223456+00,2023-10-18 09:45:44.223678+00,umair.khan@gmail.com,5
149,2023-10-19 14:30:25.987654+00,2023-10-19 15:00:36.987888+00,violet.stewart@gmail.com,4
150,2023-10-20 17:45:31.876543+00,2023-10-20 18:15:45.876877+00,william.morales@gmail.com,3
\.


--
-- Data for Name: plate; Type: TABLE DATA; Schema: public; Owner: tech_user
--

COPY public.plate (plate_id, plate_name, price, picture) FROM stdin;
1	Pizza Margherita	12.99	https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Eq_it-na_pizza-margherita_sep2005_sml.jpg/440px-Eq_it-na_pizza-margherita_sep2005_sml.jpg
2	Rösti	15.99	https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Roesti.jpg/500px-Roesti.jpg
3	Fondue	13.99	https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Swiss_fondue.jpg/500px-Swiss_fondue.jpg
4	Raclette	18.99	https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Raclette_20040817_140816.jpg/440px-Raclette_20040817_140816.jpg
5	Carpaccio	23.99	https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Carpaccio_with_cheese_in_Warsaw.jpg/500px-Carpaccio_with_cheese_in_Warsaw.jpg
6	BBQ Chicken Burger & Sweet Potato Fries	12.99	https://www.howsweeteats.com/wp-content/uploads/2011/04/bbqburgers-7.jpg
7	Spaghetti Carbonara	11.99	https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Espaguetis_carbonara.jpg/500px-Espaguetis_carbonara.jpg
8	Risotto	15.99	https://upload.wikimedia.org/wikipedia/commons/a/a5/Risotto_with_speck_and_goat_cheese_%286101067436%29.jpg
\.


--
-- Data for Name: plate_order; Type: TABLE DATA; Schema: public; Owner: tech_user
--

COPY public.plate_order (plate_id, order_id, quantity) FROM stdin WITH DELIMITER ' ';
1 1 3
2 2 7
3 3 5
4 4 8
5 5 2
6 6 6
7 7 4
8 8 9
1 9 10
2 10 1
3 11 3
4 12 7
5 13 5
6 14 8
7 15 2
8 16 6
1 17 4
2 18 9
3 19 6
4 20 3
5 21 2
6 22 7
7 23 1
8 24 10
1 25 6
2 26 8
3 27 2
4 28 5
5 29 9
6 30 4
7 31 10
8 32 1
1 33 5
2 34 3
3 35 7
4 36 6
5 37 4
6 38 10
7 39 8
8 40 2
1 41 9
2 42 1
3 43 2
4 44 8
5 45 10
6 46 5
7 47 3
8 48 7
1 49 4
2 50 6
3 51 10
4 52 5
5 53 3
6 54 7
7 55 8
8 56 2
1 57 1
2 58 9
3 59 4
4 60 2
5 61 3
6 62 7
7 63 8
8 64 10
1 65 5
2 66 6
3 67 4
4 68 9
5 69 8
6 70 10
7 71 3
8 72 2
1 73 1
2 74 7
3 75 5
4 76 4
5 77 6
6 78 10
7 79 8
8 80 3
1 81 9
2 82 2
3 83 1
4 84 7
5 85 6
6 86 4
7 87 5
8 88 3
1 89 8
2 90 10
3 91 9
4 92 2
5 93 1
6 94 4
7 95 3
8 96 5
1 97 6
2 98 7
3 99 8
4 100 9
4 101 9
1 102 9
2 103 6
3 104 3
4 105 7
5 106 4
6 107 2
7 108 1
8 109 10
1 110 5
2 111 8
3 112 9
4 113 6
5 114 10
6 115 2
7 116 7
8 117 4
1 118 3
2 119 5
3 120 6
4 121 9
5 122 8
6 123 1
7 124 10
8 125 7
1 126 2
2 127 4
3 128 8
4 129 5
5 130 3
6 131 9
7 132 6
8 133 10
1 134 1
2 135 7
3 136 5
4 137 4
5 138 3
6 139 10
7 140 9
8 141 2
1 142 8
2 143 10
3 144 9
4 145 2
5 146 1
6 147 4
7 148 3
8 149 5
1 150 6
\.

COPY public.review(plate_id, user_email,rating,comment) FROM stdin WITH DELIMITER '|';
1|alice.johnson@gmail.com|4|This Pizza Margherita was absolutely delicious! I couldn't get enough of it, and the combination of the fresh tomato sauce, creamy mozzarella, and fragrant basil was a culinary delight.
2|bob.smith@gmail.com|2|Worst Rösti in my entire life. I was really looking forward to it, but it turned out to be a major disappointment. The potatoes were undercooked, and it lacked flavor.
3|carol.williams@gmail.com|5|The Fondue was outstanding! I was in cheese heaven. The rich, melted cheese paired with crusty bread and an assortment of dipping goodies made this meal a memorable experience.
4|david.jones@gmail.com|1|The Raclette was disappointing. I had high hopes for this dish, but the cheese was not as gooey and flavorful as I expected. It left me wanting more.
5|emily.brown@gmail.com|3|The Carpaccio was decent. The thinly sliced beef was tender, but I wished there was more seasoning and flavor. It was a satisfactory appetizer.
6|frank.davis@gmail.com|5|The BBQ Chicken Burger & Sweet Potato Fries were amazing! The burger was juicy, and the barbecue sauce added a perfect smoky flavor. The sweet potato fries were crispy and slightly sweet – a delightful pairing.
7|grace.white@gmail.com|4|The Spaghetti Carbonara was really good. The creamy sauce and bits of crispy bacon made it a comforting choice. However, it could have used a touch more black pepper for extra flavor.
8|henry.anderson@gmail.com|2|I didn't enjoy the Risotto. The rice was too sticky and lacked the creamy texture I expected. The flavor was underwhelming and needed more seasoning.
1|isabella.martin@gmail.com|5|This Pizza Margherita was fantastic! It transported me to Italy with every bite. The thin, crispy crust combined with the fresh ingredients made it a memorable experience. I'll be dreaming about this pizza for days.
2|jack.thomas@gmail.com|3|The Rösti was okay. It had a nice crispy exterior, but the inside was somewhat undercooked. The dish could use a little more seasoning to enhance the flavor.
3|kate.wilson@gmail.com|5|The Fondue was excellent! It was the perfect blend of cheese, wine, and seasonings. I loved dipping bread and vegetables into the creamy concoction. A must-try for cheese lovers.
4|liam.miller@gmail.com|2|The Raclette was subpar. I was hoping for a gooey, flavorful experience, but the cheese was a bit bland and not as melted as it should be. Disappointing, to say the least.
5|mia.jackson@gmail.com|4|The Carpaccio was tasty. The beef was thinly sliced and tender, and the accompanying sauce added a nice zing. It was a good start to the meal.
6|nathan.moore@gmail.com|5|The BBQ Chicken Burger & Sweet Potato Fries were superb! The burger was incredibly juicy and bursting with smoky, savory flavors. The sweet potato fries were perfectly crispy and provided a delightful contrast. A must-try!
7|olivia.taylor@gmail.com|4|The Spaghetti Carbonara was delightful. The creamy sauce and crispy bacon created a harmonious flavor profile. I would have preferred a little more Parmesan, but it was still enjoyable.
8|peter.harris@gmail.com|3|The Risotto was mediocre. The rice was slightly overcooked, and the dish lacked the creaminess and flavor I expected. It needed more seasoning and perhaps a touch of butter for richness.
1|quinn.walker@gmail.com|3|The Pizza Margherita was average. I expected more from a classic, but it fell short. The crust was a bit too doughy, and the toppings lacked the freshness I anticipated.
2|rachel.clark@gmail.com|5|The Rösti was superb! Crispy on the outside, soft on the inside, and seasoned just right. It's a Swiss delight I'd order again and again.
3|samuel.lewis@gmail.com|4|The Fondue was exceptional! The cheese was rich and gooey, and the bread was the perfect vehicle for scooping up every last bit. A wonderful, indulgent treat.
4|sophia.lee@gmail.com|2|The Raclette was disappointing. The cheese didn't melt as well as it should, and the flavor was lacking. It didn't live up to the traditional Swiss dish I was hoping for.
5|thomas.robinson@gmail.com|5|The Carpaccio was outstanding! The beef was thinly sliced and tender, and the drizzle of olive oil and lemon juice brought out the flavors beautifully. A true delicacy.
6|victoria.turner@gmail.com|5|The BBQ Chicken Burger & Sweet Potato Fries were incredible! The burger was juicy and packed with smoky, mouthwatering goodness. The sweet potato fries were the perfect side, crispy and sweet. A delightful meal.
7|william.hall@gmail.com|4|The Spaghetti Carbonara was really good. The creamy sauce and bacon made it satisfying, but a little more pepper would have made it even better.
8|zoe.garcia@gmail.com|1|I really disliked the Risotto. It was too mushy and bland for my taste. I couldn't finish it.
1|adrian.baker@gmail.com|5|This Pizza Margherita was heavenly! Every bite felt like a slice of Italy. The perfect combination of a thin, crispy crust and the freshest ingredients made this pizza unforgettable.
2|bella.lopez@gmail.com|3|The Rösti was decent. It had a nice, crispy exterior, but the inside was a bit undercooked. It needed a little more seasoning to bring out the flavors.
3|carter.perez@gmail.com|4|The Fondue was impressive! The blend of cheeses and seasonings was delightful, and dipping crusty bread into the warm, gooey mixture was a taste sensation.
4|daisy.cook@gmail.com|2|The Raclette was underwhelming. The cheese didn't melt as expected, and it lacked the robust flavor I had hoped for. A disappointing experience.
5|elijah.collins@gmail.com|3|The Carpaccio was okay. While the beef was thinly sliced and tender, it needed more seasoning to elevate the overall taste. It was decent but not outstanding.
6|fiona.sanchez@gmail.com|5|The BBQ Chicken Burger & Sweet Potato Fries were fantastic! The burger was juicy, flavorful delight, and the sweet potato fries were the perfect complement. An absolute must-try.
7|gavin.morris@gmail.com|5|The Spaghetti Carbonara was amazing! The creamy sauce and crispy bacon made it a comforting choice. It was nearly perfect, just a tad more black pepper would have made it exceptional.
8|hannah.brown@gmail.com|2|I didn't enjoy the Risotto. The rice was overly sticky and lacked the creamy texture and flavor I anticipated. It was a letdown.
1|ian.hall@gmail.com|4|The Pizza Margherita was really good. The crust was crispy, and the toppings were fresh. It wasn't the best I've ever had, but it was definitely enjoyable.
2|jessica.roberts@gmail.com|5|The Rösti was excellent! The crispy exterior and the perfectly cooked interior made it a delightful Swiss dish. A real treat for the taste buds.
3|kyle.barnes@gmail.com|3|The Fondue was decent. The cheese was gooey and warm, but I was expecting a little more complexity in the flavor. It was a satisfying but not outstanding dish.
4|lily.martinez@gmail.com|1|The Raclette was terrible. The cheese didn't melt as it should, and the dish was a bit bland.
5|oliver.allen@gmail.com|2|The Carpaccio was disappointing. It lacked the freshness and zing I expected from this dish. It could have used more seasoning and a livelier sauce.
6|natalie.hernandez@gmail.com|5|The BBQ Chicken Burger & Sweet Potato Fries were superb! The burger was a juicy and flavorful masterpiece, and the sweet potato fries were crispy and delicious. A must-try combination.
7|oliver.allen@gmail.com|4|The Spaghetti Carbonara was delightful. The creamy sauce and crispy bacon created a harmonious flavor profile. I would have preferred a little more Parmesan, but it was still enjoyable.
8|oliver.allen@gmail.com|2|I didn't enjoy the Risotto. The rice was too mushy, and it lacked the rich creaminess and flavor I had anticipated.
3|alice.johnson@gmail.com|4|The Fondue was really good. The combination of cheese and dipping options was delightful.
4|bob.smith@gmail.com|1|The Raclette was terrible. The cheese didn't melt as it should, and the dish lacked the rich, savory taste I expected.
5|carol.williams@gmail.com|2|The Carpaccio was disappointing. It needed more seasoning and a livelier sauce.
6|david.jones@gmail.com|4|The BBQ Chicken Burger & Sweet Potato Fries were great! The burger was juicy, and the barbecue sauce added a delicious smoky flavor.
7|emily.brown@gmail.com|5|The Spaghetti Carbonara was amazing! The creamy sauce and crispy bacon made it comforting and tasty.
8|frank.davis@gmail.com|3|The Risotto was mediocre. It was too sticky, and the flavor was underwhelming.
1|grace.white@gmail.com|4|The Pizza Margherita was excellent. It was a great balance of flavors with a crispy crust.
2|henry.anderson@gmail.com|2|The Rösti was disappointing. I was hoping for more crispiness and flavor.
3|isabella.martin@gmail.com|5|The Fondue was outstanding! The cheese was rich, creamy, and packed with flavor. The dipping selections were a real treat.
4|jack.thomas@gmail.com|1|The Raclette was terrible. The cheese didn't melt properly and was flavorless.
5|kate.wilson@gmail.com|4|The Carpaccio was quite tasty. The meat was thinly sliced and tender, and the overall experience was enjoyable.
6|liam.miller@gmail.com|4|The BBQ Chicken Burger & Sweet Potato Fries were delicious! The burger was juicy and flavorful, and the sweet potato fries were a perfect complement.
7|mia.jackson@gmail.com|5|The Spaghetti Carbonara was fantastic! The creamy sauce and crispy bacon made it a delightful dish.
8|nathan.moore@gmail.com|3|The Risotto was mediocre. The texture was too sticky, and it needed more seasoning.
1|olivia.taylor@gmail.com|3|The Pizza Margherita was average. It didn't quite live up to my expectations. The crust was a bit soggy, and the flavors were just okay.
2|peter.harris@gmail.com|5|The Rösti was superb! Crispy and golden, just the way I like it.
3|quinn.walker@gmail.com|4|The Fondue was impressive! The cheese was perfectly melted, and the dipping choices were divine.
4|rachel.clark@gmail.com|2|The Raclette was underwhelming. The cheese didn't have the richness I was hoping for, and it lacked seasoning.
5|samuel.lewis@gmail.com|5|The Carpaccio was outstanding! Thin slices of meat with a flavorful dressing - it was a tasty appetizer.
6|sophia.lee@gmail.com|5|The BBQ Chicken Burger & Sweet Potato Fries were incredible! The burger was juicy, and the sweet potato fries were seasoned to perfection.
7|thomas.robinson@gmail.com|4|The Spaghetti Carbonara was really good. Creamy and filled with the perfect amount of crispy bacon.
8|victoria.turner@gmail.com|2|The Risotto was disappointing. It was too mushy and lacked the rich flavor I was expecting.
1|william.hall@gmail.com|4|The Pizza Margherita was really good. A classic combination of ingredients on a crispy crust.
2|zoe.garcia@gmail.com|1|I really disliked the Rösti. It was too greasy and lacked flavor.
3|adrian.baker@gmail.com|5|The Fondue was heavenly! The cheese was a flavorful delight, and the accompaniments were superb.
4|bella.lopez@gmail.com|3|The Raclette was decent. The cheese didn't melt as expected, and it lacked the robust flavor I was hoping for.
5|carter.perez@gmail.com|5|The Carpaccio was amazing! Thin slices of meat with a flavorful dressing - it was a tasty appetizer.
6|daisy.cook@gmail.com|4|The BBQ Chicken Burger & Sweet Potato Fries were superb! The burger was juicy, and the sweet potato fries were crispy and delicious.
7|elijah.collins@gmail.com|4|The Spaghetti Carbonara was really good. The creamy sauce and crispy bacon made it a delightful dish.
8|fiona.sanchez@gmail.com|2|I didn't enjoy the Risotto. It was too sticky and lacked the creamy texture I anticipated.
1|gavin.morris@gmail.com|3|The Pizza Margherita was okay. The crust was decent, but the toppings could have been more flavorful.
2|hannah.brown@gmail.com|5|The Rösti was excellent! Crispy and golden, just the way I like it.
3|ian.hall@gmail.com|4|The Fondue was really good. A satisfying blend of cheese and dippers.
4|jessica.roberts@gmail.com|2|The Raclette was underwhelming. The cheese didn't melt properly and was rather bland.
5|kyle.barnes@gmail.com|5|The Carpaccio was outstanding! A delightful mix of flavors and textures.
6|lily.martinez@gmail.com|5|The BBQ Chicken Burger & Sweet Potato Fries were incredible! The burger was juicy, and the sweet potato fries were seasoned to perfection.
7|michael.gonzalez@gmail.com|4|The Spaghetti Carbonara was delightful. Creamy and with a nice balance of flavors.
8|natalie.hernandez@gmail.com|2|The Risotto was disappointing. It lacked the creamy texture and flavor I expected.
1|oliver.allen@gmail.com|4|The Pizza Margherita was really good. The crust was crispy and the ingredients were fresh.
2|pamela.wood@gmail.com|5|The Rösti was superb! It had the perfect combination of crispy and soft. A Swiss classic done right.
3|quincy.rodriguez@gmail.com|4|The Fondue was outstanding! The cheese was rich and creamy, and the accompaniments were delicious.
4|riley.thompson@gmail.com|2|The Raclette was terrible. The cheese didn't melt properly, and it lacked flavor.
5|samantha.cooper@gmail.com|5|The Carpaccio was exceptional! Thin, tender slices of meat with a flavorful dressing.
6|theo.howard@gmail.com|5|The BBQ Chicken Burger & Sweet Potato Fries were amazing! The burger was juicy and flavorful, and the sweet potato fries were crispy and seasoned to perfection.
7|umair.khan@gmail.com|4|The Spaghetti Carbonara was great. Creamy and filled with the right amount of crispy bacon.
8|violet.stewart@gmail.com|2|I didn't enjoy the Risotto. It was too sticky and lacked the creamy texture I anticipated.
1|william.morales@gmail.com|3|The Pizza Margherita was average. It could have been better if the crust was crispier.
2|xavier.morales@gmail.com|5|The Rösti was superb! Crispy on the outside and soft on the inside. A true Swiss delight.
3|yasmine.hall@gmail.com|4|The Fondue was impressive! The cheese was perfectly melted, and the dippers were delightful.
4|zachary.davis@gmail.com|1|The Raclette was terrible. The cheese barely melted, and the taste was lacking.
\.

--
-- Name: order_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tech_user
--

SELECT pg_catalog.setval('public.order_order_id_seq', 151, true);


--
-- Name: plate_plate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tech_user
--

SELECT pg_catalog.setval('public.plate_plate_id_seq', 8, true);
