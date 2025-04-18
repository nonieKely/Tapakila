-- Création du type 'status'
CREATE TYPE public.status AS ENUM (
    'user',
    'admin'
);

-- Fonction decrease_ticket_quantity
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

-- Fonction increase_ticket_quantity
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

-- Fonction update_available_place
CREATE or REPLACE FUNCTION public.update_available_place() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE event
    SET available_place = (
        SELECT COALESCE(SUM(available_quantity), 0)
        FROM ticket
        WHERE id_event = NEW.id_event
    )
    WHERE id = NEW.id_event;

    RETURN NEW;
END;
$$;

-- Fonction update_past_events
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

-- Création de la table 'event'
CREATE TABLE public.event (
    id character varying(10) NOT NULL,
    image character varying(100),
    title character varying(50) NOT NULL,
    date_time timestamp without time zone NOT NULL,
    location character varying(20) NOT NULL,
    category character varying(20) NOT NULL,
    available_place integer NOT NULL,
    description text,
    organizer character varying(20)
);

-- Création de la table 'reservation'
CREATE TABLE public.reservation (
    id integer NOT NULL,
    date_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    id_user integer,
    id_ticket integer,
    quantity integer NOT NULL
);

-- Création de la séquence 'reservation_id_seq'
CREATE SEQUENCE public.reservation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Création de la table 'ticket'
CREATE TABLE public.ticket (
    id integer NOT NULL,
    id_event character varying(10),
    price double precision NOT NULL,
    available_quantity integer,
    type character varying(10),
    CONSTRAINT check_type CHECK (((type)::text = ANY ((ARRAY['vip'::character varying, 'standard'::character varying, 'early_bird'::character varying])::text[])))
);

-- Création de la séquence 'ticket_id_seq'
CREATE SEQUENCE public.ticket_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Création de la table 'user'
CREATE TABLE public."user" (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(50) NOT NULL,
    "password" character varying(50) NOT NULL,
    birthday date NOT NULL,
    phone character varying(20),
    country character varying(50),
    city character varying(50),
    status public.status NOT NULL,
    auth_token text
);

-- Création de la séquence 'user_id_seq'
CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Définition des valeurs par défaut pour les séquences
ALTER TABLE ONLY public.reservation ALTER COLUMN id SET DEFAULT nextval('public.reservation_id_seq'::regclass);
ALTER TABLE ONLY public.ticket ALTER COLUMN id SET DEFAULT nextval('public.ticket_id_seq'::regclass);
ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);

-- Insertion des données dans 'event' (remplacement de COPY par INSERT)
INSERT INTO public.event (id, image, title, date_time, location, category, available_place, description, organizer) VALUES
('EVT001', 'image1.jpg', 'Rock Live', '2025-04-01 20:00:00', 'Paris', 'Music', 98, 'Lorem ipsum dolor 1', 'Organizer A'),
('EVT003', 'image3.jpg', 'Art Expostion', '2025-06-20 14:00:00', 'Marseille', 'Exposition', 49, 'Lorem ipsum dolor 2', 'Organizer B'),
('EVT002', 'image2.jpg', 'Tech Conference', '2025-05-15 10:00:00', 'Lyon', 'Conference', 147, 'Lorem ipsum dolor 3', 'Organizer C');

-- Insertion des données dans 'reservation' (remplacement de COPY par INSERT)
INSERT INTO public.reservation (id, date_time, id_user, id_ticket, quantity) VALUES
(1, '2025-03-25 12:30:00', 1, 1, 2),
(2, '2025-03-26 15:00:00', 2, 3, 1),
(3, '2025-03-27 16:00:00', 3, 2, 3);

-- Insertion des données dans 'ticket' (remplacement de COPY par INSERT)
INSERT INTO public.ticket (id, id_event, price, available_quantity, type) VALUES
(1, 'EVT001', 30, 98, 'vip'),
(3, 'EVT003', 10, 49, 'early_bird'),
(2, 'EVT002', 20, 147, 'standard');

-- Insertion des données dans 'user' (remplacement de COPY par INSERT)
INSERT INTO public."user" VALUES
(1, 'alice_smith', 'alice.smith@example.com', 'password123', '1999-01-01', '+261341234567', 'Madagascar', 'Antananarivo', 'user', NULL),
(2, 'bob_johnson', 'bob.johnson@example.com', 'password123', '1998-01-01', '+261341234467', 'Madagascar', 'Antananarivo', 'user', NULL),
(3, 'carol_white', 'carol.white@example.com', 'password123', '1997-01-01', '+261331234567', 'Madagascar', 'Antananarivo', 'user', NULL);
(4, 'luna', 'luna@gmail.com', 'mandeha', '2000-01-01', '+261332234567', 'Madagascar', 'Antananarivo', 'admin', NULL);

-- Mise à jour des séquences
SELECT pg_catalog.setval('public.reservation_id_seq', 24, true);
SELECT pg_catalog.setval('public.ticket_id_seq', 20, true);
SELECT pg_catalog.setval('public.user_id_seq', 20, true);

-- Création des contraintes
ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_email_key UNIQUE (email);

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_phone_key UNIQUE (phone);

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_token_key UNIQUE (auth_token);

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);

-- Création des triggers
CREATE TRIGGER trg_update_available_place 
    AFTER INSERT OR DELETE OR UPDATE ON public.ticket 
    FOR EACH ROW EXECUTE FUNCTION public.update_available_place();

CREATE TRIGGER trigger_decrease_ticket_quantity 
    AFTER INSERT ON public.reservation 
    FOR EACH ROW EXECUTE FUNCTION public.decrease_ticket_quantity();

CREATE TRIGGER trigger_increase_ticket_quantity 
    AFTER DELETE ON public.reservation 
    FOR EACH ROW EXECUTE FUNCTION public.increase_ticket_quantity();

-- Création des clés étrangères
ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT fk_event FOREIGN KEY (id_event) REFERENCES public.event(id);

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_id_ticket_fkey FOREIGN KEY (id_ticket) REFERENCES public.ticket(id);

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_id_user_fkey FOREIGN KEY (id_user) REFERENCES public."user"(id);
