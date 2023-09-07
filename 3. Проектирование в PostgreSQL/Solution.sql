drop table if exists
    reward_share, pirate_duties, pirates, crews, citizens CASCADE;

drop type if exists
    crew_role, duty, progress CASCADE;

create type duty as enum
    ('rob', 'kidnap', 'treasure');

create type progress as enum
    ('planning', 'going', 'riot', 'done');

create type crew_role as enum
    ('captain', 'quartermaster', 'first mate', 'boatswain', 'cabin boy');

/*личное дело гражданина 
(имя, пьёт [да/нет], курит [да/нет], в браке [да/нет], профессия)*/
create table citizens (
    personal_id int primary key,
    real_life_name varchar(30),
    drinks bool,
    smokes bool,
    married bool,
    profession varchar(30)
);

create table crews (
    crew_id integer primary key,
    crew_name varchar(50)
);

/* личное дело пирата 
(прозвище, количество рук, награда за поимку, из какой команды, какое звание)*/
create table pirates (
    nickname varchar(50) primary key,
    hands_num int,
    head_prize int,
    crew_id int, -- каждый пират может принадлежать не более чем к одной команде
    crew_rank crew_role,
    personal_id int, -- про некоторых граждан известно, что они пираты, разные пираты могут оказаться одним и тем же гражданином
    
    foreign key (personal_id) references citizens(personal_id),
    foreign key (crew_id) references crews(crew_id),
    
    /* за юнгу нельзя назначить награду за поимку */
    constraint CabinBoyUseless check (head_prize = 0 or crew_rank != 'cabin boy'),
    /* каждый пират может иметь количество рук, не выходящее за пределы возможного количества рук */
    constraint NoMutationInHands check (hands_num <= 2)
);
/* в каждой команде может быть не более одного капитана */
create unique index OneCaptain on pirates(crew_id) where crew_rank = 'captain';

/*задания пиратов - какое задание [грабёж, похищение или закапывание клада], 
кто выполняет (задания могут выполнять только пираты) и 
ход его выполнения [подготавливается, выполняет, бунтует или завершил]*/
create table pirate_duties (
    duty_id int primary key,
    duty_type duty,
    responsible varchar(50),
    prog progress,
    
    /* каждое задание выполняется ровно одним пиратом*/
    foreign key (responsible) references pirates(nickname)
);
/* каждый пират не может выполнять больше одного задания */
create unique index OnlyOne on pirate_duties(responsible) where prog = 'going';

create table reward_share (
    crew_id int,
    crew_rank crew_role,
    reward decimal,
    
    foreign key (crew_id) references crews(crew_id),
    /* в каждой команде пиратам одинакового звания выдаётся определённое число долей от награбленного */
    constraint EqualShare unique (crew_id, crew_rank)
);

-----------------------------------------------------------------------------------

insert into citizens values 
    (1, 'Pirat Piratov', false, false, false, 'bank director'),
    (2, 'Hook Hookenko', false, false, false, 'pianist'),
    (3, 'Jack Jackieshvili', true, false, true, 'chef'),
    (4, 'Grazhdan Grazhdanyan', true, true, true, 'farmer'),
    (5, 'Lev Lebovskiy', true, true, false, 'student');

insert into crews values 
    (1, 'Baltic Vikings'),
    (2, 'Black Sea Gods'),
    (3, 'Neva Sailors Moons'),
    (4, 'The Pirates of Ladoga'),
    (5, 'Zenit Forever');

insert into pirates values 
    ('El Niño', 2, 0, 3, 'cabin boy', 5),
    ('Big Chuck', 2, 1207, 2, 'boatswain', 3),
    ('Gremchik', 1, 3755, 1, 'captain', 2),
    ('The Experienced One', 0, 2453, 3, 'first mate', NULL),
    ('The Eel', 2, 5420, 2, 'captain', 1);

insert into pirate_duties values 
    (1, 'kidnap', 'Big Chuck', 'going'),
    (2, 'rob', 'El Niño', 'done'),
    (3, 'treasure', 'Gremchik', 'planning'),
    (4, 'rob', 'El Niño', 'going'),
    (5, 'treasure', 'The Eel', 'going');

insert into reward_share values
    (1, 'boatswain', 4),
    (1, 'captain', 6),
    (2, 'boatswain', 5),
    (2, 'captain', 5),
    (3, 'boatswain', 2),
    (3, 'captain', 11);
    
SELECT * FROM reward_share
