--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

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

--
-- Name: status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.status AS ENUM (
    'user',
    'admin'
);


ALTER TYPE public.status OWNER TO postgres;

--
-- Name: decrease_ticket_quantity(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.decrease_ticket_quantity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE ticket
    SET available_quantity = available_quantity - NEW.quantity
    WHERE id = NEW.id_ticket;
    
    RETURN NEW;
END;



$$;


ALTER FUNCTION public.decrease_ticket_quantity() OWNER TO postgres;

--
-- Name: increase_ticket_quantity(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.increase_ticket_quantity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE ticket
    SET available_quantity = available_quantity + OLD.quantity
    WHERE id = OLD.id_ticket;
    
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.increase_ticket_quantity() OWNER TO postgres;

--
-- Name: update_available_place(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_available_place() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF NEW.date_time < NOW() THEN
UPDATE event
        SET available_place = 0
        WHERE id = NEW.id_event;
    ELSE
UPDATE event
        SET available_place = (
            SELECT COALESCE(SUM(available_quantity), 0) 
            FROM ticket 
            WHERE id_event = NEW.id_event
        )
        WHERE id = NEW.id_event;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_available_place() OWNER TO postgres;

--
-- Name: update_past_events(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_past_events() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
 UPDATE public.event
    SET available_place = 0
    WHERE date_time < NOW();
UPDATE public.ticket
    SET available_quantity = 0
    WHERE id_event IN (
        SELECT id
        FROM public.event
        WHERE date_time < NOW()
    );
END;
$$;


ALTER FUNCTION public.update_past_events() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event (
    id character varying(10) NOT NULL,
    image character varying(100),
    title character varying(50) NOT NULL,
    date_time timestamp without time zone NOT NULL,
    location character varying(20) NOT NULL,
    category character varying(20) NOT NULL,
    available_place integer NOT NULL
);


ALTER TABLE public.event OWNER TO postgres;

--
-- Name: reservation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservation (
    id integer NOT NULL,
    date_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    id_user integer,
    id_ticket integer,
    quantity integer NOT NULL
);


ALTER TABLE public.reservation OWNER TO postgres;

--
-- Name: reservation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reservation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reservation_id_seq OWNER TO postgres;

--
-- Name: reservation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reservation_id_seq OWNED BY public.reservation.id;


--
-- Name: ticket; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ticket (
    id integer NOT NULL,
    id_event character varying(10),
    price double precision NOT NULL,
    available_quantity integer,
    type character varying(10),
    CONSTRAINT check_type CHECK (((type)::text = ANY ((ARRAY['vip'::character varying, 'standard'::character varying, 'early_bird'::character varying])::text[])))
);


ALTER TABLE public.ticket OWNER TO postgres;

--
-- Name: ticket_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ticket_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ticket_id_seq OWNER TO postgres;

--
-- Name: ticket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ticket_id_seq OWNED BY public.ticket.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(50) NOT NULL,
    password character varying(50) NOT NULL,
    status public.status NOT NULL,
    auth_token text
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_id_seq OWNER TO postgres;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: reservation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation ALTER COLUMN id SET DEFAULT nextval('public.reservation_id_seq'::regclass);


--
-- Name: ticket id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket ALTER COLUMN id SET DEFAULT nextval('public.ticket_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Data for Name: event; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event (id, image, title, date_time, location, category, available_place) FROM stdin;
EVT001	image1.jpg	Concert de Rock	2025-04-01 20:00:00	Paris	Musique	98
EVT003	image3.jpg	Exposition Art	2025-06-20 14:00:00	Marseille	Exposition	49
EVT002	image2.jpg	Conference Tech	2025-05-15 10:00:00	Lyon	Conference	147
\.


--
-- Data for Name: reservation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reservation (id, date_time, id_user, id_ticket, quantity) FROM stdin;
1	2025-03-25 12:30:00	1	1	2
2	2025-03-26 15:00:00	2	3	1
3	2025-03-27 16:00:00	3	2	3
\.


--
-- Data for Name: ticket; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ticket (id, id_event, price, available_quantity, type) FROM stdin;
1	EVT001	30	98	vip
3	EVT003	10	49	early_bird
2	EVT002	20	147	standard
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (id, username, email, password, status, auth_token) FROM stdin;
1	alice_smith	alice.smith@example.com	password123	user	\N
2	bob_johnson	bob.johnson@example.com	password123	user	\N
3	carol_white	carol.white@example.com	password123	user	\N
\.


--
-- Name: reservation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservation_id_seq', 24, true);


--
-- Name: ticket_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ticket_id_seq', 20, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_id_seq', 20, true);


--
-- Name: event event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: reservation reservation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_pkey PRIMARY KEY (id);


--
-- Name: ticket ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_pkey PRIMARY KEY (id);


--
-- Name: user user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_email_key UNIQUE (email);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: ticket trg_update_available_place; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_available_place AFTER INSERT OR DELETE OR UPDATE ON public.ticket FOR EACH ROW EXECUTE FUNCTION public.update_available_place();


--
-- Name: reservation trigger_decrease_ticket_quantity; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_decrease_ticket_quantity AFTER INSERT ON public.reservation FOR EACH ROW EXECUTE FUNCTION public.decrease_ticket_quantity();


--
-- Name: reservation trigger_increase_ticket_quantity; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_increase_ticket_quantity AFTER DELETE ON public.reservation FOR EACH ROW EXECUTE FUNCTION public.increase_ticket_quantity();


--
-- Name: ticket fk_event; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT fk_event FOREIGN KEY (id_event) REFERENCES public.event(id);


--
-- Name: reservation reservation_id_ticket_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_id_ticket_fkey FOREIGN KEY (id_ticket) REFERENCES public.ticket(id);


--
-- Name: reservation reservation_id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_id_user_fkey FOREIGN KEY (id_user) REFERENCES public."user"(id);


--
-- PostgreSQL database dump complete
--

