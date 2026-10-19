--
-- PostgreSQL database dump
--

\restrict OfH3PVBZT351X4Uw1c0l0TyjIUP8pqGAOny7lwebEaid38bYW1IA3pI0LMyhCxs

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

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

ALTER TABLE IF EXISTS ONLY public.property_advantages DROP CONSTRAINT IF EXISTS "fk-properties-property-to-category_properties";
ALTER TABLE IF EXISTS ONLY public.property_advantages DROP CONSTRAINT IF EXISTS "fk-categories-category-to-category_properties";
DROP INDEX IF EXISTS public."IDX_session_expire";
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_username_unique;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_unique;
ALTER TABLE IF EXISTS ONLY public.sessions DROP CONSTRAINT IF EXISTS sessions_pkey;
ALTER TABLE IF EXISTS ONLY public.seaql_migrations DROP CONSTRAINT IF EXISTS seaql_migrations_pkey;
ALTER TABLE IF EXISTS ONLY public.prospeccao_leads DROP CONSTRAINT IF EXISTS prospeccao_leads_pkey;
ALTER TABLE IF EXISTS ONLY public.prospeccao_config DROP CONSTRAINT IF EXISTS prospeccao_config_pkey;
ALTER TABLE IF EXISTS ONLY public.prospeccao_cidades_alvo DROP CONSTRAINT IF EXISTS prospeccao_cidades_alvo_pkey;
ALTER TABLE IF EXISTS ONLY public.prospeccao_batches DROP CONSTRAINT IF EXISTS prospeccao_batches_pkey;
ALTER TABLE IF EXISTS ONLY public.properties DROP CONSTRAINT IF EXISTS properties_pkey;
ALTER TABLE IF EXISTS ONLY public.contacts DROP CONSTRAINT IF EXISTS contacts_pkey;
ALTER TABLE IF EXISTS ONLY public.property_advantages DROP CONSTRAINT IF EXISTS category_properties_pkey;
ALTER TABLE IF EXISTS ONLY public.advantages DROP CONSTRAINT IF EXISTS categories_pkey;
ALTER TABLE IF EXISTS public.prospeccao_cidades_alvo ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.prospeccao_batches ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.property_advantages ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.properties ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.contacts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.advantages ALTER COLUMN id DROP DEFAULT;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.sessions;
DROP TABLE IF EXISTS public.seaql_migrations;
DROP TABLE IF EXISTS public.prospeccao_leads;
DROP TABLE IF EXISTS public.prospeccao_config;
DROP SEQUENCE IF EXISTS public.prospeccao_cidades_alvo_id_seq;
DROP TABLE IF EXISTS public.prospeccao_cidades_alvo;
DROP SEQUENCE IF EXISTS public.prospeccao_batches_id_seq;
DROP TABLE IF EXISTS public.prospeccao_batches;
DROP SEQUENCE IF EXISTS public.properties_id_seq;
DROP TABLE IF EXISTS public.properties;
DROP SEQUENCE IF EXISTS public.contacts_id_seq;
DROP TABLE IF EXISTS public.contacts;
DROP SEQUENCE IF EXISTS public.category_properties_id_seq;
DROP TABLE IF EXISTS public.property_advantages;
DROP SEQUENCE IF EXISTS public.categories_id_seq;
DROP TABLE IF EXISTS public.advantages;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: advantages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.advantages (
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id integer NOT NULL,
    name character varying NOT NULL,
    icon character varying(100),
    description text
);


ALTER TABLE public.advantages OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_id_seq OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.advantages.id;


--
-- Name: property_advantages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.property_advantages (
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id integer NOT NULL,
    advantage_id integer NOT NULL,
    property_id integer NOT NULL
);


ALTER TABLE public.property_advantages OWNER TO postgres;

--
-- Name: category_properties_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.category_properties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.category_properties_id_seq OWNER TO postgres;

--
-- Name: category_properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.category_properties_id_seq OWNED BY public.property_advantages.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contacts (
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id integer NOT NULL,
    name character varying NOT NULL,
    phone character varying NOT NULL,
    email character varying,
    message text NOT NULL,
    property_id integer
);


ALTER TABLE public.contacts OWNER TO postgres;

--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contacts_id_seq OWNER TO postgres;

--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: properties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.properties (
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id integer NOT NULL,
    title character varying NOT NULL,
    description text NOT NULL,
    type character varying NOT NULL,
    category character varying NOT NULL,
    price bigint NOT NULL,
    neighborhood character varying NOT NULL,
    bedrooms integer NOT NULL,
    bathrooms integer NOT NULL,
    area real NOT NULL,
    image_urls text NOT NULL,
    video_url character varying,
    status character varying DEFAULT 'available'::character varying NOT NULL,
    city text DEFAULT 'Juazeiro'::text NOT NULL,
    state text DEFAULT 'BA'::text NOT NULL
);


ALTER TABLE public.properties OWNER TO postgres;

--
-- Name: properties_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.properties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.properties_id_seq OWNER TO postgres;

--
-- Name: properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.properties_id_seq OWNED BY public.properties.id;


--
-- Name: prospeccao_batches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prospeccao_batches (
    id integer NOT NULL,
    batch_id text NOT NULL,
    fonte text DEFAULT 'olx.com.br'::text NOT NULL,
    estado text NOT NULL,
    cidade text NOT NULL,
    tipo text NOT NULL,
    modalidade text NOT NULL,
    total_encontrados integer DEFAULT 0 NOT NULL,
    novos_encontrados integer DEFAULT 0 NOT NULL,
    removidos_encontrados integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.prospeccao_batches OWNER TO postgres;

--
-- Name: prospeccao_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.prospeccao_batches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prospeccao_batches_id_seq OWNER TO postgres;

--
-- Name: prospeccao_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.prospeccao_batches_id_seq OWNED BY public.prospeccao_batches.id;


--
-- Name: prospeccao_cidades_alvo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prospeccao_cidades_alvo (
    id integer NOT NULL,
    estado text NOT NULL,
    cidade text NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.prospeccao_cidades_alvo OWNER TO postgres;

--
-- Name: prospeccao_cidades_alvo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.prospeccao_cidades_alvo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prospeccao_cidades_alvo_id_seq OWNER TO postgres;

--
-- Name: prospeccao_cidades_alvo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.prospeccao_cidades_alvo_id_seq OWNED BY public.prospeccao_cidades_alvo.id;


--
-- Name: prospeccao_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prospeccao_config (
    id integer DEFAULT 1 NOT NULL,
    polling_schedules jsonb DEFAULT '["08:00", "12:00", "16:00", "20:00"]'::jsonb NOT NULL,
    auto_polling_enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.prospeccao_config OWNER TO postgres;

--
-- Name: prospeccao_leads; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prospeccao_leads (
    id text NOT NULL,
    titulo text NOT NULL,
    link text NOT NULL,
    fonte text DEFAULT 'olx.com.br (Particular)'::text NOT NULL,
    trecho text,
    direto_proprietario boolean DEFAULT true NOT NULL,
    cidade text NOT NULL,
    estado text NOT NULL,
    tipo text NOT NULL,
    modalidade text NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    is_new boolean DEFAULT true NOT NULL,
    first_seen_at timestamp without time zone DEFAULT now(),
    last_seen_at timestamp without time zone DEFAULT now(),
    last_batch_id text
);


ALTER TABLE public.prospeccao_leads OWNER TO postgres;

--
-- Name: seaql_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seaql_migrations (
    version character varying NOT NULL,
    applied_at bigint NOT NULL
);


ALTER TABLE public.seaql_migrations OWNER TO postgres;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    sid character varying NOT NULL,
    sess jsonb NOT NULL,
    expire timestamp without time zone NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    username character varying,
    email character varying,
    password_hash character varying,
    first_name character varying,
    last_name character varying,
    role character varying DEFAULT 'user'::character varying,
    profile_image_url character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: advantages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.advantages ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: properties id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.properties ALTER COLUMN id SET DEFAULT nextval('public.properties_id_seq'::regclass);


--
-- Name: property_advantages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.property_advantages ALTER COLUMN id SET DEFAULT nextval('public.category_properties_id_seq'::regclass);


--
-- Name: prospeccao_batches id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prospeccao_batches ALTER COLUMN id SET DEFAULT nextval('public.prospeccao_batches_id_seq'::regclass);


--
-- Name: prospeccao_cidades_alvo id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prospeccao_cidades_alvo ALTER COLUMN id SET DEFAULT nextval('public.prospeccao_cidades_alvo_id_seq'::regclass);


--
-- Data for Name: advantages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.advantages (created_at, updated_at, id, name, icon, description) FROM stdin;
2026-03-26 01:41:46.863975+00	2026-03-26 01:41:46.863975+00	3	Garagem interna	fa-car	\N
2026-03-26 01:42:31.232324+00	2026-03-26 01:42:31.232324+00	4	Próximo a Escolas	fa-graduation-cap	\N
2026-03-26 01:43:09.078451+00	2026-03-26 01:43:09.078451+00	5	Próximo a Faculdades	fa-microscope	\N
2026-03-26 01:43:51.274385+00	2026-03-26 01:43:51.274385+00	6	Piscina	fa-person-swimming	\N
2026-03-26 01:44:09.69641+00	2026-03-26 01:44:55.440264+00	7	Academia no Condominio	fa-dumbbell	\N
2026-03-26 01:45:40.628828+00	2026-03-26 01:45:40.628828+00	8	Salão de festas	fa-champagne-glasses	\N
2026-03-26 01:46:30.916681+00	2026-03-26 01:46:30.916681+00	9	Portaria 24h	fa-hand-fist	\N
2026-03-26 01:47:20.982346+00	2026-03-26 01:47:20.982346+00	10	Próximo a praias	fa-umbrella-beach	\N
2026-03-26 01:48:06.161837+00	2026-03-26 01:48:06.161837+00	11	Nascente total	fa-sun	\N
2026-03-26 01:49:00.51978+00	2026-03-26 01:49:00.51978+00	12	Próximo a restaurantes	fa-utensils	\N
2026-03-26 01:51:08.132931+00	2026-03-26 01:51:08.132931+00	13	Ar condicionado	fa-snowflake	\N
2026-03-26 01:51:45.435087+00	2026-03-26 01:51:45.435087+00	14	Energia solar	fa-bolt	\N
2026-03-26 01:55:06.548625+00	2026-03-26 01:55:06.548625+00	15	Salão de jogos	fa-table-tennis-paddle-ball	\N
2026-03-26 12:39:50.808006+00	2026-03-26 12:39:50.808006+00	17	Móveis planejados	fa-couch	\N
2026-03-26 12:40:43.401288+00	2026-03-26 12:40:43.401288+00	18	Área Gourmet	fa-mug-saucer	\N
2026-03-26 12:41:44.797525+00	2026-03-26 12:42:20.122553+00	19	Churrasqueira	fa-warehouse	\N
2026-03-26 13:27:04.343749+00	2026-03-26 13:27:04.343749+00	20	Closet	fa-hospital	\N
2026-03-25 22:35:48.857827+00	2026-03-26 13:28:12.007584+00	1	Excelente Localização	fa-magnifying-glass	\N
2026-03-26 13:29:47.25302+00	2026-03-26 13:29:47.25302+00	21	Suite	fa-bed	\N
2026-03-27 11:35:43.266614+00	2026-03-27 11:35:43.266614+00	22	Documentação em dia.	fa-envira	\N
\.


--
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contacts (created_at, updated_at, id, name, phone, email, message, property_id) FROM stdin;
\.


--
-- Data for Name: properties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.properties (created_at, updated_at, id, title, description, type, category, price, neighborhood, bedrooms, bathrooms, area, image_urls, video_url, status, city, state) FROM stdin;
2026-04-05 15:01:08.899794+00	2026-04-05 16:38:00.267214+00	14	Terreno a venda no Condomínio Residencial Bosque do Rio, Juazeiro-BA - IMOVIU	Terreno a venda no Condomínio Residencial Bosque do Rio, Juazeiro-BA\nLocalização: Rod. Juazeiro Sobradinho, 100 - Pedra do Lord, Juazeiro - BA, 48900-360\n-Área: 227,5m²;\n-Lote Nascente;\n-Apenas 300m de distância do rio;\n-Área de lazer;\n-Marina;\n-Condomínio com extensa Área Verde/Área de preservação;\n-Acesso direito ao Rio São Francisco;\n-Localizado em frente à Ilha do Massangano e Ilha do Maroto;\n-Fica a 2,5km da entrada da Ilha do Rodeadouro;\n\nValor: R$80.000,00\n	sale	land	80000	Pedra do Lord	0	0	228	["https://luizspinolaimoveis.com.br/imovel-facil/1775406069284-bb53b908b7fa4aea91b83d9d48a67716.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775406083843-1af8977a46e94e4c886179960f0f30ce.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775406083850-f40e439226514c4b9413550ad954e147.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775406083855-b132bf8c5c924de68933d593e9f2a35e.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775406083861-28f3547fbfc54e2b87f5e56aff84f951.jpg"]	https://youtu.be/PrekFbqdt-g	available	Juazeiro	BA
2026-03-26 03:09:00.329644+00	2026-03-26 03:10:57.960684+00	6	Terreno localizado na Rua Paraiba, Novo Encontro, Juazeiro, Bahia - IMOVIU	Terreno plano, com 311m2, são dois imóveis geminados, o outro tem 368m2, valor de venda 155.000,00, perto de Colégios, hospitais, mercados, restaurantes, localizado perto da Rua das Algarobas, Novo Encontro, Juazeiro, Bahia - IMOVIU	sale	land	135000	Novo Encontro	0	0	311	["https://luizspinolaimoveis.com.br/imovel-facil/1774494471329-89c3b8557ab04805acfc0f811d87a92a.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774494484967-6a08f35744ce445789370211322e2572.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774494484973-6ac816c462ef4fbf93c3d5a5d9f83847.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774494510648-a503527ec33242c38e6bcb8f195ff62f.jpg"]	\N	available	Juazeiro	BA
2026-03-26 01:12:56.845448+00	2026-03-26 02:05:46.130491+00	4	Apartamento 2/4 para locação, suite, Condominio Ville Costa dos Coqueiros, Lauro de Freitas, Bahia - IMOVIU	Apartamento 2/4, 1 suite, térreo, área gourmet, garagem próxima, moveis planejados em todos os ambientes, portaria 24 horas, ao lado do Parque Shopping Bahia, perto de escolas, faculdades, hospitais, mercados, metrô, 50 metros da estrada do côco, ao lado do Centro Administrativo de Lauro de Freitas. Taxa de condominio R$ 530,00 não incluso. Para mais informações e fotos acesse o site: www.luizspinolaimoveis.com.br	rent	apartment	2000	Aracui	2	2	60	["https://luizspinolaimoveis.com.br/imovel-facil/1774487459983-4038dabc4498475b9358ccfd5f275934.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774487487522-f0039a2748c146b293e0e9628b42a918.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488574508-9b7a5396ff454c6a9beaf5128e164a12.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488574516-c62e0a099d274d519e835f2b908abb5c.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488585965-04cdbca456d9487db994b44a130dae6b.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488585970-b698e578fd9544ab91d18cf5b115e9d4.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488585975-f71d40cab72e4f7da1924899736e3e93.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488585980-562961b180e34bf9a9bd2b979e85c330.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488641859-fd0d62bb7dda4f369cc7227feda69709.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488641864-2711ae177a5a44219edb6dfc90a3a762.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488657878-95aa2c10e663496a84f0c2d800eee38e.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488657886-093e156083744b389fbdd7658361078a.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488678281-8b505849bff541c9a04888652043f999.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488678287-107e040de6cb45b7973f2bbe26efc3d1.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488695736-6d05da559b144dad9409e203842b17d9.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488695742-6170068f62d04c7d9905ea7199f00f9f.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774488717970-3998a39ed8d747149fe716d3f2b68296.jpg"]	https://youtube.com/shorts/IllHaHv1TiQ	available	Juazeiro	BA
2026-03-26 12:39:01.552598+00	2026-03-26 12:50:18.821615+00	9	Vendemos apartamento no Edificio Jardim Primavera, Juazeiro, Bahia - IMOVIU	Apartamento 2/4, uma suite com closet, 70m2, móveis planejados, 19o. andar. 	sale	apartment	650000	Pedra do Lord	2	2	70	["https://luizspinolaimoveis.com.br/imovel-facil/1774529319172-55dff3fc479e49f3943d6f29c9225175.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774529329306-9f2a4f622fac495e930eb2bb20980c9c.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774529329313-fd96f24f389b4e2a9c6abc08f4b9fa97.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774529338681-b6674be76c7840e2a2e16f567e9f8c21.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774529338694-0cd1fe0dfc994cf7a329c4fc95d6b566.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774529338698-7d285befa2b94a7b9bf74b46f6057398.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774529351746-0366b296765947549347fb8211386580.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774529351752-699752d50e884ded8e1b582f2f3e4dfd.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774529351757-5602c2e4f02140608aa499507d4d8c14.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774529368114-b5cf8bd8bf9c4a2cb8f36fa520e5f591.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774529368120-ed7d25a39ced4e82a72ce0125d048a07.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774529368127-4f7ce793e5ec4348bd48b9aa664aadbb.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774529387061-5e18134e233a4d309402bd4e60b38dd6.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774529387068-5ff4039edc8e4856a77037b646e97634.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774529387074-ab09150f52304053957dadd421e8f946.jpg"]	\N	available	Juazeiro	BA
2026-04-30 09:13:06.686181+00	2026-05-02 13:47:39.42084+00	16	Beleza Natural Pousada - Morro de São Paulo - Bahia	Rodeada pela natureza, a Beleza Natural Pousada situa-se no centro de Morro de São Paulo, perto da praia, de bares e lojas. Com uma belíssima área verde de 500m², possui uma piscina e vista para o mar, sem contar o nascer do sol e da lua de tirar o fôlego! Nós buscamos sempre trazer uma harmonia entre nossos clientes e a natureza, para que a hospedagem seja uma experiência única. Possuímos suítes duplas, triplas e quíntuplas climatizadas, com acesso ao Wi-fi gratuito em toda pousada. O buffet de café-da-manhã inclui frutas, pães, bolos e depois de comer, você pode relaxar em nossas cadeiras de praia na piscina apreciando o som da natureza. Área construida 280m2, área verde 500m2.\nMais informações: https://www.instagram.com/belezanaturalpousada/\n\n	sale	commercial	4000000	Centro	10	12	280	{"https://luizspinolaimoveis.com.br/imovel-facil/1777540372856-3194d502e5704733b0b72e7491513eac.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1777540384350-1b34e6cc0b264d40ba6db5ad30938d49.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1777540384364-9051c903c65d4f17bba28ecbba4b31ad.jpg","]"}	https://youtube.com/shorts/xtHagyA7w2A?feature=share	available	Juazeiro	BA
2026-05-03 14:31:06.875451+00	2026-05-10 12:21:03.073065+00	21	Excelente casa - Bairro Santo Antônio-Juazeiro, 120m2, terreno 250m²	Excelente casa bem localizada ao lado do Condomínio Santo Antônio, com 120m2, área total, 250m2, 3 Quartos (uma suite), 2 salas, 4 Vagas para carros, 2 Banheiros, área de serviço, próximo ao Colégio Prisma, mercado , farmácia, etc \nRua Marques de São Vicente, Santo Antônio, Juazeiro/BA. Mais informações no site: https:/www.luizspinolaimoveis.com.br - IMOVIU	sale	house	420000	Santo Antonio	3	2	120	["https://luizspinolaimoveis.com.br/imovel-facil/1777819286422-8564cb6857ed4de69ece48ae89de5a13.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1777819333037-ddb543770574442192f91ff2a9780726.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1777819333042-79edf9ce42ce4694b713aa070e379796.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1777819333046-8da4d9d47c9242c084aa439964830dfb.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1778415646584-303a3d5ec0b542578a8db2589a68ff4f.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1778415646590-6fec13e3585a4385bbaa78bf1ce2a862.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1778415646596-acd3d1c2e4a04789b492c6ff2a53e70f.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1778415646603-cfc309e039a94783848ce60f675147ee.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1778415646608-323ccdc9f38b4c909191879d1fb7f0dc.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1778415646612-4e2d5bf4e2bf47dd96043b32bd0f0002.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1778415646618-d5f8378588534adca76db57f19f3cd6c.jpg"]	\N	available	Juazeiro	BA
2026-03-26 13:18:47.888842+00	2026-03-26 13:32:07.580294+00	10	Vendemos linda casa no Condominio Vila Premium, Pedra do Lord, Juazeiro, Bahia - IMOVIU	CASA NO CONDOMÍNIO VILLA PREMIUM\nQuadra B , Nº 14\nÁrea construída = 175,77 M2\nPiso : Porcelanato TECNOGRES\nSALA para 2 ambientes \nPorta de entrada de 4,50 metros de altura com fechadura eletrônica\nJanelão de 4,50 de altura por 1,85 de Largura \n3 SUITES (sendo 1 com closet amplo)\nCOZINHA integrada com a sala e com a área gourmet\nDepósito \nCasa para botijão com instalação \nÁrea Gourmet com WC , churrasqueira e pia , 2 caixas de som no teto\nPiscina com Deck amplo, chuveirão, piso porcelanato emadeirado	sale	house	850000	Pedra do Lord	3	5	176	["https://luizspinolaimoveis.com.br/imovel-facil/1774530771578-311d2cb6791b470d84577bf880a1c6e5.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774530784550-dd0bd5d5fe37447bbbcb4a087eb0d9cd.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774530784553-05ca139a10244a789dbb65f64845c75d.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774530784556-8bd6d9c8f0344bc594e37ee60bce9478.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774530798199-219b3b2276b64314bc7dac8b0101fd5a.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774530798203-01a18916200543c3902166a962824a81.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774530798205-ec5048cd74bc4a559b9cf5c76c1b4b6b.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774530798208-87ab70790c5d4ce1a393bf0901e2eb64.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774530813861-1e2d6450fea845b59ed9e7a036bc94c4.jpg"]	https://www.youtube.com/shorts/sPl4Xa1siKM	available	Juazeiro	BA
2026-04-01 11:43:57.380998+00	2026-04-01 12:52:09.764765+00	12	Casa Aluguel Condominio Vila Verde, Piranga, Juazeiro - Bahia - IMOVIU	Aluga-se CASA localizada na avenida PRINCIPAL da Piranga, no Condomínio Vila Verde, Juazeiro-Ba.\n* Imóvel composto de: 4 quartos sendo uma suíte com closet e 1 quarto reversível, cozinha planejada, área gourmet com churrasqueira, sala, 2  banheiros sociais, área de serviço, garagem.\n* Imóvel com móveis planejados nos quartos, cozinha, área gourmet \n* Área: 200 m²\n* Condomínio privado com 20 casas\n* Condomínio consta: Piscina, área de lazer para adultos e crianças.\n\nEndereço: Avenida Giuseppe Muccini, 641, Condomínio Vila Verde, Piranga, Juazeiro-Ba \nValor: R$ 3.000,00	rent	house	3000	Piranga	4	3	200	["https://luizspinolaimoveis.com.br/imovel-facil/1775043741674-c0086fe1df6149eaa2050a289a1645ff.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043741708-8fd091d6247c49d3a2d37979519dd558.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043741712-aec495b2c66b46c487dba5191f29fb06.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043758974-1e492cb1e6f7479f93ac1423f2620ea6.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043758983-28ae91657c7847d583a69b66049f7b29.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043758990-015ef5ed19ff46888da5374e8a67a364.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043777698-3413684be6d446e7b46c5471dd22ae6a.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043777704-f795786429b14ed1b744a5a5bc4d78a6.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043777716-750dcfb69ca249de8998375f8574b324.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043777725-921059ba161649a191b978cff4cf44b1.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043793454-436e7d296bec497895f445e49018ead7.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043793462-acfc933cb1324e888202c1866caa78e0.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043793478-512645892d1f433ba6a8ac9ffd44b5a3.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043806452-dcb324aed4864a3d9e5dd3e0980d6d57.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043806460-25734b633bbd412385ac7a276bc6165a.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775043806464-8e8b6d86c41847c3ab1373a9f31b5592.jpg"]	\N	available	Juazeiro	BA
2026-04-01 13:03:25.304444+00	2026-04-07 19:38:25.166824+00	13	Aluguel casa nova, localizada no Condomínio Sunville Mais Viver, Petrolina-PE - IMOVIU	Aluga-se CASA NOVA localizada no Condomínio Sunville Mais Viver, Petrolina-PE.\n\n* Imóvel novo\n* Imóvel composto de: 2 quartos sendo uma suíte, cozinha americana, sala, banheiro, área de serviço.\n* Condomínio fechado\n* Condomínio consta: Piscina, quadra poliesportiva, área de lazer para adultos e crianças.\n\nEndereço: Rua Nossa Senhora do Rosário, 778, Antônio Cassimiro, Petrolina-PE\nValor: R$ 1.600,00\n	rent	house	1600	Antonio Cassimiro	2	2	120	["https://luizspinolaimoveis.com.br/imovel-facil/1775049169129-0028a37bfc824b419454d6fc0b5a351b.jpg"]	\N	available	Juazeiro	BA
2026-04-05 17:37:31.901042+00	2026-04-05 19:38:47.79642+00	15	Sala Comercial para locação no Centro de Juazeiro, Bahia - IMOVIU	Sala Comercial na Rua Fernandes da Cunha (logo após a praça do Boi), Centro, Juazeiro (BA).\n30 m² no 2º andar (com escadas).\nExcelente localização no centro da cidade., próximo à Igreja Catedral e ao Comercio.\nO valor já inclui o aluguel, água, IPTU e Internet (link de 1000 MB compartilhado entre 4 salas comerciais). * Sem taxa de condomínio.\nValor: R$1.500,00.\nPrazo mínimo da locação: 02 (dois) anos.\nCaução: 02 (dois) meses de aluguel.\n(71) 9.8219-5098\nOutras salas à disposição a partir de março de 2026, com 20m² e com 155m².\n	rent	commercial	1500	Centro	0	0	30	["https://luizspinolaimoveis.com.br/imovel-facil/1775411674955-822fa12549ec489ca982ac4121698248.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775411697238-cea89def28c04e3e9f5bf25c9df6b063.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775411697242-ec52f04568134d27ac09c9b93134f139.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775411697246-b77c59cae79a463fad85a11f20c08198.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775411697249-16d0579f2c2a4699a598ffd0f40cd1fc.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775411714842-471de487d53c4349af81e15463f79b46.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775411714846-0e6f1fd1a7c54889b109186e44239842.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775411714849-50f8c905ae694ac3ae974cfa2405dc8c.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1775411714852-f1a2289ce4e3400e9162e65d18484e82.jpg"]	\N	available	Juazeiro	BA
2026-04-30 09:30:50.021363+00	2026-04-30 09:34:25.707861+00	17	Apartamento para alugar bem localizado na Orla de Juazeiro-Ba com vista direta ao Rio São Francisco.	Apartamento para alugar bem localizado na Orla de Juazeiro-Ba com vista direta ao Rio São Francisco. * Imóvel composto de: 3 quartos sendo uma suíte com armários planejados e climatizados, cozinha com armários planejados, sala climatizada, 2 banheiros  sociais, área de serviço, estacionamento para 2 veículos.\n* Área: 125 m²\n* Condomínio privado com portaria 24h.\nEndereço: Condomíno Arc de Triomphe, apto 201, Avenida Carmela Dutra, 362, Orla, Juazeiro-Ba.\n\n\n	rent	apartment	3800	Orla - Juazeiro	3	2	125	["https://luizspinolaimoveis.com.br/imovel-facil/1777541441248-05f98e7e7f674cec9210e5fbdd95aeb0.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1777541447581-2e111e23029c4773847381d68b017ebe.jpg"]	https://youtube.com/shorts/1sYfczTZW7s?feature=share	available	Juazeiro	BA
2026-05-02 17:33:06.764821+00	2026-05-02 17:39:34.602221+00	20	OPORTUNIDADE ÚNICA EM JUAZEIRO - Casa pronta para morar. - Bairro Jardim Brasilia	Você não vai encontrar uma metragem melhor por esse valor! Imóvel com excelente potencial, ideal para quem busca sair do aluguel ou investir em reforma para revenda. Detalhes do imóvel: 2 Quartos, 2 Banheiros, sala, cozinha e salão Área Externa. Quintal murado para total privacidade. Terreno: 5x20m (100 m²). Localização: Bairro Jardim Brasília - Rua Um. Preço para fechar negócio hoje! Não perca tempo com burocracia!\n	sale	house	120000	Jardim Brasilia	2	2	100	["https://luizspinolaimoveis.com.br/imovel-facil/1777743542136-5ed10d0e27154abea086b1229f8fde21.jpg"]	\N	available	Juazeiro	BA
2026-05-02 13:33:13.669967+00	2026-05-02 13:45:35.275923+00	18	Casa a venda na Rua das Bromélias, Centenário, Juazeiro, Bahia	Casa a venda, documentação atualizada, ótima localização, centro de Juazeiro, próximo a Avenida Adolfo Viana, são 3 quartos, sala, cozinha e um banheiro, um garagem. Necessita reforma.	sale	house	135000	Centenário	3	1	120	["https://luizspinolaimoveis.com.br/imovel-facil/1777729069307-9fc245a27a7e4d0d99dbbd4558056728.png","https://luizspinolaimoveis.com.br/imovel-facil/1777729250662-0ccedde2ff0d47faa00c1f4e43776740.png","https://luizspinolaimoveis.com.br/imovel-facil/1777729263418-fee0cc96c4684f1ba965ed80fcff0f38.png","https://luizspinolaimoveis.com.br/imovel-facil/1777729274130-cc1db2b1006647f2a7f6fe1fc8b59459.png","https://luizspinolaimoveis.com.br/imovel-facil/1777729407536-a7bde835e25c4819bf5d28c65a4c04e4.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1777729512368-789d8dfb26d444ac8398eef8d2bacf05.jpg"]	\N	available	Juazeiro	BA
2026-05-02 14:17:31.038028+00	2026-05-02 18:58:08.941544+00	19	Alugo Galpão próximo ao Hospital São Lucas, Juazeiro, Bahia	Alugo Galpão em Frente ao Supermercado Frango Brilhante próximo ao Hospital São Lucas! Próximo ao Assaí  na Avenida São João.\n210 metros Quadrado  banheiro escritório e área de serviço.	rent	commercial	4000	Piranga	0	1	210	["https://luizspinolaimoveis.com.br/imovel-facil/1777731448468-76b4468e5cfc404f9992367d9dbc0dc4.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1777731448472-216a1cae275d4654b616b6e75be30aaa.jpg"]	\N	available	Juazeiro	BA
2026-05-21 11:50:28.102978+00	2026-05-21 11:50:28.102978+00	24	Aluga-se terreno comercial, Juazeiro, Bahia - IMOVIU	Aluga-se terreno comercial\n\n* Área: 55 X 200\n* Área total: 5.500 mil m²\n* R$ 7 reais m²\n* Excelente para indústrias, supermercados, atacado, oficina, postos de gasolina, etc...\n\nEndereço: BR 407, Distrito Industrial, Juazeiro-Ba. Frente a Mavel concessionária de veículos.\n	rent	land	7700	Distrito Industrial	0	0	5500	[]	\N	available	Juazeiro	BA
2026-05-21 11:46:55.779531+00	2026-05-21 11:48:00.394017+00	23	Aluga-se prédio comercial Juazeiro, Bahia - IMOVIU	Prédio comercial. * Área: 12 X 22,50\n* Área total: 270 m² \n* Imóvel composto de: vão livre, 2 banheiros sociais.\n* Ótimo para: Supermercados, Material construção, Igrejas, comércio em geral.\n* Avenida principal da Aliança de alto tráfego\n\nEndereço: Avenida Irmã Dulce, Alto da Aliança, Juazeiro-Ba \n	rent	commercial	3750	Alto da Aliança	0	0	0	{"https://luizspinolaimoveis.com.br/imovel-facil/1779363727781-b55f2c7dd3234b048096aa0bcc53e9f8.jpg","]"}	https://www.youtube.com/shorts/NPrtQMXrArM	available	Juazeiro	BA
2026-05-21 11:57:16.379752+00	2026-05-21 11:57:16.379752+00	25	Aluga-se CASA NOVA localizada no Condomínio Sunville Mais Viver, Petrolina-PE - IMOVIU	Aluga-se CASA NOVA localizada no Condomínio Sunville Mais Viver, Petrolina-PE.\n\n* Imóvel novo\n* Imóvel composto de: 2 quartos sendo uma suíte, cozinha americana, sala, banheiro, área de serviço.\n* Condomínio fechado\n* Condomínio consta: Piscina, quadra poliesportiva, área de lazer para adultos e crianças.\n\nEndereço: Rua Nossa Senhora do Rosário, 778, Antônio Cassimiro, Petrolina-PE	rent	house	1600	Antonio Cassimiro, Petrolina	2	3	60	{"https://luizspinolaimoveis.com.br/imovel-facil/1779364531238-1a27a8816f144447a54ec3bc57352358.jpg"}	https://www.youtube.com/shorts/TAYh9KVjgIM	available	Juazeiro	BA
2026-07-03 20:01:18.351888+00	2026-07-03 20:01:18.351888+00	28	Casa a venda em Padre Cícero, Petrolina	Casa com garagem para 02 carros, área de 76,00m2 na laje .\n	sale	house	320000	Padre Cicero	2	1	76	{"https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783694962477-0301c837b499.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783694962489-7db95108b12b.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783694962491-b9c14d8dd9b1.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783694962493-b448f33e915a.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783694962495-8e0a1be0bdb1.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783694962495-db3a4ce3e1eb.jpg"}	https://www.youtube.com/watch?v=WKFjstF7S9o	available	Petrolina	PE
2026-07-12 22:32:21.12116+00	2026-07-12 22:32:21.12116+00	30	ALUGA-SE EXCELENTE CASA NO CONDOMÍNIO COUNTRY CLUB – JUAZEIRO/BA	ALUGA-SE EXCELENTE CASA NO CONDOMÍNIO COUNTRY CLUB – JUAZEIRO/BA\n\nSe você procura conforto, segurança e qualidade de vida, esta é a oportunidade ideal!\n\nLocalizada no Condomínio Country Club, um dos endereços mais valorizados de Juazeiro/BA, esta excelente residência oferece ambientes amplos, modernos e planejados para proporcionar o máximo de conforto à sua família.\n\nCaracterísticas do imóvel:\n\n✅ Área total de 500 m²;\n\n✅ 4 quartos, sendo suítes com closet;\n\n✅ Sala ampla;\n\n✅ Sala com isolamento acústico, ideal para home theater, estúdio ou ambiente de entretenimento;\n\n✅ Banheiro social;\n\n✅ Cozinha planejada;\n\n✅ Área gourmet completa com churrasqueira;\n\n✅ Piscina;\n\n✅ Banheiro de apoio na área da piscina;\n\n✅ Área de serviço;\n\n✅ Garagem;\n\n✅ Condomínio fechado com segurança e tranquilidade.\n\nEndereço:\nCondomínio Country Club\nAv. Miguel Silva Souza, nº 590\nPalmares – Juazeiro/BA\n\nValor do aluguel:\n\nR$ 6.000,00 (valor negociável).\n\nUma excelente opção para quem deseja morar com conforto, privacidade e segurança, em uma localização privilegiada de Juazeiro.\n\nAgende sua visita e conheça este belíssimo imóvel!	rent	house	6000	Country	4	4	500	{"https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783895822742-3a9ac682773f.jpg"}	https://youtube.com/shorts/NMnSjsRUEr4	available	Juazeiro	BA
2026-07-12 19:18:13.376251+00	2026-07-12 19:18:13.376251+00	29	CASA PARA LOCAÇÃO NO CONDOMÍNIO PARK CENTENÁRIO – JUAZEIRO/BA - IMOVIU	🏠 CASA PARA LOCAÇÃO EM CONDOMÍNIO FECHADO – JUAZEIRO/BA\nDescrição do Imóvel\nSe você busca conforto, segurança e uma infraestrutura completa para a sua família, esta é a oportunidade ideal! Localizada no prestigiado Condomínio Park Centenário, no bairro Jardim Novo Encontro, esta excelente casa duplex de 200 m² oferece ambientes amplos, bem arejados e uma distribuição inteligente do espaço.\nDestaques do Imóvel:\n * Área Total: 200 m²\n * Dormitórios: 3 quartos (sendo 1 suíte aconchegante)\n * Banheiros: 1 banheiro social bem equipado\n * Salas: Sala de estar ampla e iluminada\n * Cozinha: Espaçosa, ideal para o dia a dia\n * Área Externa: Varanda agradável no pavimento superior e área de serviço funcional\n * Vagas de Garagem: Estacionamento privativo para 2 veículos\nInfraestrutura do Condomínio Park Centenário\nMorar aqui é sinônimo de tranquilidade e lazer sem sair de casa. O condomínio oferece:\n * Portaria e segurança 24h\n * Piscina com área gourmet integrada (perfeita para receber amigos e família)\n * Área de lazer dedicada para as crianças\n * Quadra de areia para práticas esportivas\nCondições Comerciais\n * Valor do Aluguel: R$ 1.800,00 (Aberto a negociações)\n * Endereço: Rua Bela Vista, Jardim Novo Encontro – Juazeiro - BA	rent	house	1800	Novo Encontro	3	2	200	{"https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783884206546-5cb6b35f98b2.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783884206546-05c3b7caa009.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783884316852-5c5e880bc2b2.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783884316853-513c66b02a3b.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783884316855-628163f19640.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783884316855-9c7e111f91cb.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783884316857-4c2ea15a4121.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783884316858-20de37678ddc.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783884316861-c0c37db76634.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783884316862-710806c4df22.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1783884316862-364839b3a28b.jpg"}	https://youtube.com/shorts/W2oRawE531A?feature=share	available	Juazeiro	BA
2026-07-27 22:06:33.909598+00	2026-07-27 22:06:33.909598+00	33	Vendo ótima casa localizada no bairro da Codevasf, cidade de Juazeiro Bahia. 	Vendo casa localizada no bairro da Codevasf  na cidade de Juazeiro Bahia. Mede 10/20 composto por garagem pra 2 carros, 3/4   um sendo suite, 1 banheiro social, cozinha , corredor lateral. E área de lazer.	sale	house	270000	Codevasf	3	2	200	{"https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785190376178-3e5da1e48beb.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785190400113-1365391b56f7.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785190400116-60a229ec4910.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785190400119-55a7a3547cf3.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785190400123-a97b817d6bcd.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785190400127-408fc7b3d48c.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785190400131-bb9ddc2f7d6d.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785190400132-bf10c15c56eb.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785190400135-fa9cd6525dc6.jpg"}		available	Juazeiro	BA
2026-07-27 22:26:17.437304+00	2026-07-27 22:26:17.437304+00	34	Casa a venda no bairro Alto do Alencar, Juazeiro, Bahia	Casa casa localizada no bairro Alto do Alencar, cidade de Juazeiro Bahia. Dimensão total do terreno 28x13m. Composto garagem para 2 carros, corredores laterais, sala ampla, 3 quartos, sendo uma suíte. Mais 2 banheiros, Cozinha.  	sale	house	550000	Alto do Alencar	3	3	241	{"https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785191709434-6cbf144d757f.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785191802913-ddf3b8d2c6de.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785191802918-55ee80d01cb1.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785191802918-9f1036fc1fb4.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785191802923-a850483018ef.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785191802923-f92dece63aac.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785191802927-ab617b32c496.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1785191802927-e37b9516734b.jpg"}	https://www.youtube.com/watch?v=JpbgbcDxRrc	available	Juazeiro	BA
2026-08-14 13:09:16.820726+00	2026-08-14 13:09:16.820726+00	37	Casa nova para alugar no Country, Juazeiro, Bahia	Casa para alugar em Juazeiro no Country Club. Casa nova, recém construída, com 3 quartos, sendo 1 suite com closet, sala, cozinha, área de serviço, garagem, churrasqueira, portão eletronico, interfone eletronico, cerca elétrica, porcelanato. Localização privilegiada na rua Almirante Tamandaré no bairro country club. Contato: IMOVIU - luizspinolaimoveis.com.br	rent	house	3000	Country	3	2	150	{"https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1786713932570-bed66acb35fd.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1786713944208-944103a8357c.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1786713944208-9603feaeaaf8.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1786714754090-9128b91f2fa4.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1786714754091-d0b67e25eb94.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1786714754091-8fa252b26d93.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1786714754092-5a2fd754ec98.jpg"}		available	Juazeiro	BA
2026-08-03 12:20:54.239027+00	2026-08-03 12:20:54.239027+00	36	Vendo ótima casa no bairro Expedito Nascimento, Juazeiro, Bahia 	Casa localizada em rua tranquila do bairro Expedito Nascimento, tem 2 quartos, sala, cozinha, quintal, área de serviço, garagem para 1 carro, área total do terreno 200m2.. Aceitamos proposta e possibilidade de aceitação de veiculo na negociação.	sale	house	210000	Expedito Nascimento	2	1	120	{"https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1786558761033-dc20cfc9452c.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1786558803343-7ca19fd51500.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1786558803344-6d1f873bb2de.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1786558803345-b2444101cc2b.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1786558803345-db4618401df3.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1786558803348-2fe93f3e0b2c.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1786558809913-ec3e49de6a25.jpg"}		available	Juazeiro	BA
2026-03-26 02:45:31.588657+00	2026-05-10 10:26:19.948759+00	5	Terreno Vila Praiana, Lauro de Freitas, Bahia, 316m2, com imóvel em construção. IMOVIU	Terreno cercado, casa em construção, parte dos fundos, com duas lajes batidas, área livre na frente de 200m2, piso térreo pronto para morar. Água, luz, rua asfaltada, próximo a Supermercados, faculdades, hospitais, colégios, etc. Localizado na Rua Porto da Barra. Ideal para comercio (oficina, lava-jato, depósito, etc. Mais fotos e informações em https://www.luizspinolaimoveis.com.br - IMOVIU	rent	house	1500	Vila Praiana - Lauro de Freitas	2	2	316	{"https://luizspinolaimoveis.com.br/imovel-facil/1774493039404-a39e46e853724cd688c1ff358070461d.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774493055645-5b052dfa4e614a14bb482b4eee9f5e60.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774493055651-cf4ce58196474edc83cba740a397263f.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774493081474-4297ba82b77446259733ef1a2b7d95fe.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774493081480-c59d3d1406b8472ebcd9da16604ef848.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1774493081486-4c887a508e6a4a20b87444c9fe1ea226.jpg","https://luizspinolaimoveis.com.br/imovel-facil/1776179502033-c0826ea695854dfe8549c22314f5c71b.jpg","]"}		available	Juazeiro	BA
2026-08-24 12:18:44.054895+00	2026-08-24 12:18:44.054895+00	38	Casa para alugar, 2 quartos, Bairro Expedito Nascimento, Juazeiro, Bahia	Casa localizada em rua tranquila do bairro Expedito Nascimento, tem 2 quartos, sala, cozinha, quintal, área de serviço, garagem para 1 carro, área total do terreno 200m2.	rent	house	1000	Expedito Nascimento	2	1	120	{"https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1787573799032-5843a1770794.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1787573880917-93f9b6ee4932.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1787573880917-46f8c7ae8854.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1787573880918-73edc0fd5a70.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1787573917082-595c97519519.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1787573917085-6951e1a25f76.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1787573917093-9c45c7da13a8.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1787573917110-22eaed088a20.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1787573974182-a278b62a7ebf.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1787573974183-592cb0d51f0d.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1787573974184-48bb9b054cd1.jpg"}		available	Juazeiro	BA
2026-08-25 18:49:31.931714+00	2026-08-25 18:49:31.931714+00	39	Apartamento para alugar, bairro Santa Maria Goretti, centro, Juazeiro, Bahia	Apartamento localizado na Rua Dr. Dewilson, Bairro Maria Goretti, Centro, Juazeiro. Possui 3 quartos, sala, cozinha, banheiro, primeiro andar. Rua tranquila a 100 metros da Adolfo Viana. Assista o video. IMOVIU - luizspinolaimoveis.com.br , 	rent	apartment	1200	Santa Maria Goretti	3	1	100	{"https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1787685273397-9dcde74042dc.jpg"}	https://youtube.com/shorts/TgMIg-XurBI?feature=share	available	Juazeiro	BA
2026-09-08 19:17:37.412888+00	2026-09-08 19:17:37.412888+00	40	Terreno Haras Pé de Serra 1, Petrolina, Pernambuco	Terrenos no Haras Pé de Serra 1, Clube Social Equestre, cada terreno 10x20m, total de 200m2, lotes 01 a 04 e 13 ao 16, total de 1.600m2. Condominio apenas R$ 43,00, cada lote. Oportunidade única!	sale	land	22000	Haras Pé de Serra 1	0	0	200	{"https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1788895047293-05e4deb15116.jpg"}		available	Petrolina	PE
2026-09-23 14:04:19.732851+00	2026-09-23 14:04:19.732851+00	44	Alugamos, ponto comercial no centro de Juazeiro, Bahia. 	Excelente ponto comercial na Rua Barão de Cotegipe, centro, Juazeiro, Bahia.	rent	commercial	3500	Centro	0	1	60	{"https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790172317739-3c28dca20ccf.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790172473677-17a910eddd19.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790172473677-5d659ead446c.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790172473677-262a5e6324f6.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790172521070-4d4193c68b08.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790172521071-3d9d82be147f.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790172521071-70223c5dad2d.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790172521072-59a2dc453447.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790172521072-77c20780f856.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790172521072-7931ca081f4c.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790172521073-ca0735cea82a.jpg"}		available	Juazeiro	BA
2026-09-23 12:55:15.558105+00	2026-09-23 12:55:15.558105+00	43	Apartamento mobiliado, aluguel, bairro Antonio Cassimiro, Petrolina, PE	Excelente apartamento, mobiliado, bairro Antonio Cassimiro em Petrolina, ótima localização, portaria 24 horas, vaga de garagem, área de lazer.	rent	apartment	1800	Antonio Cassimiro	2	1	50	{"https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790169289674-9c6c5752cb0f.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790169310153-3e6fbf2fe2d1.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790169310154-d1fc58457793.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790169347043-1511d8c42436.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790169347043-76b5ac48154e.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790169347045-553a498b3d11.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790169386116-386b903b124c.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790169386117-d14d70d402f5.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790169386117-78c4d2765f06.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790169386118-8f662eba3d2a.jpg","https://www.luizspinolaimoveis.com.br/storage/imovel-facil/1790169386118-97e133a64bc6.jpg"}	https://youtube.com/shorts/xD26DzBKgm8?feature=share	available	Petrolina	PE
\.


--
-- Data for Name: property_advantages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.property_advantages (created_at, updated_at, id, advantage_id, property_id) FROM stdin;
2026-03-26 01:58:49.805167+00	2026-03-26 01:58:49.805167+00	4	1	4
2026-03-26 01:58:49.864536+00	2026-03-26 01:58:49.864536+00	5	3	4
2026-03-26 01:58:49.920309+00	2026-03-26 01:58:49.920309+00	6	4	4
2026-03-26 01:58:49.972327+00	2026-03-26 01:58:49.972327+00	7	5	4
2026-03-26 01:58:50.023038+00	2026-03-26 01:58:50.023038+00	8	6	4
2026-03-26 01:58:50.073025+00	2026-03-26 01:58:50.073025+00	9	7	4
2026-03-26 01:58:50.122406+00	2026-03-26 01:58:50.122406+00	10	8	4
2026-03-26 01:58:50.171726+00	2026-03-26 01:58:50.171726+00	11	9	4
2026-03-26 01:58:50.223998+00	2026-03-26 01:58:50.223998+00	12	10	4
2026-03-26 01:58:50.274577+00	2026-03-26 01:58:50.274577+00	13	11	4
2026-03-26 01:58:50.322453+00	2026-03-26 01:58:50.322453+00	14	12	4
2026-03-26 01:58:50.375426+00	2026-03-26 01:58:50.375426+00	15	15	4
2026-03-26 02:45:31.682095+00	2026-03-26 02:45:31.682095+00	16	1	5
2026-03-26 02:45:31.746864+00	2026-03-26 02:45:31.746864+00	17	3	5
2026-03-26 02:45:31.795352+00	2026-03-26 02:45:31.795352+00	18	4	5
2026-03-26 02:45:31.849754+00	2026-03-26 02:45:31.849754+00	19	5	5
2026-03-26 02:45:31.907056+00	2026-03-26 02:45:31.907056+00	20	10	5
2026-03-26 02:45:31.959384+00	2026-03-26 02:45:31.959384+00	21	11	5
2026-03-26 02:45:32.018717+00	2026-03-26 02:45:32.018717+00	22	12	5
2026-03-26 03:09:00.389168+00	2026-03-26 03:09:00.389168+00	23	1	6
2026-03-26 03:09:00.443117+00	2026-03-26 03:09:00.443117+00	24	5	6
2026-03-26 03:09:00.48834+00	2026-03-26 03:09:00.48834+00	25	11	6
2026-03-26 03:09:00.538819+00	2026-03-26 03:09:00.538819+00	26	12	6
2026-03-26 12:50:18.938864+00	2026-03-26 12:50:18.938864+00	31	1	9
2026-03-26 12:50:18.989894+00	2026-03-26 12:50:18.989894+00	32	3	9
2026-03-26 12:50:19.040672+00	2026-03-26 12:50:19.040672+00	33	4	9
2026-03-26 12:50:19.086402+00	2026-03-26 12:50:19.086402+00	34	8	9
2026-03-26 12:50:19.133801+00	2026-03-26 12:50:19.133801+00	35	9	9
2026-03-26 12:50:19.182888+00	2026-03-26 12:50:19.182888+00	36	12	9
2026-03-26 12:50:19.232874+00	2026-03-26 12:50:19.232874+00	37	17	9
2026-03-26 13:20:54.75287+00	2026-03-26 13:20:54.75287+00	38	1	10
2026-03-26 13:20:54.823778+00	2026-03-26 13:20:54.823778+00	39	3	10
2026-03-26 13:20:54.88776+00	2026-03-26 13:20:54.88776+00	40	6	10
2026-03-26 13:20:55.030482+00	2026-03-26 13:20:55.030482+00	41	8	10
2026-03-26 13:20:55.094934+00	2026-03-26 13:20:55.094934+00	42	9	10
2026-03-26 13:20:55.161146+00	2026-03-26 13:20:55.161146+00	43	18	10
2026-03-26 13:20:55.22501+00	2026-03-26 13:20:55.22501+00	44	19	10
2026-03-26 13:32:07.712649+00	2026-03-26 13:32:07.712649+00	45	20	10
2026-03-26 13:32:07.766947+00	2026-03-26 13:32:07.766947+00	46	21	10
2026-04-01 12:52:09.897562+00	2026-04-01 12:52:09.897562+00	53	18	12
2026-04-01 12:52:09.950524+00	2026-04-01 12:52:09.950524+00	54	20	12
2026-04-01 12:52:10.003564+00	2026-04-01 12:52:10.003564+00	55	1	12
2026-04-01 12:52:10.051761+00	2026-04-01 12:52:10.051761+00	56	21	12
2026-04-01 13:03:25.378383+00	2026-04-01 13:03:25.378383+00	57	1	13
2026-04-01 13:03:49.431086+00	2026-04-01 13:03:49.431086+00	58	3	13
2026-04-01 13:03:49.477464+00	2026-04-01 13:03:49.477464+00	59	6	13
2026-04-01 13:03:49.527384+00	2026-04-01 13:03:49.527384+00	60	9	13
2026-04-01 13:14:29.845913+00	2026-04-01 13:14:29.845913+00	61	12	13
2026-04-01 13:14:29.895288+00	2026-04-01 13:14:29.895288+00	62	21	13
2026-04-05 16:23:09.241555+00	2026-04-05 16:23:09.241555+00	63	1	14
2026-04-05 16:23:50.256398+00	2026-04-05 16:23:50.256398+00	64	10	14
2026-04-05 16:23:50.306465+00	2026-04-05 16:23:50.306465+00	65	12	14
2026-04-05 16:23:50.356785+00	2026-04-05 16:23:50.356785+00	66	22	14
2026-04-05 17:55:55.331183+00	2026-04-05 17:55:55.331183+00	67	12	15
2026-04-05 17:55:55.382816+00	2026-04-05 17:55:55.382816+00	68	1	15
2026-04-30 09:13:06.782195+00	2026-04-30 09:13:06.782195+00	69	1	16
2026-05-02 13:33:13.787197+00	2026-05-02 13:33:13.787197+00	70	3	18
2026-05-02 13:33:13.866289+00	2026-05-02 13:33:13.866289+00	71	4	18
2026-05-02 13:33:13.919451+00	2026-05-02 13:33:13.919451+00	72	5	18
2026-05-02 13:33:14.273557+00	2026-05-02 13:33:14.273557+00	73	11	18
2026-05-02 13:33:14.364468+00	2026-05-02 13:33:14.364468+00	74	12	18
2026-05-02 13:33:14.411189+00	2026-05-02 13:33:14.411189+00	75	1	18
2026-05-02 13:33:14.464466+00	2026-05-02 13:33:14.464466+00	76	22	18
2026-05-02 13:47:39.803168+00	2026-05-02 13:47:39.803168+00	77	6	16
2026-05-02 13:47:39.864263+00	2026-05-02 13:47:39.864263+00	78	13	16
2026-05-02 13:47:39.946324+00	2026-05-02 13:47:39.946324+00	79	21	16
2026-05-02 14:17:31.085711+00	2026-05-02 14:17:31.085711+00	80	1	19
2026-05-03 14:31:07.014407+00	2026-05-03 14:31:07.014407+00	81	3	21
2026-05-03 14:31:07.127759+00	2026-05-03 14:31:07.127759+00	82	1	21
2026-07-03 20:08:54.119153+00	2026-07-03 20:08:54.119153+00	88	19	28
2026-07-12 19:27:57.434724+00	2026-07-12 19:27:57.434724+00	89	4	29
2026-07-12 19:28:14.079285+00	2026-07-12 19:28:14.079285+00	90	12	29
2026-07-12 19:28:19.534161+00	2026-07-12 19:28:19.534161+00	91	6	29
2026-07-12 19:28:26.190714+00	2026-07-12 19:28:26.190714+00	92	3	29
2026-07-12 19:28:32.733002+00	2026-07-12 19:28:32.733002+00	93	9	29
2026-07-14 18:44:23.940873+00	2026-07-14 18:44:23.940873+00	94	7	30
2026-07-14 18:44:35.576705+00	2026-07-14 18:44:35.576705+00	95	3	30
2026-07-14 18:49:05.258938+00	2026-07-14 18:49:05.258938+00	96	9	30
2026-07-14 18:49:11.371641+00	2026-07-14 18:49:11.371641+00	97	11	30
2026-07-15 13:28:26.166171+00	2026-07-15 13:28:26.166171+00	98	5	30
\.


--
-- Data for Name: prospeccao_batches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.prospeccao_batches (id, batch_id, fonte, estado, cidade, tipo, modalidade, total_encontrados, novos_encontrados, removidos_encontrados, created_at) FROM stdin;
328	desktop-1785202112	olx.com.br	BA	Juazeiro	Apartamento	venda	4	4	0	2026-08-02 23:32:48.363
329	desktop-1785202136	olx.com.br	BA	Juazeiro	Apartamento	aluguel	7	7	0	2026-08-02 23:33:11.839
330	desktop-1785202157	olx.com.br	BA	Juazeiro	Terreno	venda	35	0	0	2026-08-02 23:33:33.591
331	desktop-1785202180	olx.com.br	BA	Juazeiro	Terreno	aluguel	22	4	0	2026-08-02 23:33:56.497
332	desktop-1785202205	olx.com.br	BA	Juazeiro	Comercial	venda	35	0	0	2026-08-02 23:34:20.86
333	desktop-1785202231	olx.com.br	BA	Juazeiro	Comercial	aluguel	22	0	0	2026-08-02 23:34:47.177
334	desktop-1785205981	olx.com.br	BA	Juazeiro	Casa	venda	31	0	0	2026-08-03 00:37:17.101
335	desktop-1785206005	olx.com.br	BA	Juazeiro	Casa	aluguel	11	0	0	2026-08-03 00:37:41.164
336	desktop-1785206030	olx.com.br	BA	Juazeiro	Apartamento	venda	4	0	0	2026-08-03 00:38:05.883
337	desktop-1785206055	olx.com.br	BA	Juazeiro	Apartamento	aluguel	7	0	0	2026-08-03 00:38:31
338	desktop-1785206075	olx.com.br	BA	Juazeiro	Terreno	venda	35	0	0	2026-08-03 00:38:51.61
339	desktop-1785206098	olx.com.br	BA	Juazeiro	Terreno	aluguel	22	0	0	2026-08-03 00:39:14.627
340	desktop-1785206121	olx.com.br	BA	Juazeiro	Comercial	venda	35	0	0	2026-08-03 00:39:37.479
341	desktop-1785206146	olx.com.br	BA	Juazeiro	Comercial	aluguel	22	0	0	2026-08-03 00:40:01.965
342	desktop-1785206183	olx.com.br	PE	Petrolina	Casa	venda	50	50	0	2026-08-03 00:40:39.201
343	desktop-1785206217	olx.com.br	PE	Petrolina	Casa	aluguel	50	50	0	2026-08-03 00:41:13.233
344	desktop-1785206241	olx.com.br	PE	Petrolina	Apartamento	venda	43	43	0	2026-08-03 00:41:36.798
345	desktop-1785206276	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	50	0	2026-08-03 00:42:12.147
346	desktop-1785206310	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-08-03 00:42:46.519
347	desktop-1785206349	olx.com.br	PE	Petrolina	Terreno	aluguel	50	4	0	2026-08-03 00:43:24.888
348	desktop-1785206386	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-08-03 00:44:01.927
349	desktop-1785206421	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-08-03 00:44:37.376
350	desktop-1786130710	olx.com.br	BA	Juazeiro	Casa	venda	33	4	2	2026-08-07 19:25:10.657
351	desktop-1786130736	olx.com.br	BA	Juazeiro	Casa	aluguel	11	1	1	2026-08-07 19:25:37.392
352	desktop-1786130807	olx.com.br	BA	Juazeiro	Apartamento	venda	4	0	0	2026-08-07 19:26:47.608
353	desktop-1786130844	olx.com.br	BA	Juazeiro	Apartamento	aluguel	11	5	1	2026-08-07 19:27:25.133
354	desktop-1786130872	olx.com.br	BA	Juazeiro	Terreno	venda	37	0	0	2026-08-07 19:27:52.642
355	desktop-1786130911	olx.com.br	BA	Juazeiro	Terreno	aluguel	27	2	1	2026-08-07 19:28:31.842
356	desktop-1786130942	olx.com.br	BA	Juazeiro	Comercial	venda	37	0	0	2026-08-07 19:29:02.449
357	desktop-1786130973	olx.com.br	BA	Juazeiro	Comercial	aluguel	27	0	0	2026-08-07 19:29:33.356
358	desktop-1786131024	olx.com.br	PE	Petrolina	Casa	venda	50	20	20	2026-08-07 19:30:25.064
359	desktop-1786131074	olx.com.br	PE	Petrolina	Casa	aluguel	50	7	7	2026-08-07 19:31:15.214
360	desktop-1786131104	olx.com.br	PE	Petrolina	Apartamento	venda	44	7	6	2026-08-07 19:31:44.616
361	desktop-1786131141	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	19	19	2026-08-07 19:32:21.935
362	desktop-1786131173	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-08-07 19:32:53.791
363	desktop-1786131206	olx.com.br	PE	Petrolina	Terreno	aluguel	50	2	1	2026-08-07 19:33:27.054
364	desktop-1786131243	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-08-07 19:34:04.047
365	desktop-1786131285	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-08-07 19:34:45.931
366	desktop-1786132273	olx.com.br	BA	Juazeiro	Casa	venda	33	0	0	2026-08-07 19:51:13.492
367	desktop-1786132297	olx.com.br	BA	Juazeiro	Casa	aluguel	11	0	0	2026-08-07 19:51:37.331
368	desktop-1786132320	olx.com.br	BA	Juazeiro	Apartamento	venda	4	0	0	2026-08-07 19:52:00.538
369	desktop-1786132344	olx.com.br	BA	Juazeiro	Apartamento	aluguel	11	0	0	2026-08-07 19:52:25.059
370	desktop-1786132368	olx.com.br	BA	Juazeiro	Terreno	venda	37	0	0	2026-08-07 19:52:48.75
371	desktop-1786132391	olx.com.br	BA	Juazeiro	Terreno	aluguel	27	0	0	2026-08-07 19:53:11.517
372	desktop-1786132416	olx.com.br	BA	Juazeiro	Comercial	venda	37	0	0	2026-08-07 19:53:36.805
373	desktop-1786132443	olx.com.br	BA	Juazeiro	Comercial	aluguel	27	0	0	2026-08-07 19:54:04.083
374	desktop-1786132475	olx.com.br	PE	Petrolina	Casa	venda	50	0	0	2026-08-07 19:54:35.981
375	desktop-1786132515	olx.com.br	PE	Petrolina	Casa	aluguel	50	0	0	2026-08-07 19:55:15.955
376	desktop-1786132543	olx.com.br	PE	Petrolina	Apartamento	venda	44	0	0	2026-08-07 19:55:43.446
377	desktop-1786132582	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	0	0	2026-08-07 19:56:23.007
378	desktop-1786132616	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-08-07 19:56:56.374
379	desktop-1786132650	olx.com.br	PE	Petrolina	Terreno	aluguel	50	0	0	2026-08-07 19:57:30.773
380	desktop-1786132687	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-08-07 19:58:07.294
381	desktop-1786132722	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-08-07 19:58:43.127
382	desktop-1786440998	olx.com.br	BA	Juazeiro	Casa	venda	30	2	5	2026-08-11 09:36:39.967
383	desktop-1786441052	olx.com.br	BA	Juazeiro	Casa	aluguel	0	0	11	2026-08-11 09:37:34.134
384	desktop-1786441167	olx.com.br	BA	Juazeiro	Apartamento	venda	0	0	4	2026-08-11 09:39:30.519
326	desktop-1785202065	olx.com.br	BA	Juazeiro	Casa	venda	31	31	0	2026-08-02 23:32:01.357
327	desktop-1785202088	olx.com.br	BA	Juazeiro	Casa	aluguel	11	11	0	2026-08-02 23:32:24.217
385	desktop-1786441233	olx.com.br	BA	Juazeiro	Apartamento	aluguel	0	0	11	2026-08-11 09:40:34.647
386	desktop-1786441342	olx.com.br	BA	Juazeiro	Terreno	venda	0	0	0	2026-08-11 09:42:23.815
387	desktop-1786441443	olx.com.br	BA	Juazeiro	Terreno	aluguel	0	0	5	2026-08-11 09:44:04.585
388	desktop-1786441544	olx.com.br	BA	Juazeiro	Comercial	venda	34	0	0	2026-08-11 09:45:45.73
389	desktop-1786441633	olx.com.br	BA	Juazeiro	Comercial	aluguel	0	0	0	2026-08-11 09:47:14.399
390	desktop-1786441725	olx.com.br	PE	Petrolina	Casa	venda	50	14	14	2026-08-11 09:48:46.762
391	desktop-1786441803	olx.com.br	PE	Petrolina	Casa	aluguel	50	7	7	2026-08-11 09:50:05.013
392	desktop-1786441856	olx.com.br	PE	Petrolina	Apartamento	venda	47	4	1	2026-08-11 09:50:57.954
393	desktop-1786442138	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-08-11 09:55:39.577
394	desktop-1786442208	olx.com.br	PE	Petrolina	Comercial	aluguel	50	5	0	2026-08-11 09:56:49.77
395	desktop-1786646862	olx.com.br	BA	Juazeiro	Casa	venda	31	2	0	2026-08-13 18:47:42.177
396	desktop-1786646885	olx.com.br	BA	Juazeiro	Casa	aluguel	10	1	0	2026-08-13 18:48:05.721
397	desktop-1786646907	olx.com.br	BA	Juazeiro	Apartamento	venda	4	0	0	2026-08-13 18:48:27.974
398	desktop-1786646932	olx.com.br	BA	Juazeiro	Apartamento	aluguel	11	2	0	2026-08-13 18:48:51.989
399	desktop-1786646958	olx.com.br	BA	Juazeiro	Terreno	venda	35	0	0	2026-08-13 18:49:18.64
400	desktop-1786646981	olx.com.br	BA	Juazeiro	Terreno	aluguel	27	1	0	2026-08-13 18:49:41.618
401	desktop-1786647015	olx.com.br	BA	Juazeiro	Comercial	venda	35	0	0	2026-08-13 18:50:15.575
402	desktop-1786647039	olx.com.br	BA	Juazeiro	Comercial	aluguel	27	0	0	2026-08-13 18:50:39.09
403	desktop-1786647071	olx.com.br	PE	Petrolina	Casa	venda	50	50	0	2026-08-13 18:51:11.927
404	desktop-1786647103	olx.com.br	PE	Petrolina	Casa	aluguel	50	50	0	2026-08-13 18:51:43.909
405	desktop-1786647127	olx.com.br	PE	Petrolina	Apartamento	venda	46	46	0	2026-08-13 18:52:07.595
406	desktop-1786647163	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	50	0	2026-08-13 18:52:43.389
407	desktop-1786647197	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-08-13 18:53:17.439
408	desktop-1786647230	olx.com.br	PE	Petrolina	Terreno	aluguel	50	6	0	2026-08-13 18:53:50.686
409	desktop-1786647264	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-08-13 18:54:24.61
410	desktop-1786647300	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-08-13 18:55:00.566
411	desktop-1786647519	olx.com.br	BA	Lauro de Freitas	Casa	venda	50	50	0	2026-08-13 18:58:39.567
412	desktop-1786647553	olx.com.br	BA	Lauro de Freitas	Casa	aluguel	50	50	0	2026-08-13 18:59:13.231
413	desktop-1786647586	olx.com.br	BA	Lauro de Freitas	Apartamento	venda	50	50	0	2026-08-13 18:59:46.388
414	desktop-1786647620	olx.com.br	BA	Lauro de Freitas	Apartamento	aluguel	50	50	0	2026-08-13 19:00:20.278
415	desktop-1786647653	olx.com.br	BA	Lauro de Freitas	Terreno	venda	50	0	0	2026-08-13 19:00:53.601
416	desktop-1786647685	olx.com.br	BA	Lauro de Freitas	Terreno	aluguel	50	3	0	2026-08-13 19:01:25.452
417	desktop-1786647721	olx.com.br	BA	Lauro de Freitas	Comercial	venda	50	0	0	2026-08-13 19:02:01.242
418	desktop-1786647757	olx.com.br	BA	Lauro de Freitas	Comercial	aluguel	50	0	0	2026-08-13 19:02:37.091
419	desktop-1786648847	olx.com.br	BA	Juazeiro	Casa	venda	31	31	0	2026-08-13 19:20:47.699
420	desktop-1786648870	olx.com.br	BA	Juazeiro	Casa	aluguel	10	10	0	2026-08-13 19:21:10.544
421	desktop-1786648901	olx.com.br	BA	Juazeiro	Apartamento	venda	0	0	0	2026-08-13 19:21:41.616
422	desktop-1786648959	olx.com.br	BA	Juazeiro	Apartamento	aluguel	11	11	0	2026-08-13 19:22:39.863
423	desktop-1786648984	olx.com.br	BA	Juazeiro	Terreno	venda	35	4	0	2026-08-13 19:23:04.852
424	desktop-1786649007	olx.com.br	BA	Juazeiro	Terreno	aluguel	27	6	0	2026-08-13 19:23:27.195
425	desktop-1786649030	olx.com.br	BA	Juazeiro	Comercial	venda	35	0	0	2026-08-13 19:23:50.215
426	desktop-1786649080	olx.com.br	BA	Juazeiro	Comercial	aluguel	27	0	0	2026-08-13 19:24:40.486
427	desktop-1786707928	olx.com.br	BA	Juazeiro	Casa	venda	0	0	31	2026-08-14 11:45:29.202
428	desktop-1786708174	olx.com.br	BA	Juazeiro	Casa	aluguel	0	0	10	2026-08-14 11:49:36.015
429	desktop-1786708339	olx.com.br	BA	Juazeiro	Apartamento	venda	4	0	0	2026-08-14 11:52:21.006
430	desktop-1786708566	olx.com.br	BA	Juazeiro	Apartamento	aluguel	0	0	11	2026-08-14 11:56:07.525
431	desktop-1786708747	olx.com.br	BA	Juazeiro	Terreno	venda	34	0	0	2026-08-14 11:59:09.452
432	desktop-1786708814	olx.com.br	BA	Juazeiro	Terreno	aluguel	6	6	6	2026-08-14 12:00:15.646
433	desktop-1786708879	olx.com.br	BA	Juazeiro	Comercial	venda	34	0	0	2026-08-14 12:01:21.34
434	desktop-1786708941	olx.com.br	BA	Juazeiro	Comercial	aluguel	27	0	0	2026-08-14 12:02:22.996
435	desktop-1786711151	olx.com.br	BA	Juazeiro	Casa	venda	30	0	0	2026-08-14 12:39:11.411
436	desktop-1786711175	olx.com.br	BA	Juazeiro	Casa	aluguel	10	0	0	2026-08-14 12:39:35.621
437	desktop-1786711207	olx.com.br	BA	Juazeiro	Apartamento	venda	4	0	0	2026-08-14 12:40:07.655
438	desktop-1786711233	olx.com.br	BA	Juazeiro	Apartamento	aluguel	12	1	0	2026-08-14 12:40:32.929
439	desktop-1786711262	olx.com.br	BA	Juazeiro	Terreno	venda	34	0	0	2026-08-14 12:41:01.916
440	desktop-1786711284	olx.com.br	BA	Juazeiro	Terreno	aluguel	28	0	6	2026-08-14 12:41:24.59
441	desktop-1786711308	olx.com.br	BA	Juazeiro	Comercial	venda	34	0	0	2026-08-14 12:41:48.517
442	desktop-1786711333	olx.com.br	BA	Juazeiro	Comercial	aluguel	28	0	0	2026-08-14 12:42:13.651
443	desktop-1786711405	olx.com.br	BA	Juazeiro	Casa	venda	30	0	0	2026-08-14 12:43:24.745
444	desktop-1786711437	olx.com.br	BA	Juazeiro	Casa	aluguel	10	0	0	2026-08-14 12:43:57.323
445	desktop-1786711460	olx.com.br	BA	Juazeiro	Apartamento	venda	4	0	0	2026-08-14 12:44:20.486
446	desktop-1786711493	olx.com.br	BA	Juazeiro	Apartamento	aluguel	12	0	0	2026-08-14 12:44:53.166
447	desktop-1786711515	olx.com.br	BA	Juazeiro	Terreno	venda	34	0	0	2026-08-14 12:45:15.197
448	desktop-1786711542	olx.com.br	BA	Juazeiro	Terreno	aluguel	28	0	0	2026-08-14 12:45:42.439
449	desktop-1786711568	olx.com.br	BA	Juazeiro	Comercial	venda	34	0	0	2026-08-14 12:46:07.954
450	desktop-1786711598	olx.com.br	BA	Juazeiro	Comercial	aluguel	28	0	0	2026-08-14 12:46:38.206
451	desktop-1786711666	olx.com.br	PE	Petrolina	Casa	venda	50	3	3	2026-08-14 12:47:46.14
452	desktop-1786711837	olx.com.br	PE	Petrolina	Casa	aluguel	50	2	2	2026-08-14 12:50:37.325
453	desktop-1786711950	olx.com.br	PE	Petrolina	Apartamento	venda	46	0	0	2026-08-14 12:52:30.641
454	desktop-1786712012	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	2	2	2026-08-14 12:53:32.233
455	desktop-1786712127	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-08-14 12:55:27.767
456	desktop-1786712178	olx.com.br	PE	Petrolina	Terreno	aluguel	50	0	1	2026-08-14 12:56:18.471
457	desktop-1786712262	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-08-14 12:57:42.764
458	desktop-1786712313	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-08-14 12:58:33.791
459	desktop-1786732499	olx.com.br	BA	Lauro de Freitas	Casa	venda	50	50	0	2026-08-14 18:34:59.364
460	desktop-1786732543	olx.com.br	BA	Lauro de Freitas	Casa	aluguel	50	50	0	2026-08-14 18:35:43.143
461	desktop-1786732584	olx.com.br	BA	Lauro de Freitas	Apartamento	venda	50	50	0	2026-08-14 18:36:24.385
462	desktop-1786732671	olx.com.br	BA	Lauro de Freitas	Apartamento	aluguel	50	50	0	2026-08-14 18:37:50.704
463	desktop-1786732704	olx.com.br	BA	Lauro de Freitas	Terreno	venda	50	0	0	2026-08-14 18:38:23.995
464	desktop-1786732745	olx.com.br	BA	Lauro de Freitas	Terreno	aluguel	50	2	0	2026-08-14 18:39:05.181
465	desktop-1786732783	olx.com.br	BA	Lauro de Freitas	Comercial	venda	50	0	0	2026-08-14 18:39:43.635
466	desktop-1786732821	olx.com.br	BA	Lauro de Freitas	Comercial	aluguel	50	0	0	2026-08-14 18:40:21.41
467	desktop-1786970721	olx.com.br	BA	Juazeiro	Casa	venda	31	31	0	2026-08-17 12:45:21.525
468	desktop-1786970754	olx.com.br	BA	Juazeiro	Casa	aluguel	11	11	0	2026-08-17 12:45:54.502
469	desktop-1786970803	olx.com.br	BA	Juazeiro	Apartamento	venda	4	4	0	2026-08-17 12:46:44.16
470	desktop-1786970835	olx.com.br	BA	Juazeiro	Apartamento	aluguel	13	13	0	2026-08-17 12:47:16.255
471	desktop-1786970866	olx.com.br	BA	Juazeiro	Terreno	venda	35	0	0	2026-08-17 12:47:47.222
472	desktop-1786970894	olx.com.br	BA	Juazeiro	Terreno	aluguel	30	6	0	2026-08-17 12:48:15.32
473	desktop-1786970922	olx.com.br	BA	Juazeiro	Comercial	venda	35	0	0	2026-08-17 12:48:42.863
474	desktop-1786970950	olx.com.br	BA	Juazeiro	Comercial	aluguel	30	0	0	2026-08-17 12:49:10.984
475	desktop-1786971003	olx.com.br	PE	Petrolina	Casa	venda	50	50	0	2026-08-17 12:50:03.615
476	desktop-1786971044	olx.com.br	PE	Petrolina	Casa	aluguel	50	50	0	2026-08-17 12:50:44.961
477	desktop-1786971087	olx.com.br	PE	Petrolina	Apartamento	venda	44	44	0	2026-08-17 12:51:27.844
478	desktop-1786971137	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	50	0	2026-08-17 12:52:18.173
479	desktop-1786971193	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-08-17 12:53:13.561
480	desktop-1786971311	olx.com.br	PE	Petrolina	Terreno	aluguel	50	5	0	2026-08-17 12:55:12.08
481	desktop-1786971390	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-08-17 12:56:30.898
482	desktop-1786971451	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-08-17 12:57:31.644
483	desktop-1786985544	olx.com.br	BA	Juazeiro	Casa	venda	32	1	0	2026-08-17 16:52:23.86
484	desktop-1786985567	olx.com.br	BA	Juazeiro	Casa	aluguel	11	0	0	2026-08-17 16:52:47.428
485	desktop-1786985589	olx.com.br	BA	Juazeiro	Apartamento	venda	4	0	0	2026-08-17 16:53:09.429
486	desktop-1786985612	olx.com.br	BA	Juazeiro	Apartamento	aluguel	13	0	0	2026-08-17 16:53:32.178
487	desktop-1786985633	olx.com.br	BA	Juazeiro	Terreno	venda	36	0	0	2026-08-17 16:53:52.901
488	desktop-1786985655	olx.com.br	BA	Juazeiro	Terreno	aluguel	30	0	0	2026-08-17 16:54:14.77
489	desktop-1786985680	olx.com.br	BA	Juazeiro	Comercial	venda	36	0	0	2026-08-17 16:54:39.62
490	desktop-1786985703	olx.com.br	BA	Juazeiro	Comercial	aluguel	30	0	0	2026-08-17 16:55:02.825
491	desktop-1786985735	olx.com.br	PE	Petrolina	Casa	venda	50	2	2	2026-08-17 16:55:35.127
492	desktop-1786985770	olx.com.br	PE	Petrolina	Casa	aluguel	50	2	2	2026-08-17 16:56:10.087
493	desktop-1786985805	olx.com.br	PE	Petrolina	Apartamento	venda	44	0	0	2026-08-17 16:56:45.475
494	desktop-1786985853	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	1	1	2026-08-17 16:57:33.183
495	desktop-1786985892	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-08-17 16:58:12.934
496	desktop-1786985960	olx.com.br	PE	Petrolina	Terreno	aluguel	50	0	0	2026-08-17 16:59:21.096
497	desktop-1786986002	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-08-17 17:00:02.755
498	desktop-1786986043	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-08-17 17:00:42.938
499	desktop-1786986320	olx.com.br	BA	Juazeiro	Casa	venda	32	0	0	2026-08-17 17:05:20.405
500	desktop-1786986343	olx.com.br	BA	Juazeiro	Casa	aluguel	11	0	0	2026-08-17 17:05:42.657
501	desktop-1786986365	olx.com.br	BA	Juazeiro	Apartamento	venda	4	0	0	2026-08-17 17:06:05.47
502	desktop-1786986390	olx.com.br	BA	Juazeiro	Apartamento	aluguel	13	0	0	2026-08-17 17:06:30.35
503	desktop-1786986413	olx.com.br	BA	Juazeiro	Terreno	venda	36	0	0	2026-08-17 17:06:53.182
504	desktop-1786986436	olx.com.br	BA	Juazeiro	Terreno	aluguel	30	0	0	2026-08-17 17:07:16.278
505	desktop-1786986459	olx.com.br	BA	Juazeiro	Comercial	venda	36	0	0	2026-08-17 17:07:38.89
506	desktop-1786986485	olx.com.br	BA	Juazeiro	Comercial	aluguel	30	0	0	2026-08-17 17:08:04.889
507	desktop-1786986519	olx.com.br	PE	Petrolina	Casa	venda	50	0	0	2026-08-17 17:08:39.49
508	desktop-1786986553	olx.com.br	PE	Petrolina	Casa	aluguel	50	0	0	2026-08-17 17:09:12.98
509	desktop-1786986577	olx.com.br	PE	Petrolina	Apartamento	venda	44	0	0	2026-08-17 17:09:36.66
510	desktop-1786986612	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	0	0	2026-08-17 17:10:12.429
511	desktop-1786986650	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-08-17 17:10:50.326
512	desktop-1786986683	olx.com.br	PE	Petrolina	Terreno	aluguel	50	0	0	2026-08-17 17:11:23.337
513	desktop-1786986717	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-08-17 17:11:56.831
514	desktop-1786986752	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-08-17 17:12:32.426
515	desktop-1786986784	olx.com.br	BA	Lauro de Freitas	Casa	venda	50	50	0	2026-08-17 17:13:03.846
516	desktop-1786986816	olx.com.br	BA	Lauro de Freitas	Casa	aluguel	50	50	0	2026-08-17 17:13:36.04
517	desktop-1786986851	olx.com.br	BA	Lauro de Freitas	Apartamento	venda	50	50	0	2026-08-17 17:14:11.075
518	desktop-1786986886	olx.com.br	BA	Lauro de Freitas	Apartamento	aluguel	50	50	0	2026-08-17 17:14:46.126
519	desktop-1786986917	olx.com.br	BA	Lauro de Freitas	Terreno	venda	50	0	0	2026-08-17 17:15:16.905
520	desktop-1786986953	olx.com.br	BA	Lauro de Freitas	Terreno	aluguel	50	3	0	2026-08-17 17:15:53.285
521	desktop-1786986986	olx.com.br	BA	Lauro de Freitas	Comercial	venda	50	0	0	2026-08-17 17:16:26
522	desktop-1786987022	olx.com.br	BA	Lauro de Freitas	Comercial	aluguel	50	0	0	2026-08-17 17:17:01.64
523	desktop-1787131391	olx.com.br	BA	Juazeiro	Casa	venda	0	0	17	2026-08-19 09:23:12.099
524	desktop-1787131476	olx.com.br	BA	Juazeiro	Casa	aluguel	10	0	1	2026-08-19 09:24:37.401
525	desktop-1787131575	olx.com.br	BA	Juazeiro	Apartamento	venda	4	0	0	2026-08-19 09:26:15.764
526	desktop-1787131673	olx.com.br	BA	Juazeiro	Apartamento	aluguel	0	0	7	2026-08-19 09:27:53.677
527	desktop-1787131750	olx.com.br	BA	Juazeiro	Terreno	venda	36	2	0	2026-08-19 09:29:10.805
528	desktop-1787131780	olx.com.br	BA	Juazeiro	Terreno	aluguel	27	0	1	2026-08-19 09:29:40.894
529	desktop-1787131817	olx.com.br	BA	Juazeiro	Comercial	venda	36	0	0	2026-08-19 09:30:17.617
530	desktop-1787131893	olx.com.br	BA	Juazeiro	Comercial	aluguel	27	0	0	2026-08-19 09:31:34.203
531	desktop-1787132006	olx.com.br	PE	Petrolina	Casa	venda	50	9	10	2026-08-19 09:33:26.529
532	desktop-1787132061	olx.com.br	PE	Petrolina	Casa	aluguel	50	4	4	2026-08-19 09:34:22.389
533	desktop-1787132104	olx.com.br	PE	Petrolina	Apartamento	venda	43	1	2	2026-08-19 09:35:05.839
534	desktop-1787132184	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	8	8	2026-08-19 09:36:24.519
535	desktop-1787132246	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-08-19 09:37:27.332
536	desktop-1787132298	olx.com.br	PE	Petrolina	Terreno	aluguel	50	0	1	2026-08-19 09:38:18.864
537	desktop-1787132363	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-08-19 09:39:24.322
538	desktop-1787132463	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-08-19 09:41:03.949
539	desktop-1787132602	olx.com.br	BA	Lauro de Freitas	Casa	venda	50	5	5	2026-08-19 09:43:23.84
540	desktop-1787132659	olx.com.br	BA	Lauro de Freitas	Casa	aluguel	50	5	5	2026-08-19 09:44:19.747
541	desktop-1787132771	olx.com.br	BA	Lauro de Freitas	Apartamento	venda	50	5	5	2026-08-19 09:46:12.812
542	desktop-1787132848	olx.com.br	BA	Lauro de Freitas	Apartamento	aluguel	50	9	8	2026-08-19 09:47:29.39
543	desktop-1787132917	olx.com.br	BA	Lauro de Freitas	Terreno	venda	50	0	0	2026-08-19 09:48:37.978
544	desktop-1787132967	olx.com.br	BA	Lauro de Freitas	Terreno	aluguel	50	0	0	2026-08-19 09:49:28.034
545	desktop-1787133025	olx.com.br	BA	Lauro de Freitas	Comercial	venda	50	0	0	2026-08-19 09:50:25.503
546	desktop-1787133087	olx.com.br	BA	Lauro de Freitas	Comercial	aluguel	50	0	0	2026-08-19 09:51:27.681
547	desktop-1787140918	olx.com.br	BA	Juazeiro	Casa	venda	32	0	0	2026-08-19 12:01:58.289
548	desktop-1787140942	olx.com.br	BA	Juazeiro	Casa	aluguel	10	0	0	2026-08-19 12:02:22.912
549	desktop-1787140967	olx.com.br	BA	Juazeiro	Apartamento	venda	4	0	0	2026-08-19 12:02:47.992
550	desktop-1787141008	olx.com.br	BA	Juazeiro	Apartamento	aluguel	12	0	0	2026-08-19 12:03:28.563
551	desktop-1787141072	olx.com.br	BA	Juazeiro	Terreno	venda	36	0	0	2026-08-19 12:04:32.261
552	desktop-1787141093	olx.com.br	BA	Juazeiro	Terreno	aluguel	27	0	0	2026-08-19 12:04:54.3
553	desktop-1787141123	olx.com.br	BA	Juazeiro	Comercial	venda	0	0	0	2026-08-19 12:05:24.212
554	desktop-1787141148	olx.com.br	BA	Juazeiro	Comercial	aluguel	27	0	0	2026-08-19 12:05:48.887
555	desktop-1787141181	olx.com.br	PE	Petrolina	Casa	venda	50	2	2	2026-08-19 12:06:21.545
556	desktop-1787141225	olx.com.br	PE	Petrolina	Casa	aluguel	50	0	1	2026-08-19 12:07:05.601
557	desktop-1787141270	olx.com.br	PE	Petrolina	Apartamento	venda	43	0	0	2026-08-19 12:07:50.92
558	desktop-1787141325	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	0	0	2026-08-19 12:08:45.261
559	desktop-1787141393	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-08-19 12:09:54.061
560	desktop-1787141442	olx.com.br	PE	Petrolina	Terreno	aluguel	50	0	0	2026-08-19 12:10:42.382
561	desktop-1787141480	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-08-19 12:11:20.747
562	desktop-1787141542	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-08-19 12:12:22.692
563	desktop-1787141601	olx.com.br	BA	Lauro de Freitas	Casa	venda	50	0	0	2026-08-19 12:13:21.572
564	desktop-1787141650	olx.com.br	BA	Lauro de Freitas	Casa	aluguel	50	1	1	2026-08-19 12:14:11.134
565	desktop-1787141727	olx.com.br	BA	Lauro de Freitas	Apartamento	venda	50	0	1	2026-08-19 12:15:27.229
566	desktop-1787141795	olx.com.br	BA	Lauro de Freitas	Apartamento	aluguel	50	0	0	2026-08-19 12:16:36.051
567	desktop-1787141901	olx.com.br	BA	Lauro de Freitas	Terreno	venda	50	0	0	2026-08-19 12:18:21.82
568	desktop-1787141949	olx.com.br	BA	Lauro de Freitas	Terreno	aluguel	50	0	0	2026-08-19 12:19:09.589
569	desktop-1787142012	olx.com.br	BA	Lauro de Freitas	Comercial	venda	50	0	0	2026-08-19 12:20:12.467
570	desktop-1787142072	olx.com.br	BA	Lauro de Freitas	Comercial	aluguel	50	0	0	2026-08-19 12:21:12.576
571	desktop-1787142105	olx.com.br	BA	Salvador	Casa	venda	50	50	0	2026-08-19 12:21:46.072
572	desktop-1787142141	olx.com.br	BA	Salvador	Casa	aluguel	50	50	0	2026-08-19 12:22:21.529
573	desktop-1787142177	olx.com.br	BA	Salvador	Apartamento	venda	50	50	0	2026-08-19 12:22:57.76
574	desktop-1787142212	olx.com.br	BA	Salvador	Apartamento	aluguel	50	50	0	2026-08-19 12:23:32.397
575	desktop-1787142247	olx.com.br	BA	Salvador	Terreno	venda	50	0	0	2026-08-19 12:24:07.847
576	desktop-1787142281	olx.com.br	BA	Salvador	Terreno	aluguel	50	10	0	2026-08-19 12:24:41.439
577	desktop-1787142314	olx.com.br	BA	Salvador	Comercial	venda	50	0	0	2026-08-19 12:25:15.208
578	desktop-1787142351	olx.com.br	BA	Salvador	Comercial	aluguel	50	0	0	2026-08-19 12:25:52.113
579	desktop-1787148621	olx.com.br	SE	Aracaju	Casa	venda	50	50	0	2026-08-19 14:10:22.07
580	desktop-1787148656	olx.com.br	SE	Aracaju	Casa	aluguel	50	50	0	2026-08-19 14:10:56.997
581	desktop-1787148690	olx.com.br	SE	Aracaju	Apartamento	venda	50	50	0	2026-08-19 14:11:30.864
582	desktop-1787148731	olx.com.br	SE	Aracaju	Apartamento	aluguel	50	50	0	2026-08-19 14:12:11.489
583	desktop-1787148764	olx.com.br	SE	Aracaju	Terreno	venda	50	0	0	2026-08-19 14:12:44.335
584	desktop-1787148798	olx.com.br	SE	Aracaju	Terreno	aluguel	50	12	0	2026-08-19 14:13:18.813
585	desktop-1787148836	olx.com.br	SE	Aracaju	Comercial	venda	50	0	0	2026-08-19 14:13:56.707
586	desktop-1787148874	olx.com.br	SE	Aracaju	Comercial	aluguel	50	0	0	2026-08-19 14:14:34.635
587	desktop-1787149716	olx.com.br	SE	Aracaju	Casa	venda	50	50	0	2026-08-19 14:28:36.811
588	desktop-1787149753	olx.com.br	SE	Aracaju	Casa	aluguel	50	50	0	2026-08-19 14:29:13.362
589	desktop-1787149792	olx.com.br	SE	Aracaju	Apartamento	venda	50	50	0	2026-08-19 14:29:52.646
590	desktop-1787149828	olx.com.br	SE	Aracaju	Apartamento	aluguel	50	50	0	2026-08-19 14:30:28.393
591	desktop-1787149861	olx.com.br	SE	Aracaju	Terreno	venda	50	0	0	2026-08-19 14:31:02.053
592	desktop-1787149898	olx.com.br	SE	Aracaju	Terreno	aluguel	50	12	0	2026-08-19 14:31:38.668
593	desktop-1787149933	olx.com.br	SE	Aracaju	Comercial	venda	50	0	0	2026-08-19 14:32:13.457
594	desktop-1787149968	olx.com.br	SE	Aracaju	Comercial	aluguel	50	0	0	2026-08-19 14:32:48.125
595	desktop-1787149994	olx.com.br	BA	Juazeiro	Casa	venda	32	32	0	2026-08-19 14:33:14.84
596	desktop-1787150016	olx.com.br	BA	Juazeiro	Casa	aluguel	11	11	0	2026-08-19 14:33:36.474
597	desktop-1787150041	olx.com.br	BA	Juazeiro	Apartamento	venda	4	4	0	2026-08-19 14:34:01.65
598	desktop-1787150068	olx.com.br	BA	Juazeiro	Apartamento	aluguel	12	12	0	2026-08-19 14:34:28.233
599	desktop-1787150093	olx.com.br	BA	Juazeiro	Terreno	venda	36	0	0	2026-08-19 14:34:53.312
600	desktop-1787150115	olx.com.br	BA	Juazeiro	Terreno	aluguel	28	5	0	2026-08-19 14:35:15.356
601	desktop-1787150140	olx.com.br	BA	Juazeiro	Comercial	venda	36	0	0	2026-08-19 14:35:40.241
602	desktop-1787150165	olx.com.br	BA	Juazeiro	Comercial	aluguel	28	0	0	2026-08-19 14:36:05.259
603	desktop-1787150198	olx.com.br	PE	Petrolina	Casa	venda	50	50	0	2026-08-19 14:36:38.945
604	desktop-1787150231	olx.com.br	PE	Petrolina	Casa	aluguel	50	50	0	2026-08-19 14:37:11.223
605	desktop-1787150253	olx.com.br	PE	Petrolina	Apartamento	venda	43	43	0	2026-08-19 14:37:33.465
606	desktop-1787150289	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	50	0	2026-08-19 14:38:09.851
607	desktop-1787150321	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-08-19 14:38:41.792
608	desktop-1787150358	olx.com.br	PE	Petrolina	Terreno	aluguel	50	4	0	2026-08-19 14:39:18.783
609	desktop-1787150397	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-08-19 14:39:57.685
610	desktop-1787150431	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-08-19 14:40:31.205
611	desktop-1787229222	olx.com.br	SE	Aracaju	Casa	venda	50	11	11	2026-08-20 12:33:42.327
612	desktop-1787229260	olx.com.br	SE	Aracaju	Casa	aluguel	50	9	9	2026-08-20 12:34:19.788
613	desktop-1787229294	olx.com.br	SE	Aracaju	Apartamento	venda	50	18	18	2026-08-20 12:34:53.904
614	desktop-1787229329	olx.com.br	SE	Aracaju	Apartamento	aluguel	50	16	16	2026-08-20 12:35:29.652
615	desktop-1787229364	olx.com.br	SE	Aracaju	Terreno	venda	50	0	0	2026-08-20 12:36:03.851
616	desktop-1787229399	olx.com.br	SE	Aracaju	Terreno	aluguel	50	1	9	2026-08-20 12:36:39.213
617	desktop-1787229439	olx.com.br	SE	Aracaju	Comercial	venda	50	0	0	2026-08-20 12:37:19.312
618	desktop-1787229474	olx.com.br	SE	Aracaju	Comercial	aluguel	50	0	0	2026-08-20 12:37:54.243
619	desktop-1787229496	olx.com.br	BA	Juazeiro	Casa	venda	32	0	0	2026-08-20 12:38:16.725
620	desktop-1787229519	olx.com.br	BA	Juazeiro	Casa	aluguel	11	0	0	2026-08-20 12:38:38.904
621	desktop-1787229541	olx.com.br	BA	Juazeiro	Apartamento	venda	4	0	0	2026-08-20 12:39:01.636
622	desktop-1787229570	olx.com.br	BA	Juazeiro	Apartamento	aluguel	13	1	0	2026-08-20 12:39:30.237
623	desktop-1787229595	olx.com.br	BA	Juazeiro	Terreno	venda	36	0	0	2026-08-20 12:39:55.286
624	desktop-1787229618	olx.com.br	BA	Juazeiro	Terreno	aluguel	28	0	1	2026-08-20 12:40:18.336
625	desktop-1787229642	olx.com.br	BA	Juazeiro	Comercial	venda	36	0	0	2026-08-20 12:40:42.578
626	desktop-1787229668	olx.com.br	BA	Juazeiro	Comercial	aluguel	28	0	0	2026-08-20 12:41:08.031
627	desktop-1787229700	olx.com.br	PE	Petrolina	Casa	venda	50	7	7	2026-08-20 12:41:39.842
628	desktop-1787229733	olx.com.br	PE	Petrolina	Casa	aluguel	50	1	1	2026-08-20 12:42:13.631
629	desktop-1787229760	olx.com.br	PE	Petrolina	Apartamento	venda	43	0	0	2026-08-20 12:42:40.737
630	desktop-1787229800	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	2	2	2026-08-20 12:43:19.913
631	desktop-1787229832	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-08-20 12:43:52.12
632	desktop-1787229864	olx.com.br	PE	Petrolina	Terreno	aluguel	50	0	0	2026-08-20 12:44:24.524
633	desktop-1787229897	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-08-20 12:44:57.576
634	desktop-1787229934	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-08-20 12:45:34.426
635	desktop-1787532186	olx.com.br	SE	Aracaju	Casa	venda	50	15	15	2026-08-24 00:43:06.814
636	desktop-1787532231	olx.com.br	SE	Aracaju	Casa	aluguel	50	21	22	2026-08-24 00:43:51.357
637	desktop-1787532275	olx.com.br	SE	Aracaju	Apartamento	venda	50	29	29	2026-08-24 00:44:36.084
638	desktop-1787532347	olx.com.br	SE	Aracaju	Apartamento	aluguel	50	25	25	2026-08-24 00:45:47.969
639	desktop-1787532391	olx.com.br	SE	Aracaju	Terreno	venda	50	0	0	2026-08-24 00:46:31.404
640	desktop-1787532427	olx.com.br	SE	Aracaju	Terreno	aluguel	50	7	2	2026-08-24 00:47:07.551
641	desktop-1787532463	olx.com.br	SE	Aracaju	Comercial	venda	50	0	0	2026-08-24 00:47:43.617
642	desktop-1787532501	olx.com.br	SE	Aracaju	Comercial	aluguel	50	0	0	2026-08-24 00:48:21.935
643	desktop-1787532526	olx.com.br	BA	Juazeiro	Casa	venda	33	2	1	2026-08-24 00:48:47.058
644	desktop-1787532557	olx.com.br	BA	Juazeiro	Casa	aluguel	10	0	1	2026-08-24 00:49:17.315
645	desktop-1787532582	olx.com.br	BA	Juazeiro	Apartamento	venda	4	0	0	2026-08-24 00:49:42.329
646	desktop-1787532612	olx.com.br	BA	Juazeiro	Apartamento	aluguel	13	0	0	2026-08-24 00:50:12.462
647	desktop-1787532680	olx.com.br	BA	Juazeiro	Terreno	venda	37	0	0	2026-08-24 00:51:20.826
648	desktop-1787532707	olx.com.br	BA	Juazeiro	Terreno	aluguel	27	0	0	2026-08-24 00:51:47.207
649	desktop-1787532729	olx.com.br	BA	Juazeiro	Comercial	venda	37	0	0	2026-08-24 00:52:09.377
650	desktop-1787532764	olx.com.br	BA	Juazeiro	Comercial	aluguel	27	0	0	2026-08-24 00:52:44.324
651	desktop-1787532801	olx.com.br	PE	Petrolina	Casa	venda	50	8	11	2026-08-24 00:53:21.879
652	desktop-1787532838	olx.com.br	PE	Petrolina	Casa	aluguel	50	3	3	2026-08-24 00:53:59.12
653	desktop-1787532863	olx.com.br	PE	Petrolina	Apartamento	venda	45	4	2	2026-08-24 00:54:24.051
654	desktop-1787532906	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	6	6	2026-08-24 00:55:06.776
655	desktop-1787532952	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-08-24 00:55:52.702
656	desktop-1787532994	olx.com.br	PE	Petrolina	Terreno	aluguel	50	1	0	2026-08-24 00:56:34.874
657	desktop-1787533032	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-08-24 00:57:12.726
658	desktop-1787533069	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-08-24 00:57:49.442
659	desktop-1787533094	olx.com.br	BA	Irecê	Casa	venda	7	7	0	2026-08-24 00:58:14.602
660	desktop-1787533117	olx.com.br	BA	Irecê	Casa	aluguel	5	5	0	2026-08-24 00:58:37.533
661	desktop-1787533141	olx.com.br	BA	Irecê	Apartamento	venda	5	0	0	2026-08-24 00:59:01.694
662	desktop-1787533162	olx.com.br	BA	Irecê	Apartamento	aluguel	4	4	0	2026-08-24 00:59:22.695
663	desktop-1787533184	olx.com.br	BA	Irecê	Terreno	venda	7	0	0	2026-08-24 00:59:44.764
664	desktop-1787533209	olx.com.br	BA	Irecê	Terreno	aluguel	4	0	0	2026-08-24 01:00:09.544
665	desktop-1787533237	olx.com.br	BA	Irecê	Comercial	venda	7	0	0	2026-08-24 01:00:37.756
666	desktop-1787533268	olx.com.br	BA	Irecê	Comercial	aluguel	4	0	0	2026-08-24 01:01:08.619
667	desktop-1788277503	olx.com.br	SE	Aracaju	Casa	venda	50	17	17	2026-09-01 15:45:04.34
668	desktop-1788277576	olx.com.br	SE	Aracaju	Casa	aluguel	50	43	42	2026-09-01 15:46:17.119
669	desktop-1788277638	olx.com.br	SE	Aracaju	Apartamento	venda	50	30	31	2026-09-01 15:47:19.223
670	desktop-1788277693	olx.com.br	SE	Aracaju	Apartamento	aluguel	50	33	31	2026-09-01 15:48:14.471
671	desktop-1788277750	olx.com.br	SE	Aracaju	Terreno	venda	50	0	0	2026-09-01 15:49:10.418
672	desktop-1788277832	olx.com.br	SE	Aracaju	Terreno	aluguel	50	4	6	2026-09-01 15:50:32.657
673	desktop-1788277889	olx.com.br	SE	Aracaju	Comercial	venda	50	0	0	2026-09-01 15:51:29.775
674	desktop-1788277961	olx.com.br	SE	Aracaju	Comercial	aluguel	50	0	0	2026-09-01 15:52:41.316
675	desktop-1788278002	olx.com.br	BA	Juazeiro	Casa	venda	34	7	6	2026-09-01 15:53:22.874
676	desktop-1788278030	olx.com.br	BA	Juazeiro	Casa	aluguel	13	5	1	2026-09-01 15:53:50.401
677	desktop-1788278054	olx.com.br	BA	Juazeiro	Apartamento	venda	3	0	1	2026-09-01 15:54:14.802
678	desktop-1788278076	olx.com.br	BA	Juazeiro	Apartamento	aluguel	11	3	5	2026-09-01 15:54:36.375
679	desktop-1788278099	olx.com.br	BA	Juazeiro	Terreno	venda	37	0	0	2026-09-01 15:54:59.99
680	desktop-1788278123	olx.com.br	BA	Juazeiro	Terreno	aluguel	27	0	1	2026-09-01 15:55:24.116
681	desktop-1788278149	olx.com.br	BA	Juazeiro	Comercial	venda	37	0	0	2026-09-01 15:55:49.685
682	desktop-1788278174	olx.com.br	BA	Juazeiro	Comercial	aluguel	27	0	0	2026-09-01 15:56:14.87
683	desktop-1788278215	olx.com.br	PE	Petrolina	Casa	venda	51	16	16	2026-09-01 15:56:55.779
684	desktop-1788278250	olx.com.br	PE	Petrolina	Casa	aluguel	50	18	18	2026-09-01 15:57:30.296
685	desktop-1788278275	olx.com.br	PE	Petrolina	Apartamento	venda	45	7	7	2026-09-01 15:57:55.904
686	desktop-1788278312	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	24	24	2026-09-01 15:58:32.266
687	desktop-1788278347	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-09-01 15:59:07.241
688	desktop-1788278382	olx.com.br	PE	Petrolina	Terreno	aluguel	50	0	0	2026-09-01 15:59:42.607
689	desktop-1788278416	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-09-01 16:00:16.66
690	desktop-1788278455	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-09-01 16:00:55.839
691	desktop-1788278474	olx.com.br	BA	Irecê	Casa	venda	8	2	1	2026-09-01 16:01:15.048
692	desktop-1788278496	olx.com.br	BA	Irecê	Casa	aluguel	4	0	1	2026-09-01 16:01:36.852
693	desktop-1788278519	olx.com.br	BA	Irecê	Apartamento	venda	4	0	0	2026-09-01 16:01:59.947
694	desktop-1788278546	olx.com.br	BA	Irecê	Apartamento	aluguel	3	0	1	2026-09-01 16:02:27.954
695	desktop-1788278576	olx.com.br	BA	Irecê	Terreno	venda	8	0	0	2026-09-01 16:02:56.802
696	desktop-1788278598	olx.com.br	BA	Irecê	Terreno	aluguel	3	0	0	2026-09-01 16:03:18.906
697	desktop-1788278625	olx.com.br	BA	Irecê	Comercial	venda	8	0	0	2026-09-01 16:03:45.274
698	desktop-1788278649	olx.com.br	BA	Irecê	Comercial	aluguel	3	0	0	2026-09-01 16:04:09.513
699	desktop-1788295996	olx.com.br	SE	Aracaju	Casa	venda	50	7	7	2026-09-01 20:53:17.031
700	desktop-1788296032	olx.com.br	SE	Aracaju	Casa	aluguel	50	2	2	2026-09-01 20:53:52.612
701	desktop-1788296070	olx.com.br	SE	Aracaju	Apartamento	venda	50	4	5	2026-09-01 20:54:30.502
702	desktop-1788296106	olx.com.br	SE	Aracaju	Apartamento	aluguel	50	4	4	2026-09-01 20:55:07.077
703	desktop-1788296159	olx.com.br	SE	Aracaju	Terreno	venda	50	0	0	2026-09-01 20:55:59.807
704	desktop-1788296197	olx.com.br	SE	Aracaju	Terreno	aluguel	50	3	1	2026-09-01 20:56:37.317
705	desktop-1788296231	olx.com.br	SE	Aracaju	Comercial	venda	50	0	0	2026-09-01 20:57:11.37
706	desktop-1788296270	olx.com.br	SE	Aracaju	Comercial	aluguel	50	0	0	2026-09-01 20:57:50.782
707	desktop-1788296295	olx.com.br	BA	Juazeiro	Casa	venda	34	0	0	2026-09-01 20:58:15.584
708	desktop-1788296319	olx.com.br	BA	Juazeiro	Casa	aluguel	13	0	0	2026-09-01 20:58:39.649
709	desktop-1788296346	olx.com.br	BA	Juazeiro	Apartamento	venda	3	0	0	2026-09-01 20:59:06.654
710	desktop-1788296369	olx.com.br	BA	Juazeiro	Apartamento	aluguel	11	0	0	2026-09-01 20:59:29.95
711	desktop-1788296393	olx.com.br	BA	Juazeiro	Terreno	venda	37	0	0	2026-09-01 20:59:53.337
712	desktop-1788296419	olx.com.br	BA	Juazeiro	Terreno	aluguel	27	0	0	2026-09-01 21:00:20.126
713	desktop-1788296445	olx.com.br	BA	Juazeiro	Comercial	venda	37	0	0	2026-09-01 21:00:45.776
714	desktop-1788296472	olx.com.br	BA	Juazeiro	Comercial	aluguel	27	0	0	2026-09-01 21:01:12.288
715	desktop-1788296511	olx.com.br	PE	Petrolina	Casa	venda	50	0	1	2026-09-01 21:01:51.479
716	desktop-1788296550	olx.com.br	PE	Petrolina	Casa	aluguel	50	1	1	2026-09-01 21:02:30.321
717	desktop-1788296578	olx.com.br	PE	Petrolina	Apartamento	venda	46	1	0	2026-09-01 21:02:58.817
718	desktop-1788296614	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	0	3	2026-09-01 21:03:34.573
719	desktop-1788296646	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-09-01 21:04:07.211
720	desktop-1788296682	olx.com.br	PE	Petrolina	Terreno	aluguel	50	0	0	2026-09-01 21:04:42.546
721	desktop-1788296717	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-09-01 21:05:17.57
722	desktop-1788296753	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-09-01 21:05:54.186
723	desktop-1788296777	olx.com.br	BA	Irecê	Casa	venda	8	0	0	2026-09-01 21:06:17.459
724	desktop-1788296799	olx.com.br	BA	Irecê	Casa	aluguel	4	0	0	2026-09-01 21:06:39.992
725	desktop-1788296826	olx.com.br	BA	Irecê	Apartamento	venda	4	0	0	2026-09-01 21:07:07.072
726	desktop-1788296854	olx.com.br	BA	Irecê	Apartamento	aluguel	3	0	0	2026-09-01 21:07:34.64
727	desktop-1788296876	olx.com.br	BA	Irecê	Terreno	venda	8	0	0	2026-09-01 21:07:57.091
728	desktop-1788296899	olx.com.br	BA	Irecê	Terreno	aluguel	3	0	0	2026-09-01 21:08:19.624
729	desktop-1788296923	olx.com.br	BA	Irecê	Comercial	venda	8	0	0	2026-09-01 21:08:43.472
730	desktop-1788296948	olx.com.br	BA	Irecê	Comercial	aluguel	3	0	0	2026-09-01 21:09:09.109
731	desktop-1788983606	olx.com.br	BA	Juazeiro	Casa	venda	35	6	5	2026-09-09 19:53:27.956
732	desktop-1788983702	olx.com.br	BA	Juazeiro	Casa	aluguel	13	1	1	2026-09-09 19:55:03.771
733	desktop-1788983728	olx.com.br	BA	Juazeiro	Apartamento	venda	3	0	0	2026-09-09 19:55:29.85
734	desktop-1788983765	olx.com.br	BA	Juazeiro	Apartamento	aluguel	8	0	3	2026-09-09 19:56:07.073
735	desktop-1788983796	olx.com.br	BA	Juazeiro	Terreno	venda	38	0	0	2026-09-09 19:56:37.577
736	desktop-1788983826	olx.com.br	BA	Juazeiro	Terreno	aluguel	25	1	0	2026-09-09 19:57:07.614
737	desktop-1788983852	olx.com.br	BA	Juazeiro	Comercial	venda	38	0	0	2026-09-09 19:57:33.754
738	desktop-1788983896	olx.com.br	BA	Juazeiro	Comercial	aluguel	25	0	0	2026-09-09 19:58:17.174
739	desktop-1788983926	olx.com.br	BA	Irecê	Casa	venda	8	1	1	2026-09-09 19:58:47.867
740	desktop-1788983948	olx.com.br	BA	Irecê	Casa	aluguel	4	0	0	2026-09-09 19:59:10.006
741	desktop-1788983978	olx.com.br	BA	Irecê	Apartamento	venda	1	1	0	2026-09-09 19:59:39.329
742	desktop-1788984014	olx.com.br	BA	Irecê	Apartamento	aluguel	2	0	1	2026-09-09 20:00:15.808
743	desktop-1788984048	olx.com.br	BA	Irecê	Terreno	venda	9	0	0	2026-09-09 20:00:49.776
744	desktop-1788984076	olx.com.br	BA	Irecê	Terreno	aluguel	2	0	0	2026-09-09 20:01:17.278
745	desktop-1788984125	olx.com.br	BA	Irecê	Comercial	venda	9	0	0	2026-09-09 20:02:06.886
746	desktop-1788984174	olx.com.br	BA	Irecê	Comercial	aluguel	2	0	0	2026-09-09 20:02:55.435
747	desktop-1789122675	olx.com.br	BA	Juazeiro	Casa	venda	37	3	1	2026-09-11 10:31:16.34
748	desktop-1789122726	olx.com.br	BA	Juazeiro	Casa	aluguel	13	0	0	2026-09-11 10:32:06.385
749	desktop-1789122753	olx.com.br	BA	Juazeiro	Apartamento	venda	3	0	0	2026-09-11 10:32:33.562
750	desktop-1789122781	olx.com.br	BA	Juazeiro	Apartamento	aluguel	7	0	1	2026-09-11 10:33:01.752
751	desktop-1789122807	olx.com.br	BA	Juazeiro	Terreno	venda	40	0	0	2026-09-11 10:33:27.772
752	desktop-1789122836	olx.com.br	BA	Juazeiro	Terreno	aluguel	24	0	0	2026-09-11 10:33:56.384
753	desktop-1789122865	olx.com.br	BA	Juazeiro	Comercial	venda	40	0	0	2026-09-11 10:34:26.082
754	desktop-1789122902	olx.com.br	BA	Juazeiro	Comercial	aluguel	24	0	0	2026-09-11 10:35:02.756
755	desktop-1789122926	olx.com.br	BA	Irecê	Casa	venda	8	0	0	2026-09-11 10:35:26.58
756	desktop-1789122951	olx.com.br	BA	Irecê	Casa	aluguel	4	0	0	2026-09-11 10:35:51.823
757	desktop-1789122979	olx.com.br	BA	Irecê	Apartamento	venda	1	0	0	2026-09-11 10:36:20.279
758	desktop-1789123011	olx.com.br	BA	Irecê	Apartamento	aluguel	2	0	0	2026-09-11 10:36:51.558
759	desktop-1789123035	olx.com.br	BA	Irecê	Terreno	venda	9	0	0	2026-09-11 10:37:15.863
760	desktop-1789123062	olx.com.br	BA	Irecê	Terreno	aluguel	2	0	0	2026-09-11 10:37:43.312
761	desktop-1789123085	olx.com.br	BA	Irecê	Comercial	venda	9	0	0	2026-09-11 10:38:05.547
762	desktop-1789123112	olx.com.br	BA	Irecê	Comercial	aluguel	2	0	0	2026-09-11 10:38:33.029
763	desktop-1789134532	olx.com.br	BA	Juazeiro	Casa	venda	38	1	0	2026-09-11 13:48:51.415
764	desktop-1789134555	olx.com.br	BA	Juazeiro	Casa	aluguel	13	0	0	2026-09-11 13:49:15.324
765	desktop-1789134581	olx.com.br	BA	Juazeiro	Apartamento	venda	3	0	0	2026-09-11 13:49:40.444
766	desktop-1789134605	olx.com.br	BA	Juazeiro	Apartamento	aluguel	8	1	0	2026-09-11 13:50:04.528
767	desktop-1789134635	olx.com.br	BA	Juazeiro	Terreno	venda	41	0	0	2026-09-11 13:50:35.012
768	desktop-1789134661	olx.com.br	BA	Juazeiro	Terreno	aluguel	25	0	0	2026-09-11 13:51:01.16
769	desktop-1789134687	olx.com.br	BA	Juazeiro	Comercial	venda	41	0	0	2026-09-11 13:51:27.172
770	desktop-1789134712	olx.com.br	BA	Juazeiro	Comercial	aluguel	25	0	0	2026-09-11 13:51:52.104
771	desktop-1789134734	olx.com.br	BA	Irecê	Casa	venda	8	0	0	2026-09-11 13:52:13.624
772	desktop-1789134756	olx.com.br	BA	Irecê	Casa	aluguel	4	0	0	2026-09-11 13:52:36.075
773	desktop-1789134788	olx.com.br	BA	Irecê	Apartamento	venda	1	0	0	2026-09-11 13:53:07.636
774	desktop-1789134818	olx.com.br	BA	Irecê	Apartamento	aluguel	2	0	0	2026-09-11 13:53:38.271
775	desktop-1789134840	olx.com.br	BA	Irecê	Terreno	venda	9	0	0	2026-09-11 13:54:00.29
776	desktop-1789134862	olx.com.br	BA	Irecê	Terreno	aluguel	2	0	0	2026-09-11 13:54:21.779
777	desktop-1789134897	olx.com.br	BA	Irecê	Comercial	venda	9	0	0	2026-09-11 13:54:57.027
778	desktop-1789134962	olx.com.br	BA	Irecê	Comercial	aluguel	0	0	0	2026-09-11 13:56:01.555
779	desktop-1789135001	olx.com.br	PE	Petrolina	Casa	venda	50	50	0	2026-09-11 13:56:40.793
780	desktop-1789135066	olx.com.br	PE	Petrolina	Casa	aluguel	50	50	0	2026-09-11 13:57:45.666
781	desktop-1789135101	olx.com.br	PE	Petrolina	Apartamento	venda	47	47	0	2026-09-11 13:58:20.993
782	desktop-1789135142	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	50	0	2026-09-11 13:59:01.973
783	desktop-1789135209	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-09-11 14:00:08.893
784	desktop-1789135249	olx.com.br	PE	Petrolina	Terreno	aluguel	50	6	0	2026-09-11 14:00:48.726
785	desktop-1789135310	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-09-11 14:01:50.042
786	desktop-1789135383	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-09-11 14:03:02.944
787	desktop-1789408386	olx.com.br	BA	Juazeiro	Casa	venda	37	0	1	2026-09-14 17:53:07.574
788	desktop-1789408434	olx.com.br	BA	Juazeiro	Casa	aluguel	13	0	0	2026-09-14 17:53:55.453
789	desktop-1789408469	olx.com.br	BA	Juazeiro	Apartamento	venda	2	0	1	2026-09-14 17:54:30.83
790	desktop-1789408499	olx.com.br	BA	Juazeiro	Apartamento	aluguel	9	1	0	2026-09-14 17:55:00.163
791	desktop-1789408526	olx.com.br	BA	Juazeiro	Terreno	venda	39	0	0	2026-09-14 17:55:27.332
792	desktop-1789408551	olx.com.br	BA	Juazeiro	Terreno	aluguel	25	1	2	2026-09-14 17:55:52.942
793	desktop-1789408591	olx.com.br	BA	Juazeiro	Comercial	venda	39	0	0	2026-09-14 17:56:32.917
794	desktop-1789408635	olx.com.br	BA	Juazeiro	Comercial	aluguel	25	0	0	2026-09-14 17:57:16.809
795	desktop-1789408675	olx.com.br	BA	Irecê	Casa	venda	8	0	0	2026-09-14 17:57:56.212
796	desktop-1789408737	olx.com.br	BA	Irecê	Casa	aluguel	4	0	0	2026-09-14 17:58:58.801
797	desktop-1789408788	olx.com.br	BA	Irecê	Apartamento	venda	1	0	0	2026-09-14 17:59:49.115
798	desktop-1789408826	olx.com.br	BA	Irecê	Apartamento	aluguel	1	0	1	2026-09-14 18:00:27.139
799	desktop-1789408859	olx.com.br	BA	Irecê	Terreno	venda	9	0	0	2026-09-14 18:01:00.255
800	desktop-1789408916	olx.com.br	BA	Irecê	Terreno	aluguel	1	0	0	2026-09-14 18:01:57.454
801	desktop-1789408966	olx.com.br	BA	Irecê	Comercial	venda	9	0	0	2026-09-14 18:02:47.331
802	desktop-1789409007	olx.com.br	BA	Irecê	Comercial	aluguel	1	0	0	2026-09-14 18:03:28.586
803	desktop-1789409061	olx.com.br	PE	Petrolina	Casa	venda	50	11	11	2026-09-14 18:04:22.287
804	desktop-1789409113	olx.com.br	PE	Petrolina	Casa	aluguel	50	8	8	2026-09-14 18:05:14.396
805	desktop-1789409196	olx.com.br	PE	Petrolina	Apartamento	venda	50	5	2	2026-09-14 18:06:37.726
806	desktop-1789409247	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	7	7	2026-09-14 18:07:28.868
807	desktop-1789409311	olx.com.br	PE	Petrolina	Terreno	venda	50	0	0	2026-09-14 18:08:32.371
808	desktop-1789409407	olx.com.br	PE	Petrolina	Terreno	aluguel	50	2	2	2026-09-14 18:10:08.944
809	desktop-1789649221	olx.com.br	BA	Juazeiro	Casa	venda	37	1	1	2026-09-17 12:47:01.015
810	desktop-1789649238	olx.com.br	BA	Juazeiro	Casa	aluguel	11	1	3	2026-09-17 12:47:18.601
811	desktop-1789649256	olx.com.br	BA	Juazeiro	Apartamento	venda	1	0	1	2026-09-17 12:47:36.958
812	desktop-1789649276	olx.com.br	BA	Juazeiro	Apartamento	aluguel	9	0	0	2026-09-17 12:47:56.262
813	desktop-1789649293	olx.com.br	BA	Juazeiro	Terreno	venda	38	0	0	2026-09-17 12:48:13.521
814	desktop-1789649310	olx.com.br	BA	Juazeiro	Terreno	aluguel	23	0	0	2026-09-17 12:48:30.734
815	desktop-1789649329	olx.com.br	BA	Juazeiro	Comercial	venda	38	0	0	2026-09-17 12:48:49.342
816	desktop-1789649348	olx.com.br	BA	Juazeiro	Comercial	aluguel	23	0	0	2026-09-17 12:49:08.682
817	desktop-1789649364	olx.com.br	BA	Irecê	Casa	venda	8	0	0	2026-09-17 12:49:24.914
818	desktop-1789649382	olx.com.br	BA	Irecê	Casa	aluguel	5	1	0	2026-09-17 12:49:42.101
819	desktop-1789649400	olx.com.br	BA	Irecê	Apartamento	venda	1	0	0	2026-09-17 12:50:00.326
820	desktop-1789649419	olx.com.br	BA	Irecê	Apartamento	aluguel	1	0	0	2026-09-17 12:50:19.395
821	desktop-1789649435	olx.com.br	BA	Irecê	Terreno	venda	9	0	0	2026-09-17 12:50:35.406
822	desktop-1789649452	olx.com.br	BA	Irecê	Terreno	aluguel	1	0	0	2026-09-17 12:50:52.467
823	desktop-1789649471	olx.com.br	BA	Irecê	Comercial	venda	9	0	0	2026-09-17 12:51:11.862
824	desktop-1789649492	olx.com.br	BA	Irecê	Comercial	aluguel	1	0	0	2026-09-17 12:51:32.279
825	desktop-1789649515	olx.com.br	PE	Petrolina	Casa	venda	50	11	11	2026-09-17 12:51:55.942
826	desktop-1789649540	olx.com.br	PE	Petrolina	Casa	aluguel	50	6	6	2026-09-17 12:52:20.304
827	desktop-1789649558	olx.com.br	PE	Petrolina	Apartamento	venda	48	2	4	2026-09-17 12:52:38.71
828	desktop-1789649585	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	8	8	2026-09-17 12:53:05.641
829	desktop-1789649618	olx.com.br	PE	Petrolina	Terreno	venda	51	1	0	2026-09-17 12:53:38.824
830	desktop-1789649645	olx.com.br	PE	Petrolina	Terreno	aluguel	50	2	1	2026-09-17 12:54:05.086
831	desktop-1789649678	olx.com.br	PE	Petrolina	Comercial	venda	51	0	0	2026-09-17 12:54:38.993
832	desktop-1789649706	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-09-17 12:55:06.556
833	desktop-1789650965	olx.com.br	BA	Juazeiro	Casa	venda	37	0	0	2026-09-17 13:16:05.879
834	desktop-1789650983	olx.com.br	BA	Juazeiro	Casa	aluguel	11	0	0	2026-09-17 13:16:23.449
835	desktop-1789651001	olx.com.br	BA	Juazeiro	Apartamento	venda	1	0	0	2026-09-17 13:16:41.511
836	desktop-1789651021	olx.com.br	BA	Juazeiro	Apartamento	aluguel	9	0	0	2026-09-17 13:17:01.117
837	desktop-1789651038	olx.com.br	BA	Juazeiro	Terreno	venda	38	0	0	2026-09-17 13:17:18.618
838	desktop-1789651056	olx.com.br	BA	Juazeiro	Terreno	aluguel	23	0	0	2026-09-17 13:17:36.592
839	desktop-1789651076	olx.com.br	BA	Juazeiro	Comercial	venda	38	0	0	2026-09-17 13:17:56.136
840	desktop-1789651096	olx.com.br	BA	Juazeiro	Comercial	aluguel	23	0	0	2026-09-17 13:18:16.949
841	desktop-1789651113	olx.com.br	BA	Irecê	Casa	venda	8	0	0	2026-09-17 13:18:33.835
842	desktop-1789651134	olx.com.br	BA	Irecê	Casa	aluguel	5	0	0	2026-09-17 13:18:54.307
843	desktop-1789651154	olx.com.br	BA	Irecê	Apartamento	venda	1	0	0	2026-09-17 13:19:14.524
844	desktop-1789651175	olx.com.br	BA	Irecê	Apartamento	aluguel	1	0	0	2026-09-17 13:19:35.676
845	desktop-1789651196	olx.com.br	BA	Irecê	Terreno	venda	9	0	0	2026-09-17 13:19:56.073
846	desktop-1789651214	olx.com.br	BA	Irecê	Terreno	aluguel	1	0	0	2026-09-17 13:20:14.327
847	desktop-1789651232	olx.com.br	BA	Irecê	Comercial	venda	9	0	0	2026-09-17 13:20:32.914
848	desktop-1789651252	olx.com.br	BA	Irecê	Comercial	aluguel	1	0	0	2026-09-17 13:20:52.499
849	desktop-1789651279	olx.com.br	PE	Petrolina	Casa	venda	50	0	1	2026-09-17 13:21:19.908
850	desktop-1789651307	olx.com.br	PE	Petrolina	Casa	aluguel	50	0	0	2026-09-17 13:21:47.167
851	desktop-1789651328	olx.com.br	PE	Petrolina	Apartamento	venda	48	0	0	2026-09-17 13:22:08.358
852	desktop-1789651364	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	1	1	2026-09-17 13:22:44.272
853	desktop-1789651505	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-09-17 13:25:05.92
854	desktop-1789652025	olx.com.br	BA	Juazeiro	Casa	venda	37	0	0	2026-09-17 13:33:45.742
855	desktop-1789652044	olx.com.br	BA	Juazeiro	Casa	aluguel	11	0	0	2026-09-17 13:34:04.428
856	desktop-1789652062	olx.com.br	BA	Juazeiro	Apartamento	venda	1	0	0	2026-09-17 13:34:22.32
857	desktop-1789652081	olx.com.br	BA	Juazeiro	Apartamento	aluguel	9	0	0	2026-09-17 13:34:41.386
858	desktop-1789652097	olx.com.br	BA	Juazeiro	Terreno	venda	38	0	0	2026-09-17 13:34:57.156
859	desktop-1789652116	olx.com.br	BA	Juazeiro	Terreno	aluguel	23	0	0	2026-09-17 13:35:16.361
860	desktop-1789652135	olx.com.br	BA	Juazeiro	Comercial	venda	38	0	0	2026-09-17 13:35:35.308
861	desktop-1789652495	olx.com.br	BA	Irecê	Apartamento	aluguel	1	0	0	2026-09-17 13:41:37.832
862	desktop-1789652523	olx.com.br	BA	Irecê	Terreno	venda	9	0	0	2026-09-17 13:42:03.641
863	desktop-1789652544	olx.com.br	BA	Irecê	Terreno	aluguel	1	0	0	2026-09-17 13:42:24.49
864	desktop-1789652564	olx.com.br	BA	Irecê	Comercial	venda	9	0	0	2026-09-17 13:42:44.242
865	desktop-1789652585	olx.com.br	BA	Irecê	Comercial	aluguel	1	0	0	2026-09-17 13:43:05.691
866	desktop-1789652612	olx.com.br	PE	Petrolina	Casa	venda	50	0	0	2026-09-17 13:43:32.693
867	desktop-1789652639	olx.com.br	PE	Petrolina	Casa	aluguel	50	0	0	2026-09-17 13:43:59.768
868	desktop-1789652661	olx.com.br	PE	Petrolina	Apartamento	venda	48	0	0	2026-09-17 13:44:21.557
869	desktop-1789652691	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	0	0	2026-09-17 13:44:51.255
870	desktop-1789652745	olx.com.br	PE	Petrolina	Terreno	venda	55	0	0	2026-09-17 13:45:45.34
871	desktop-1789652773	olx.com.br	PE	Petrolina	Terreno	aluguel	50	0	0	2026-09-17 13:46:13.656
872	desktop-1789652803	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-09-17 13:46:43.343
873	desktop-1789652834	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-09-17 13:47:14.535
874	desktop-1789652851	olx.com.br	BA	Lapão	Casa	venda	1	1	0	2026-09-17 13:47:31.107
875	desktop-1789652869	olx.com.br	BA	Lapão	Casa	aluguel	5	0	0	2026-09-17 13:47:49.009
876	desktop-1789652890	olx.com.br	BA	Lapão	Apartamento	venda	5	0	0	2026-09-17 13:48:10.389
877	desktop-1789652909	olx.com.br	BA	Lapão	Apartamento	aluguel	5	0	0	2026-09-17 13:48:29.749
878	desktop-1789652928	olx.com.br	BA	Lapão	Terreno	venda	1	0	0	2026-09-17 13:48:48.456
879	desktop-1789652946	olx.com.br	BA	Lapão	Terreno	aluguel	5	0	0	2026-09-17 13:49:06.58
880	desktop-1789652964	olx.com.br	BA	Lapão	Comercial	venda	1	0	0	2026-09-17 13:49:24.847
881	desktop-1789652983	olx.com.br	BA	Lapão	Comercial	aluguel	5	0	0	2026-09-17 13:49:43.55
882	desktop-1789653000	olx.com.br	BA	Xique-Xique	Casa	venda	1	1	0	2026-09-17 13:50:00.254
883	desktop-1789653017	olx.com.br	BA	Xique-Xique	Casa	aluguel	5	0	0	2026-09-17 13:50:17.213
884	desktop-1789653036	olx.com.br	BA	Xique-Xique	Apartamento	venda	5	0	0	2026-09-17 13:50:36.871
885	desktop-1789653058	olx.com.br	BA	Xique-Xique	Apartamento	aluguel	5	0	0	2026-09-17 13:50:58.309
886	desktop-1789653075	olx.com.br	BA	Xique-Xique	Terreno	venda	1	0	0	2026-09-17 13:51:15.91
887	desktop-1789653095	olx.com.br	BA	Xique-Xique	Terreno	aluguel	5	0	0	2026-09-17 13:51:36.249
888	desktop-1789653114	olx.com.br	BA	Xique-Xique	Comercial	venda	1	0	0	2026-09-17 13:51:55.815
889	desktop-1789653149	olx.com.br	BA	Xique-Xique	Comercial	aluguel	5	0	0	2026-09-17 13:52:29.832
890	desktop-1789653171	olx.com.br	BA	João Dourado	Casa	venda	12	12	0	2026-09-17 13:52:52.907
891	desktop-1789653190	olx.com.br	BA	João Dourado	Casa	aluguel	5	5	0	2026-09-17 13:53:10.804
892	desktop-1789653212	olx.com.br	BA	João Dourado	Apartamento	venda	9	9	0	2026-09-17 13:53:32.464
893	desktop-1789653231	olx.com.br	BA	João Dourado	Apartamento	aluguel	5	0	0	2026-09-17 13:53:52.379
894	desktop-1789653255	olx.com.br	BA	João Dourado	Terreno	venda	21	0	0	2026-09-17 13:54:15.181
895	desktop-1789653277	olx.com.br	BA	João Dourado	Terreno	aluguel	13	8	0	2026-09-17 13:54:37.098
896	desktop-1789653298	olx.com.br	BA	João Dourado	Comercial	venda	21	0	0	2026-09-17 13:54:58.176
897	desktop-1789653318	olx.com.br	BA	João Dourado	Comercial	aluguel	13	0	0	2026-09-17 13:55:18.36
898	desktop-1790189685	olx.com.br	BA	Juazeiro	Casa	venda	36	4	5	2026-09-23 18:54:44.714
899	desktop-1790189705	olx.com.br	BA	Juazeiro	Casa	aluguel	14	5	2	2026-09-23 18:55:05.232
900	desktop-1790189728	olx.com.br	BA	Juazeiro	Apartamento	venda	1	0	0	2026-09-23 18:55:28.839
901	desktop-1790189752	olx.com.br	BA	Juazeiro	Apartamento	aluguel	12	4	1	2026-09-23 18:55:51.618
902	desktop-1790189773	olx.com.br	BA	Juazeiro	Terreno	venda	37	0	0	2026-09-23 18:56:12.862
903	desktop-1790189799	olx.com.br	BA	Juazeiro	Terreno	aluguel	28	0	1	2026-09-23 18:56:38.437
904	desktop-1790189822	olx.com.br	BA	Juazeiro	Comercial	venda	37	0	0	2026-09-23 18:57:01.443
905	desktop-1790189845	olx.com.br	BA	Juazeiro	Comercial	aluguel	28	0	0	2026-09-23 18:57:24.545
906	desktop-1790189864	olx.com.br	BA	Irecê	Casa	venda	8	1	1	2026-09-23 18:57:44.184
907	desktop-1790189885	olx.com.br	BA	Irecê	Casa	aluguel	5	1	1	2026-09-23 18:58:05.769
908	desktop-1790634187	olx.com.br	BA	Juazeiro	Casa	venda	33	3	6	2026-09-28 22:23:08.472
909	desktop-1790634218	olx.com.br	BA	Juazeiro	Casa	aluguel	14	2	2	2026-09-28 22:23:39.895
910	desktop-1790634258	olx.com.br	BA	Juazeiro	Apartamento	venda	1	0	0	2026-09-28 22:24:19.74
911	desktop-1790634287	olx.com.br	BA	Juazeiro	Apartamento	aluguel	11	2	3	2026-09-28 22:24:48.666
912	desktop-1790634312	olx.com.br	BA	Juazeiro	Terreno	venda	34	0	0	2026-09-28 22:25:14.339
913	desktop-1790634340	olx.com.br	BA	Juazeiro	Terreno	aluguel	27	0	0	2026-09-28 22:25:42.079
914	desktop-1790634368	olx.com.br	BA	Juazeiro	Comercial	venda	34	0	0	2026-09-28 22:26:09.769
915	desktop-1790634395	olx.com.br	BA	Juazeiro	Comercial	aluguel	27	0	0	2026-09-28 22:26:37.414
916	desktop-1790634421	olx.com.br	BA	Irecê	Casa	venda	7	0	1	2026-09-28 22:27:03.068
917	desktop-1790634449	olx.com.br	BA	Irecê	Casa	aluguel	5	0	0	2026-09-28 22:27:31.419
918	desktop-1790634478	olx.com.br	BA	Irecê	Apartamento	venda	1	0	0	2026-09-28 22:27:59.948
919	desktop-1790634510	olx.com.br	BA	Irecê	Apartamento	aluguel	1	0	0	2026-09-28 22:28:32.013
920	desktop-1790634536	olx.com.br	BA	Irecê	Terreno	venda	8	0	0	2026-09-28 22:28:57.435
921	desktop-1790634563	olx.com.br	BA	Irecê	Terreno	aluguel	1	0	0	2026-09-28 22:29:24.969
922	desktop-1790634595	olx.com.br	BA	Irecê	Comercial	venda	8	0	0	2026-09-28 22:29:56.891
923	desktop-1790634622	olx.com.br	BA	Irecê	Comercial	aluguel	1	0	0	2026-09-28 22:30:24.171
924	desktop-1790634682	olx.com.br	PE	Petrolina	Casa	venda	50	17	17	2026-09-28 22:31:23.447
925	desktop-1790634728	olx.com.br	PE	Petrolina	Casa	aluguel	50	21	21	2026-09-28 22:32:09.922
926	desktop-1790634758	olx.com.br	PE	Petrolina	Apartamento	venda	47	10	11	2026-09-28 22:32:39.92
927	desktop-1790634802	olx.com.br	PE	Petrolina	Apartamento	aluguel	50	22	22	2026-09-28 22:33:24.468
928	desktop-1790634844	olx.com.br	PE	Petrolina	Terreno	venda	50	0	1	2026-09-28 22:34:06.365
929	desktop-1790634896	olx.com.br	PE	Petrolina	Terreno	aluguel	50	1	4	2026-09-28 22:34:58.259
930	desktop-1790634960	olx.com.br	PE	Petrolina	Comercial	venda	50	0	0	2026-09-28 22:36:01.754
931	desktop-1790635006	olx.com.br	PE	Petrolina	Comercial	aluguel	50	0	0	2026-09-28 22:36:47.801
\.


--
-- Data for Name: prospeccao_cidades_alvo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.prospeccao_cidades_alvo (id, estado, cidade, ativo, created_at) FROM stdin;
133	BA	Juazeiro	t	2026-09-28 22:21:47.992802
134	BA	Irecê	t	2026-09-28 22:21:48.000352
135	PE	Petrolina	t	2026-09-28 22:21:48.001802
\.


--
-- Data for Name: prospeccao_config; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.prospeccao_config (id, polling_schedules, auto_polling_enabled) FROM stdin;
1	["00:00", "08:00", "12:00", "16:00", "20:00"]	t
\.


--
-- Data for Name: prospeccao_leads; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.prospeccao_leads (id, titulo, link, fonte, trecho, direto_proprietario, cidade, estado, tipo, modalidade, status, is_new, first_seen_at, last_seen_at, last_batch_id) FROM stdin;
olx-casa-1533895161	Casa	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-1533895161	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-09 19:53:27.956	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-no-dom-jose-rodrigues-1533692099	Casa No Dom Jose Rodrigues	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-no-dom-jose-rodrigues-1533692099	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-09 19:53:27.956	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-em-petrolina-1520508493	Casa Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-em-petrolina-1520508493	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-17 13:46:43.343	desktop-1789652803
olx-vende-se-casa-alto-padrao-petrolina-pe-1524409891	Vende Se Casa Alto Padrao Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vende-se-casa-alto-padrao-petrolina-pe-1524409891	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-venda-em-petrolina-1523124213	Casa Venda Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-venda-em-petrolina-1523124213	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-no-loteamento-nova-petrolina-estrutura-premium-1519327659	Casa No Loteamento Nova Petrolina Estrutura Premium	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-no-loteamento-nova-petrolina-estrutura-premium-1519327659	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-17 13:46:43.343	desktop-1789652803
olx-casa-alphaville-petrolina-veja-a-descricao-1523168965	Casa Alphaville Petrolina Veja A Descricao	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-alphaville-petrolina-veja-a-descricao-1523168965	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-vendo-casa-no-centro-de-petrolina-1523895891	Vendo Casa No Centro De Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-casa-no-centro-de-petrolina-1523895891	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-procuro-menina-para-dividir-apartamento-no-sao-jose-1536018247	Procuro Menina Para Dividir Apartamento No Sao Jose	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/procuro-menina-para-dividir-apartamento-no-sao-jose-1536018247	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-17 12:53:05.641	2026-09-17 13:47:14.535	desktop-1789652834
olx-casa-em-petrolina-1525383563	Casa Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-em-petrolina-1525383563	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-vende-se-imovel-no-centro-de-petrolina-1525620441	Vende Se Imovel No Centro De Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vende-se-imovel-no-centro-de-petrolina-1525620441	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-para-lazer-ou-moradia-no-projeto-mandacaru-1-1533836065	Casa Para Lazer Ou Moradia No Projeto Mandacaru 1	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-para-lazer-ou-moradia-no-projeto-mandacaru-1-1533836065	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-09 19:53:27.956	2026-09-28 22:26:09.769	desktop-1790634368
olx-imovel-disponivel-para-venda-petrolina-pe-1524778966	Imovel Disponivel Para Venda Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/imovel-disponivel-para-venda-petrolina-pe-1524778966	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-com-piscina-1533893920	Casa Com Piscina	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-com-piscina-1533893920	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-09 19:53:27.956	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-de-alto-padrao-em-petrolina-1519209376	Casa De Alto Padrao Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-de-alto-padrao-em-petrolina-1519209376	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-14 18:08:32.371	desktop-1789409311
olx-casa-a-venda-em-petrolina-1538315111	Casa A Venda Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-a-venda-em-petrolina-1538315111	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-28 22:31:23.447	2026-09-28 22:36:01.754	desktop-1790634960
olx-vende-se-casa-no-condominio-country-club-4-suites-com-closet-porteira-fechada-1508014697	Vende Se Casa No Condominio Country Club 4 Suites Com Closet Porteira Fechada	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/vende-se-casa-no-condominio-country-club-4-suites-com-closet-porteira-fechada-1508014697	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-09 19:53:27.956	2026-09-28 22:26:09.769	desktop-1790634368
olx-compra-e-venda-1534498522	Compra E Venda	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/compra-e-venda-1534498522	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-11 13:48:51.415	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-em-petrolina-1524514462	Casa Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-em-petrolina-1524514462	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-a-venda-em-lapao-ba-1527078185	Casa A Venda Em Lapao Ba	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-em-lapao-ba-1527078185	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Lapão-BA.	t	Lapão	BA	Casa	venda	active	f	2026-09-17 13:47:31.107	2026-09-17 13:49:24.847	desktop-1789652964
olx-casa-de-225m-a-venda-no-bairro-jatoba-petrolina-pe-1509380428	Casa De 225m A Venda No Bairro Jatoba Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-de-225m-a-venda-no-bairro-jatoba-petrolina-pe-1509380428	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-imovel-com-2-casas-independentes-ideal-para-morar-e-alugar-terra-do-sul-petrolina-1523363647	Imovel Com 2 Casas Independentes Ideal Para Morar E Alugar Terra Do Sul Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/imovel-com-2-casas-independentes-ideal-para-morar-e-alugar-terra-do-sul-petrolina-1523363647	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-para-alugar-no-centro-de-juazeiro-ba-1533828646	Casa Para Alugar No Centro De Juazeiro Ba	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-para-alugar-no-centro-de-juazeiro-ba-1533828646	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	active	f	2026-09-09 19:55:03.771	2026-09-28 22:26:37.414	desktop-1790634395
olx-casa-espacosa-e-de-qualidade-em-petrolina-1523212222	Casa Espacosa E De Qualidade Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-espacosa-e-de-qualidade-em-petrolina-1523212222	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-alugo-apartamento-condominio-fechado-1535617431	Alugo Apartamento Condominio Fechado	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-apartamento-condominio-fechado-1535617431	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-17 12:53:05.641	2026-09-17 13:47:14.535	desktop-1789652834
olx-apartamento-na-avenida-nordeste-santa-luzia-1535590028	Apartamento Na Avenida Nordeste Santa Luzia	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-na-avenida-nordeste-santa-luzia-1535590028	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-17 12:53:05.641	2026-09-17 13:47:14.535	desktop-1789652834
olx-duas-casas-pelo-preco-de-uma-no-jardim-guararapes-em-petrolina-1528958196	Duas Casas Pelo Preco De Uma No Jardim Guararapes Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/duas-casas-pelo-preco-de-uma-no-jardim-guararapes-em-petrolina-1528958196	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-com-3-quartos-e-suite-em-petrolina-entrada-de-r-15-mil-1522973310	Casa Com 3 Quartos E Suite Em Petrolina Entrada De R 15 Mil	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-com-3-quartos-e-suite-em-petrolina-entrada-de-r-15-mil-1522973310	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-ampla-com-154-m-de-area-construida-no-bairro-colina-do-rio-petrolina-pe-1525632467	Casa Ampla Com 154 M De Area Construida No Bairro Colina Do Rio Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-ampla-com-154-m-de-area-construida-no-bairro-colina-do-rio-petrolina-pe-1525632467	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-excelente-apartamento-mobiliado-com-ar-condicionado-com-proprietario-zap-87-1534481369	Excelente Apartamento Mobiliado Com Ar Condicionado Com Proprietario Zap 87	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/excelente-apartamento-mobiliado-com-ar-condicionado-com-proprietario-zap-87-1534481369	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	active	f	2026-09-11 13:50:04.528	2026-09-28 22:26:37.414	desktop-1790634395
olx-casa-a-venda-vila-nova-1-petrolina-1481148498	Casa A Venda Vila Nova 1 Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-a-venda-vila-nova-1-petrolina-1481148498	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-5-quartos-centro-de-petrolina-1525015429	Casa 5 Quartos Centro De Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-5-quartos-centro-de-petrolina-1525015429	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-14 18:08:32.371	desktop-1789409311
olx-vende-se-casa-no-centro-de-petrolina-495m-prox-a-praca-do-peixe-1534879253	Vende Se Casa No Centro De Petrolina 495m Prox A Praca Do Peixe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vende-se-casa-no-centro-de-petrolina-495m-prox-a-praca-do-peixe-1534879253	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-28 22:31:23.447	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-de-esquina-bairro-jatoba-petrolina-1517671354	Casa De Esquina Bairro Jatoba Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-de-esquina-bairro-jatoba-petrolina-1517671354	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-11 14:01:50.042	desktop-1789135310
olx-casa-nascente-mobiliada-cond-alphaville-petrolina-pe-1478385599	Casa Nascente Mobiliada Cond Alphaville Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-nascente-mobiliada-cond-alphaville-petrolina-pe-1478385599	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-17 13:46:43.343	desktop-1789652803
olx-vendo-ou-troco-esse-sobrado-1527650597	Vendo Ou Troco Esse Sobrado	https://ba.olx.com.br/regiao-de-vitoria-da-conquista-e-barreiras/imoveis/vendo-ou-troco-esse-sobrado-1527650597	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Xique-Xique-BA.	t	Xique-Xique	BA	Casa	venda	active	f	2026-09-17 13:50:00.254	2026-09-17 13:51:55.815	desktop-1789653114
olx-casa-no-jd-petropolis-em-petrolina-pe-r-120-000-1526369019	Casa No Jd Petropolis Em Petrolina Pe R 120 000	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-no-jd-petropolis-em-petrolina-pe-r-120-000-1526369019	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-excelente-casa-a-venda-no-bairro-caminho-do-sol-1526638499	Excelente Casa A Venda No Bairro Caminho Do Sol	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/excelente-casa-a-venda-no-bairro-caminho-do-sol-1526638499	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-17 13:43:32.693	desktop-1789652612
olx-vende-si-uma-casa-com-ponto-comercial-1534016394	Vende Si Uma Casa Com Ponto Comercial	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vende-si-uma-casa-com-ponto-comercial-1534016394	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-14 18:04:22.287	desktop-1789409061
olx-casa-em-condominio-1502085907	Casa Em Condominio	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-em-condominio-1502085907	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-14 18:04:22.287	desktop-1789409061
olx-quarto-mobiliado-com-ar-condicionado-1533656597	Quarto Mobiliado Com Ar Condicionado	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/quarto-mobiliado-com-ar-condicionado-1533656597	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Terreno	aluguel	removed	f	2026-09-09 19:57:07.614	2026-09-11 13:51:52.104	desktop-1789134712
olx-oportunidade-condominio-prime-1459144266	Oportunidade Condominio Prime	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/oportunidade-condominio-prime-1459144266	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-14 18:04:22.287	desktop-1789409061
olx-casa-no-bairro-ouro-preto-1534208868	Casa No Bairro Ouro Preto	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-no-bairro-ouro-preto-1534208868	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-14 18:04:22.287	desktop-1789409061
olx-vendo-casa-no-bairro-padre-cicero-1522199475	Vendo Casa No Bairro Padre Cicero	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-casa-no-bairro-padre-cicero-1522199475	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-14 18:04:22.287	desktop-1789409061
olx-opoportunidade-no-bairro-padre-jose-de-castro-1534160695	Opoportunidade No Bairro Padre Jose De Castro	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/opoportunidade-no-bairro-padre-jose-de-castro-1534160695	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-14 18:04:22.287	desktop-1789409061
olx-vendo-casa-vila-eulalia-1529628097	Vendo Casa Vila Eulalia	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-casa-vila-eulalia-1529628097	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:31:23.447	desktop-1790634682
olx-casa-pelo-programa-minha-casa-minha-vida-1518282089	Casa Pelo Programa Minha Casa Minha Vida	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-pelo-programa-minha-casa-minha-vida-1518282089	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	t	2026-09-11 13:56:40.793	2026-09-11 13:56:40.793	desktop-1789135001
olx-casa-em-condominio-1531731003	Casa Em Condominio	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-em-condominio-1531731003	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	t	2026-09-11 13:56:40.793	2026-09-11 13:56:40.793	desktop-1789135001
olx-casa-na-cohab-vi-cohab-sao-francisco-1523845117	Casa Na Cohab Vi Cohab Sao Francisco	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-na-cohab-vi-cohab-sao-francisco-1523845117	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	t	2026-09-11 13:56:40.793	2026-09-11 13:56:40.793	desktop-1789135001
olx-casa-a-venda-entrada-de-r-26-800-00-1529387060	Casa A Venda Entrada De R 26 800 00	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-a-venda-entrada-de-r-26-800-00-1529387060	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	t	2026-09-11 13:56:40.793	2026-09-11 13:56:40.793	desktop-1789135001
olx-disponivel-na-areia-branca-1533404294	Disponivel Na Areia Branca	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/disponivel-na-areia-branca-1533404294	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	t	2026-09-11 13:56:40.793	2026-09-11 13:56:40.793	desktop-1789135001
olx-casa-a-venda-com-piscina-no-loteamento-recife-iii-1533363476	Casa A Venda Com Piscina No Loteamento Recife Iii	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-a-venda-com-piscina-no-loteamento-recife-iii-1533363476	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	t	2026-09-11 13:56:40.793	2026-09-11 13:56:40.793	desktop-1789135001
olx-casa-em-condominio-com-piscina-750-000-00-1533340161	Casa Em Condominio Com Piscina 750 000 00	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-em-condominio-com-piscina-750-000-00-1533340161	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	t	2026-09-11 13:56:40.793	2026-09-11 13:56:40.793	desktop-1789135001
olx-casa-condominio-vale-ds-mangueiras-1533240013	Casa Condominio Vale Ds Mangueiras	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-condominio-vale-ds-mangueiras-1533240013	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	t	2026-09-11 13:56:40.793	2026-09-11 13:56:40.793	desktop-1789135001
olx-casa-escriturada-na-areia-branca-aceita-financiamento-1533204413	Casa Escriturada Na Areia Branca Aceita Financiamento	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-escriturada-na-areia-branca-aceita-financiamento-1533204413	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	t	2026-09-11 13:56:40.793	2026-09-11 13:56:40.793	desktop-1789135001
olx-casa-sao-joao-do-cabrito-1530119296	Casa Sao Joao Do Cabrito	https://ba.olx.com.br/grande-salvador/imoveis/casa-sao-joao-do-cabrito-1530119296	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	venda	active	f	2026-09-17 13:52:52.907	2026-09-17 13:54:58.176	desktop-1789653298
olx-apartamento-mobiliado-2-4-palhinhas-1535401186	Apartamento Mobiliado 2 4 Palhinhas	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-mobiliado-2-4-palhinhas-1535401186	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-17 12:53:05.641	2026-09-28 22:33:24.468	desktop-1790634802
olx-alugo-casa-1-000-00-rua-paulo-afonso-75a-vila-eduardo-sala-cozinha-quarto-banheiro-e-muro-1534495600	Alugo Casa 1 000 00 Rua Paulo Afonso 75a Vila Eduardo Sala Cozinha Quarto Banheiro E Muro	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-casa-1-000-00-rua-paulo-afonso-75a-vila-eduardo-sala-cozinha-quarto-banheiro-e-muro-1534495600	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:32:09.922	desktop-1790634728
olx-casa-1521002160	Casa	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-1521002160	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:32:09.922	desktop-1790634728
olx-casa-moderna-no-coopirece-1532312122	Casa Moderna No Coopirece	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-moderna-no-coopirece-1532312122	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	venda	active	f	2026-09-09 19:58:47.867	2026-09-28 22:29:56.891	desktop-1790634595
olx-casa-pequena-bem-localizada-alto-do-cocar-jardim-amazonas-1534188971	Casa Pequena Bem Localizada Alto Do Cocar Jardim Amazonas	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-pequena-bem-localizada-alto-do-cocar-jardim-amazonas-1534188971	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:32:09.922	desktop-1790634728
olx-casa-para-alugar-no-cond-valle-das-mangueiras-em-petrolina-1522951062	Casa Para Alugar No Cond Valle Das Mangueiras Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-para-alugar-no-cond-valle-das-mangueiras-em-petrolina-1522951062	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:36:47.801	desktop-1790635006
olx-casa-2-quartos-para-alugar-no-condominio-flor-de-guaruja-1534181974	Casa 2 Quartos Para Alugar No Condominio Flor De Guaruja	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-2-quartos-para-alugar-no-condominio-flor-de-guaruja-1534181974	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:32:09.922	desktop-1790634728
olx-casa-venda-bairro-fernando-idalino-petrolina-pe-br-1538736057	Casa Venda Bairro Fernando Idalino Petrolina Pe Br	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-venda-bairro-fernando-idalino-petrolina-pe-br-1538736057	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-28 22:31:23.447	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-mobiliada-em-petrolina-2-quartos-1518047277	Casa Mobiliada Em Petrolina 2 Quartos	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-mobiliada-em-petrolina-2-quartos-1518047277	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-14 18:10:08.944	desktop-1789409407
olx-ccasa-no-parque-massangano-petrolina-pe-1521349690	Ccasa No Parque Massangano Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/ccasa-no-parque-massangano-petrolina-pe-1521349690	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:47:14.535	desktop-1789652834
olx-casa-3-quartos-ouro-preto-1534178929	Casa 3 Quartos Ouro Preto	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-3-quartos-ouro-preto-1534178929	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:32:09.922	desktop-1790634728
olx-excelente-casa-em-condominio-mais-viver-petrolina-1519889480	Excelente Casa Em Condominio Mais Viver Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/excelente-casa-em-condominio-mais-viver-petrolina-1519889480	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:47:14.535	desktop-1789652834
olx-casa-com-4-quartos-sendo-3-suites-cond-sol-nascente-petrolina-pe-1518587647	Casa Com 4 Quartos Sendo 3 Suites Cond Sol Nascente Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-com-4-quartos-sendo-3-suites-cond-sol-nascente-petrolina-pe-1518587647	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-14 18:10:08.944	desktop-1789409407
olx-2-quartos-mobiliado-vale-dos-coqueiros-1535453835	2 Quartos Mobiliado Vale Dos Coqueiros	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/2-quartos-mobiliado-vale-dos-coqueiros-1535453835	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-17 12:53:05.641	2026-09-28 22:33:24.468	desktop-1790634802
olx-aluguel-cosme-e-damiao-ipsep-petrolina-1521958782	Aluguel Cosme E Damiao Ipsep Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluguel-cosme-e-damiao-ipsep-petrolina-1521958782	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:47:14.535	desktop-1789652834
olx-aluga-se-para-fins-comerciais-1449184624	Aluga Se Para Fins Comerciais	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluga-se-para-fins-comerciais-1449184624	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:32:09.922	desktop-1790634728
olx-imovel-comercial-no-centro-de-petrolina-1522763394	Imovel Comercial No Centro De Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/imovel-comercial-no-centro-de-petrolina-1522763394	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:36:47.801	desktop-1790635006
olx-vendo-casa-coronel-joao-sa-bahia-1522016829	Vendo Casa Coronel Joao Sa Bahia	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/vendo-casa-coronel-joao-sa-bahia-1522016829	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	venda	active	f	2026-09-17 13:52:52.907	2026-09-17 13:54:58.176	desktop-1789653298
olx-casa-para-aluguel-dom-avelar-1532389965	Casa Para Aluguel Dom Avelar	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-para-aluguel-dom-avelar-1532389965	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:32:09.922	desktop-1790634728
olx-casa-ampla-e-confortavel-para-aluguel-1531531804	Casa Ampla E Confortavel Para Aluguel	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-ampla-e-confortavel-para-aluguel-1531531804	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:43:59.768	desktop-1789652639
olx-casa-pra-alugar-1532087911	Casa Pra Alugar	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-pra-alugar-1532087911	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:32:09.922	desktop-1790634728
olx-procuro-moca-para-dividir-casa-no-bairro-alto-da-boa-vista-joao-de-deus-1531365832	Procuro Moca Para Dividir Casa No Bairro Alto Da Boa Vista Joao De Deus	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/procuro-moca-para-dividir-casa-no-bairro-alto-da-boa-vista-joao-de-deus-1531365832	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:43:59.768	desktop-1789652639
olx-alugo-casa-no-condominio-sol-nascente-etapa-3-1530857527	Alugo Casa No Condominio Sol Nascente Etapa 3	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-casa-no-condominio-sol-nascente-etapa-3-1530857527	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:43:59.768	desktop-1789652639
olx-casa-em-condominio-para-alugar-1532470951	Casa Em Condominio Para Alugar	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-em-condominio-para-alugar-1532470951	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:32:09.922	desktop-1790634728
olx-casa-mobiliada-para-alugar-1530347406	Casa Mobiliada Para Alugar	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-mobiliada-para-alugar-1530347406	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:43:59.768	desktop-1789652639
olx-pago-150-1530307881	Pago 150	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/pago-150-1530307881	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:43:59.768	desktop-1789652639
olx-casa-j-no-jardim-amazonas-3-quartos-sendo-2-com-ar-sala-cozinha-2-banheiros-garagem-1528370340	Casa J No Jardim Amazonas 3 Quartos Sendo 2 Com Ar Sala Cozinha 2 Banheiros Garagem	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-j-no-jardim-amazonas-3-quartos-sendo-2-com-ar-sala-cozinha-2-banheiros-garagem-1528370340	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:43:59.768	desktop-1789652639
olx-casa-no-valle-dos-flamboyants-1529351552	Casa No Valle Dos Flamboyants	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-no-valle-dos-flamboyants-1529351552	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:43:59.768	desktop-1789652639
olx-mobiliado-lindo-moderno-e-confortavel-viver-com-estilo-1535206644	Mobiliado Lindo Moderno E Confortavel Viver Com Estilo	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/mobiliado-lindo-moderno-e-confortavel-viver-com-estilo-1535206644	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-17 12:53:05.641	2026-09-17 13:44:51.255	desktop-1789652691
olx-apartamento-mobiliado-condominio-vinhedoss-1532679030	Apartamento Mobiliado Condominio Vinhedoss	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-mobiliado-condominio-vinhedoss-1532679030	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-17 12:53:05.641	2026-09-17 13:44:51.255	desktop-1789652691
olx-excelente-casa-no-dom-avelar-petrolina-1537531846	Excelente Casa No Dom Avelar Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/excelente-casa-no-dom-avelar-petrolina-1537531846	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-28 22:31:23.447	2026-09-28 22:36:01.754	desktop-1790634960
olx-imovel-para-locacao-localizado-na-rua-santa-ines-vila-eulalia-1532317042	Imovel Para Locacao Localizado Na Rua Santa Ines Vila Eulalia	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/imovel-para-locacao-localizado-na-rua-santa-ines-vila-eulalia-1532317042	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:32:09.922	desktop-1790634728
olx-casa-nova-com-3-4-e-garagem-1531923385	Casa Nova Com 3 4 E Garagem	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-nova-com-3-4-e-garagem-1531923385	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:32:09.922	desktop-1790634728
olx-casa-sunville-1531847726	Casa Sunville	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-sunville-1531847726	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:32:09.922	desktop-1790634728
olx-apartamento-com-2-quartos-proximo-ao-centro-de-irece-r-130-mil-1531903533	Apartamento Com 2 Quartos Proximo Ao Centro De Irece R 130 Mil	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/apartamento-com-2-quartos-proximo-ao-centro-de-irece-r-130-mil-1531903533	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Apartamento	venda	active	f	2026-09-09 19:59:39.329	2026-09-28 22:29:56.891	desktop-1790634595
olx-vendo-casa-no-lot-recife-em-petrolina-1538559773	Vendo Casa No Lot Recife Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-casa-no-lot-recife-em-petrolina-1538559773	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-28 22:31:23.447	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-mobiliada-no-jatoba-3-quartos-1527685426	Casa Mobiliada No Jatoba 3 Quartos	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-mobiliada-no-jatoba-3-quartos-1527685426	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:43:59.768	desktop-1789652639
olx-casa-locacao-alphaville-1527345381	Casa Locacao Alphaville	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-locacao-alphaville-1527345381	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:43:59.768	desktop-1789652639
olx-venda-a-vista-1534017608	Venda A Vista	https://ba.olx.com.br/regiao-de-vitoria-da-conquista-e-barreiras/imoveis/venda-a-vista-1534017608	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-09-11 10:31:16.34	2026-09-17 13:35:35.308	desktop-1789652135
olx-oportunidade-casa-grande-ponto-comercial-1516629609	Oportunidade Casa Grande Ponto Comercial	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/oportunidade-casa-grande-ponto-comercial-1516629609	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-11 10:31:16.34	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-2-quarto-1527276203	Casa 2 Quarto	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-2-quarto-1527276203	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:43:59.768	desktop-1789652639
olx-casa-3-quartos-garagem-quintal-grande-1526558930	Casa 3 Quartos Garagem Quintal Grande	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-3-quartos-garagem-quintal-grande-1526558930	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:43:59.768	desktop-1789652639
olx-casa-em-condominio-1529181145	Casa Em Condominio	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-em-condominio-1529181145	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:43:59.768	desktop-1789652639
olx-aluguel-de-casa-condominio-flor-do-guaruja-1528945728	Aluguel De Casa Condominio Flor Do Guaruja	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluguel-de-casa-condominio-flor-do-guaruja-1528945728	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:43:59.768	desktop-1789652639
olx-casa-no-condominio-flamboyants-1526556582	Casa No Condominio Flamboyants	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-no-condominio-flamboyants-1526556582	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-14 18:05:14.396	desktop-1789409113
olx-alugo-ponto-comercial-1-500-1526447155	Alugo Ponto Comercial 1 500	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-ponto-comercial-1-500-1526447155	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-14 18:05:14.396	desktop-1789409113
olx-casa-reformada-1526071412	Casa Reformada	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-reformada-1526071412	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-14 18:05:14.396	desktop-1789409113
olx-alugo-casa-valle-flor-do-guaruja-1525532898	Alugo Casa Valle Flor Do Guaruja	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-casa-valle-flor-do-guaruja-1525532898	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-14 18:05:14.396	desktop-1789409113
olx-aluga-se-casa-no-santa-barbara-1529005944	Aluga Se Casa No Santa Barbara	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluga-se-casa-no-santa-barbara-1529005944	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	t	2026-09-11 13:57:45.666	2026-09-11 13:57:45.666	desktop-1789135066
olx-alugo-ou-vendo-casa-no-parque-massangano-proxima-do-mix-mateus-1437962123	Alugo Ou Vendo Casa No Parque Massangano Proxima Do Mix Mateus	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-ou-vendo-casa-no-parque-massangano-proxima-do-mix-mateus-1437962123	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	t	2026-09-11 13:57:45.666	2026-09-11 13:57:45.666	desktop-1789135066
olx-casa-ampla-e-bem-localizada-1524158138	Casa Ampla E Bem Localizada	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-ampla-e-bem-localizada-1524158138	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	t	2026-09-11 13:57:45.666	2026-09-11 13:57:45.666	desktop-1789135066
olx-casa-mobiliada-condominio-mais-viver-1523955873	Casa Mobiliada Condominio Mais Viver	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-mobiliada-condominio-mais-viver-1523955873	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	t	2026-09-11 13:57:45.666	2026-09-11 13:57:45.666	desktop-1789135066
olx-casa-padre-cicero-1523955237	Casa Padre Cicero	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-padre-cicero-1523955237	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	t	2026-09-11 13:57:45.666	2026-09-11 13:57:45.666	desktop-1789135066
olx-alugo-apartamento-na-vila-eduardo-em-condominio-1523254982	Alugo Apartamento Na Vila Eduardo Em Condominio	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-apartamento-na-vila-eduardo-em-condominio-1523254982	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	t	2026-09-11 13:57:45.666	2026-09-11 13:57:45.666	desktop-1789135066
olx-apartamento-terreo-no-solaris-1477810535	Apartamento Terreo No Solaris	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-terreo-no-solaris-1477810535	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	t	2026-09-11 13:57:45.666	2026-09-11 13:57:45.666	desktop-1789135066
olx-casa-vale-dourado-petrolina-1536657691	Casa Vale Dourado Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-vale-dourado-petrolina-1536657691	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-28 22:31:23.447	2026-09-28 22:36:01.754	desktop-1790634960
olx-alugo-casa-no-condominio-valle-das-mangueiras-1509292844	Alugo Casa No Condominio Valle Das Mangueiras	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-casa-no-condominio-valle-das-mangueiras-1509292844	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	t	2026-09-11 13:57:45.666	2026-09-11 13:57:45.666	desktop-1789135066
olx-vendo-casa-em-mata-de-sao-joao-1522814736	Vendo Casa Em Mata De Sao Joao	https://ba.olx.com.br/grande-salvador/imoveis/vendo-casa-em-mata-de-sao-joao-1522814736	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	venda	active	f	2026-09-17 13:52:52.907	2026-09-17 13:54:58.176	desktop-1789653298
olx-ponto-comercial-escriturado-proximo-a-esquina-da-av-joao-durval-feira-ba-1522724493	Ponto Comercial Escriturado Proximo A Esquina Da Av Joao Durval Feira Ba	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/ponto-comercial-escriturado-proximo-a-esquina-da-av-joao-durval-feira-ba-1522724493	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	venda	active	f	2026-09-17 13:52:52.907	2026-09-17 13:54:58.176	desktop-1789653298
olx-vande-se-uma-casa-em-praia-do-forte-mata-de-sao-joao-1521900435	Vande Se Uma Casa Em Praia Do Forte Mata De Sao Joao	https://ba.olx.com.br/grande-salvador/imoveis/vande-se-uma-casa-em-praia-do-forte-mata-de-sao-joao-1521900435	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	venda	active	f	2026-09-17 13:52:52.907	2026-09-17 13:54:58.176	desktop-1789653298
olx-casa-em-barra-de-jacuipe-loteamento-dourado-3-quartos-3-banheiros-vaga-para-4-carros-1526090379	Casa Em Barra De Jacuipe Loteamento Dourado 3 Quartos 3 Banheiros Vaga Para 4 Carros	https://ba.olx.com.br/grande-salvador/imoveis/casa-em-barra-de-jacuipe-loteamento-dourado-3-quartos-3-banheiros-vaga-para-4-carros-1526090379	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	venda	active	f	2026-09-17 13:52:52.907	2026-09-17 13:54:58.176	desktop-1789653298
olx-casa-no-bairro-padre-jose-de-castro-petrolina-1422834764	Casa No Bairro Padre Jose De Castro Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-no-bairro-padre-jose-de-castro-petrolina-1422834764	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-a-venda-no-lot-padre-cicero-petrolina-pe-1531912352	Casa A Venda No Lot Padre Cicero Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-a-venda-no-lot-padre-cicero-petrolina-pe-1531912352	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-vendo-casa-bairro-sao-goncalo-1536339419	Vendo Casa Bairro Sao Goncalo	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-casa-bairro-sao-goncalo-1536339419	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Terreno	venda	removed	f	2026-09-17 12:53:38.824	2026-09-17 13:46:43.343	desktop-1789652803
olx-vendo-casa-no-nova-vida-1-1539660835	Vendo Casa No Nova Vida 1	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-casa-no-nova-vida-1-1539660835	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	t	2026-09-28 22:31:23.447	2026-09-28 22:31:23.447	desktop-1790634682
olx-roca-1600-m-em-mata-de-sao-joao-6-km-do-entroncamento-no-assentamento-bela-vista-1535175403	Roca 1600 M Em Mata De Sao Joao 6 Km Do Entroncamento No Assentamento Bela Vista	https://ba.olx.com.br/grande-salvador/imoveis/roca-1600-m-em-mata-de-sao-joao-6-km-do-entroncamento-no-assentamento-bela-vista-1535175403	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	venda	active	f	2026-09-17 13:52:52.907	2026-09-17 13:54:58.176	desktop-1789653298
olx-casa-venda-iacu-bahia-rua-joao-amaro-1535068192	Casa Venda Iacu Bahia Rua Joao Amaro	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/casa-venda-iacu-bahia-rua-joao-amaro-1535068192	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	venda	active	f	2026-09-17 13:52:52.907	2026-09-17 13:54:58.176	desktop-1789653298
olx-casa-a-venda-no-centro-mata-de-sao-joao-1534792184	Casa A Venda No Centro Mata De Sao Joao	https://ba.olx.com.br/grande-salvador/imoveis/casa-a-venda-no-centro-mata-de-sao-joao-1534792184	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	venda	active	f	2026-09-17 13:52:52.907	2026-09-17 13:54:58.176	desktop-1789653298
olx-casa-rio-vermelho-parque-joao-xxlll-1531870600	Casa Rio Vermelho Parque Joao Xxlll	https://ba.olx.com.br/grande-salvador/imoveis/casa-rio-vermelho-parque-joao-xxlll-1531870600	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	venda	active	f	2026-09-17 13:52:52.907	2026-09-17 13:54:58.176	desktop-1789653298
olx-casa-loteamento-recife-ii-1539523264	Casa Loteamento Recife Ii	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-loteamento-recife-ii-1539523264	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	t	2026-09-28 22:31:23.447	2026-09-28 22:31:23.447	desktop-1790634682
olx-casa-a-venda-na-rua-petunia-amplo-espaco-e-excelente-estrutura-1516594656	Casa A Venda Na Rua Petunia Amplo Espaco E Excelente Estrutura	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-a-venda-na-rua-petunia-amplo-espaco-e-excelente-estrutura-1516594656	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	t	2026-09-28 22:31:23.447	2026-09-28 22:31:23.447	desktop-1790634682
olx-casa-1539062931	Casa	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-1539062931	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	t	2026-09-28 22:31:23.447	2026-09-28 22:31:23.447	desktop-1790634682
olx-casa-no-condominio-park-jatoba-luxo-e-natureza-se-encontram-melhor-localizacao-petrolina-1525006192	Casa No Condominio Park Jatoba Luxo E Natureza Se Encontram Melhor Localizacao Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-no-condominio-park-jatoba-luxo-e-natureza-se-encontram-melhor-localizacao-petrolina-1525006192	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-apartamento-a-venda-1-andar-bairro-jatoba-petrolina-1525044249	Apartamento A Venda 1 Andar Bairro Jatoba Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-a-venda-1-andar-bairro-jatoba-petrolina-1525044249	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:36:01.754	desktop-1790634960
olx-apartamento-residencial-paulo-coelho-vila-moco-petrolina-pe-1523749651	Apartamento Residencial Paulo Coelho Vila Moco Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-residencial-paulo-coelho-vila-moco-petrolina-pe-1523749651	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:36:01.754	desktop-1790634960
olx-apartamento-venda-morada-dos-ypes-cohab-massangano-petrolina-pe-1528262083	Apartamento Venda Morada Dos Ypes Cohab Massangano Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-venda-morada-dos-ypes-cohab-massangano-petrolina-pe-1528262083	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:36:01.754	desktop-1790634960
olx-apartamento-mobiliado-a-venda-nao-financia-avalio-troca-1516993035	Apartamento Mobiliado A Venda Nao Financia Avalio Troca	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-mobiliado-a-venda-nao-financia-avalio-troca-1516993035	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-apartamento-no-bairro-jatoba-1529507016	Apartamento No Bairro Jatoba	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-no-bairro-jatoba-1529507016	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-11 13:58:20.993	2026-09-17 13:44:21.557	desktop-1789652661
olx-apartamento-morada-movao-petrolina-pe-1529158002	Apartamento Morada Movao Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-morada-movao-petrolina-pe-1529158002	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-no-vale-do-grande-rio-1538166504	Casa No Vale Do Grande Rio	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-no-vale-do-grande-rio-1538166504	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	t	2026-09-28 22:31:23.447	2026-09-28 22:31:23.447	desktop-1790634682
olx-apartamento-no-residencial-pomares-em-petroli-1534441503	Apartamento No Residencial Pomares Em Petroli	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-no-residencial-pomares-em-petroli-1534441503	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-11 13:58:20.993	2026-09-17 13:44:21.557	desktop-1789652661
olx-apartamento-no-centro-de-petrolina-a-as-1522004286	Apartamento No Centro De Petrolina A As	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-no-centro-de-petrolina-a-as-1522004286	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-11 13:58:20.993	2026-09-17 13:46:43.343	desktop-1789652803
olx-apartamento-petrolina-centro-duplex-1521011260	Apartamento Petrolina Centro Duplex	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-petrolina-centro-duplex-1521011260	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-11 13:58:20.993	2026-09-17 13:46:43.343	desktop-1789652803
olx-apartamento-nascente-na-vila-moco-petrolina-pe-123-metros-excelente-localizacao-1519766874	Apartamento Nascente Na Vila Moco Petrolina Pe 123 Metros Excelente Localizacao	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-nascente-na-vila-moco-petrolina-pe-123-metros-excelente-localizacao-1519766874	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-11 13:58:20.993	2026-09-17 13:46:43.343	desktop-1789652803
olx-apartamento-nova-petrolina-vende-se-1524954896	Apartamento Nova Petrolina Vende Se	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-nova-petrolina-vende-se-1524954896	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:36:01.754	desktop-1790634960
olx-apartamento-orla-de-petrolina-vista-rio-942162989	Apartamento Orla De Petrolina Vista Rio	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-orla-de-petrolina-vista-rio-942162989	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:36:01.754	desktop-1790634960
olx-apartamento-3-4-com-suite-na-vila-moco-petrolina-pe-1523715205	Apartamento 3 4 Com Suite Na Vila Moco Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-3-4-com-suite-na-vila-moco-petrolina-pe-1523715205	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-11 13:58:20.993	2026-09-14 18:08:32.371	desktop-1789409311
olx-apto-201-rio-jardim-109m-3q-1-suite-armarios-vaga-201-petrolina-pe-1529508776	Apto 201 Rio Jardim 109m 3q 1 Suite Armarios Vaga 201 Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apto-201-rio-jardim-109m-3q-1-suite-armarios-vaga-201-petrolina-pe-1529508776	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:36:01.754	desktop-1790634960
olx-apartamento-reformado-a-venda-no-condominio-paulo-coelho-em-petrolina-proximo-a-univasf-1528238680	Apartamento Reformado A Venda No Condominio Paulo Coelho Em Petrolina Proximo A Univasf	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-reformado-a-venda-no-condominio-paulo-coelho-em-petrolina-proximo-a-univasf-1528238680	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:36:01.754	desktop-1790634960
olx-aluga-se-casa-na-papa-joao-xxlll-1533623013	Aluga Se Casa Na Papa Joao Xxlll	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/aluga-se-casa-na-papa-joao-xxlll-1533623013	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	aluguel	active	f	2026-09-17 13:53:10.804	2026-09-17 13:55:18.36	desktop-1789653318
olx-apartamento-terreo-jatoba-3-4-1530099288	Apartamento Terreo Jatoba 3 4	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-terreo-jatoba-3-4-1530099288	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-vale-dos-coqueiros-apartamento-1528765960	Vale Dos Coqueiros Apartamento	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vale-dos-coqueiros-apartamento-1528765960	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-repasso-apartamento-condominio-vale-do-sol-1528311013	Repasso Apartamento Condominio Vale Do Sol	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/repasso-apartamento-condominio-vale-do-sol-1528311013	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-apartamento-residencial-brasil-1527304572	Apartamento Residencial Brasil	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-residencial-brasil-1527304572	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-apartamento-todo-mobiliado-e-planejado-1508931792	Apartamento Todo Mobiliado E Planejado	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-todo-mobiliado-e-planejado-1508931792	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-repasso-apartamento-ja-financiado-1525122577	Repasso Apartamento Ja Financiado	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/repasso-apartamento-ja-financiado-1525122577	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-repasse-unique-residence-1525116820	Repasse Unique Residence	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/repasse-unique-residence-1525116820	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-apartamento-edificio-jose-mororo-1523876353	Apartamento Edificio Jose Mororo	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-edificio-jose-mororo-1523876353	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-excelente-oportunidade-apartamento-proximo-a-igreja-matriz-e-orla-1521960115	Excelente Oportunidade Apartamento Proximo A Igreja Matriz E Orla	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/excelente-oportunidade-apartamento-proximo-a-igreja-matriz-e-orla-1521960115	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-11 13:58:20.993	2026-09-17 13:44:21.557	desktop-1789652661
olx-vendo-apartamento-3-4-jatoba-1489766906	Vendo Apartamento 3 4 Jatoba	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-apartamento-3-4-jatoba-1489766906	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-apartamento-a-venda-1523363052	Apartamento A Venda	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-a-venda-1523363052	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-residencial-vila-verde-1523281319	Residencial Vila Verde	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/residencial-vila-verde-1523281319	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-apartamento-terreo-residencial-vivendas-2-1522474356	Apartamento Terreo Residencial Vivendas 2	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-terreo-residencial-vivendas-2-1522474356	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-apartamento-cond-vinhedos-1522147449	Apartamento Cond Vinhedos	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-cond-vinhedos-1522147449	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-apartamento-a-venda-no-vila-rea-1524263608	Apartamento A Venda No Vila Rea	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-a-venda-no-vila-rea-1524263608	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-11 13:58:20.993	2026-09-17 13:44:21.557	desktop-1789652661
olx-quarto-para-alugar-1536322823	Quarto Para Alugar	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/quarto-para-alugar-1536322823	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Terreno	aluguel	removed	f	2026-09-17 12:54:05.086	2026-09-17 13:47:14.535	desktop-1789652834
olx-casa-nova-mcmv-1538706141	Casa Nova Mcmv	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-nova-mcmv-1538706141	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	t	2026-09-28 22:31:23.447	2026-09-28 22:31:23.447	desktop-1790634682
olx-apartamento-flat-vitae-1528919461	Apartamento Flat Vitae	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-flat-vitae-1528919461	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-repasse-visus-1517688771	Repasse Visus	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/repasse-visus-1517688771	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	t	2026-09-11 13:58:20.993	2026-09-11 13:58:20.993	desktop-1789135101
olx-apto-vila-mariana-1497889741	Apto Vila Mariana	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apto-vila-mariana-1497889741	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-quitinete-quarto-sala-cozinha-banheiro-e-lavanderia-1535524585	Quitinete Quarto Sala Cozinha Banheiro E Lavanderia	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/quitinete-quarto-sala-cozinha-banheiro-e-lavanderia-1535524585	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Terreno	aluguel	removed	f	2026-09-17 12:54:05.086	2026-09-17 13:47:14.535	desktop-1789652834
olx-flat-no-edificio-vitae-1519882485	Flat No Edificio Vitae	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/flat-no-edificio-vitae-1519882485	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-11 13:58:20.993	2026-09-17 13:44:21.557	desktop-1789652661
olx-apartamento-venda-excelente-oportunidade-para-morar-ou-investir--valor-r-260-1519489713	Apartamento Venda Excelente Oportunidade Para Morar Ou Investir  Valor R 260	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-venda-excelente-oportunidade-para-morar-ou-investir--valor-r-260-1519489713	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-11 13:58:20.993	2026-09-17 13:44:21.557	desktop-1789652661
olx-vendo-apart-mobiliado-no-condominio-morada-real-jatoba-3-quartos-sendo-1-suit-1519246508	Vendo Apart Mobiliado No Condominio Morada Real Jatoba 3 Quartos Sendo 1 Suit	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-apart-mobiliado-no-condominio-morada-real-jatoba-3-quartos-sendo-1-suit-1519246508	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-11 13:58:20.993	2026-09-17 13:44:21.557	desktop-1789652661
olx-vende-se-apartamento-no-residencial-vivendas-2-1517729152	Vende Se Apartamento No Residencial Vivendas 2	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vende-se-apartamento-no-residencial-vivendas-2-1517729152	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	t	2026-09-11 13:58:20.993	2026-09-11 13:58:20.993	desktop-1789135101
olx-aluga-kitnet-proximo-da-univasf-1535540734	Aluga Kitnet Proximo Da Univasf	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluga-kitnet-proximo-da-univasf-1535540734	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-17 12:53:05.641	2026-09-28 22:33:24.468	desktop-1790634802
olx-vende-se-casa-fino-acabando-e-com-desconto-surpreendente-1515668906	Vende Se Casa Fino Acabando E Com Desconto Surpreendente	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vende-se-casa-fino-acabando-e-com-desconto-surpreendente-1515668906	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-11 13:58:20.993	2026-09-14 18:06:37.726	desktop-1789409196
olx-repasso-ap-no-unique-1518580033	Repasso Ap No Unique	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/repasso-ap-no-unique-1518580033	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-11 13:58:20.993	2026-09-14 18:06:37.726	desktop-1789409196
olx-vendo-apartamento-no-vivendas-2-1518547951	Vendo Apartamento No Vivendas 2	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-apartamento-no-vivendas-2-1518547951	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-11 13:58:20.993	2026-09-14 18:06:37.726	desktop-1789409196
olx-aluga-se-kitnet-no-bairro-sao-joao-1528165326	Aluga Se Kitnet No Bairro Sao Joao	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/aluga-se-kitnet-no-bairro-sao-joao-1528165326	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	aluguel	active	f	2026-09-17 13:53:10.804	2026-09-17 13:55:18.36	desktop-1789653318
olx-casa-para-vender-1538667788	Casa Para Vender	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-para-vender-1538667788	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	t	2026-09-28 22:31:23.447	2026-09-28 22:31:23.447	desktop-1790634682
olx-vende-se-1538258976	Vende Se	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vende-se-1538258976	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	t	2026-09-28 22:31:23.447	2026-09-28 22:31:23.447	desktop-1790634682
olx-casa-com-02-quartos-disponivel-para-locacao-anual-acu-da-torre-mata-de-sao-joao-bahia-1530770978	Casa Com 02 Quartos Disponivel Para Locacao Anual Acu Da Torre Mata De Sao Joao Bahia	https://ba.olx.com.br/grande-salvador/imoveis/casa-com-02-quartos-disponivel-para-locacao-anual-acu-da-torre-mata-de-sao-joao-bahia-1530770978	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	aluguel	active	f	2026-09-17 13:53:10.804	2026-09-17 13:55:18.36	desktop-1789653318
olx-box-comercial-av-joao-durval-1525979149	Box Comercial Av Joao Durval	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/box-comercial-av-joao-durval-1525979149	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	aluguel	active	f	2026-09-17 13:53:10.804	2026-09-17 13:55:18.36	desktop-1789653318
olx-oportunidade-imperdivel-casa-linda-e-grande-no-dom-avelar-terreno-10-x-20-200-m-1538198771	Oportunidade Imperdivel Casa Linda E Grande No Dom Avelar Terreno 10 X 20 200 M	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/oportunidade-imperdivel-casa-linda-e-grande-no-dom-avelar-terreno-10-x-20-200-m-1538198771	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	t	2026-09-28 22:31:23.447	2026-09-28 22:31:23.447	desktop-1790634682
olx-oportunidade-unica-1538023159	Oportunidade Unica	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/oportunidade-unica-1538023159	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	t	2026-09-28 22:31:23.447	2026-09-28 22:31:23.447	desktop-1790634682
olx-casa-5x20-loteamento-recife-1537611658	Casa 5x20 Loteamento Recife	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-5x20-loteamento-recife-1537611658	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	t	2026-09-28 22:31:23.447	2026-09-28 22:31:23.447	desktop-1790634682
olx-casa-a-venda-no-condominio-buona-vita-1533093142	Casa A Venda No Condominio Buona Vita	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-a-venda-no-condominio-buona-vita-1533093142	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-17 13:43:32.693	desktop-1789652612
olx-apartamento-todo-mobiliado-na-orla-de-petrolina-1529563313	Apartamento Todo Mobiliado Na Orla De Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-todo-mobiliado-na-orla-de-petrolina-1529563313	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-casa-a-venda-em-juazeiro-ba-1515327398	Casa A Venda Em Juazeiro Ba	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-em-juazeiro-ba-1515327398	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-09-01 21:00:45.776	desktop-1788296445
olx-apartamento-na-orla-de-petrolina-1528928386	Apartamento Na Orla De Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-na-orla-de-petrolina-1528928386	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-casa-nova-em-petrolina-pronta-para-morar-1522236813	Casa Nova Em Petrolina Pronta Para Morar	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-nova-em-petrolina-pronta-para-morar-1522236813	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-aluguel-jatoba-petrolina-1520846098	Aluguel Jatoba Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluguel-jatoba-petrolina-1520846098	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:47:14.535	desktop-1789652834
olx-casa-com-13-sala-disponivel-vila-moco-petrolina-1539034219	Casa Com 13 Sala Disponivel Vila Moco Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-com-13-sala-disponivel-vila-moco-petrolina-1539034219	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-28 22:32:09.922	2026-09-28 22:36:47.801	desktop-1790635006
olx-alugo-apartamento-no-centro-de-petrolina-1527732601	Alugo Apartamento No Centro De Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-apartamento-no-centro-de-petrolina-1527732601	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-alugo-apartamento-no-condominio-vale-dos-coqueiros-petrolina-pe-1513779571	Alugo Apartamento No Condominio Vale Dos Coqueiros Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-apartamento-no-condominio-vale-dos-coqueiros-petrolina-pe-1513779571	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-vende-se-ou-aluga-se-em-juazeiro-1521828308	Vende Se Ou Aluga Se Em Juazeiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/vende-se-ou-aluga-se-em-juazeiro-1521828308	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-09-23 18:57:01.443	desktop-1790189822
olx-casa-em-juazeiro-e-petrolina-1521523489	Casa Em Juazeiro E Petrolina	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-em-juazeiro-e-petrolina-1521523489	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-09-23 18:57:01.443	desktop-1790189822
olx-apartamento-novo-luxo-na-orla-petrolina-4-quartos-3-suites-mobiliado-2-vagas-1521069361	Apartamento Novo Luxo Na Orla Petrolina 4 Quartos 3 Suites Mobiliado 2 Vagas	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-novo-luxo-na-orla-petrolina-4-quartos-3-suites-mobiliado-2-vagas-1521069361	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-na-orla-petrolina-edf-monte-sinai-1517356315	Apartamento Na Orla Petrolina Edf Monte Sinai	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-na-orla-petrolina-edf-monte-sinai-1517356315	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-14 18:10:08.944	desktop-1789409407
olx-casa-venda-em-juazeiro-1523285364	Casa Venda Em Juazeiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-venda-em-juazeiro-1523285364	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-08-19 14:33:14.84	2026-09-28 22:26:09.769	desktop-1790634368
olx-vendo-casa-em-juazeiro-1495894083	Vendo Casa Em Juazeiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/vendo-casa-em-juazeiro-1495894083	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-08-24 00:52:09.377	desktop-1787532729
olx-aluga-se-apartamento-condominio-vale-do-sol-petrolina-pe-1525815079	Aluga Se Apartamento Condominio Vale Do Sol Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluga-se-apartamento-condominio-vale-do-sol-petrolina-pe-1525815079	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-11 14:03:02.944	desktop-1789135383
olx-apt-mobiliado-vila-moco-petrolina-1528370779	Apt Mobiliado Vila Moco Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apt-mobiliado-vila-moco-petrolina-1528370779	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-sao-jose-petrolina-1497227857	Apartamento Sao Jose Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-sao-jose-petrolina-1497227857	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-alugo-esse-apartamento-no-condominio-morada-nova-em-petrolina-1534219165	Alugo Esse Apartamento No Condominio Morada Nova Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-esse-apartamento-no-condominio-morada-nova-em-petrolina-1534219165	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-casa-a-venda-1527192138	Casa A Venda	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-1527192138	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-09-17 13:35:35.308	desktop-1789652135
olx-casa-com-documento-120-000-1521037848	Casa Com Documento 120 000	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-com-documento-120-000-1521037848	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-09-23 18:57:01.443	desktop-1790189822
olx-sua-casa-atraves-do-parcelamento-1521824688	Sua Casa Atraves Do Parcelamento	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/sua-casa-atraves-do-parcelamento-1521824688	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-09-23 18:57:01.443	desktop-1790189822
olx-casas-com-entrada-parcelas-mensais-1526986639	Casas Com Entrada Parcelas Mensais	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casas-com-entrada-parcelas-mensais-1526986639	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-08-19 14:33:14.84	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-dom-jose-rodrigues-juazeiro-ja-no-menor-preco-1517005303	Casa Dom Jose Rodrigues Juazeiro Ja No Menor Preco	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-dom-jose-rodrigues-juazeiro-ja-no-menor-preco-1517005303	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-09-01 21:00:45.776	desktop-1788296445
olx-compre-sua-casa-atraves-do-credito-imobiliario-1523685470	Compre Sua Casa Atraves Do Credito Imobiliario	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/compre-sua-casa-atraves-do-credito-imobiliario-1523685470	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-08-19 14:33:14.84	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-no-bairro-quide-1522769939	Casa No Bairro Quide	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-no-bairro-quide-1522769939	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-08-19 14:33:14.84	2026-09-28 22:26:09.769	desktop-1790634368
olx-vanda-casa-urgente-1520161957	Vanda Casa Urgente	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/vanda-casa-urgente-1520161957	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-09-17 13:35:35.308	desktop-1789652135
olx-vendo-casa-1522229078	Vendo Casa	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/vendo-casa-1522229078	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-08-19 14:33:14.84	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-pra-vende-1522053082	Casa Pra Vende	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-pra-vende-1522053082	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-08-19 14:33:14.84	2026-09-28 22:26:09.769	desktop-1790634368
olx-vendo-casa-com-1-andar-1525798179	Vendo Casa Com 1 Andar	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/vendo-casa-com-1-andar-1525798179	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-08-24 00:52:09.377	desktop-1787532729
olx-casa-com-4-quartos-sendo-3-suites-piscina-area-gourmet-sol-nascente-et-3-petrolina-pe-1537102196	Casa Com 4 Quartos Sendo 3 Suites Piscina Area Gourmet Sol Nascente Et 3 Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-com-4-quartos-sendo-3-suites-piscina-area-gourmet-sol-nascente-et-3-petrolina-pe-1537102196	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-28 22:32:09.922	2026-09-28 22:36:47.801	desktop-1790635006
olx-repasse-duplex-em-juazeiro-ba-1526685959	Repasse Duplex Em Juazeiro Ba	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/repasse-duplex-em-juazeiro-ba-1526685959	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-08-19 14:33:14.84	2026-09-28 22:26:09.769	desktop-1790634368
olx-sua-casa-atraves-do-parcelamento-1521486566	Sua Casa Atraves Do Parcelamento	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/sua-casa-atraves-do-parcelamento-1521486566	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-09-23 18:57:01.443	desktop-1790189822
olx-casa-a-venda-no-monte-castelo-1493346760	Casa A Venda No Monte Castelo	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-no-monte-castelo-1493346760	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-08-19 14:33:14.84	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-a-venda-3-quartos-1-suite-2-vagas-area-gourmet-moveis-planejados-prox-ao-centro-1525002061	Casa A Venda 3 Quartos 1 Suite 2 Vagas Area Gourmet Moveis Planejados Prox Ao Centro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-3-quartos-1-suite-2-vagas-area-gourmet-moveis-planejados-prox-ao-centro-1525002061	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-08-19 14:33:14.84	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-a-venda-em-condominio-fechado-br-1524254565	Casa A Venda Em Condominio Fechado Br	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-em-condominio-fechado-br-1524254565	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-08-19 14:33:14.84	2026-09-28 22:26:09.769	desktop-1790634368
olx-vendo-casa-no-expedito-alm-nascimento-juazeiro-r-230-000-00-casa-com-2quartos-1-banheiro-1513958299	Vendo Casa No Expedito Alm Nascimento Juazeiro R 230 000 00 Casa Com 2quartos 1 Banheiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/vendo-casa-no-expedito-alm-nascimento-juazeiro-r-230-000-00-casa-com-2quartos-1-banheiro-1513958299	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-08-24 00:52:09.377	desktop-1787532729
olx-apartamento-1-4-itapua-amplo-1513413310	Apartamento 1 4 Itapua Amplo	https://ba.olx.com.br/grande-salvador/imoveis/apartamento-1-4-itapua-amplo-1513413310	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	venda	removed	f	2026-08-19 14:34:01.65	2026-08-24 00:52:09.377	desktop-1787532729
olx-casa-em-itapua-1517356746	Casa Em Itapua	https://ba.olx.com.br/grande-salvador/imoveis/casa-em-itapua-1517356746	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-09-09 19:57:33.754	desktop-1788983852
olx-casa-no-rodeadouro-1514099473	Casa No Rodeadouro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-no-rodeadouro-1514099473	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-08-24 00:52:09.377	desktop-1787532729
olx-vende-se-kitnets-1514342516	Vende Se Kitnets	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/vende-se-kitnets-1514342516	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-08-24 00:52:09.377	desktop-1787532729
olx-vendo-apartamento-1518693567	Vendo Apartamento	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/vendo-apartamento-1518693567	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	venda	removed	f	2026-08-19 14:34:01.65	2026-09-14 17:56:32.917	desktop-1789408591
olx-otima-casa-em-itapua-frente-de-rua-1519070625	Otima Casa Em Itapua Frente De Rua	https://ba.olx.com.br/grande-salvador/imoveis/otima-casa-em-itapua-frente-de-rua-1519070625	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	removed	f	2026-08-19 14:33:36.474	2026-09-14 17:57:16.809	desktop-1789408635
olx-casa-pra-alugar-em-juazeiro-ba-1527677452	Casa Pra Alugar Em Juazeiro Ba	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-pra-alugar-em-juazeiro-ba-1527677452	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	active	f	2026-08-19 14:33:36.474	2026-09-28 22:26:37.414	desktop-1790634395
olx-alugo-casa-centro-juazeiro-ba-1520549458	Alugo Casa Centro Juazeiro Ba	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/alugo-casa-centro-juazeiro-ba-1520549458	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	removed	f	2026-08-19 14:33:36.474	2026-09-17 13:35:16.361	desktop-1789652116
olx-aluga-se-kitnet-1525227909	Aluga Se Kitnet	https://ba.olx.com.br/grande-salvador/imoveis/aluga-se-kitnet-1525227909	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	removed	f	2026-08-19 14:33:36.474	2026-09-17 13:35:16.361	desktop-1789652116
olx-casa-a-venda-sao-joao-do-cabrito-plataforma-1516705519	Casa A Venda Sao Joao Do Cabrito Plataforma	https://ba.olx.com.br/grande-salvador/imoveis/casa-a-venda-sao-joao-do-cabrito-plataforma-1516705519	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-09-01 21:00:45.776	desktop-1788296445
olx-casa-pra-alugar-1521422894	Casa Pra Alugar	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-pra-alugar-1521422894	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	active	f	2026-08-19 14:33:36.474	2026-09-28 22:26:37.414	desktop-1790634395
olx-oportunidade-casa-com-ponto-comercia-1516629609	Oportunidade Casa Com Ponto Comercia	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/oportunidade-casa-com-ponto-comercia-1516629609	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-09-01 21:00:45.776	desktop-1788296445
olx-alugo-casa-no-bairro-maringa-1517848289	Alugo Casa No Bairro Maringa	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/alugo-casa-no-bairro-maringa-1517848289	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	tentou_converter	f	2026-08-19 14:33:36.474	2026-08-26 13:07:43.361	desktop-1787532764
olx-casa-para-alugar-em-juazeiro-no-country-club-1519610636	Casa Para Alugar Em Juazeiro No Country Club	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-para-alugar-em-juazeiro-no-country-club-1519610636	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	removed	f	2026-08-19 14:33:36.474	2026-08-24 00:52:44.324	desktop-1787532764
olx-apartamento-124m--condominio-arc-the-triumph-1523028764	Apartamento 124m  Condominio Arc The Triumph	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/apartamento-124m--condominio-arc-the-triumph-1523028764	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	venda	active	f	2026-08-19 14:34:01.65	2026-09-28 22:26:09.769	desktop-1790634368
olx-vendo-casa-no-bairro-caixa-d-agua-1518809051	Vendo Casa No Bairro Caixa D Agua	https://ba.olx.com.br/grande-salvador/imoveis/vendo-casa-no-bairro-caixa-d-agua-1518809051	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-09-14 17:56:32.917	desktop-1789408591
olx-alugo-casa-mobiliada-centro-juazeiro-1512280739	Alugo Casa Mobiliada Centro Juazeiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/alugo-casa-mobiliada-centro-juazeiro-1512280739	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	removed	f	2026-08-19 14:33:36.474	2026-08-20 12:41:08.031	desktop-1787229668
olx-aluguel-apartamento-condominio-vale-do-sol-petrolina-pe-1534367406	Aluguel Apartamento Condominio Vale Do Sol Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluguel-apartamento-condominio-vale-do-sol-petrolina-pe-1534367406	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:36:47.801	desktop-1790635006
olx-aluga-se-casa-em-condominio-fechado-br-1524256936	Aluga Se Casa Em Condominio Fechado Br	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/aluga-se-casa-em-condominio-fechado-br-1524256936	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	active	f	2026-08-19 14:33:36.474	2026-09-28 22:26:37.414	desktop-1790634395
olx-casa-para-alugar-no-condominio-villas-do-bembom-juazeiro-bahia-1521085248	Casa Para Alugar No Condominio Villas Do Bembom Juazeiro Bahia	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-para-alugar-no-condominio-villas-do-bembom-juazeiro-bahia-1521085248	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	removed	f	2026-08-19 14:33:36.474	2026-09-23 18:57:24.545	desktop-1790189845
olx-casa-alugar-proximo-a-univasf-de-juazeiro-1526919862	Casa Alugar Proximo A Univasf De Juazeiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-alugar-proximo-a-univasf-de-juazeiro-1526919862	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	active	f	2026-08-19 14:33:36.474	2026-09-28 22:26:37.414	desktop-1790634395
olx-alugo-excelente-apartamento-no-san-rafael-1534147635	Alugo Excelente Apartamento No San Rafael	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-excelente-apartamento-no-san-rafael-1534147635	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:44:51.255	desktop-1789652691
olx-alugo-apartamento-condominio-mais-viver-juazeiro-bahia-1526640583	Alugo Apartamento Condominio Mais Viver Juazeiro Bahia	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/alugo-apartamento-condominio-mais-viver-juazeiro-bahia-1526640583	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	removed	f	2026-08-19 14:34:28.233	2026-09-23 18:57:24.545	desktop-1790189845
olx-procuro-pessoa-para-dividir-apartamento-em-juazeiro-bahia-1526280438	Procuro Pessoa Para Dividir Apartamento Em Juazeiro Bahia	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/procuro-pessoa-para-dividir-apartamento-em-juazeiro-bahia-1526280438	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	removed	f	2026-08-19 14:34:28.233	2026-09-01 21:01:12.288	desktop-1788296472
olx-alugo-apto-na-orla-de-juazeiro-ba-1513252282	Alugo Apto Na Orla De Juazeiro Ba	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/alugo-apto-na-orla-de-juazeiro-ba-1513252282	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	removed	f	2026-08-19 14:34:28.233	2026-08-24 00:52:44.324	desktop-1787532764
olx-1-e-2-quartos-em-itapua-1523868323	1 E 2 Quartos Em Itapua	https://ba.olx.com.br/grande-salvador/imoveis/1-e-2-quartos-em-itapua-1523868323	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	removed	f	2026-08-19 14:34:28.233	2026-08-24 00:52:44.324	desktop-1787532764
olx-casa-a-venda-juazeiro-ba-monte-castelo-1512285243	Casa A Venda Juazeiro Ba Monte Castelo	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-juazeiro-ba-monte-castelo-1512285243	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-08-20 12:40:42.578	desktop-1787229642
olx-estou-procurando-uma-pessoa-mulher-responsavel-e-organizada-para-dividir-apartamento-1524511963	Estou Procurando Uma Pessoa Mulher Responsavel E Organizada Para Dividir Apartamento	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/estou-procurando-uma-pessoa-mulher-responsavel-e-organizada-para-dividir-apartamento-1524511963	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Terreno	aluguel	removed	f	2026-08-19 14:35:15.356	2026-08-19 14:36:05.259	desktop-1787150165
olx-aluguel-disponivel-bairro-novo-encontro-1525768467	Aluguel Disponivel Bairro Novo Encontro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/aluguel-disponivel-bairro-novo-encontro-1525768467	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	active	f	2026-08-19 14:34:28.233	2026-09-28 22:26:37.414	desktop-1790634395
olx-apartamento-quitado-1526609664	Apartamento Quitado	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/apartamento-quitado-1526609664	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	venda	removed	f	2026-08-19 14:34:01.65	2026-09-11 13:51:27.172	desktop-1789134687
olx-ap-2-quartos-semi-mobiliado-juazeiro-1517412067	Ap 2 Quartos Semi Mobiliado Juazeiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/ap-2-quartos-semi-mobiliado-juazeiro-1517412067	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	removed	f	2026-08-19 14:34:28.233	2026-09-09 19:58:17.174	desktop-1788983896
olx-alugo-apt-mobiliado-em-juazeiro-bahia-1513654249	Alugo Apt Mobiliado Em Juazeiro Bahia	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/alugo-apt-mobiliado-em-juazeiro-bahia-1513654249	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	removed	f	2026-08-19 14:34:28.233	2026-08-24 00:52:44.324	desktop-1787532764
olx-lindo-apartamento-1526286810	Lindo Apartamento	https://ba.olx.com.br/grande-salvador/imoveis/lindo-apartamento-1526286810	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	removed	f	2026-08-19 14:34:28.233	2026-08-24 00:52:44.324	desktop-1787532764
olx-apartamento-02-quartos-mobiliado-proximo-a-uneb-juazeiro-ba-1514500605	Apartamento 02 Quartos Mobiliado Proximo A Uneb Juazeiro Ba	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/apartamento-02-quartos-mobiliado-proximo-a-uneb-juazeiro-ba-1514500605	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	removed	f	2026-08-19 14:34:28.233	2026-08-24 00:52:44.324	desktop-1787532764
olx-apartamento-para-aluguel-no-maringa-1523440296	Apartamento Para Aluguel No Maringa	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/apartamento-para-aluguel-no-maringa-1523440296	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	removed	f	2026-08-19 14:34:28.233	2026-09-01 21:01:12.288	desktop-1788296472
olx-casa-3-quartos-com-suite-portal-da-cidade-petrolina-1524784123	Casa 3 Quartos Com Suite Portal Da Cidade Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-3-quartos-com-suite-portal-da-cidade-petrolina-1524784123	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:36:47.801	desktop-1790635006
olx-kitnet-faculdade-estacio-de-sa-saida-de-juazeiro-1525423733	Kitnet Faculdade Estacio De Sa Saida De Juazeiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/kitnet-faculdade-estacio-de-sa-saida-de-juazeiro-1525423733	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	active	f	2026-08-19 14:34:28.233	2026-09-28 22:26:37.414	desktop-1790634395
olx-procuro-alguem-para-dividir-apartamento-comigo-em-juazeiro-bahia-1523806757	Procuro Alguem Para Dividir Apartamento Comigo Em Juazeiro Bahia	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/procuro-alguem-para-dividir-apartamento-comigo-em-juazeiro-bahia-1523806757	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	active	f	2026-08-19 14:34:28.233	2026-09-28 22:26:37.414	desktop-1790634395
olx-vendo-apto-tipo-casa-com-area-externa-murado-na-dom-joao-vi-brotas-1529455066	Vendo Apto Tipo Casa Com Area Externa Murado Na Dom Joao Vi Brotas	https://ba.olx.com.br/grande-salvador/imoveis/vendo-apto-tipo-casa-com-area-externa-murado-na-dom-joao-vi-brotas-1529455066	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Apartamento	venda	active	f	2026-09-17 13:53:32.464	2026-09-17 13:54:58.176	desktop-1789653298
olx-duplex-2-suites-em-petrolina-perto-do-shopping-univasf-uninassau-facape-upe-1515272818	Duplex 2 Suites Em Petrolina Perto Do Shopping Univasf Uninassau Facape Upe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/duplex-2-suites-em-petrolina-perto-do-shopping-univasf-uninassau-facape-upe-1515272818	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-28 22:32:09.922	2026-09-28 22:36:47.801	desktop-1790635006
olx-alugo-apartamentos-com-3-quartos-sendo-uma-suite-no-caminho-do-sol-terreo-e-1-andar-1528676923	Alugo Apartamentos Com 3 Quartos Sendo Uma Suite No Caminho Do Sol Terreo E 1 Andar	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-apartamentos-com-3-quartos-sendo-uma-suite-no-caminho-do-sol-terreo-e-1-andar-1528676923	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:44:51.255	desktop-1789652691
olx-quarto-privativo-rio-vermelho-1517691609	Quarto Privativo Rio Vermelho	https://ba.olx.com.br/grande-salvador/imoveis/quarto-privativo-rio-vermelho-1517691609	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Terreno	aluguel	removed	f	2026-08-19 14:35:15.356	2026-09-11 13:51:52.104	desktop-1789134712
olx-alugo-apartamento-mobiliado-1533293560	Alugo Apartamento Mobiliado	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-apartamento-mobiliado-1533293560	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:44:51.255	desktop-1789652691
olx-apartamento-avenida-mario-rodrigues-coelho-1533228892	Apartamento Avenida Mario Rodrigues Coelho	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-avenida-mario-rodrigues-coelho-1533228892	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:44:51.255	desktop-1789652691
olx-alugo-sala-para-esteticista-nutricionista-e-fisioterapeuta-1523694104	Alugo Sala Para Esteticista Nutricionista E Fisioterapeuta	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/alugo-sala-para-esteticista-nutricionista-e-fisioterapeuta-1523694104	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Terreno	aluguel	active	f	2026-08-19 14:35:15.356	2026-09-28 22:26:37.414	desktop-1790634395
olx-kitnet-prox-nassau-facape-hosp-unimed-e-av-integracao-1515269670	Kitnet Prox Nassau Facape Hosp Unimed E Av Integracao	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/kitnet-prox-nassau-facape-hosp-unimed-e-av-integracao-1515269670	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:44:51.255	desktop-1789652691
olx-apartamento-vila-eduardo-1532643069	Apartamento Vila Eduardo	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-vila-eduardo-1532643069	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:44:51.255	desktop-1789652691
olx-aluguel-cohab-massangano-1515689802	Aluguel Cohab Massangano	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluguel-cohab-massangano-1515689802	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:44:51.255	desktop-1789652691
olx-apartamento-para-aluguel-moradia-1533215222	Apartamento Para Aluguel Moradia	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-para-aluguel-moradia-1533215222	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:44:51.255	desktop-1789652691
olx-espaco-para-evento-1525397043	Espaco Para Evento	https://ba.olx.com.br/grande-salvador/imoveis/espaco-para-evento-1525397043	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Terreno	aluguel	removed	f	2026-08-19 14:35:15.356	2026-09-17 13:35:16.361	desktop-1789652116
olx-aluguel-sala-comercial-1522234347	Aluguel Sala Comercial	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/aluguel-sala-comercial-1522234347	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Terreno	aluguel	removed	f	2026-08-19 14:35:15.356	2026-08-24 00:52:44.324	desktop-1787532764
olx-apartamento-cond-paulo-coelho-1532303592	Apartamento Cond Paulo Coelho	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-cond-paulo-coelho-1532303592	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:44:51.255	desktop-1789652691
olx-flat-100-mobiliado-porteira-fechada-agua-condominio-e-iptu-inclusos-dom-malan-1530996887	Flat 100 Mobiliado Porteira Fechada Agua Condominio E Iptu Inclusos Dom Malan	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/flat-100-mobiliado-porteira-fechada-agua-condominio-e-iptu-inclusos-dom-malan-1530996887	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-mobiliado-vila-moco-1533474092	Apartamento Mobiliado Vila Moco	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-mobiliado-vila-moco-1533474092	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:33:24.468	desktop-1790634802
olx-apartamento-2-quartos-mobiliado-e-com-energia-solar-palhinhas-atras-da-banca-1516571618	Apartamento 2 Quartos Mobiliado E Com Energia Solar Palhinhas Atras Da Banca	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-2-quartos-mobiliado-e-com-energia-solar-palhinhas-atras-da-banca-1516571618	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:33:24.468	desktop-1790634802
olx-apartamento-mobiliado-condominio-vinhedos-1532679030	Apartamento Mobiliado Condominio Vinhedos	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-mobiliado-condominio-vinhedos-1532679030	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-14 18:07:28.868	desktop-1789409247
olx-apartamento-2-quartos-1532629798	Apartamento 2 Quartos	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-2-quartos-1532629798	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	t	2026-09-11 13:59:01.973	2026-09-11 13:59:01.973	desktop-1789135142
olx-vaga-em-apartamento-1531374856	Vaga Em Apartamento	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vaga-em-apartamento-1531374856	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 12:53:05.641	desktop-1789649585
olx-apartamento-todo-mobiliado-res-paulo-coelho-1532241166	Apartamento Todo Mobiliado Res Paulo Coelho	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-todo-mobiliado-res-paulo-coelho-1532241166	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:44:51.255	desktop-1789652691
olx-alugo-apartamento-no-bairro-jatoba-1531217454	Alugo Apartamento No Bairro Jatoba	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-apartamento-no-bairro-jatoba-1531217454	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-14 18:07:28.868	desktop-1789409247
olx-kitnet-1532054790	Kitnet	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/kitnet-1532054790	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-14 18:07:28.868	desktop-1789409247
olx-apartamento-excelente-localizacao-1531356924	Apartamento Excelente Localizacao	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-excelente-localizacao-1531356924	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-14 18:07:28.868	desktop-1789409247
olx-apartamento-loteamento-recife-super-conservado-1532195464	Apartamento Loteamento Recife Super Conservado	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-loteamento-recife-super-conservado-1532195464	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:44:51.255	desktop-1789652691
olx-apartamento-aluguel-1531728749	Apartamento Aluguel	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-aluguel-1531728749	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:44:51.255	desktop-1789652691
olx-apartamento-terreo-solaris-1531933566	Apartamento Terreo Solaris	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-terreo-solaris-1531933566	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	t	2026-09-11 13:59:01.973	2026-09-11 13:59:01.973	desktop-1789135142
olx-flat-estilo-kitnet-no-centro-da-cidade-localizacao-fantastica-1531013259	Flat Estilo Kitnet No Centro Da Cidade Localizacao Fantastica	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/flat-estilo-kitnet-no-centro-da-cidade-localizacao-fantastica-1531013259	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	t	2026-09-11 13:59:01.973	2026-09-11 13:59:01.973	desktop-1789135142
olx-apartamento-cond-carlos-wuilson-por-tras-da-orla-1530596727	Apartamento Cond Carlos Wuilson Por Tras Da Orla	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-cond-carlos-wuilson-por-tras-da-orla-1530596727	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	t	2026-09-11 13:59:01.973	2026-09-11 13:59:01.973	desktop-1789135142
olx-aluga-se-casa-santa-luzia-1529526410	Aluga Se Casa Santa Luzia	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluga-se-casa-santa-luzia-1529526410	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	t	2026-09-11 13:59:01.973	2026-09-11 13:59:01.973	desktop-1789135142
olx-apartamento-perto-das-faculdades-1529505696	Apartamento Perto Das Faculdades	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-perto-das-faculdades-1529505696	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	t	2026-09-11 13:59:01.973	2026-09-11 13:59:01.973	desktop-1789135142
olx-vendo-apto-quitado-em-ilha-de-sao-joao-1521555221	Vendo Apto Quitado Em Ilha De Sao Joao	https://ba.olx.com.br/grande-salvador/imoveis/vendo-apto-quitado-em-ilha-de-sao-joao-1521555221	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Apartamento	venda	active	f	2026-09-17 13:53:32.464	2026-09-17 13:54:58.176	desktop-1789653298
olx-apartamento-andar-alto-mobiliado-1531963697	Apartamento Andar Alto Mobiliado	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-andar-alto-mobiliado-1531963697	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:47:14.535	desktop-1789652834
olx-apartamento-no-rio-jordao-1531616261	Apartamento No Rio Jordao	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-no-rio-jordao-1531616261	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:44:51.255	desktop-1789652691
olx-casa-pra-alugar-bairro-boa-vista-jatoba-1539655849	Casa Pra Alugar Bairro Boa Vista Jatoba	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-pra-alugar-bairro-boa-vista-jatoba-1539655849	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-28 22:32:09.922	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-vinhedos-1531278111	Apartamento Vinhedos	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-vinhedos-1531278111	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-14 18:07:28.868	desktop-1789409247
olx-3-4-amplo-condominio-joao-durval-2-vaga-garagem-1525215794	3 4 Amplo Condominio Joao Durval 2 Vaga Garagem	https://ba.olx.com.br/grande-salvador/imoveis/3-4-amplo-condominio-joao-durval-2-vaga-garagem-1525215794	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Apartamento	venda	active	f	2026-09-17 13:53:32.464	2026-09-17 13:54:58.176	desktop-1789653298
olx-aluguel-casa-ao-lado-do-shopping-e-arena-ems-1539711204	Aluguel Casa Ao Lado Do Shopping E Arena Ems	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluguel-casa-ao-lado-do-shopping-e-arena-ems-1539711204	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-28 22:32:09.922	2026-09-28 22:36:47.801	desktop-1790635006
olx-vendo-casa-em-petrolina-no-bairro-jardim-sao-paulo-r-270-000-00-1523470385	Vendo Casa Em Petrolina No Bairro Jardim Sao Paulo R 270 000 00	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-casa-em-petrolina-no-bairro-jardim-sao-paulo-r-270-000-00-1523470385	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-entrada-a-partir-de-17-300-e-parcelas-a-partir-de-530-00-1519757663	Entrada A Partir De 17 300 E Parcelas A Partir De 530 00	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/entrada-a-partir-de-17-300-e-parcelas-a-partir-de-530-00-1519757663	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-19 14:33:14.84	2026-09-17 13:35:35.308	desktop-1789652135
olx-casa-no-padre-cicero-1534475875	Casa No Padre Cicero	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-no-padre-cicero-1534475875	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-14 18:04:22.287	desktop-1789409061
olx-casa-para-venda-no-condominio-encontro-das-aguas-1534192402	Casa Para Venda No Condominio Encontro Das Aguas	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-para-venda-no-condominio-encontro-das-aguas-1534192402	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-11 13:56:40.793	2026-09-14 18:04:22.287	desktop-1789409061
olx-casa-bairro-padre-cicero-petrolina-br-1534051047	Casa Bairro Padre Cicero Petrolina Br	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-bairro-padre-cicero-petrolina-br-1534051047	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-aluga-se-uma-casa-no-sao-joao-do-cabrito-rua-sa-oliveira-1525540963	Aluga Se Uma Casa No Sao Joao Do Cabrito Rua Sa Oliveira	https://ba.olx.com.br/grande-salvador/imoveis/aluga-se-uma-casa-no-sao-joao-do-cabrito-rua-sa-oliveira-1525540963	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	venda	active	f	2026-09-17 13:52:52.907	2026-09-17 13:54:58.176	desktop-1789653298
olx-bairro-doutor-juracy-praca-joao-romao-1536348043	Bairro Doutor Juracy Praca Joao Romao	https://ba.olx.com.br/regiao-de-vitoria-da-conquista-e-barreiras/imoveis/bairro-doutor-juracy-praca-joao-romao-1536348043	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	venda	active	f	2026-09-17 13:52:52.907	2026-09-17 13:54:58.176	desktop-1789653298
olx-oportunidade-para-vender-com-urgencia-apartamento-na-papa-joao-xxiii-x-1536100179	Oportunidade Para Vender Com Urgencia Apartamento Na Papa Joao Xxiii X	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/oportunidade-para-vender-com-urgencia-apartamento-na-papa-joao-xxiii-x-1536100179	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Apartamento	venda	active	f	2026-09-17 13:53:32.464	2026-09-17 13:54:58.176	desktop-1789653298
olx-vendo-imovel-comercial-e-residencial-petrolina-2-apartamentos-1-ponto-comercial-1527153386	Vendo Imovel Comercial E Residencial Petrolina 2 Apartamentos 1 Ponto Comercial	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-imovel-comercial-e-residencial-petrolina-2-apartamentos-1-ponto-comercial-1527153386	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-sunville-murada-com-condominio-incluso-1539543195	Casa Sunville Murada Com Condominio Incluso	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-sunville-murada-com-condominio-incluso-1539543195	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-28 22:32:09.922	2026-09-28 22:36:47.801	desktop-1790635006
olx-procuro-para-dividir-1539193009	Procuro Para Dividir	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/procuro-para-dividir-1539193009	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-28 22:32:09.922	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-2-quartos-na-papa-joao-xxiii-1533368221	Apartamento 2 Quartos Na Papa Joao Xxiii	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/apartamento-2-quartos-na-papa-joao-xxiii-1533368221	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Apartamento	venda	active	f	2026-09-17 13:53:32.464	2026-09-17 13:54:58.176	desktop-1789653298
olx-apartamento-a-venda-2-4-condominio-residencial-sao-joao-mata-escura-principal-1532447654	Apartamento A Venda 2 4 Condominio Residencial Sao Joao Mata Escura Principal	https://ba.olx.com.br/grande-salvador/imoveis/apartamento-a-venda-2-4-condominio-residencial-sao-joao-mata-escura-principal-1532447654	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Apartamento	venda	active	f	2026-09-17 13:53:32.464	2026-09-17 13:54:58.176	desktop-1789653298
olx-casa-seminova-para-alugar-1539208624	Casa Seminova Para Alugar	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-seminova-para-alugar-1539208624	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-28 22:32:09.922	2026-09-28 22:36:47.801	desktop-1790635006
olx-casa-a-venda-no-centro-de-juazeiro-bairro-jardim-vitoria-1522415691	Casa A Venda No Centro De Juazeiro Bairro Jardim Vitoria	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-no-centro-de-juazeiro-bairro-jardim-vitoria-1522415691	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-08-19 14:33:14.84	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-loteamento-recife-1530897203	Casa Loteamento Recife	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-loteamento-recife-1530897203	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:36:47.801	desktop-1790635006
olx-casa-venda-em-petrolina-1525634353	Casa Venda Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-venda-em-petrolina-1525634353	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-11 13:56:40.793	2026-09-28 22:36:01.754	desktop-1790634960
olx-quarto-para-mocas-em-petrolina-no-pensionato-vovo-rita-1525805890	Quarto Para Mocas Em Petrolina No Pensionato Vovo Rita	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/quarto-para-mocas-em-petrolina-no-pensionato-vovo-rita-1525805890	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Terreno	aluguel	active	f	2026-09-11 14:00:48.726	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-3-4-mobiliado-no-centro-de-petrolina-1523671362	Apartamento 3 4 Mobiliado No Centro De Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-3-4-mobiliado-no-centro-de-petrolina-1523671362	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-vagas-abertas-residencia-feminina-premium-petrolina-1528210557	Vagas Abertas Residencia Feminina Premium Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vagas-abertas-residencia-feminina-premium-petrolina-1528210557	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Terreno	aluguel	active	f	2026-09-11 14:00:48.726	2026-09-28 22:36:47.801	desktop-1790635006
olx-casa-para-aluguel-avenida-monsenhor-em-frente-ao-paraiba-construcao-1539024581	Casa Para Aluguel Avenida Monsenhor Em Frente Ao Paraiba Construcao	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-para-aluguel-avenida-monsenhor-em-frente-ao-paraiba-construcao-1539024581	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-28 22:32:09.922	2026-09-28 22:36:47.801	desktop-1790635006
olx-casa-mobiliada-2-quartos-1537031651	Casa Mobiliada 2 Quartos	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-mobiliada-2-quartos-1537031651	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-28 22:32:09.922	2026-09-28 22:36:47.801	desktop-1790635006
olx-procuro-menina-para-dividir-ape-no-sao-jose-1533843474	Procuro Menina Para Dividir Ape No Sao Jose	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/procuro-menina-para-dividir-ape-no-sao-jose-1533843474	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Terreno	aluguel	removed	f	2026-09-11 14:00:48.726	2026-09-11 14:03:02.944	desktop-1789135383
olx-aluga-se-ap-preferencia-por-estudantes-1534258036	Aluga Se Ap Preferencia Por Estudantes	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluga-se-ap-preferencia-por-estudantes-1534258036	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:33:24.468	desktop-1790634802
olx-aluguel-de-quarto-1533626888	Aluguel De Quarto	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluguel-de-quarto-1533626888	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Terreno	aluguel	removed	f	2026-09-11 14:00:48.726	2026-09-11 14:03:02.944	desktop-1789135383
olx-sobrado-3-quartos-em-ilha-de-sao-joao-proximo-ao-vlt-1531759581	Sobrado 3 Quartos Em Ilha De Sao Joao Proximo Ao Vlt	https://ba.olx.com.br/grande-salvador/imoveis/sobrado-3-quartos-em-ilha-de-sao-joao-proximo-ao-vlt-1531759581	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Apartamento	venda	active	f	2026-09-17 13:53:32.464	2026-09-17 13:54:58.176	desktop-1789653298
olx-apartamento-2-4-localizacao-estrategica-locacao-petrolina-pe-1524221544	Apartamento 2 4 Localizacao Estrategica Locacao Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-2-4-localizacao-estrategica-locacao-petrolina-pe-1524221544	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-aluga-ou-vendo-se-sala-comercial-na-galeria-imperial-center-em-petrolina-pe-1519100289	Aluga Ou Vendo Se Sala Comercial Na Galeria Imperial Center Em Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluga-ou-vendo-se-sala-comercial-na-galeria-imperial-center-em-petrolina-pe-1519100289	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Terreno	aluguel	removed	f	2026-09-11 14:00:48.726	2026-09-14 18:10:08.944	desktop-1789409407
olx-vendo-apto-tipo-casa-com-area-externa-murado-na-dom-joao-vi-brotas-proximo-ao-acupe-1529443502	Vendo Apto Tipo Casa Com Area Externa Murado Na Dom Joao Vi Brotas Proximo Ao Acupe	https://ba.olx.com.br/grande-salvador/imoveis/vendo-apto-tipo-casa-com-area-externa-murado-na-dom-joao-vi-brotas-proximo-ao-acupe-1529443502	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Apartamento	venda	active	f	2026-09-17 13:53:32.464	2026-09-17 13:54:58.176	desktop-1789653298
olx-aluga-se-no-centro-de-petrolina-loft-mobiliado-1524556630	Aluga Se No Centro De Petrolina Loft Mobiliado	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluga-se-no-centro-de-petrolina-loft-mobiliado-1524556630	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-2-quartos-novo-ao-lado-da-facape-1533828692	Apartamento 2 Quartos Novo Ao Lado Da Facape	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-2-quartos-novo-ao-lado-da-facape-1533828692	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:33:24.468	desktop-1790634802
olx-apartamento-mobiliado-no-coracao-da-vila-da-praia-do-forte-mata-de-sao-joao-bahia-1523195736	Apartamento Mobiliado No Coracao Da Vila Da Praia Do Forte Mata De Sao Joao Bahia	https://ba.olx.com.br/grande-salvador/imoveis/apartamento-mobiliado-no-coracao-da-vila-da-praia-do-forte-mata-de-sao-joao-bahia-1523195736	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Apartamento	venda	active	f	2026-09-17 13:53:32.464	2026-09-17 13:54:58.176	desktop-1789653298
olx-alugo-casa-bairro-sao-goncalo-prox-distrito-1535052829	Alugo Casa Bairro Sao Goncalo Prox Distrito	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-casa-bairro-sao-goncalo-prox-distrito-1535052829	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-28 22:32:09.922	2026-09-28 22:36:47.801	desktop-1790635006
olx-alugo-quarto-com-banheiro-exclusivo-apartamento-mobiliado-1534149746	Alugo Quarto Com Banheiro Exclusivo Apartamento Mobiliado	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-quarto-com-banheiro-exclusivo-apartamento-mobiliado-1534149746	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Terreno	aluguel	removed	f	2026-09-11 14:00:48.726	2026-09-17 13:47:14.535	desktop-1789652834
olx-casa-no-sao-joao-do-cabrito-aluguel-1533866504	Casa No Sao Joao Do Cabrito Aluguel	https://ba.olx.com.br/grande-salvador/imoveis/casa-no-sao-joao-do-cabrito-aluguel-1533866504	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Terreno	aluguel	active	f	2026-09-17 13:54:37.098	2026-09-17 13:55:18.36	desktop-1789653318
olx-aluguel-de-apartamento-na-papa-joao-xxiii-tomba-1526874384	Aluguel De Apartamento Na Papa Joao Xxiii Tomba	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/aluguel-de-apartamento-na-papa-joao-xxiii-tomba-1526874384	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Terreno	aluguel	active	f	2026-09-17 13:54:37.098	2026-09-17 13:55:18.36	desktop-1789653318
olx-quarto-c-banheiro-r-450-00-agua-e-luz-inclusos-av-joao-durval-1534871539	Quarto C Banheiro R 450 00 Agua E Luz Inclusos Av Joao Durval	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/quarto-c-banheiro-r-450-00-agua-e-luz-inclusos-av-joao-durval-1534871539	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Terreno	aluguel	active	f	2026-09-17 13:54:37.098	2026-09-17 13:55:18.36	desktop-1789653318
olx-alugo-casa-valle-dos-flamboyant-1538745197	Alugo Casa Valle Dos Flamboyant	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-casa-valle-dos-flamboyant-1538745197	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	t	2026-09-28 22:32:09.922	2026-09-28 22:32:09.922	desktop-1790634728
olx-condominio-vog-joao-de-goes-para-temporada-1535377923	Condominio Vog Joao De Goes Para Temporada	https://ba.olx.com.br/sul-da-bahia/imoveis/condominio-vog-joao-de-goes-para-temporada-1535377923	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Terreno	aluguel	active	f	2026-09-17 13:54:37.098	2026-09-17 13:55:18.36	desktop-1789653318
olx-sala-na-avenida-joao-durval-px-shopping-zap-1534688172	Sala Na Avenida Joao Durval Px Shopping Zap	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/sala-na-avenida-joao-durval-px-shopping-zap-1534688172	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Terreno	aluguel	active	f	2026-09-17 13:54:37.098	2026-09-17 13:55:18.36	desktop-1789653318
olx-kitnet-na-avenida-joao-durval-ao-lado-do-shopping-1534682371	Kitnet Na Avenida Joao Durval Ao Lado Do Shopping	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/kitnet-na-avenida-joao-durval-ao-lado-do-shopping-1534682371	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Casa	aluguel	active	f	2026-09-17 13:53:10.804	2026-09-17 13:55:18.36	desktop-1789653318
olx-alugo-reveillon-2-4-mobiliado-em-vog-joao-de-goes-ilheus-1525405197	Alugo Reveillon 2 4 Mobiliado Em Vog Joao De Goes Ilheus	https://ba.olx.com.br/sul-da-bahia/imoveis/alugo-reveillon-2-4-mobiliado-em-vog-joao-de-goes-ilheus-1525405197	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Terreno	aluguel	active	f	2026-09-17 13:54:37.098	2026-09-17 13:55:18.36	desktop-1789653318
olx-alugo-galpao-na-av-eduardo-froes-da-mota-do-lado-do-hotel-cavalo-dourado-1532263593	Alugo Galpao Na Av Eduardo Froes Da Mota Do Lado Do Hotel Cavalo Dourado	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/alugo-galpao-na-av-eduardo-froes-da-mota-do-lado-do-hotel-cavalo-dourado-1532263593	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Terreno	aluguel	active	f	2026-09-17 13:54:37.098	2026-09-17 13:55:18.36	desktop-1789653318
olx-casa-ampla-duplex-3-4-com-suite-dependencia-no-condominio-vale-dourado-lagoa-salgada-1519805523	Casa Ampla Duplex 3 4 Com Suite Dependencia No Condominio Vale Dourado Lagoa Salgada	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/casa-ampla-duplex-3-4-com-suite-dependencia-no-condominio-vale-dourado-lagoa-salgada-1519805523	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em João Dourado-BA.	t	João Dourado	BA	Terreno	aluguel	active	f	2026-09-17 13:54:37.098	2026-09-17 13:55:18.36	desktop-1789653318
olx-aluguel-de-casa-em-condominio-fechado-beira-rio-1538726683	Aluguel De Casa Em Condominio Fechado Beira Rio	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluguel-de-casa-em-condominio-fechado-beira-rio-1538726683	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	t	2026-09-28 22:32:09.922	2026-09-28 22:32:09.922	desktop-1790634728
olx-excelente-localizacao-1538546760	Excelente Localizacao	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/excelente-localizacao-1538546760	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	t	2026-09-28 22:32:09.922	2026-09-28 22:32:09.922	desktop-1790634728
olx-kitnet-vizinha-a-academia-smartfit-1538401447	Kitnet Vizinha A Academia Smartfit	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/kitnet-vizinha-a-academia-smartfit-1538401447	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	t	2026-09-28 22:32:09.922	2026-09-28 22:32:09.922	desktop-1790634728
olx-casa-diaria-temporada-otima-localizacao-garagem-super-wi-fi-953226364	Casa Diaria Temporada Otima Localizacao Garagem Super Wi Fi	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-diaria-temporada-otima-localizacao-garagem-super-wi-fi-953226364	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	t	2026-09-28 22:32:09.922	2026-09-28 22:32:09.922	desktop-1790634728
olx-alugo-casa-no-bairro-jardim-imperial-portal-da-cidade-1538258720	Alugo Casa No Bairro Jardim Imperial Portal Da Cidade	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-casa-no-bairro-jardim-imperial-portal-da-cidade-1538258720	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	t	2026-09-28 22:32:09.922	2026-09-28 22:32:09.922	desktop-1790634728
olx-casa-maravilhosa-terras-do-barao-1534141837	Casa Maravilhosa Terras Do Barao	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-maravilhosa-terras-do-barao-1534141837	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-11 10:31:16.34	2026-09-28 22:26:09.769	desktop-1790634368
olx-aluga-se-casa-com-ponto-comercial-incluso-r-1-600-1537763852	Aluga Se Casa Com Ponto Comercial Incluso R 1 600	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluga-se-casa-com-ponto-comercial-incluso-r-1-600-1537763852	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	t	2026-09-28 22:32:09.922	2026-09-28 22:32:09.922	desktop-1790634728
olx-aluguel-casa-incluso-energia-1537395111	Aluguel Casa Incluso Energia	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluguel-casa-incluso-energia-1537395111	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	t	2026-09-28 22:32:09.922	2026-09-28 22:32:09.922	desktop-1790634728
olx-procuro-lugar-para-alugar-1534541236	Procuro Lugar Para Alugar	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/procuro-lugar-para-alugar-1534541236	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	removed	f	2026-09-14 17:55:00.163	2026-09-17 13:35:16.361	desktop-1789652116
olx-condominio-valle-das-mangueiras-1537046580	Condominio Valle Das Mangueiras	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/condominio-valle-das-mangueiras-1537046580	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	t	2026-09-28 22:32:09.922	2026-09-28 22:32:09.922	desktop-1790634728
olx-alugo-casa-3-4-suite-valle-sao-francisco-taxa-de-condominio-inclusa-1536410453	Alugo Casa 3 4 Suite Valle Sao Francisco Taxa De Condominio Inclusa	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-casa-3-4-suite-valle-sao-francisco-taxa-de-condominio-inclusa-1536410453	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	t	2026-09-28 22:32:09.922	2026-09-28 22:32:09.922	desktop-1790634728
olx-casa-com-excelente-localizacao-e-nova-pronta-pra-morar-1531030991	Casa Com Excelente Localizacao E Nova Pronta Pra Morar	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-com-excelente-localizacao-e-nova-pronta-pra-morar-1531030991	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-11 13:57:45.666	2026-09-28 22:32:09.922	desktop-1790634728
olx-duplex-2-quartos-em-petrolina-perto-do-shopping-univasf-uninassau-facape-upe-1515272818	Duplex 2 Quartos Em Petrolina Perto Do Shopping Univasf Uninassau Facape Upe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/duplex-2-quartos-em-petrolina-perto-do-shopping-univasf-uninassau-facape-upe-1515272818	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:47:14.535	desktop-1789652834
olx-casa-a-venda-no-condominio-residencial-vitoria-em-juazeiro-ba-1536690765	Casa A Venda No Condominio Residencial Vitoria Em Juazeiro Ba	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-no-condominio-residencial-vitoria-em-juazeiro-ba-1536690765	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-23 18:54:44.714	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-a-venda-bairro-argemiro-juazeiro-da-bahia-3-4-sendo-1-suite-6-5-1530398040	Casa A Venda Bairro Argemiro Juazeiro Da Bahia 3 4 Sendo 1 Suite 6 5	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-bairro-argemiro-juazeiro-da-bahia-3-4-sendo-1-suite-6-5-1530398040	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-09 19:53:27.956	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-7x20-monte-castelo-rua-asfaltada-1537920434	Casa 7x20 Monte Castelo Rua Asfaltada	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-7x20-monte-castelo-rua-asfaltada-1537920434	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-23 18:54:44.714	2026-09-28 22:26:09.769	desktop-1790634368
olx-consorcio-de-imoveis-1536908155	Consorcio De Imoveis	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/consorcio-de-imoveis-1536908155	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-23 18:54:44.714	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-2-quartos-1536660437	Casa 2 Quartos	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-2-quartos-1536660437	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-23 18:54:44.714	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-para-alugar-em-juazeiro-no-country-club-proximo-a-univasf-1537628334	Casa Para Alugar Em Juazeiro No Country Club Proximo A Univasf	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-para-alugar-em-juazeiro-no-country-club-proximo-a-univasf-1537628334	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	active	f	2026-09-23 18:55:05.232	2026-09-28 22:26:37.414	desktop-1790634395
olx-aluguel-condominio-vila-bela-juazeiro-1537443303	Aluguel Condominio Vila Bela Juazeiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/aluguel-condominio-vila-bela-juazeiro-1537443303	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	active	f	2026-09-23 18:55:05.232	2026-09-28 22:26:37.414	desktop-1790634395
olx-aluga-se-casa-nova-em-condominio-residencial-juazeiro-ba-1537041668	Aluga Se Casa Nova Em Condominio Residencial Juazeiro Ba	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/aluga-se-casa-nova-em-condominio-residencial-juazeiro-ba-1537041668	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	active	f	2026-09-23 18:55:05.232	2026-09-28 22:26:37.414	desktop-1790634395
olx-casa-3-quartos-com-suite-para-alugar-bairro-santo-antonio-1537338666	Casa 3 Quartos Com Suite Para Alugar Bairro Santo Antonio	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-3-quartos-com-suite-para-alugar-bairro-santo-antonio-1537338666	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	active	f	2026-09-23 18:55:05.232	2026-09-28 22:26:37.414	desktop-1790634395
olx-alugo-camas-em-quarto-em-pensionato-feminino-1534521346	Alugo Camas Em Quarto Em Pensionato Feminino	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/alugo-camas-em-quarto-em-pensionato-feminino-1534521346	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Terreno	aluguel	active	f	2026-09-14 17:55:52.942	2026-09-28 22:26:37.414	desktop-1790634395
olx-alugo-casa-no-bairro-jardim-florida-mobiliada-3-quartos-suite-moveis-planejados-e-novos-1536526182	Alugo Casa No Bairro Jardim Florida Mobiliada 3 Quartos Suite Moveis Planejados E Novos	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/alugo-casa-no-bairro-jardim-florida-mobiliada-3-quartos-suite-moveis-planejados-e-novos-1536526182	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	removed	f	2026-09-23 18:55:05.232	2026-09-23 18:57:24.545	desktop-1790189845
olx-apartamento-2-4-com-suite-terreo-varanda-reformado-condominio-valle-dos-coqueiros-1479687720	Apartamento 2 4 Com Suite Terreo Varanda Reformado Condominio Valle Dos Coqueiros	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-2-4-com-suite-terreo-varanda-reformado-condominio-valle-dos-coqueiros-1479687720	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	t	2026-09-28 22:32:39.92	2026-09-28 22:32:39.92	desktop-1790634758
olx-vendo-apartamento-excelente-localizacao-1439001288	Vendo Apartamento Excelente Localizacao	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-apartamento-excelente-localizacao-1439001288	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	t	2026-09-28 22:32:39.92	2026-09-28 22:32:39.92	desktop-1790634758
olx-apartamento-a-venda-loteamento-recife-1519940410	Apartamento A Venda Loteamento Recife	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-a-venda-loteamento-recife-1519940410	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-vendo-apto-na-vila-moco-1538821893	Vendo Apto Na Vila Moco	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-apto-na-vila-moco-1538821893	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	t	2026-09-28 22:32:39.92	2026-09-28 22:32:39.92	desktop-1790634758
olx-apartamento-1538383483	Apartamento	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-1538383483	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	t	2026-09-28 22:32:39.92	2026-09-28 22:32:39.92	desktop-1790634758
olx-apartamento-centro-1538022201	Apartamento Centro	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-centro-1538022201	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	t	2026-09-28 22:32:39.92	2026-09-28 22:32:39.92	desktop-1790634758
olx-apartamento-no-condominio-vinhedos-em-petrolina-45m-frente-para-nascente-2-andar-em-1539394193	Apartamento No Condominio Vinhedos Em Petrolina 45m Frente Para Nascente 2 Andar Em	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-no-condominio-vinhedos-em-petrolina-45m-frente-para-nascente-2-andar-em-1539394193	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-28 22:32:39.92	2026-09-28 22:36:01.754	desktop-1790634960
olx-apartamento-na-orla-2-petrolina-pe-1539013100	Apartamento Na Orla 2 Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-na-orla-2-petrolina-pe-1539013100	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-28 22:32:39.92	2026-09-28 22:36:01.754	desktop-1790634960
olx-vendo-apartamento-condominio-residencial-vila-verde-petrolina-pe-1533873900	Vendo Apartamento Condominio Residencial Vila Verde Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-apartamento-condominio-residencial-vila-verde-petrolina-pe-1533873900	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:36:01.754	desktop-1790634960
olx-apartamento-no-condominio-monte-carmelo-3-quartos-proximo-a-orla-i-em-petrolina-pe-1489654892	Apartamento No Condominio Monte Carmelo 3 Quartos Proximo A Orla I Em Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-no-condominio-monte-carmelo-3-quartos-proximo-a-orla-i-em-petrolina-pe-1489654892	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:36:01.754	desktop-1790634960
olx-vendo-apartamento-no-nova-petrolina-1532595384	Vendo Apartamento No Nova Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-apartamento-no-nova-petrolina-1532595384	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:36:01.754	desktop-1790634960
olx-linda-casa-no-loteamento-recife-1535181582	Linda Casa No Loteamento Recife	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/linda-casa-no-loteamento-recife-1535181582	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-14 18:04:22.287	2026-09-17 13:43:32.693	desktop-1789652612
olx-casa-venda-na-areia-branca-documentacao-100-legalizada-1534555426	Casa Venda Na Areia Branca Documentacao 100 Legalizada	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-venda-na-areia-branca-documentacao-100-legalizada-1534555426	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-14 18:04:22.287	2026-09-17 12:51:55.942	desktop-1789649515
olx-apartamentos-1538004248	Apartamentos	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/apartamentos-1538004248	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	active	f	2026-09-23 18:55:51.618	2026-09-28 22:26:37.414	desktop-1790634395
olx-casa-1534813428	Casa	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-1534813428	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-14 18:04:22.287	2026-09-17 13:43:32.693	desktop-1789652612
olx-casa-para-vender-1534718830	Casa Para Vender	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-para-vender-1534718830	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-14 18:04:22.287	2026-09-17 13:43:32.693	desktop-1789652612
olx-vendo-casa-no-portal-da-cidade-promocao-1412934620	Vendo Casa No Portal Da Cidade Promocao	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-casa-no-portal-da-cidade-promocao-1412934620	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-14 18:04:22.287	2026-09-17 13:43:32.693	desktop-1789652612
olx-vendo-apartamento-mobiliado-em-condominio-1536553083	Vendo Apartamento Mobiliado Em Condominio	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-apartamento-mobiliado-em-condominio-1536553083	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	t	2026-09-28 22:32:39.92	2026-09-28 22:32:39.92	desktop-1790634758
olx-casa-a-venda-cohab-vi-petrolina-pe-area-total-do-terreno-200m-1504069761	Casa A Venda Cohab Vi Petrolina Pe Area Total Do Terreno 200m	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-a-venda-cohab-vi-petrolina-pe-area-total-do-terreno-200m-1504069761	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-14 18:04:22.287	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-no-centro-de-petrolina-prox-a-praca-do-peixe-1534879253	Casa No Centro De Petrolina Prox A Praca Do Peixe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-no-centro-de-petrolina-prox-a-praca-do-peixe-1534879253	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-14 18:04:22.287	2026-09-14 18:08:32.371	desktop-1789409311
olx-vende-se-imovel-condominio-vale-do-sol-1535153230	Vende Se Imovel Condominio Vale Do Sol	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vende-se-imovel-condominio-vale-do-sol-1535153230	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-14 18:04:22.287	2026-09-28 22:31:23.447	desktop-1790634682
olx-aluguel-apto-1-quarto-1537509751	Aluguel Apto 1 Quarto	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/aluguel-apto-1-quarto-1537509751	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	removed	f	2026-09-23 18:55:51.618	2026-09-23 18:57:24.545	desktop-1790189845
olx-apartamento-no-dom-thomas-2-quartos-1536937687	Apartamento No Dom Thomas 2 Quartos	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/apartamento-no-dom-thomas-2-quartos-1536937687	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	removed	f	2026-09-23 18:55:51.618	2026-09-23 18:57:24.545	desktop-1790189845
olx-busco-alguem-1536370028	Busco Alguem	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/busco-alguem-1536370028	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	active	f	2026-09-23 18:55:51.618	2026-09-28 22:26:37.414	desktop-1790634395
olx-vendo-casa-na-areia-branca-1534815586	Vendo Casa Na Areia Branca	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-casa-na-areia-branca-1534815586	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-14 18:04:22.287	2026-09-17 13:43:32.693	desktop-1789652612
olx-casa-condominio-buona-vita-1534693185	Casa Condominio Buona Vita	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-condominio-buona-vita-1534693185	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-14 18:04:22.287	2026-09-17 13:43:32.693	desktop-1789652612
olx-oportunidade-casa-a-venda-em-condominio-fechado-1534583555	Oportunidade Casa A Venda Em Condominio Fechado	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/oportunidade-casa-a-venda-em-condominio-fechado-1534583555	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-14 18:04:22.287	2026-09-17 13:43:32.693	desktop-1789652612
olx-apartamento-a-venda-1530678074	Apartamento A Venda	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-a-venda-1530678074	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-alugo-casa-bairro-sao-goncalo-1535052829	Alugo Casa Bairro Sao Goncalo	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-casa-bairro-sao-goncalo-1535052829	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-14 18:05:14.396	2026-09-17 13:43:59.768	desktop-1789652639
olx-apartamento-a-venda-no-vila-real-1524263608	Apartamento A Venda No Vila Real	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-a-venda-no-vila-real-1524263608	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	t	2026-09-28 22:32:39.92	2026-09-28 22:32:39.92	desktop-1790634758
olx-casa-em-petrolina-03-quartos-suite-garagem-1535315737	Casa Em Petrolina 03 Quartos Suite Garagem	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-em-petrolina-03-quartos-suite-garagem-1535315737	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-14 18:05:14.396	2026-09-28 22:36:47.801	desktop-1790635006
olx-alugo-casa-antonio-cassimiro-petrolina-1534799948	Alugo Casa Antonio Cassimiro Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-casa-antonio-cassimiro-petrolina-1534799948	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-14 18:05:14.396	2026-09-28 22:36:47.801	desktop-1790635006
olx-casa-nova-a-venda-irece-e-regiao-joao-dourado-ba-r-220-000-negociavel-1537044509	Casa Nova A Venda Irece E Regiao Joao Dourado Ba R 220 000 Negociavel	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-nova-a-venda-irece-e-regiao-joao-dourado-ba-r-220-000-negociavel-1537044509	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	venda	active	f	2026-09-23 18:57:44.184	2026-09-28 22:29:56.891	desktop-1790634595
olx-alugo-casa-2-4-suite-condominio-sunville-1514957348	Alugo Casa 2 4 Suite Condominio Sunville	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-casa-2-4-suite-condominio-sunville-1514957348	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-14 18:05:14.396	2026-09-28 22:32:09.922	desktop-1790634728
olx-aluga-se-casa-no-condominio-valle-dos-sonhos-1535308581	Aluga Se Casa No Condominio Valle Dos Sonhos	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluga-se-casa-no-condominio-valle-dos-sonhos-1535308581	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-14 18:05:14.396	2026-09-28 22:32:09.922	desktop-1790634728
olx-aluguel-de-casa-disponivel-condominio-com-energia-solar-1535142716	Aluguel De Casa Disponivel Condominio Com Energia Solar	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluguel-de-casa-disponivel-condominio-com-energia-solar-1535142716	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-14 18:05:14.396	2026-09-28 22:32:09.922	desktop-1790634728
olx-casa-p-alugar-vila-eduardo-1535102923	Casa P Alugar Vila Eduardo	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-p-alugar-vila-eduardo-1535102923	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-14 18:05:14.396	2026-09-28 22:32:09.922	desktop-1790634728
olx-bairro-km-2-1534915000	Bairro Km 2	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/bairro-km-2-1534915000	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-14 18:05:14.396	2026-09-28 22:32:09.922	desktop-1790634728
olx-residencial-nova-petrolina-1534360566	Residencial Nova Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/residencial-nova-petrolina-1534360566	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-mobiliado-3-quartos-situado-na-vila-moco-petrolina-proximo-a-curso-bios-1539670159	Apartamento Mobiliado 3 Quartos Situado Na Vila Moco Petrolina Proximo A Curso Bios	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-mobiliado-3-quartos-situado-na-vila-moco-petrolina-proximo-a-curso-bios-1539670159	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-28 22:33:24.468	2026-09-28 22:36:47.801	desktop-1790635006
olx-1o34js-10	1o34js	https://static.olx.com.br/cd/vi/js/listing-next/_next/static/chunks/1o34js-10	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	aluguel	active	f	2026-09-23 18:58:05.769	2026-09-28 22:27:31.419	desktop-1790634449
olx-apartamento-em-petrolina-pe-para-venda-condominio-fechado-2-quartos-1534693104	Apartamento Em Petrolina Pe Para Venda Condominio Fechado 2 Quartos	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-em-petrolina-pe-para-venda-condominio-fechado-2-quartos-1534693104	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-14 18:06:37.726	2026-09-28 22:36:01.754	desktop-1790634960
olx-apartamento-venda-no-coracao-de-petrolina-1534534437	Apartamento Venda No Coracao De Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-venda-no-coracao-de-petrolina-1534534437	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-14 18:06:37.726	2026-09-28 22:36:01.754	desktop-1790634960
olx-apartamento-1535082091	Apartamento	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-1535082091	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-14 18:06:37.726	2026-09-28 22:32:39.92	desktop-1790634758
olx-vendo-apartamento-1534826350	Vendo Apartamento	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-apartamento-1534826350	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-14 18:06:37.726	2026-09-28 22:32:39.92	desktop-1790634758
olx-apartamento-no-bernardino-1531270979	Apartamento No Bernardino	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-no-bernardino-1531270979	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-apartamento-vista-livre-nascente-na-melhor-localizacao-da-cidade-1526970892	Apartamento Vista Livre Nascente Na Melhor Localizacao Da Cidade	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-vista-livre-nascente-na-melhor-localizacao-da-cidade-1526970892	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-11 13:58:20.993	2026-09-28 22:32:39.92	desktop-1790634758
olx-r-360-mil-apto-2-quartos-mobiliado-e-reformado-piscina-petrolina-1534609629	R 360 Mil Apto 2 Quartos Mobiliado E Reformado Piscina Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/r-360-mil-apto-2-quartos-mobiliado-e-reformado-piscina-petrolina-1534609629	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-14 18:06:37.726	2026-09-28 22:36:01.754	desktop-1790634960
olx-aluga-se-apartamento-em-petrolina-pe-1539154920	Aluga Se Apartamento Em Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluga-se-apartamento-em-petrolina-pe-1539154920	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-28 22:33:24.468	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-em-petrolina-1538239404	Apartamento Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-em-petrolina-1538239404	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-28 22:33:24.468	2026-09-28 22:36:47.801	desktop-1790635006
olx-casa-no-condominio-country-club-1539404609	Casa No Condominio Country Club	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-no-condominio-country-club-1539404609	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-28 22:23:08.472	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-moderna-com-3-suites-area-gourmet-e-piscina-pronta-para-morar-1539190487	Casa Moderna Com 3 Suites Area Gourmet E Piscina Pronta Para Morar	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-moderna-com-3-suites-area-gourmet-e-piscina-pronta-para-morar-1539190487	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-28 22:23:08.472	2026-09-28 22:26:09.769	desktop-1790634368
olx-nao-perca-essa-oportunidade-tal-investir-em-duas-casas-com-o-preco-de-uma-1525798179	Nao Perca Essa Oportunidade Tal Investir Em Duas Casas Com O Preco De Uma	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/nao-perca-essa-oportunidade-tal-investir-em-duas-casas-com-o-preco-de-uma-1525798179	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-28 22:23:08.472	2026-09-28 22:26:09.769	desktop-1790634368
olx-apto-2-4-areia-branca-1535099779	Apto 2 4 Areia Branca	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apto-2-4-areia-branca-1535099779	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-14 18:07:28.868	2026-09-28 22:33:24.468	desktop-1790634802
olx-alugo-ap-na-vila-moco-1534790627	Alugo Ap Na Vila Moco	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-ap-na-vila-moco-1534790627	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-14 18:07:28.868	2026-09-28 22:33:24.468	desktop-1790634802
olx-apartamento-mobilado-proximo-a-univasf-1534675411	Apartamento Mobilado Proximo A Univasf	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-mobilado-proximo-a-univasf-1534675411	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-14 18:07:28.868	2026-09-28 22:33:24.468	desktop-1790634802
olx-apartamento-na-cohab-massangano-petrolina-pe-3-quartos-3-banheiros-perto-da-progresso-1535181577	Apartamento Na Cohab Massangano Petrolina Pe 3 Quartos 3 Banheiros Perto Da Progresso	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-na-cohab-massangano-petrolina-pe-3-quartos-3-banheiros-perto-da-progresso-1535181577	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-14 18:07:28.868	2026-09-17 13:47:14.535	desktop-1789652834
olx-lindo-confortavel-e-mobiliado-viver-com-estilo-1535206644	Lindo Confortavel E Mobiliado Viver Com Estilo	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/lindo-confortavel-e-mobiliado-viver-com-estilo-1535206644	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-14 18:07:28.868	2026-09-14 18:10:08.944	desktop-1789409407
olx-aluguel-de-kitnet-1534914094	Aluguel De Kitnet	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluguel-de-kitnet-1534914094	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-14 18:07:28.868	2026-09-14 18:10:08.944	desktop-1789409407
olx-excelente-apartamento-terreo-condominio-valle-dos-coqueiros-1502563566	Excelente Apartamento Terreo Condominio Valle Dos Coqueiros	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/excelente-apartamento-terreo-condominio-valle-dos-coqueiros-1502563566	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-28 22:33:24.468	2026-09-28 22:36:47.801	desktop-1790635006
olx-kitnet-1-quarto-tipo-suite-1539619070	Kitnet 1 Quarto Tipo Suite	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/kitnet-1-quarto-tipo-suite-1539619070	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-28 22:33:24.468	2026-09-28 22:36:47.801	desktop-1790635006
olx-alugo-apartamento-no-primeiro-andar-condominio-mais-viver-sao-francisco-1539302793	Alugo Apartamento No Primeiro Andar Condominio Mais Viver Sao Francisco	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-apartamento-no-primeiro-andar-condominio-mais-viver-sao-francisco-1539302793	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-28 22:33:24.468	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-mobiliado-na-areia-branca-1538828639	Apartamento Mobiliado Na Areia Branca	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-mobiliado-na-areia-branca-1538828639	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-28 22:33:24.468	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-primeira-locacao-mobiliado-1531963697	Apartamento Primeira Locacao Mobiliado	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-primeira-locacao-mobiliado-1531963697	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-28 22:33:24.468	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-kit-net-mobiliado-1483344053	Apartamento Kit Net Mobiliado	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-kit-net-mobiliado-1483344053	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-28 22:33:24.468	2026-09-28 22:36:47.801	desktop-1790635006
olx-kitnet-com-ar-condicionado-prox-nassau-facape-hosp-unimed-e-av-integracao-1515269670	Kitnet Com Ar Condicionado Prox Nassau Facape Hosp Unimed E Av Integracao	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/kitnet-com-ar-condicionado-prox-nassau-facape-hosp-unimed-e-av-integracao-1515269670	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-28 22:33:24.468	2026-09-28 22:36:47.801	desktop-1790635006
olx-apt-de-3-quartos-vista-para-a-orla-de-petrolina-incluso-condominio-agua-e-iptu-1524169042	Apt De 3 Quartos Vista Para A Orla De Petrolina Incluso Condominio Agua E Iptu	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apt-de-3-quartos-vista-para-a-orla-de-petrolina-incluso-condominio-agua-e-iptu-1524169042	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-2-4-1-banheiro-incluso-condominio-e-iptu-no-mais-viver-sao-francisco-1533362549	Apartamento 2 4 1 Banheiro Incluso Condominio E Iptu No Mais Viver Sao Francisco	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-2-4-1-banheiro-incluso-condominio-e-iptu-no-mais-viver-sao-francisco-1533362549	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:36:47.801	desktop-1790635006
olx-procura-se-profissional-do-sexo-masculino-para-dividir-casa-apartamento-1538816873	Procura Se Profissional Do Sexo Masculino Para Dividir Casa Apartamento	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/procura-se-profissional-do-sexo-masculino-para-dividir-casa-apartamento-1538816873	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-28 22:33:24.468	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-para-solteiros-mobiliado-1538726715	Apartamento Para Solteiros Mobiliado	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-para-solteiros-mobiliado-1538726715	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	t	2026-09-28 22:33:24.468	2026-09-28 22:33:24.468	desktop-1790634802
olx-apartamento-a-rua-engenheiro-carlos-pinheiro-265-centro-1538533213	Apartamento A Rua Engenheiro Carlos Pinheiro 265 Centro	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-a-rua-engenheiro-carlos-pinheiro-265-centro-1538533213	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	t	2026-09-28 22:33:24.468	2026-09-28 22:33:24.468	desktop-1790634802
olx-apartamentos-disponiveis-para-locacao-1538216486	Apartamentos Disponiveis Para Locacao	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamentos-disponiveis-para-locacao-1538216486	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	t	2026-09-28 22:33:24.468	2026-09-28 22:33:24.468	desktop-1790634802
olx-casa-duplex-com-2-suites-varanda-garagem-e-energia-solar-country-1538771671	Casa Duplex Com 2 Suites Varanda Garagem E Energia Solar Country	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-duplex-com-2-suites-varanda-garagem-e-energia-solar-country-1538771671	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	active	f	2026-09-28 22:23:39.895	2026-09-28 22:26:37.414	desktop-1790634395
olx-procuro-gente-para-dividir-apartamento-comigo-e-um-amigo-1538301970	Procuro Gente Para Dividir Apartamento Comigo E Um Amigo	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/procuro-gente-para-dividir-apartamento-comigo-e-um-amigo-1538301970	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	active	f	2026-09-28 22:23:39.895	2026-09-28 22:26:37.414	desktop-1790634395
olx-dividir-apartamento-1538207852	Dividir Apartamento	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/dividir-apartamento-1538207852	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	t	2026-09-28 22:33:24.468	2026-09-28 22:33:24.468	desktop-1790634802
olx-alugo-apartamento-mobiliado-residencial-san-rafael-1529191388	Alugo Apartamento Mobiliado Residencial San Rafael	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-apartamento-mobiliado-residencial-san-rafael-1529191388	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-17 13:22:44.272	2026-09-28 22:33:24.468	desktop-1790634802
olx-locacao-de-apartamento-1537690263	Locacao De Apartamento	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/locacao-de-apartamento-1537690263	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	t	2026-09-28 22:33:24.468	2026-09-28 22:33:24.468	desktop-1790634802
olx-apartamento-vizinho-a-academia-smartfit-1537241314	Apartamento Vizinho A Academia Smartfit	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-vizinho-a-academia-smartfit-1537241314	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	t	2026-09-28 22:33:24.468	2026-09-28 22:33:24.468	desktop-1790634802
olx-alugo-apartamento-1-andar-1536673075	Alugo Apartamento 1 Andar	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-apartamento-1-andar-1536673075	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	t	2026-09-28 22:33:24.468	2026-09-28 22:33:24.468	desktop-1790634802
olx-alugo-casa-mobiliada-ideal-para-estudantes-e-trabalhadores-1536377834	Alugo Casa Mobiliada Ideal Para Estudantes E Trabalhadores	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-casa-mobiliada-ideal-para-estudantes-e-trabalhadores-1536377834	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	t	2026-09-28 22:33:24.468	2026-09-28 22:33:24.468	desktop-1790634802
olx-o-apartamento-na-avenida-nordeste-bairro-santa-luzia-1535590028	O Apartamento Na Avenida Nordeste Bairro Santa Luzia	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/o-apartamento-na-avenida-nordeste-bairro-santa-luzia-1535590028	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	t	2026-09-28 22:33:24.468	2026-09-28 22:33:24.468	desktop-1790634802
olx-alugo-apartamentos-83-no-antonio-cassimiro-1535297577	Alugo Apartamentos 83 No Antonio Cassimiro	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-apartamentos-83-no-antonio-cassimiro-1535297577	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-14 18:07:28.868	2026-09-28 22:33:24.468	desktop-1790634802
olx-excelnete-ap-vale-do-sol-mobiliado-1538866094	Excelnete Ap Vale Do Sol Mobiliado	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/excelnete-ap-vale-do-sol-mobiliado-1538866094	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-28 22:33:24.468	2026-09-28 22:36:47.801	desktop-1790635006
olx-procuro-colega-de-quarto-em-petrolina-pe-1534915801	Procuro Colega De Quarto Em Petrolina Pe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/procuro-colega-de-quarto-em-petrolina-pe-1534915801	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Terreno	aluguel	removed	f	2026-09-14 18:10:08.944	2026-09-17 13:47:14.535	desktop-1789652834
olx-apartamento-mobiliado-lindo-moderno-e-confortavel-viver-com-estilo-1535206644	Apartamento Mobiliado Lindo Moderno E Confortavel Viver Com Estilo	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-mobiliado-lindo-moderno-e-confortavel-viver-com-estilo-1535206644	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	t	2026-09-28 22:33:24.468	2026-09-28 22:33:24.468	desktop-1790634802
olx-alugo-apartamento-com-mobilia-no-condominio-carlos-1533253247	Alugo Apartamento Com Mobilia No Condominio Carlos	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-apartamento-com-mobilia-no-condominio-carlos-1533253247	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	active	f	2026-09-11 13:59:01.973	2026-09-28 22:33:24.468	desktop-1790634802
olx-alugo-apto-no-centro-de-petrolina-1534189604	Alugo Apto No Centro De Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-apto-no-centro-de-petrolina-1534189604	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	aluguel	removed	f	2026-09-11 13:59:01.973	2026-09-17 13:47:14.535	desktop-1789652834
olx-casa-a-venda-em-condominio-em-juazeiro-1536221434	Casa A Venda Em Condominio Em Juazeiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-em-condominio-em-juazeiro-1536221434	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-17 12:47:01.015	2026-09-28 22:26:09.769	desktop-1790634368
olx-apartamento-mobiliado-dois-quartos-com-ar-condicionado-proximo-ao-centro-de-juazeiro-1539663619	Apartamento Mobiliado Dois Quartos Com Ar Condicionado Proximo Ao Centro De Juazeiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/apartamento-mobiliado-dois-quartos-com-ar-condicionado-proximo-ao-centro-de-juazeiro-1539663619	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	active	f	2026-09-28 22:24:48.666	2026-09-28 22:26:37.414	desktop-1790634395
olx-casa-e-apartamento-santo-anotonio-juazeiro-1538879150	Casa E Apartamento Santo Anotonio Juazeiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-e-apartamento-santo-anotonio-juazeiro-1538879150	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	active	f	2026-09-28 22:24:48.666	2026-09-28 22:26:37.414	desktop-1790634395
olx-apartamento-em-petrolina-r-45-000-00-1538621215	Apartamento Em Petrolina R 45 000 00	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-em-petrolina-r-45-000-00-1538621215	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-28 22:32:39.92	2026-09-28 22:36:01.754	desktop-1790634960
olx-apto-2-4-mais-viver-sao-francisco-juazeiro-ba-proximo-a-uneb-1523948451	Apto 2 4 Mais Viver Sao Francisco Juazeiro Ba Proximo A Uneb	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/apto-2-4-mais-viver-sao-francisco-juazeiro-ba-proximo-a-uneb-1523948451	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	active	f	2026-08-20 12:39:30.237	2026-09-28 22:26:37.414	desktop-1790634395
olx-casa-no-centro-da-cidade-para-residencia-ou-comercio-1535782842	Casa No Centro Da Cidade Para Residencia Ou Comercio	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-no-centro-da-cidade-para-residencia-ou-comercio-1535782842	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	active	f	2026-09-17 12:47:18.601	2026-09-28 22:26:37.414	desktop-1790634395
olx-quarto-hospedagem-galo-hostel-petrolina-com-nf-953336690	Quarto Hospedagem Galo Hostel Petrolina Com Nf	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/quarto-hospedagem-galo-hostel-petrolina-com-nf-953336690	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Terreno	aluguel	active	f	2026-09-28 22:34:58.259	2026-09-28 22:36:47.801	desktop-1790635006
olx-vaga-de-um-quarto-para-menina-ou-homem-gay-em-petrolina-1534711928	Vaga De Um Quarto Para Menina Ou Homem Gay Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vaga-de-um-quarto-para-menina-ou-homem-gay-em-petrolina-1534711928	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Terreno	aluguel	active	f	2026-09-14 18:10:08.944	2026-09-28 22:36:47.801	desktop-1790635006
olx-2h-6	2h	https://static.olx.com.br/cd/vi/js/listing-next/_next/static/chunks/2h-6	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	aluguel	removed	f	2026-09-17 12:49:42.101	2026-09-17 13:53:52.379	desktop-1789653231
olx-vende-se-casa-no-centro-de-petrolina-prox-a-praca-do-peixe-1534879253	Vende Se Casa No Centro De Petrolina Prox A Praca Do Peixe	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vende-se-casa-no-centro-de-petrolina-prox-a-praca-do-peixe-1534879253	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-17 12:51:55.942	2026-09-17 13:46:43.343	desktop-1789652803
olx-casa-comercial-avenida-paraiba-areia-branca-1536134969	Casa Comercial Avenida Paraiba Areia Branca	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-comercial-avenida-paraiba-areia-branca-1536134969	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-17 12:51:55.942	2026-09-17 13:43:32.693	desktop-1789652612
olx-casa-a-venda-no-park-sao-goncalo-1536112231	Casa A Venda No Park Sao Goncalo	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-a-venda-no-park-sao-goncalo-1536112231	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-17 12:51:55.942	2026-09-17 13:43:32.693	desktop-1789652612
olx-casa-nova-para-venda-em-petrolina-1535800405	Casa Nova Para Venda Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-nova-para-venda-em-petrolina-1535800405	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-17 12:51:55.942	2026-09-28 22:36:01.754	desktop-1790634960
olx-casa-de-alto-padrao-3-pavimentos-piscina-e-area-gourmet-colinas-imperial-1536002006	Casa De Alto Padrao 3 Pavimentos Piscina E Area Gourmet Colinas Imperial	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-de-alto-padrao-3-pavimentos-piscina-e-area-gourmet-colinas-imperial-1536002006	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-17 12:51:55.942	2026-09-28 22:31:23.447	desktop-1790634682
olx-casa-no-bairro-vale-dourado-1536202087	Casa No Bairro Vale Dourado	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-no-bairro-vale-dourado-1536202087	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-17 12:51:55.942	2026-09-28 22:31:23.447	desktop-1790634682
olx-casas-novas-documentacao-prontas-pra-financiamento-1536117730	Casas Novas Documentacao Prontas Pra Financiamento	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casas-novas-documentacao-prontas-pra-financiamento-1536117730	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-17 12:51:55.942	2026-09-28 22:31:23.447	desktop-1790634682
olx-vendo-casa-1536106219	Vendo Casa	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/vendo-casa-1536106219	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-17 12:51:55.942	2026-09-28 22:31:23.447	desktop-1790634682
olx-casa-a-venda-no-jatoba-1535975047	Casa A Venda No Jatoba	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-a-venda-no-jatoba-1535975047	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-17 12:51:55.942	2026-09-17 13:43:32.693	desktop-1789652612
olx-casa-no-bairro-santa-barbara-proximo-ao-buona-vita-1535748129	Casa No Bairro Santa Barbara Proximo Ao Buona Vita	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-no-bairro-santa-barbara-proximo-ao-buona-vita-1535748129	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	removed	f	2026-09-17 12:51:55.942	2026-09-17 13:43:32.693	desktop-1789652612
olx-casa-5-quartos-centro-de-petrolina--1525015429	Casa 5 Quartos Centro De Petrolina 	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-5-quartos-centro-de-petrolina--1525015429	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	venda	active	f	2026-09-17 12:51:55.942	2026-09-28 22:36:01.754	desktop-1790634960
olx-aluguel-1536250171	Aluguel	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluguel-1536250171	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-17 12:52:20.304	2026-09-28 22:32:09.922	desktop-1790634728
olx-aluguel-dom-avelar-1536000579	Aluguel Dom Avelar	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluguel-dom-avelar-1536000579	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-17 12:52:20.304	2026-09-28 22:32:09.922	desktop-1790634728
olx-casa-no-cond-valle-das-mangueiras-1535512282	Casa No Cond Valle Das Mangueiras	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-no-cond-valle-das-mangueiras-1535512282	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-17 12:52:20.304	2026-09-28 22:32:09.922	desktop-1790634728
olx-aluga-se-casa-no-primeiro-andar-no-bairro-dom-avelar-1536174550	Aluga Se Casa No Primeiro Andar No Bairro Dom Avelar	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluga-se-casa-no-primeiro-andar-no-bairro-dom-avelar-1536174550	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-17 12:52:20.304	2026-09-17 13:47:14.535	desktop-1789652834
olx-casa-para-alugar-dom-avelar-1536097306	Casa Para Alugar Dom Avelar	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/casa-para-alugar-dom-avelar-1536097306	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-17 12:52:20.304	2026-09-17 13:47:14.535	desktop-1789652834
olx-aluga-se-casa-em-condominio-fechado-more-com-seguranca-e-conforto-1529202427	Aluga Se Casa Em Condominio Fechado More Com Seguranca E Conforto	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/aluga-se-casa-em-condominio-fechado-more-com-seguranca-e-conforto-1529202427	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	removed	f	2026-09-11 13:57:45.666	2026-09-17 13:43:59.768	desktop-1789652639
olx-alugo-uma-casa-no-condominio-em-vila-eduardo-em-petrolina-1535601855	Alugo Uma Casa No Condominio Em Vila Eduardo Em Petrolina	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/alugo-uma-casa-no-condominio-em-vila-eduardo-em-petrolina-1535601855	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Casa	aluguel	active	f	2026-09-17 12:52:20.304	2026-09-28 22:36:47.801	desktop-1790635006
olx-apartamento-a-venda-no-edf-santa-cecilia-na-vila-moco-1536088347	Apartamento A Venda No Edf Santa Cecilia Na Vila Moco	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/apartamento-a-venda-no-edf-santa-cecilia-na-vila-moco-1536088347	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	active	f	2026-09-17 12:52:38.71	2026-09-28 22:32:39.92	desktop-1790634758
olx-condominio-mais-viver-sao-francisco-contato-whatsapp-1535771806	Condominio Mais Viver Sao Francisco Contato Whatsapp	https://pe.olx.com.br/regiao-de-petrolina-e-garanhuns/imoveis/condominio-mais-viver-sao-francisco-contato-whatsapp-1535771806	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Petrolina-PE.	t	Petrolina	PE	Apartamento	venda	removed	f	2026-09-17 12:52:38.71	2026-09-17 13:44:21.557	desktop-1789652661
olx-sobrado-4-quartos-sendo-3-suites-2-vagas-de-garagem-232-m2-centro-juazeiro-1528645569	Sobrado 4 Quartos Sendo 3 Suites 2 Vagas De Garagem 232 M2 Centro Juazeiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/sobrado-4-quartos-sendo-3-suites-2-vagas-de-garagem-232-m2-centro-juazeiro-1528645569	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-08-24 00:48:47.058	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-no-parque-residencial-praia-do-rodeadouro-2-quartos-juazeiro-1528082077	Casa No Parque Residencial Praia Do Rodeadouro 2 Quartos Juazeiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-no-parque-residencial-praia-do-rodeadouro-2-quartos-juazeiro-1528082077	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-08-24 00:48:47.058	2026-08-24 00:52:09.377	desktop-1787532729
olx-casa-barata-1528508751	Casa Barata	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-barata-1528508751	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	venda	active	f	2026-08-24 00:58:14.602	2026-09-28 22:29:56.891	desktop-1790634595
olx-android-chrome-192	Android Chrome	https://static.olx.com.br/cd/vi/images/icons/android-chrome-192	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	aluguel	active	f	2026-08-24 00:58:37.533	2026-09-28 22:27:31.419	desktop-1790634449
olx-vendo-ou-troco-1522314769	Vendo Ou Troco	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/vendo-ou-troco-1522314769	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	venda	removed	f	2026-08-24 00:58:14.602	2026-09-23 18:57:44.184	desktop-1790189864
olx-casa-no-bairro-quide-juazeiro-ba-3-quartos-sendo-um-suite-1523970029	Casa No Bairro Quide Juazeiro Ba 3 Quartos Sendo Um Suite	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-no-bairro-quide-juazeiro-ba-3-quartos-sendo-um-suite-1523970029	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-08-19 14:33:14.84	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-a-venda-ideal-para-morar-ou-investir-1524489173	Casa A Venda Ideal Para Morar Ou Investir	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-ideal-para-morar-ou-investir-1524489173	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	venda	active	f	2026-08-24 00:58:14.602	2026-09-28 22:29:56.891	desktop-1790634595
olx-favicon-16	Favicon	https://static.olx.com.br/cd/vi/images/icons/favicon-16	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	aluguel	active	f	2026-08-24 00:58:37.533	2026-09-28 22:27:31.419	desktop-1790634449
olx-alugo-mobiliado-paripe-diaria-e-mensal-1525570578	Alugo Mobiliado Paripe Diaria E Mensal	https://ba.olx.com.br/grande-salvador/imoveis/alugo-mobiliado-paripe-diaria-e-mensal-1525570578	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Apartamento	aluguel	removed	f	2026-08-24 00:59:22.695	2026-09-01 21:09:09.109	desktop-1788296948
olx-casa-condominio-new-house-com-energia-solar-1523947985	Casa Condominio New House Com Energia Solar	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-condominio-new-house-com-energia-solar-1523947985	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	venda	active	f	2026-08-24 00:58:14.602	2026-09-28 22:29:56.891	desktop-1790634595
olx-0vygpb_2rk-26	0vygpb_2rk	https://static.olx.com.br/cd/vi/js/listing-next/_next/static/chunks/0vygpb_2rk-26	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	aluguel	removed	f	2026-08-24 00:58:37.533	2026-08-24 00:59:01.694	desktop-1787533141
olx-turbopack-1	Turbopack	https://static.olx.com.br/cd/vi/js/listing-next/_next/static/chunks/turbopack-1	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	aluguel	active	f	2026-08-24 00:58:37.533	2026-09-28 22:27:31.419	desktop-1790634449
olx-casa-com-ponto-comercial-na-avenida-raimundo-bonfim-em-irece-br-apenas-venda-1515243719	Casa Com Ponto Comercial Na Avenida Raimundo Bonfim Em Irece Br Apenas Venda	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-com-ponto-comercial-na-avenida-raimundo-bonfim-em-irece-br-apenas-venda-1515243719	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	venda	removed	f	2026-08-24 00:58:14.602	2026-09-01 21:08:43.472	desktop-1788296923
olx-casa-para-vender-na-cidade-de-serrinha-1513854663	Casa Para Vender Na Cidade De Serrinha	https://ba.olx.com.br/regiao-de-feira-de-santana-e-alagoinhas/imoveis/casa-para-vender-na-cidade-de-serrinha-1513854663	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	venda	removed	f	2026-08-24 00:58:14.602	2026-08-24 01:00:37.756	desktop-1787533237
olx-favicon-32	Favicon	https://static.olx.com.br/cd/vi/images/icons/favicon-32	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	aluguel	active	f	2026-08-24 00:58:37.533	2026-09-28 22:27:31.419	desktop-1790634449
olx-sobrado-com-ponto-comercial-em-irece-1528256048	Sobrado Com Ponto Comercial Em Irece	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/sobrado-com-ponto-comercial-em-irece-1528256048	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	venda	active	f	2026-08-24 00:58:14.602	2026-09-28 22:29:56.891	desktop-1790634595
olx-alugo-kitnet-em-irece-ba-1517995175	Alugo Kitnet Em Irece Ba	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/alugo-kitnet-em-irece-ba-1517995175	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Apartamento	aluguel	removed	f	2026-08-24 00:59:22.695	2026-09-11 13:54:21.779	desktop-1789134862
olx-edificio-mirante-da-chapada-irece-ba-1518419522	Edificio Mirante Da Chapada Irece Ba	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/edificio-mirante-da-chapada-irece-ba-1518419522	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Apartamento	aluguel	removed	f	2026-08-24 00:59:22.695	2026-08-24 01:01:08.619	desktop-1787533268
olx-aluguel-agua-gas-internet-luz-tudo-incluso-1455894033	Aluguel Agua Gas Internet Luz Tudo Incluso	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/aluguel-agua-gas-internet-luz-tudo-incluso-1455894033	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Apartamento	aluguel	active	f	2026-08-24 00:59:22.695	2026-09-28 22:30:24.171	desktop-1790634622
olx-aluga-casa-fins-comercial-residencial-1529711074	Aluga Casa Fins Comercial Residencial	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/aluga-casa-fins-comercial-residencial-1529711074	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	active	f	2026-09-01 15:53:50.401	2026-09-28 22:26:37.414	desktop-1790634395
olx-casa-a-venda-no-bairro-argemiro-3-4-sendo-1-suite-6-5m-x-20m-1530398040	Casa A Venda No Bairro Argemiro 3 4 Sendo 1 Suite 6 5m X 20m	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-no-bairro-argemiro-3-4-sendo-1-suite-6-5m-x-20m-1530398040	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-09-01 15:53:22.874	2026-09-01 21:00:45.776	desktop-1788296445
olx-que-tal-investir-em-duas-casas-com-o-preco-de-uma-1525798179	Que Tal Investir Em Duas Casas Com O Preco De Uma	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/que-tal-investir-em-duas-casas-com-o-preco-de-uma-1525798179	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-09-01 15:53:22.874	2026-09-23 18:57:01.443	desktop-1790189822
olx-vendo-repasse-de-casa-da-caixa-1520113916	Vendo Repasse De Casa Da Caixa	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/vendo-repasse-de-casa-da-caixa-1520113916	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-09-01 15:53:22.874	2026-09-17 13:35:35.308	desktop-1789652135
olx-vendo-casa-ampla-no-jardim-vitoria-juazeiro-1495894083	Vendo Casa Ampla No Jardim Vitoria Juazeiro	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/vendo-casa-ampla-no-jardim-vitoria-juazeiro-1495894083	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-01 15:53:22.874	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-em-piranga-juazeiro-ba-2-quartos-1531059730	Casa Em Piranga Juazeiro Ba 2 Quartos	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-em-piranga-juazeiro-ba-2-quartos-1531059730	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	removed	f	2026-09-01 15:53:50.401	2026-09-14 17:57:16.809	desktop-1789408635
olx-casa-a-venda-1531286188	Casa A Venda	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-1531286188	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-01 15:53:22.874	2026-09-28 22:26:09.769	desktop-1790634368
olx-casa-para-alugar-em-juazeiro-no-country-club-1529932655	Casa Para Alugar Em Juazeiro No Country Club	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-para-alugar-em-juazeiro-no-country-club-1529932655	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	active	f	2026-09-01 15:53:50.401	2026-09-28 22:26:37.414	desktop-1790634395
olx-casa-a-venda-em-itapua-2-4-com-garagem-1531185199	Casa A Venda Em Itapua 2 4 Com Garagem	https://ba.olx.com.br/grande-salvador/imoveis/casa-a-venda-em-itapua-2-4-com-garagem-1531185199	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	removed	f	2026-09-01 15:53:22.874	2026-09-11 13:51:27.172	desktop-1789134687
olx-casa-duplex-no-country-3-quartos-sendo-2-suites-1529640428	Casa Duplex No Country 3 Quartos Sendo 2 Suites	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-duplex-no-country-3-quartos-sendo-2-suites-1529640428	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	removed	f	2026-09-01 15:53:50.401	2026-09-01 21:01:12.288	desktop-1788296472
olx-procuro-menina-para-dividir-apartamento-1531367544	Procuro Menina Para Dividir Apartamento	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/procuro-menina-para-dividir-apartamento-1531367544	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	removed	f	2026-09-01 15:54:36.375	2026-09-01 21:01:12.288	desktop-1788296472
olx-casa-para-locacao-1530298441	Casa Para Locacao	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-para-locacao-1530298441	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	aluguel	removed	f	2026-09-01 15:53:50.401	2026-09-14 17:57:16.809	desktop-1789408635
olx-casa-a-venda-em-juazeiro-no-dom-jose-rodrigues-1529090247	Casa A Venda Em Juazeiro No Dom Jose Rodrigues	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-a-venda-em-juazeiro-no-dom-jose-rodrigues-1529090247	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Casa	venda	active	f	2026-09-01 15:53:22.874	2026-09-28 22:26:09.769	desktop-1790634368
olx-alugo-apt-no-edf-clube-primavera-1529054365	Alugo Apt No Edf Clube Primavera	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/alugo-apt-no-edf-clube-primavera-1529054365	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	active	f	2026-09-01 15:54:36.375	2026-09-28 22:26:37.414	desktop-1790634395
olx-seu-imovel-esta-aqui-1529932132	Seu Imovel Esta Aqui	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/seu-imovel-esta-aqui-1529932132	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	venda	active	f	2026-09-01 16:01:15.048	2026-09-28 22:29:56.891	desktop-1790634595
olx-vende-se-casa-com-lage-livre-1531054475	Vende Se Casa Com Lage Livre	https://ba.olx.com.br/grande-salvador/imoveis/vende-se-casa-com-lage-livre-1531054475	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Irecê-BA.	t	Irecê	BA	Casa	venda	removed	f	2026-09-01 16:01:15.048	2026-09-17 13:42:44.242	desktop-1789652564
olx-casa-para-alugar-no-bairro-santo-antonio-proxima-a-univasf-padaria-academias-1529135397	Casa Para Alugar No Bairro Santo Antonio Proxima A Univasf Padaria Academias	https://ba.olx.com.br/regiao-de-juazeiro-e-jacobina/imoveis/casa-para-alugar-no-bairro-santo-antonio-proxima-a-univasf-padaria-academias-1529135397	OLX Brasil (Particular)	Imóvel de proprietário particular capturado em Juazeiro-BA.	t	Juazeiro	BA	Apartamento	aluguel	active	f	2026-09-01 15:54:36.375	2026-09-28 22:26:37.414	desktop-1790634395
\.


--
-- Data for Name: seaql_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.seaql_migrations (version, applied_at) FROM stdin;
m20220101_000001_users	1774474685
m20260324_034531_properties	1774474685
m20260324_035948_categories	1774474685
m20260324_040822_category_properties	1774474685
m20260324_221319_contacts	1774474685
m20260324_221529_add_role_to_users	1774474685
m20260324_230000_rename_categories_to_advantages	1774474685
m20260324_235959_add_icon_to_advantages	1774474685
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (sid, sess, expire) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, password_hash, first_name, last_name, role, profile_image_url, created_at, updated_at) FROM stdin;
cd3739ba-562c-450b-8c1c-512d464961e0	admin	admin@local	1e27df4f7aab7ae6a5f7a20a5d41296a_0de3d0b869a3c06f87b423b8428221add514ce268ac8ba9865d5fef98b3bfb51721e6dc8f46b3a13ac4743e6b09cc1f6ad1418bc06fe76a32033233ba995218e	Admin	Local	admin	\N	2026-06-10 14:49:46.414166	2026-06-10 14:49:46.414166
4bea07bc-b566-48b9-a0ed-ecd148ce7060	\N	yasfreitas@icloud.com	437abff6a1a28287f5ba3a458e6c93f6_bc90a65972ca6a8a120bc5bb7334804e9983a4d486f9574d989401c74a61507be043309a95b7defd14211c52d83ddd3b4a314c14681fafa776396f4d6e8fdc13	Yasmin	Costa Spinola	admin	\N	2026-07-01 20:47:12.059975	2026-07-01 20:47:12.059975
7610137e-1042-471c-93e3-b71fe1459272	\N	lspinolagoncalves@gmail.com	6408992ebe3980e9e94da9ae963b2dff_9b5baf3a1928565ebcdb1093ed10bd5c03461fc01de5ba33e9709d9139ca4e1ad5d4ee03a39d7bdeeed22b213a6eaf3b97bc7ddae0bc36b1bba12b8c22b9faf1	Luiz	lspinolagoncalves@gmail.com	admin	\N	2026-07-09 08:50:13.527708	2026-07-09 08:50:13.527708
d43493df-8f33-47b3-aa5b-5a02a8dd1fad	claus	claus@local	5b7ffb00c8f02279df8c433b85c930b1_304b24496f6bdf2dbf387b8ddfb5f2bf3fd500aacaf94c08d5bad532802d5ba2cce348bcc9ce8ae74189dcbca50490271fd186e199f570c3a5292db0a1e98dc6	Claus	Admin	admin	\N	2026-06-10 14:54:05.315576	2026-06-10 14:54:05.315576
52f63a12-31c1-452c-949b-dfa69eb0d3aa	\N	gabrielsamuel@gmail.com	a20a13c6aab49ec3022a8c09950f9d20_7196e0d1dfab28c8fd3698bbedf7be24450dae85378a47213b1afdb20603219f856be855ea7162550caf5c9cdb84aebb271227cafd74a98ae745f9e826e5a31c	Gabriel		admin	\N	2026-09-17 02:43:28.128206	2026-09-17 02:43:28.128206
\.


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_id_seq', 22, true);


--
-- Name: category_properties_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.category_properties_id_seq', 98, true);


--
-- Name: contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contacts_id_seq', 1, false);


--
-- Name: properties_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.properties_id_seq', 44, true);


--
-- Name: prospeccao_batches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.prospeccao_batches_id_seq', 931, true);


--
-- Name: prospeccao_cidades_alvo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.prospeccao_cidades_alvo_id_seq', 135, true);


--
-- Name: advantages categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.advantages
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: property_advantages category_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.property_advantages
    ADD CONSTRAINT category_properties_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: properties properties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (id);


--
-- Name: prospeccao_batches prospeccao_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prospeccao_batches
    ADD CONSTRAINT prospeccao_batches_pkey PRIMARY KEY (id);


--
-- Name: prospeccao_cidades_alvo prospeccao_cidades_alvo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prospeccao_cidades_alvo
    ADD CONSTRAINT prospeccao_cidades_alvo_pkey PRIMARY KEY (id);


--
-- Name: prospeccao_config prospeccao_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prospeccao_config
    ADD CONSTRAINT prospeccao_config_pkey PRIMARY KEY (id);


--
-- Name: prospeccao_leads prospeccao_leads_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prospeccao_leads
    ADD CONSTRAINT prospeccao_leads_pkey PRIMARY KEY (id);


--
-- Name: seaql_migrations seaql_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seaql_migrations
    ADD CONSTRAINT seaql_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (sid);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_unique UNIQUE (username);


--
-- Name: IDX_session_expire; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_session_expire" ON public.sessions USING btree (expire);


--
-- Name: property_advantages fk-categories-category-to-category_properties; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.property_advantages
    ADD CONSTRAINT "fk-categories-category-to-category_properties" FOREIGN KEY (advantage_id) REFERENCES public.advantages(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: property_advantages fk-properties-property-to-category_properties; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.property_advantages
    ADD CONSTRAINT "fk-properties-property-to-category_properties" FOREIGN KEY (property_id) REFERENCES public.properties(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict OfH3PVBZT351X4Uw1c0l0TyjIUP8pqGAOny7lwebEaid38bYW1IA3pI0LMyhCxs

